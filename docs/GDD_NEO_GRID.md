# Especificação implementada — MV 0.1.0

Implementação própria autorizada pelo prompt v3.2, sem dependência de ROM,
MAME ou acesso a D:. O documento `M0_GDD_NEO_GRID.md` conserva o briefing
amplo; esta página distingue o que realmente existe de M1–M3 futuros.

## Pilares, escopo e apresentação

Precisão arcade, decisões de rota/risco, feedback legível e mundo 3D neon.
Uma área 17×13, uma protagonista volumétrica de boca animada, laço e olhos,
quatro fantasmas com malha de domo/saia ondulada e material translúcido.
Paredes chanfradas roxas, ciano e magenta; piso escuro, partículas e rastro
3D em fita, câmera oblíqua próxima e vista superior da mesma cena.
Olhos dos fantasmas se orientam para a câmera por legibilidade; isso não muda
sua direção ou hitbox de simulação. Reduzir efeitos desativa partículas/rastro
intensos, glow e a oscilação vertical dos atores.

Godot 4.6.3 / Forward+. O piso usa geometria espelhada para reflexos estilizados
dinâmicos, inclusive transparências, combinada com o material do piso.
SSR é complementar e não é apresentado como solução para fantasmas.
Acabamento visual completo e orçamento em GPU física ainda não aprovados.

## Regras concretas

Parâmetros versionados em `assets/balance.json`:

| Regra | Implementação MV |
| --- | --- |
| Simulação | 120 Hz, interpolação visual; máximo 8 passos de recuperação por frame |
| Movimento | 3,2 células/s, centro de corredor e grafo legal, buffer 120 ms |
| Micro-Drift | Curva perpendicular nova nos 80 ms anteriores ao centro; +10% por 200 ms; intervalo 350 ms; segurar/inverter não renova |
| Dash | Máximo 2 células/150 ms; energia 100, custo 40, cooldown 1 s, +5 por pellet único; sem invulnerabilidade ou curva 90° durante dash |
| Pickups | Pellet 10; Power Pellet 50; fruta 100; Flow multiplica somente pellet/fruta com roundi |
| Vulnerabilidade | 6 s; nova esfera substitui prazo e inicia nova janela/índice |
| Captura | 200/400/800/1600, teto 1600 por captura; retorno não pontua |
| Flow | +0,5 por captura até 3×, renova 5 s sem somar |
| Vidas | 3; um contato letal encerra o processamento do passo; espera 1,5 s para retorno |
| Fim | Todos os itens = área concluída; zero vidas = fim de jogo; reinício pelo menu |

Hitboxes planares têm raios 0,29/0,30 célula (jogador/fantasma), distintos
dos volumes visuais de aproximadamente 0,47/0,43. Célula visual = 1,4 unidade.
A apresentação não altera distâncias/velocidades entre câmeras e qualidades.
Não há túneis ou portais nesta pequena área; a borda é fechada.

## Estados e ordem dos eventos

Estados de jogo: ready, playing, respawning, won, game_over, com pausa separada.
Fantasmas: house, chase, scatter, vulnerable, returning. Saída da casa usa
liberação temporizada; o estado intermediário Saindo completo é expansão M1.
Liberam após 2,5 + 1,2×índice segundos. Retorno usa o grafo, espera 1,5 s e fica
imune à mesma janela; Power Pellet não converte returning. A casa memoriza
implicitamente a janela global e só aplica vulnerabilidade ao liberar.

O ciclo normal tem 5 s de dispersão e 15 s de perseguição. Política de direção:
não inverter imediatamente, salvo beco sem saída. Quatro alvos simples próprios:
posição do jogador; projeção de 3 células; posição oposta no tabuleiro;
patrulha da fruta alternada com perseguição. BFS somente ao atingir centros,
com mapa pequeno e desempate determinístico. Não são perfis históricos,
Ghost Train nem todos os perfis táticos finais de M1.

Cada passo consome input, calcula segmentos legais, resolve grafo, ordena
pickups/encontros pelo instante de impacto, aplica Power Pellet/expiração,
resolve capturas/morte e depois conclusão/topologia. Interseção contínua usa
movimento relativo dos segmentos. Só em empate real pickup precede contato;
Power Pellet posterior não salva uma colisão letal anterior. Após morte não
há coleta nem perdas adicionais no mesmo passo.

## Mudança segura e recompensa

Uma troca de parede por partida MV: abrir (5,5) e fechar (8,3). Fruta ou 50%
de coleta solicita o mesmo evento único. Há aviso de 1,5 s, bloco a abrir
pulsando e volume translúcido mostrando o fechamento candidato.
Valida conectividade total, itens e casas; revalida ocupação/proximidade de
uma célula na aplicação. Adia até 3 s e cancela sem penalizar se inseguro.
Grafo muda atomicamente e todos os agentes usam a nova versão.
O modo completo de M1 poderá ter até duas mudanças e portais; não está pronto.

Loop: planejar rota → curva/dash → Power Pellet → captura → Flow → decidir
nova rota. Na gravação real, essa sequência gera eventos de coleta, duas
capturas, mudança válida, morte e retorno, sem esconder a morte com cortes.

## Interface, dados e áudio

Menu PT-BR funcional: jogar MV, ajuda, configurações, recorde e sair.
Setas/WASD, Enter, Espaço, P/Esc, C e F11; foco perdido pausa/limpa input;
retomada explícita; saída em jogo pede confirmação. Última tecla pressionada
controla a intenção; release retoma a última ainda segurada. Sem multiplayer.
HUD mostra estado real: pontos, três vidas, energia, Power Pellet, Flow/minimapa.

Qualidade Baixa/Média/Alta preserva malhas; reduz partículas, SSR/SSAO e atlas
posicional de sombras. Não corresponde ainda ao perfil de GPU final homologado.
Configurações e recorde exclusivo MV persistem em user://; dados inválidos
recuperam defaults e guardam cópia. Escrita temporária e backup .bak.
Trilha e efeitos originais sintetizados offline; loop de 112 BPM, 5 vozes de
SFX, volume/mudo e Dummy audio testado. Camadas/BPM adaptativo completo = M2.

## Gate e escopo que permanece pendente

MV é **parcial em homologação visual/desempenho/Windows**, embora fontes,
regras, cena executada, vídeo e PE já existam. Não expandido para M1–M3.
Não existem Clássico, três fases, Time Attack, Rogue, multiplayer, remapeamento
completo, janela assistida ou editor. Nenhum botão promete esses recursos.
