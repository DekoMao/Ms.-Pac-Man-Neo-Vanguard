# Validação — rodada de ação 0.2

## Resultados atuais

- Godot 4.6.3 e templates compatíveis, reaproveitados da base com verificação SHA-512.
- **87 verificações passaram, zero falhas:** 39 de regras/persistência, 27 de ação
  e 21 de cena/input/acessibilidade/áudio. `evidencias/testes_*.json` e respectivos logs.
- As sete etapas de `scripts/build.py` encerraram com código zero: importação,
  três suítes, smoke do projeto, exportação Windows e smoke do pacote embutido.
- PE AMD64 GUI real, PCK embutido, seis imagens de ícone e versão 0.2.0.0.
  `evidencias/build_artefato.json` e `windows_resources.json` registram tamanho e hash.
- Reproduzidos os 5.400 comandos/45s também pelo PCK do próprio EXE, em diretório
  temporário fora das fontes. Pontos/vidas/eventos coincidiram com a execução das
  fontes: 6500 pontos, 3 vidas, 10 capturas, 2 quase colisões e aposta concluída.
  Isso é validação do pacote no **host Linux**, não execução nativa do PE.
- Base e refino receberam a mesma fita, fase, semente e condições iniciais, conferidas
  por igualdade dos objetos `initial`. Ver `REFINO_ACAO.md` e `comparacao_*.json`.
- Fontes da base preservadas e recuperadas por clone Git independente; nenhum cache,
  credencial de exportação ou token faz parte do projeto publicado.
- A saída do Movie Maker foi ajustada para drenar os loops durante quatro frames
  antes de encerrar. O ensaio gráfico final terminou sem recursos de áudio vazados;
  ensaios preliminares com o problema estão identificados no histórico.

## Limites que permanecem

Não há Windows nem GPU física nesta máquina. Não foram aprovados execução nativa,
latência de controle em hardware, desempenho 60fps, percentis de GPU física ou
percepção humana do novo acabamento. A base foi aprovada pelo usuário; o refino
é entregue para avaliação. Não há expansão de fases, multiplayer ou outros modos.

O replay usa comandos de movimento/dash/aposta públicos e não altera a simulação.
Testes geométricos isolados posicionam atores para verificar casos de borda, como
é normal em testes; esses cenários não são inseridos na gravação de gameplay.

## Captura final executada

O Movie Maker encerrou sem SCRIPT ERROR, ERROR ou recursos de áudio vazados:
1084 frames a 24fps, 45,166667s, gravados em 6min58s de tempo de parede.
Os 5400 ticks/45s de simulação jogável são contínuos; quatro frames finais
mantêm a imagem enquanto drenam os loops. O AVI inteiro foi transcodificado
sem cortes para H.264/AAC. FFprobe confirmou duração, resolução e codecs.
A decodificação completa e o nível de áudio constam em `decode_audio_acao.log`.

As capturas intermediárias reais em 3/12/23/35/44s foram inspecionadas. Não há
homologação artística por jogador para a nova rodada. Os percentis em
`runtime_acao_45s.json` são tempos de parede de renderização **software offline**,
não latência de controle ou desempenho de GPU física.

`replay_captura_45s.json` coincide em pontos, vidas e todos os eventos com
`comparacao_refino.json` e `pck_replay_45s.json`. Os 78 hashes congelados em
`fonte_build_captura_acao.json` permaneceram idênticos durante build e gravação.

A validação histórica da base permanece no commit preservado
`f28df2ff46465d1a3df88d343b258f5d3c0348e5`, arquivo `docs/VALIDACAO.md`.

Decodificação integral do MP4: 1084 frames, sem erros; pico de áudio −16,3dBFS, sem saturação.
