# NeoGrid 0.8 — Circuito Vivo

Esta entrega implementa o roteiro 0.6–0.8 sobre a direção visual aprovada da 0.5.
A arquitetura, paletas neon, perspectiva, túneis e câmera de visão geral foram
preservados. As referências artísticas não foram usadas como fundos falsos.

## Escopo entregue

| Item | Implementação |
|---|---|
| Capturas | Quatro arpejos originais crescentes, partículas limitadas, faíscas em direção à protagonista, uma única legenda curta; quarta captura anuncia Caçada Perfeita. |
| Expressão | Inclinação em curvas, deformação breve no dash/captura, respiração e olhos dos fantasmas. Redução de movimento mantém escala neutra e remove efeitos extras. |
| Fruta móvel | Duas oportunidades por área, aos 12s e 34s. Duração de 12s; no Mercado Fugaz, 10s e movimento mais rápido. Recompensa de (300 + 100 × índice da fase) × Flow e +15 energia. |
| Overdrive | Três minutos de tempo jogado, pressão crescente, caça de 3s a cada 40s e troca automática de mapa após limpeza. Mantém comando, pontuação, vidas e tempo acumulado. |
| Melhorias | Escolha opcional para a próxima fase: escudo de 11s; ímã de 9s/até duas células conectadas; dash por 30E. Não acumulam e não repõem cargas após morte. |
| Seis áreas | Pórtico Neon, Jardim Iônico, Reator Solar, Anel de Fuga, Mercado Fugaz e Núcleo Colossal. |
| Desafios | Dezoito medalhas de conclusão/desafio/tempo e dezoito extras por concluir sem dash, sem mortes e com cadeia de quatro. Objetivos opcionais não bloqueiam avanço. |
| Trem Fantasma | Modo de três minutos com seguidores menores em cadeia, novas ondas a partir de 8s e a cada 20s; limite de oito seguidores além dos quatro fantasmas principais. |
| Colosso | Confronto ao limpar a sexta área do Circuito. Três núcleos Power carregam pulsos; F/RB atinge o Colosso durante sua recuperação. |
| Revanche | Enter/A e botão Jogar novamente reiniciam o mesmo modo; comparação com recorde anterior à tentativa. |
| Controle | Teclado, direcional digital e analógico com zona morta de 0,5; botões X/A/Y/LB/RB/Start/Back. Validação física ainda pendente. |

## Regras importantes

A fruta móvel tem um anel dourado e marcador dourado no mapa. É um bônus separado
dos pontos, Power Pellets e fruta fixa obrigatórios. Sua expiração não tira vidas,
não altera o contador e não impede a vitória. Pausa/M congela a oportunidade.
A escolha de rota usa o grafo do labirinto, inclusive túneis; a fruta tenta fugir
quando a protagonista está próxima, mas permanece mais lenta que ela. Morte
encerra a oportunidade atual, sem repeti-la; outra pode aparecer na janela seguinte.

Coleta e contatos com fantasmas/seguidores são ordenados pelo instante do impacto.
Um Power anterior ao contato protege; um Power posterior não salva retroativamente.
Dash não torna invulnerável. A troca de paredes aguarda fruta e seguidores saírem
da região afetada. Túneis são descontinuidades, sem colisão pelo meio do mapa.

O Anel de Fuga tem três pares de túneis nas linhas 3, 5 e 9. As outras áreas mantêm
os dois pares originais. O Mercado Fugaz modifica as frutas opcionais; o Núcleo
Colossal acrescenta o confronto final. Os seis layouts são autorais e distintos.

Overdrive e Trem Fantasma têm placares separados do Circuito. O relógio começa
após a primeira direção, congela na pausa/mapa e continua nas mudanças automáticas
de área, preservando a direção já comandada. Vidas esgotadas encerram a tentativa
antes de 180s. Limpar uma área concede bônus e uma vida, limitada a três.
O pulso periódico de Overdrive não encurta um Power ativo nem cancela sua cadeia.

Os seguidores mantêm distância do anterior, percorrem caminhos legais e ficam
vulneráveis com Power. Capturados pontuam na cadeia existente e desaparecem;
não são reutilizados na mesma janela. Uma morte dispersa a composição atual,
que pode crescer novamente em ondas futuras. Há breve proteção ao aparecerem.

## Colosso

Após limpar os itens da sexta área, aparecem três núcleos Power nos cantos do
labirinto. A contagem total incorpora esses três itens. A coleta carrega até os
pulsos necessários; o HUD passa a mostrar vida, cargas e estado do Colosso.

| Estado | Duração | Regra |
|---|---:|---|
| Aviso | 1,6s | Uma rota é marcada em vermelho no chão e no mapa; sem dano. |
| Varredura | 0,9s | Contato com a rota ativa causa dano; escudo/proteção funcionam. |
| Recuperação | 3s | F/RB gasta uma carga e tira uma vida do Colosso, uma vez por ciclo. |

As rotas alternam entre linhas 3, 11 e 7, apenas em células transitáveis. O corpo
holográfico fica na casa central e não tem hitbox de contato. Após uma morte,
a próxima varredura recebe novo aviso com margem para reaparecer. Três pulsos
encerram o confronto, dão +1500 e permitem a conclusão do Circuito. Cargas e
vida do Colosso persistem nessa luta após perda de vida, evitando perda dos
recursos necessários. O confronto não aparece nos modos cronometrados.

## Progresso e medições locais

O save migra para schema 4, conservando configurações, desbloqueios e as medalhas
anteriores. As listas passam de três para seis áreas. O recorde do antigo circuito
de três fases é arquivado e mostrado em Recordes; o novo circuito tem classificação
própria. Overdrive e Trem Fantasma não sobrescrevem esse placar.

A execução opcional com `-- --report=CAMINHO.json` gera um relatório local ao sair.
Inclui ambiente/renderizador/adaptador, distribuição de tempos de quadro em tempo
real, tentativas/revanches, locais de morte e uso de habilidades na sessão. Não há
envio pela rede, identificação de jogador, ranking online ou coleta em servidor.
Os valores de quadro são observações de tempo de CPU/parede, não timestamps de GPU.

## Validação e limites

340 verificações aprovadas: 52 regras, 27 ação, 16 mapa, 36 circuito, 52 integração,
33 túneis/casa/interface e 124 expansão. Incluem limpeza por movimento dos novos
mapas 4/5 com inimigos isolados, alcançabilidade de todos os itens dos seis mapas,
limites de tempo, Power/contato em ordem temporal, escolhas, migração, controles
sintéticos e interface em 960×720, 1280×720 e 1920×1080.

Exportação Windows x64 real, com PCK, ícone e versão embutidos. O conteúdo exportado
passou por smoke no motor Linux fora da pasta de fontes. Isso não executa o PE no
Windows. Execução nativa, controle físico, desempenho em GPU física e equilíbrio
com jogadores continuam pendentes. Trem Fantasma e Colosso exigem teste humano
para ajustar dificuldade; não há promessa de taxa de quadros ou retenção.

As capturas `vivo_*_080.png` são do Godot 4.6.3, Linux/X11, Forward+/Vulkan em
llvmpipe. O script `tests/capture_living.gd` registra os preparos controlados:
posicionamento de fruta/seguidores, quatro fantasmas imóveis capturados por dash,
limpeza preparada da sexta área para inspecionar o Colosso, e resultado de tempo
preparado para revisar o menu. Não equivalem a uma partida humana de três minutos.
