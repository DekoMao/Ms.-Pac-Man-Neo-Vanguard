@echo off
setlocal
set "NEOGRID_GAME=%~dp0MsPacMan_Aperfeicoado.exe"
if not exist "%NEOGRID_GAME%" set "NEOGRID_GAME=%~dp0..\entrega\MsPacMan_Aperfeicoado\MsPacMan_Aperfeicoado.exe"
if not exist "%NEOGRID_GAME%" (
 echo Executavel nao encontrado. Extraia o pacote inteiro.
 pause
 exit /b 1
)
echo Teste os tres modos, teclado e controle. Feche o jogo pelo menu ao terminar.
echo O relatorio fica somente nesta pasta, sem envio pela rede.
start "" /wait "%NEOGRID_GAME%" -- --report="%~dp0validacao_windows.json"
if exist "%~dp0validacao_windows.json" (
 echo Relatorio salvo em validacao_windows.json.
) else (
 echo O jogo nao gerou relatorio. Consulte a documentacao de validacao.
)
pause
