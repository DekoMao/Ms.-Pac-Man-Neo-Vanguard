# Continuar esta versão sem perder o trabalho

Projeto: `/workspace/NeoGrid`; no Windows, copiar para o destino novo
`D:\Ms PACMan_Aperfeicoado` depois de verificar conteúdo pré-existente. Se
existir trabalho anterior, preservar e escolher destino datado. Não tocar
na origem `D:\Ms PACMan`. O checkpoint M0 anterior continua intacto.

O próximo passo não é reconstruir documentação ou instalar um decompilador:
execute o pacote Windows e homologue MV, usando vídeo/capturas como evidência
Linux. Use a mesma versão de fontes e confirme SHA256SUMS antes da homologação.

1. Extraia o portátil em `D:\Teste do Jogo\Versão Final`. Abra o EXE sem editor,
   Python, Node ou MAME; observe os logs em user://logs. Confirme versão/ícone.
2. Jogue com teclado real: curvas, dash/energia, Power Pellet, captura/Flow,
   fruta e aviso de parede. Complete a área; teste as três vidas/reinício.
3. Valide pausa/foco, fechamento da janela durante pausa/partida, configurações,
   mudo/ausência de dispositivo, persistência, janela/fullscreen e 720p/1080p.
4. Teste contínuo real de 20 minutos com memória e travamentos anotados.
5. Em GPU física, confirme Forward+ e driver, meça presets/reflexos/SSR com
   sequências de pelo menos 60 s, aquecimento e percentis. Não usar a taxa do
   MP4 para aprovar performance. Corrija a diferença artística conforme
   VALIDACAO_VISUAL.md e compare ao kit v3.2 acessível na fonte.
6. Depois de MV aprovado, retome os requisitos amplos em M1→M2→M3, mantendo
   pacotes independentes de M1/M2 antes do multiplayer. Não declarar recursos
   não implementados ou recuperar fidelidade histórica por inferência de MAME.

Se desejar comparar o original, a sessão local deverá inventariar e executar
os arquivos reais de D:, auditar o novo mspacman.zip com o emulador compatível
e registrar as diferenças observadas. Essa comparação é separada do projeto
próprio já construído e não justifica apagar ou reiniciar o MV.
