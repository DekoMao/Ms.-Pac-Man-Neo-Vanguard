"""Package the validated 0.9 Windows export without touching earlier ZIPs."""
from pathlib import Path
import hashlib, json, shutil, zipfile

ROOT=Path(__file__).resolve().parents[1]
NAME='NeoGrid_0.9_FusaoBomberChase'

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    out=ROOT/'entrega'/NAME;out.mkdir(parents=True,exist_ok=True)
    files={
        'entrega/MsPacMan_Aperfeicoado/MsPacMan_Aperfeicoado.exe':'MsPacMan_Aperfeicoado.exe',
        'LEIA-ME.txt':'LEIA-ME.txt','scripts/TESTAR_WINDOWS.cmd':'TESTAR_WINDOWS.cmd',
    }
    for name in ['FUSAO_BOMBER_CHASE.md','VALIDACAO_WINDOWS.md','CREDITOS_E_LICENCAS.md']:
        files['docs/'+name]='docs/'+name
    for name in ['build_artefato.json','build_comandos.json','windows_resources.json','fusao_captura.log','pacote_fusao_embutido.log']:
        files['evidencias/'+name]='validacao/'+name
    for name in ['logica','integracao','acao','mapa','circuito','arcade','expansao','fusao']:
        files['evidencias/testes_'+name+'.json']='validacao/testes_'+name+'.json'
    for name in ['Godot_LICENSE.txt','Godot_THIRD_PARTY.txt','DejaVu_copyright.txt']:
        files['licencas/'+name]='licencas/'+name
    for name in ['inicio','pavio','explosao','melhoria','labirinto','mapa','menu']:
        files['evidencias/fusao_'+name+'_090.png']='imagens/fusao_'+name+'_090.png'
    expected=json.loads((ROOT/'evidencias/build_artefato.json').read_text())
    assert digest(ROOT/'entrega/MsPacMan_Aperfeicoado/MsPacMan_Aperfeicoado.exe')==expected['sha256']
    executed=0
    for name in ['logica','integracao','acao','mapa','circuito','arcade','expansao','fusao']:
        result=json.loads((ROOT/('evidencias/testes_'+name+'.json')).read_text())
        assert result['executed']>0 and result['failed']==0
        executed+=result['executed']
    assert executed==445
    for source,target in files.items():
        destination=out/target;destination.parent.mkdir(parents=True,exist_ok=True)
        if target.endswith('.cmd'):
            destination.write_bytes((ROOT/source).read_bytes().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'))
        else:shutil.copyfile(ROOT/source,destination)
    (out/'SHA256SUMS.txt').write_text(''.join(digest(out/t)+'  '+t+'\n' for t in sorted(files.values())))
    targets=sorted([*files.values(),'SHA256SUMS.txt'])
    archive=ROOT/'entrega'/(NAME+'_Windows_x64.zip')
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for target in targets:z.write(out/target,NAME+'/'+target)
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        assert set(z.namelist())=={NAME+'/'+t for t in targets}
        assert hashlib.sha256(z.read(NAME+'/MsPacMan_Aperfeicoado.exe')).hexdigest()==expected['sha256']
    result={'zip':str(archive),'bytes':archive.stat().st_size,'sha256':digest(archive),'entries':len(targets),'crc_valid':True,'exe_sha256':expected['sha256'],'tests':executed,'native_windows_tested':False}
    (ROOT/'evidencias/entrega_fusao_090.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))

if __name__=='__main__':main()
