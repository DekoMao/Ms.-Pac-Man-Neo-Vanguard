#!/usr/bin/env python3
"""Edit resources of our unsigned Godot export in place, preserving embedded PCK.
No Wine, rcedit, compiler or third-party Python package is required.
"""
from pathlib import Path
import argparse
import hashlib
import json
import struct


def u16(data, offset):
    return struct.unpack_from('<H', data, offset)[0]


def u32(data, offset):
    return struct.unpack_from('<I', data, offset)[0]


def version_block(key, value=b'', children=(), string=False):
    key = (key + '\0').encode('utf-16-le')
    out = bytearray(struct.pack('<HHH', 0, len(value)//2 if string else len(value), int(string)))
    out += key
    out += b'\0' * (-len(out) % 4)
    out += value
    for child in children:
        out += b'\0' * (-len(out) % 4)
        out += child
    struct.pack_into('<H', out, 0, len(out))
    return bytes(out)


def version_resource():
    fixed = struct.pack('<13I', 0xFEEF04BD, 0x00010000, 2, 0, 2, 0, 0x3F, 0, 0x40004, 1, 0, 0, 0)
    strings = {
        'FileDescription': 'Neo-Grid MV',
        'FileVersion': '0.2.0.0',
        'ProductName': 'Neo-Grid',
    }
    table = version_block('040904b0', children=[
        version_block(k, (v+'\0').encode('utf-16-le'), string=True) for k,v in strings.items()
    ], string=True)
    info = version_block('StringFileInfo', children=[table], string=True)
    translation = version_block('VarFileInfo', children=[version_block('Translation', struct.pack('<HH', 0x409, 1200))], string=True)
    return version_block('VS_VERSION_INFO', fixed, [info])


def embed(executable, ico):
    original = Path(executable).read_bytes()
    data = bytearray(original)
    if data[:2] != b'MZ':
        raise ValueError('Not PE')
    pe = u32(data, 0x3C)
    if data[pe:pe+4] != b'PE\0\0' or u16(data, pe+4) != 0x8664:
        raise ValueError('Expected AMD64 PE')
    optional = pe+24
    if u16(data, optional) != 0x20B:
        raise ValueError('Expected PE32+')
    if u32(data, optional+112+4*8+4):
        raise ValueError('Refusing to modify an Authenticode-signed artifact')
    section_table = optional+u16(data,pe+20)
    sections=[]
    for i in range(u16(data, pe+6)):
        off=section_table+40*i
        virtual_size, rva, raw_size, raw=struct.unpack_from('<4I',data,off+8)
        sections.append((rva,max(virtual_size,raw_size),raw))
    def offset(rva):
        for start,size,raw in sections:
            if start <= rva < start+size:
                return raw+rva-start
        raise ValueError('Resource RVA outside PE sections')
    resource_base=offset(u32(data,optional+112+2*8))
    resources={}
    def directory(relative, path=()):
        if len(path)>4:
            raise ValueError('Resource tree too deep')
        base=resource_base+relative
        count=u16(data,base+12)+u16(data,base+14)
        for i in range(count):
            name,child=struct.unpack_from('<II',data,base+16+8*i)
            key=name if not name & 0x80000000 else 'named-'+str(name & 0x7FFFFFFF)
            if child & 0x80000000:
                directory(child & 0x7FFFFFFF,path+(key,))
            else:
                entry=resource_base+child
                rva,size=struct.unpack_from('<II',data,entry)
                resources[path+(key,)]=(entry,offset(rva),size)
    directory(0)
    icon_data=Path(ico).read_bytes()
    if icon_data[:4] != b'\0\0\1\0':
        raise ValueError('Invalid ICO')
    frames=[]
    for i in range(u16(icon_data,4)):
        w,h,_,_,planes,bpp,size,start=struct.unpack_from('<BBBBHHII',icon_data,6+i*16)
        frames.append((w or 256,h or 256,bpp or 32,icon_data[start:start+size]))
    changed=0
    for key,(_,start,size) in resources.items():
        if key[0] != 14:
            continue
        for i in range(u16(data,start+4)):
            group=start+6+14*i
            w,h=data[group] or 256,data[group+1] or 256
            icon_id=u16(data,group+12)
            candidates=[v for k,v in resources.items() if k[0]==3 and k[1]==icon_id]
            if not candidates:
                raise ValueError('Missing icon resource')
            entry,icon_start,capacity=candidates[0]
            possible=sorted((f for f in frames if len(f[3])<=capacity),key=lambda f:abs(f[0]-w)+abs(f[1]-h))
            if not possible:
                raise ValueError('No source icon fits the existing slot')
            fw,fh,bpp,payload=possible[0]
            data[icon_start:icon_start+capacity]=payload+b'\0'*(capacity-len(payload))
            struct.pack_into('<I',data,entry+4,len(payload))
            struct.pack_into('<BBBBHHI',data,group,fw%256,fh%256,0,0,1,bpp,len(payload))
            changed+=1
    if not changed:
        raise ValueError('No icon group found')
    version=version_resource()
    versions=0
    for key,(entry,start,capacity) in resources.items():
        if key[0]==16:
            if len(version)>capacity:
                raise ValueError(f'Version resource needs {len(version)}, capacity is {capacity}')
            data[start:start+capacity]=version+b'\0'*(capacity-len(version))
            struct.pack_into('<I',data,entry+4,len(version))
            versions+=1
    # PE checksum is recomputed; image layout and PCK bytes stay unchanged.
    struct.pack_into('<I',data,optional+64,0)
    checksum=0
    for i in range(0,len(data)-1,2):
        checksum+=data[i]+(data[i+1]<<8)
        checksum=(checksum & 0xFFFF)+(checksum>>16)
    if len(data)%2:
        checksum+=data[-1]
    checksum=(checksum & 0xFFFF)+(checksum>>16)
    checksum=(checksum & 0xFFFF)+(checksum>>16)
    struct.pack_into('<I',data,optional+64,(checksum & 0xFFFF)+len(data))
    assert len(data)==len(original)
    end_of_sections=max(raw+size for _,size,raw in sections)
    # Godot may have virtual-only sections. Compare the final PCK footer explicitly.
    assert data[-32:]==original[-32:]
    Path(executable).write_bytes(data)
    return {'icons_replaced':changed,'version_resources':versions,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'pck_footer_preserved':True,'signed':False}


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('executable')
    parser.add_argument('icon')
    args=parser.parse_args()
    print(json.dumps(embed(args.executable,args.icon),indent=2))
