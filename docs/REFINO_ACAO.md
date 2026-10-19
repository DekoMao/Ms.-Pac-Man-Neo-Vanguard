# Ação 0.2: escopo, critérios e comparação

A base aprovada é o commit `f28df2ff46465d1a3df88d343b258f5d3c0348e5`, branch
`fontes/mv-base-20261019`. Os 114 arquivos foram confrontados com o ZIP de fontes
da entrega 0.1 antes de qualquer modificação. O ZIP portátil 0.1 permanece intacto
na branch `entrega/mv-20261019`, commit `c623b5323f21a873ccd1202d1ea50a609eab24ea`.

## Refinamento dos sistemas existentes

| Sistema | Base | Rodada 0.2 |
|---|---|---|
| Perseguição | Velocidade fixa e ciclos scatter/chase | Avisos 0,8s antes dos níveis em 8/20/32s; +4/8/12% de velocidade hostil; scatter diminui até 2,9s por ciclo de 20s |
| Dash | Custo 40E, 2 células em 150ms, cooldown 1s | Mesmos parâmetros; FOV breve, rastro, anel e som sobreposto a outros efeitos |
| Quase colisão | Sem reconhecimento | Distância mínima entre trajetórias relativas; raio combinado 0,59; entrada até 0,95 e saída acima de 1,12 célula; +6E; cooldown de 3s por adversário |
| Power | 6s, vulnerabilidade e captura | Contraste textual FUGA/CAÇA, onda no piso, câmera e camada musical de caça; aviso 1,5s antes do fim |
| Capturas/Flow | 200/400/800/1600, Flow +0,5 até ×3 por 5s | Mesmas regras e limites; altura do efeito, texto, anéis e ganho musical crescem com a cadeia |
| Objetivo opcional | Nenhum | Q durante Power: 20E por duas novas capturas na mesma janela; +600 pontos/+35E; uma tentativa por fase |
| Câmera | Seguimento oblíquo/superior e redução geral | Antecipação discreta, impulsos de até 0,065 unidade × intensidade; slider 0–100%; redução geral zera impulsos/FOV e suprime efeitos decorativos |
| Áudio | Um tocador trocando a amostra | Oito vozes de efeitos; música e camadas 112 BPM reiniciadas juntas, pausadas/retomadas em conjunto |

Nenhuma invulnerabilidade, magnetismo de captura, teletransporte, aumento de raio,
hit-stop ou ralentamento altera a simulação. Dash continua sujeito à colisão contínua.
Colisão anterior à coleta de Power continua letal; coleta anterior continua salvando.
Quase colisão exige saída segura; tocar, morrer, capturar ou passar por fantasma
vulnerável não produz recompensa de escape. As cores originais indicam fantasmas
que já voltaram da casa e são perigosos, preservando a imunidade da base.

A aceitação exige pelo menos 2s de Power restantes e 20E. A aposta não é necessária para concluir a área. Falhar perde apenas os 20E
voluntariamente gastos; não tira vidas, pontos acumulados ou Power. Uma nova esfera
Power não renova a aposta ativa. Morte, expiração ou nova janela encerram a tentativa.

## Comparação controlada e limites

Mesma grade 17×13, pickups, quatro casas/tempos de saída, posição/direção inicial,
3 vidas, 100E, semente 73021 e passo fixo 1/120s. Os objetos `initial` dos dois
relatórios foram comparados e são idênticos. A fita `evidencias/replay_45s.json`
contém exatamente 5.400 comandos e é reproduzida sem alteração nas duas versões.
Q é ignorado na base, onde o sistema não existe. Consequências de energia, movimento,
perseguição e morte podem divergir depois do início; essa divergência é o resultado.

| Resultado lógico em 45s | Base 0.1 | Ação 0.2 |
|---|---:|---:|
| Pontos | 1345 | 6500 |
| Capturas | 2 | 10 |
| Cadeia máxima | 1 | 3 |
| Vidas restantes | 1 | 3 |
| Dash aceitos | 11 | 15 |
| Quase colisões confirmadas | inexistente | 2 |
| Aposta | inexistente | concluída |

Controle automatizado por `tests/action_bot.gd`, sem editar estado ou sortear vantagens.
Foram ensaiados quatro valores de cautela (1,5/2,5/3/4); 1,5 foi escolhido para mostrar
uma partida completa de 45s com os eventos novos. A fita escolhida é aplicada igualmente
à base e ao refino. Não é teste cego com jogadores, prova estatística de diversão ou
benchmark de dificuldade. Os pontos incluem o novo bônus opcional. A avaliação subjetiva
do acabamento e da sensação continua dependendo de jogar a rodada entregue.

## Referência visual e captura

O vídeo Gemini anexado tem 10,005s, 1280×720/24fps. Foi inspecionado: paredes ciano/rosa,
piso escuro reflexivo, protagonistas legíveis e trilha dourada de dash. O refino conserva
as malhas, a arquitetura e a paleta aprovadas; acrescenta sinais de evento e hierarquia
de HUD. É referência de direção artística, não evidência de execução deste jogo.

As capturas reais usam Godot 4.6.3 Forward+, Vulkan/llvmpipe em Xvfb, qualidade Alta,
1280×720/24fps. São renderizadas offline com controle automatizado e áudio real do motor.
Não comprovam 24/60fps em tempo real, execução do PE no Windows ou desempenho de GPU física.
O fim da gravação mantém alguns frames finais para drenar o áudio antes do encerramento;
os 45s de simulação jogável são contínuos, sem cortes ou montagem.

`tests/replay_capture.gd` pode ser usado com `--path` apontando para cada projeto;
`--tape` deve apontar para a mesma fita. O driver tem prioridade -100 e alimenta a
simulação a 120 Hz, sem depender de decisões novas no meio da gravação.
