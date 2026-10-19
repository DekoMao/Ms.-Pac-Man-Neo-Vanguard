# Marcos e rastreabilidade atuais

O roadmap amplo está preservado em `M0_ROADMAP.md`. Aplicada a continuidade
v3.2: origem pendente não bloqueia código próprio. Nenhum marco completo foi
aprovado por inferência de um teste isolado.

| Requisito | Marco | Evidência/teste | Estado |
| --- | --- | --- | --- |
| R00 preservar checkpoint/origem | M0 | retomada_v3_2.json, hashes | Checkpoint preservado; pasta Windows inacessível |
| R01 REA no novo artefato | M0 | rea_mspacman_zip.json | Inventário ZIP executado; ROM não executada |
| R02 motor/templates/build | M0/MV | templates.json, build_comandos.json, build_artefato.json | Godot/templates 4.6.3 compatíveis; PE exportado |
| R03 cena/personagens reais | MV | main/player/ghost.tscn, modelos procedurais, capturas | Implementado e renderizado |
| R04 movimento/drift/colisões | MV | MOVE/DRIFT/COLLIDE/TIME em testes_logica.json | Automatizados passaram |
| R05 dash/coleta/vidas | MV | DASH/COLLECT/LIVES/RESET | Automatizados passaram |
| R06 Power/captura/Flow | MV | POWER/CAPTURE/FLOW; eventos da gravação | Automatizados passaram; gameplay real capturado |
| R07 troca de parede | MV | GRAPH-01…05 e runtime_movie.json | Aplicação, adiamento e cancelamento testados |
| R08 menu/input/pausa/dados | MV | testes_integracao.json e STORE | 14 checks de cena/input e persistência passaram |
| R09 vídeo/capturas reais | MV | vídeo 1280×720, 24 FPS, 240 frames | Produzido no Linux/llvmpipe; não nativo Windows |
| R10 direção visual | MV | VALIDACAO_VISUAL.md, capturas e referências | Parcial; não aprovado integralmente |
| R11 perfil GPU/reflexos | MV | ORCAMENTO_GPU.md, runtime_movie.json | Software medido; GPU física/SSR comparativo pendentes |
| R12 pacote fora da fonte | MV | pacote_embutido.log e teste de ZIP | Conteúdo exercitado pelo motor Linux; Windows pendente |
| R13 Clássico/Neo três fases/portais/IA completa | M1 | matriz AC-01…15/20 da v3.2 | Não iniciado; depende do gate MV |
| R14 Time Attack/Rogue/áudio adaptativo/acessibilidade final | M2 | AC-16…18, ≥200 sementes | Não iniciado |
| R15 coop/versus, input físico e câmera/HUD duplos | M3 | AC-19/23/24 e regressões | Não iniciado |
| R16 M1/M2 independentes preservados | M1/M2 | AC-25 | Não aplicável ainda: nenhuma dessas versões foi criada |

Não usar o `.exe` do MAME como entrega. Não homologar Windows por executar
seu PCK no Linux. Não homologar 60 FPS por codificar um vídeo a 24 FPS.
Próxima ação de aprovação: testar o pacote no Windows/GPU, comparar os oito
critérios de MV e resolver as diferenças visuais antes de expandir os modos.
