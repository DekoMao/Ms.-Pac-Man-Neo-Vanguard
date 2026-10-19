#!/usr/bin/env python3
"""Reproducible MV Windows export. Build host requires Godot 4.6.3 + templates.
The player needs neither Python nor the editor.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import time
import tempfile
import shutil
from embed_windows_resources import embed

ROOT=Path(__file__).resolve().parents[1]


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--godot', default='godot')
    args=parser.parse_args()
    version=subprocess.check_output([args.godot,'--headless','--version'],text=True).strip()
    if not version.startswith('4.6.3.stable.'):
        raise RuntimeError('Expected Godot 4.6.3 stable, got '+version)
    evidence=ROOT/'evidencias'
    evidence.mkdir(exist_ok=True)
    target=ROOT/'entrega/MsPacMan_Aperfeicoado/MsPacMan_Aperfeicoado.exe'
    target.parent.mkdir(parents=True,exist_ok=True)
    commands=[]
    def run(label,tail,timeout,packaged=False,working_directory=ROOT):
        command=[args.godot,'--headless',*((['--path',str(ROOT)]) if not packaged else []),*tail]
        start=time.time()
        result=subprocess.run(command,cwd=working_directory,capture_output=True,text=True,timeout=timeout)
        text=result.stdout+result.stderr
        (evidence/(label+'.log')).write_text(text,encoding='utf-8')
        record={'id':label,'command':command,'cwd':str(working_directory),'exit_code':result.returncode,'duration_seconds':round(time.time()-start,3)}
        commands.append(record)
        if result.returncode or 'SCRIPT ERROR:' in text or '\nERROR:' in text:
            print(text[-6000:],file=sys.stderr)
            raise RuntimeError(f'{label} failed (exit {result.returncode}); see log')
        print(label+': OK',flush=True)
    try:
        run('importacao',['--editor','--import','--quit'],120)
        (evidence/'testes_logica.json').unlink(missing_ok=True)
        run('testes_logica',['--script','res://tests/test_rules.gd'],90)
        tests=json.loads((evidence/'testes_logica.json').read_text())
        if tests['executed']<1 or tests['failed']:
            raise RuntimeError('Logic tests did not execute and pass')
        (evidence/'testes_integracao.json').unlink(missing_ok=True)
        run('testes_integracao',['--script','res://tests/test_integration.gd'],90)
        integration=json.loads((evidence/'testes_integracao.json').read_text())
        if integration['executed']<1 or integration['failed']:
            raise RuntimeError('Scene tests did not execute and pass')
        run('smoke_headless',['--fixed-fps','60','--quit-after','240','--','--smoke'],45)
        run('export_windows',['--export-release','Windows Desktop',str(target)],180)
        resources=embed(target,ROOT/'assets/icon.ico')
        (evidence/'windows_resources.json').write_text(json.dumps(resources,indent=2)+'\n')
        # Inspect shipped PCK using the Linux/host Godot. This is NOT PE execution.
        with tempfile.TemporaryDirectory(prefix='NeoGrid Teste versão ') as temp:
            copy=Path(temp)/target.name
            shutil.copyfile(target,copy)
            run('pacote_embutido',['--main-pack',str(copy),'--fixed-fps','60','--quit-after','240','--','--smoke'],45,packaged=True,working_directory=temp)
        text=(evidence/'pacote_embutido.log').read_text()
        if 'NEOGRID_SMOKE_OK' not in text:
            raise RuntimeError('Embedded pack did not reach functional smoke check')
        (evidence/'build_artefato.json').write_text(json.dumps({'editor_version':version,'artifact':str(target),'bytes':target.stat().st_size,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'pe_amd64':True,'embedded_pack_smoke_on_host':True,'native_windows_tested':False,'code_signed':False},indent=2)+'\n')
        print('Windows PE: '+str(target),flush=True)
    finally:
        (evidence/'build_comandos.json').write_text(json.dumps(commands,indent=2)+'\n')


if __name__=='__main__':
    main()
