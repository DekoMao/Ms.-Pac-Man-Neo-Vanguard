# NeoGrid 0.9 — Fusão / Bomber Chase

O modo Fusão combina coleta, perseguição, túneis e Flow do NeoGrid 0.8 com
bombas em grade, explosões em cruz, cadeias e caches destrutíveis. Usa os seis
labirintos e a direção visual neon 3D aprovada. Circuito, Overdrive e Trem
Fantasma continuam disponíveis com suas regras anteriores.

## Como jogar

Na abertura, escolha **NOVO · Fusão — Bomber Chase**. WASD/setas movem;
**B** no teclado ou botão **B** no controle planta uma bomba no centro da
célula ocupada. Espaço/X continua sendo dash; E/A escudo; R/Y ímã; Q/LB aposta;
F/RB pulso do Colosso; M/Back mapa com pausa; P/Start pausa; C muda a câmera.

A personagem aguarda uma direção. Plantar uma bomba também é um comando
explícito que inicia o relógio, mesmo que a personagem ainda esteja parada.

Cada fase contém seis caches âmbar que substituem paredes internas. Os
corredores principais e túneis permanecem livres desde o início. Os caches
abrem novas conexões, escondem um ponto obrigatório e uma melhoria. Todos os
pontos escondidos já entram no contador de itens restantes e aparecem como
caches no mapa. Destruir um cache não equivale a coletar seu ponto.

**Loop:** observar a rota, plantar, escapar, abrir uma passagem, coletar a
melhoria, buscar Power e transformar a mesma explosão em captura com Flow.

## Regras e equilíbrio inicial

| Sistema | Regra desta versão |
| --- | --- |
| Bombas | 2 simultâneas inicialmente; máximo 4. Sem custo de energia. |
| Pavio | 2,3 segundos de simulação; pausa e mapa congelam o tempo. |
| Alcance | 2 células em cada direção ortogonal; máximo 5. Sem diagonais. |
| Colisão | Quem estava sobre a bomba pode sair. Ao alcançar outra célula, não pode reentrar enquanto a bomba existir. Olhos em retorno podem atravessar bombas. |
| Bloqueios | Parede sólida, casa e porta param a cruz. Cache quebra e encerra aquele raio. Outra bomba encerra o raio e recebe a cadeia. |
| Cadeia | Antecipação para 0,1s depois do impacto, sem duplicar detonações. |
| Explosão | Persiste por 0,65s; atravessar com dash ainda causa dano. |
| Antecipação | Últimos 0,85s mostram a cruz prevista no piso. Bombas que entrarem em cadeia podem antecipar esse aviso. |
| Fantasma normal | Fica atordoado por 1,8s, inofensivo durante o atordoamento. Um mesmo fogo não prolonga o efeito continuamente. |
| Fantasma vulnerável | É capturado pela explosão com a pontuação e o Flow normais. |
| Ms. Pac-Man | A própria explosão custa uma vida, inclusive durante Power. Escudo absorve um impacto e concede a proteção curta existente. |
| Túneis | A personagem cruza as bordas; a explosão termina na borda e não aparece do outro lado. |
| Caches | +50 por abertura; ponto continua obrigatório; melhoria +100 ao coletar. |
| Melhorias | +B aumenta capacidade; +R aumenta alcance; E dá carga de escudo até 2; energia restaura a barra. |
| Persistência | Capacidade/alcance seguem nas fases da mesma partida, inclusive após morte. Revanche reinicia em 2/2. As vantagens de escudo/ímã/dash entre fases continuam temporárias. |
| Objetivo | Limpar os itens, incluindo os escondidos; seis fases sem limite de 180s; Colosso ao final. |
| Desafio extra | Pelo menos uma reação em cadeia na área. Não bloqueia o avanço. |
| Recorde | `fusion_record`, separado dos outros modos. Medalhas antigas preservadas. |

As melhorias ficam visíveis e coletáveis depois que o fogo no cache termina.
Não são destruídas por novas explosões. Morrer remove bombas e fogo ativos,
preserva os atalhos já abertos e reinicia a personagem parada. Os fantasmas
preferem uma saída segura quando percebem uma bomba próxima de explodir.

## Referência analisada e procedência

Benchmark solicitado: [Super-Bomberman-6-Unity, MauricioSuporte](https://github.com/MauricioSuporte/Super-Bomberman-6-Unity),
fixado no commit `79bffa5accfd519f9be40235b1353fd4502d9493` para esta análise.

Arquivos lidos: `README.md`, `Assets/Scripts/Bomb/Bomb.cs`,
`Assets/Scripts/Bomb/BombController.cs`, `Assets/Scripts/Explosions/BombExplosion.cs`,
`Assets/Scripts/Destructible/Destructible.cs` e `Assets/Scripts/Itens/ItemType.cs`.

O controlador da referência declara pavio de 2,3s, raio inicial 2, capacidade
e propagação ortogonal com bloqueios e cadeias. O objeto bomba permite saída
antes de tornar a colisão sólida. A lista de itens distingue capacidade, alcance,
chute, controle remoto e outras habilidades. São referências de mecânica para
este recorte. A duração do fogo e a interação com Power/Flow foram adaptadas
ao movimento contínuo e aos fantasmas do NeoGrid.

Não foram copiados C#, cenas Unity, sprites, músicas ou outros recursos da
referência. `fusion.gd`, `fusion_visual.gd` e os sons sintetizados são próprios.
O README da referência se identifica como projeto educativo de fã; a API não
identifica licença SPDX. Nenhuma licença foi presumida para copiar recursos.
Multiplayer, montarias, chute e bomba remota da referência não fazem parte
desta primeira integração jogável.

## Arquitetura e validação

- `fusion.gd`: simulação independente de renderização, caches, raios, fuses,
  cadeias, danos, atordoamento, upgrades e limites.
- `rules.gd`: subdivide apenas Fusão a 120Hz e nas fronteiras exatas dos pavios.
  Power, coleta, explosão e contato são resolvidos na ordem temporal.
- `fusion_visual.gd`: caches, bombas, aros de pavio, avisos e fogo baixo no piso;
  não altera colisões. Redução de movimento deixa os sinais estáveis.
- `test_fusion.gd`: 105 verificações, incluindo seis mapas, bloqueios,
  simultaneidade, fuga/reentrada, pausa, cadeias, dano, Power, upgrades,
  limpeza dos itens por movimento, transições, save e limites da interface.
- O builder exige as oito suítes: 340 verificações anteriores e 105 novas.
  Exporta PE Windows x64 e abre seu PCK embutido no motor Linux fora das fontes.

Capturas `fusao_*_090.png` mostram o motor real em Forward+/Vulkan no Linux,
adaptador de software llvmpipe. São cenas de QA preparadas por
`tests/capture_fusion.gd`, com posicionamento e tempo controlados; não registram
uma partida humana completa. A execução nativa no Windows, controle físico,
GPU física e o equilíbrio com jogadores permanecem pendentes. Use
`TESTAR_WINDOWS.cmd` para registrar a sessão local.
