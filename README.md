# NeoGrid — entrega da rodada de ação 0.2

A base aprovada e seu ZIP original permanecem preservados nas branches
`fontes/mv-base-20261019` e `entrega/mv-20261019`.

- [Windows x64 — EXE dentro do ZIP portátil](NeoGrid_Acao_0_2_Windows_x64.zip)
- [Gravação real contínua — 45,17s, 1280×720/24fps, áudio](NeoGrid_Acao_45s.mp4)
- [Fontes Godot completos em ZIP](NeoGrid_Acao_0_2_Fontes.zip)
- [Mudanças e comparação nas mesmas condições](docs/REFINO_ACAO.md)
- [Testes e limitações](docs/VALIDACAO.md)
- [SHA-256 dos arquivos](SHA256SUMS.txt)

Fontes: https://github.com/DekoMao/Ms.-Pac-Man-Neo-Vanguard/tree/96618c46cb593c99c9ad617cda9febdefe6fbb16

Refinados perseguição com aviso e pressão progressiva, dash/escape, transição de
Power, capturas/Flow, aposta opcional de 20E por duas capturas e câmera/áudio.
Há slider de câmera até zero e redução geral de efeitos.

87 verificações passaram. A mesma fita de 5400 comandos foi usada nas duas versões,
com a mesma fase, semente e condições iniciais. O refino, o PCK do EXE e a gravação
coincidiram: 6500 pontos, 3 vidas, 10 capturas, 2 quase colisões, aposta concluída.
A base, com a mesma fita, terminou com 1345 pontos e 1 vida; os resultados não são
uma avaliação humana da diversão ou dificuldade.

O vídeo foi renderizado offline pelo Godot Linux/Forward+/llvmpipe com controle
automatizado, sem cortes ou inserção do vídeo Gemini. Execução nativa Windows,
GPU física e desempenho em tempo real permanecem pendentes.

Para jogar: extraia o ZIP Windows completo, leia LEIA-ME.txt e abra o EXE.
Para baixar cada binário no GitHub, abra o arquivo e use o botão de download.
