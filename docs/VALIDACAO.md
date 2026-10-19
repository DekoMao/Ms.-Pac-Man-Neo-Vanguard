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

## Histórico da entrega 0.1 (preservado abaixo)

## Resultados executados

- Editor e templates Godot 4.6.3 compatíveis, TPZ conferido por SHA-512 oficial.
- Importação/parsing do projeto final sem SCRIPT ERROR ou ERROR.
- **39 testes de regras/persistência aprovados**, zero falhas e zero skips.
- **14 testes de cena/menu/input sintético aprovados**, zero falhas.
- Smoke funcional com cena, quatro fantasmas, itens e pontuação executado.
- Exportação Windows release real, PE32+ AMD64 GUI com PCK incorporado.
- Ícone original e recurso de versão 0.1.0.0 aplicados; seis imagens de ícone.
- PCK do EXE exercitado no Godot Linux, fora da fonte, em caminho com espaço
  e acento. Não é teste nativo Windows.
- Execução gráfica real por X11/Xvfb, Vulkan 1.4.305 e Forward+ no llvmpipe.
- Gravação contínua de 240 frames / 24 FPS / 1280×720, codificada em MP4 de
  10 segundos. Capturas reais em 2 s e 7 s; uma extraída em 4,5 s.
- Comparações gráficas controladas da mesma cena, Alta/Baixa e vista superior.

Os JSONs e logs finais estão em `evidencias/`. `build_comandos.json` preserva
comandos, working directories, duração e exit status, incluindo inspeção
funcional do PCK. `testes_logica.json`/`testes_integracao.json` enumeram cada
check; uma contagem zero reprovaria o builder.

## Cobertura da matriz v3.2

| Cenário | Resultado e limite |
| --- | --- |
| AC-01 menu/início | UI-01/02/07/08/09 e smoke passaram; duplo clique Windows pendente |
| AC-02/11 movimento/drift | Buffer, paredes, curva, sem farming e equivalência 30/60/144 passaram; sem túneis neste mapa |
| AC-03/14 vidas/Power/captura | Varredura relativa, Power antes/depois do contato, morte única, retorno/imunidade/expiração passaram |
| AC-04 avanço | Uma área MV com estado de conclusão; três fases pertencem a M1 e não existem ainda |
| AC-05 pausa/foco | Input sintético e foco/notificação congelaram a simulação; retomada explícita passou |
| AC-06 câmeras/escala | Capturas reais 720p oblíqua/superior; 1080p/tela cheia em Windows pendentes |
| AC-07/18 áudio | Mix original com Dummy funcionou sem dispositivo; volume/mudo/persistência exercitados; hardware real/BPM adaptativo pendentes |
| AC-08 persistência | Ausente, gravação, reabertura, JSON corrompido e defaults passaram |
| AC-09 offline/usuário normal | Sem rede no código do jogo; execução Linux sem admin, PCK fora da fonte passou; Windows limpo pendente |
| AC-10 estabilidade | Não executada sessão real contínua de 20 minutos; nenhuma simulação acelerada foi usada para alegar essa aprovação |
| AC-12 dash | Energia zero/insuficiente/exata, custo, cooldown, parede, alcance e coleta única passaram; portais não implementados |
| AC-13 topologia | Conectividade, troca atômica, ocupação, adiamento e cancelamento passaram; uma troca no MV |
| AC-15 Flow/combo | Captura ativa Flow; retorno não pontua; expiração passou; balanceamento completo de M1 pendente |
| AC-16/17 Time Attack/Rogue | Não implementados, não testados |
| AC-19/20/23/24 multiplayer/Clássico | Não implementados; sem afirmação de testes físicos, históricos ou regressões desses modos |
| AC-21 estética | Evidência real disponível; critérios parciais em VALIDACAO_VISUAL.md |
| AC-22 GPU/SSR | Dispositivo software e tempos registrados; ensaios ≥60 s por variante em GPU física pendentes |
| AC-25 pacotes M1/M2 | Não aplicável: marcos não iniciados; não inventar versões estáveis desses modos |

## Gravação e desempenho

A automação `--demo` percorre o **mesmo jogo e simulação** com solicitações
normais de direção/dash. Não é vídeo externo ou animação separada. A morte e
o retorno permanecem no filme, sem cortes. O MP4 tem áudio e frames do motor;
compressão/transcodificação não altera o enquadramento nem troca o conteúdo.

`runtime_movie.json` registra os eventos reais e percentis de intervalos
wall-clock, depois dos dois primeiros segundos simulados. Isso é captura
**offline** com passo fixo; não confundir 24 FPS do arquivo com desempenho
atingido pelo computador. llvmpipe ficou muito abaixo da meta de 60 FPS.
Métricas e limitações detalhadas em ORCAMENTO_GPU.md.

## Pendências para aprovar MV e retomar expansão

1. Abrir o ZIP portátil extraído no Windows x64 sem editor/SDK, com caminho
   como `D:\Teste do Jogo\Versão Final`; confirmar ícone, versão e navegação.
2. Concluir uma partida; testar teclado real, áudio/mudo, pausa/foco, reinício,
   sair/confirmar, fullscreen e 720p/1080p; reabrir para validar persistência.
3. Jogar 20 minutos reais, observar memória/travamentos, guardar logs do usuário.
4. Em GPU física, registrar backend real, limites de reflexos/transparências,
   comparações SSR e presets, aquecimento e p95/p99 de sequências ≥60 s.
5. Comparar o jogo em movimento às referências e resolver itens parciais de
   acabamento/reflexos/câmera antes de passar para M1, depois M2 e M3.
6. Se desejada a comparação histórica, verificar a origem local e auditar o
   novo conjunto candidato de ROMs em um MAME compatível; isso não é dependência
   do Neo-Grid próprio já entregue.

O diretório `evidencias/historico/` conserva diagnósticos preliminares anteriores
às correções. Os logs de build/testes atuais são a evidência da versão entregue.
