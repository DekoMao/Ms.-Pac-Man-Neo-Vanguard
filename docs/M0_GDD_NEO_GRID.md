# Ms. PAC-Man: Neo-Grid — especificação operacional inicial

**Status: requisitos do prompt v3.1; jogo não implementado.**
Nenhuma regra histórica foi observada. Os números abaixo são hipóteses
iniciais do briefing, a centralizar em configuração e validar antes de aprovar.

## Pilares e arquitetura pretendida

Precisão arcade, decisões de rota/risco, feedback legível e apresentação 3D
acabada. Nome anterior Neo-Vanguard não cria um segundo produto.
Separar simulação planar fixa de 1/120 s, input por jogador, renderização
interpolada, áudio e persistência. Limitar recuperação após atraso/foco perdido.
Estado de regras e grafo versionados; dois viewports nunca duplicam a simulação.
Godot 4 estável é a preferência em caso de reconstrução; escolher após M0.

## Escopo por marco

| Marco | Resultado exigido | Estado |
| --- | --- | --- |
| M0 | Preservação, REA, comportamento-base, pipeline e export Windows inicial | Parcial/bloqueado por origem |
| MV | Área pequena 3D jogável, acabamento, quatro fantasmas, coleta, dash, captura, Flow e uma mudança segura | Não iniciado |
| M1 | Neo-Grid/Clássico, três fases, perfis, Ghost Train, portais, menu e persistência | Não iniciado |
| M2 | Time Attack 3/5 min, Rogue 5 fases, áudio adaptativo/BPM, presets e acessibilidade | Não iniciado |
| M3 | Cooperativo/versus, input, câmera/HUD e teste físico de teclado | Não iniciado |

MV exige EXE correspondente, dez segundos contínuos reais, duas capturas
do motor e comparação dos oito critérios visuais. Não expandir sem esse gate.
Preservar entregas independentes de M1 e M2 antes de M3.

## Controles e interface

Setas/WASD; Enter confirma; P pausa; Esc pausa/volta; F11 tela cheia;
Espaço dash no Neo. Reinício pelo menu; confirmar saída em partida;
pausa automática no foco perdido e retomada explícita. Menu PT-BR: Jogar,
Como jogar, Configurações, Recordes, Sair. Não exibir recursos futuros.
HUD de pontos/vidas/fase/dash/Flow legível sem encobrir rotas.
M3: ações isoladas, P1 WASD/Espaço, P2 IJKL/Ctrl direito; remapeamento e
teste físico de rollover; versus seleciona fantasma com 1–4.

## Balanceamento e recompensa inicial

| Parâmetro | Proposta, não resultado medido |
| --- | --- |
| Buffer de curva | 120 ms, só curva válida |
| Micro-Drift | Nova curva 90° nos 80 ms anteriores ao centro; +10% por 200 ms |
| Limites de drift | Intervalo 350 ms, sem farming ao segurar/inverter; teto +25% fora do dash; assistência 140 ms separa recordes |
| Dash | Energia 100; custo 40; +5 por pellet único; até 2 células em 150 ms; intervalo 1 s |
| Colisão dash | Sem invulnerabilidade; parar na parede; contatos ao longo do trajeto; não combinar portal Neo/dash no primeiro incremento |
| Vulnerabilidade | 6 s iniciais no Neo; nova Power Pellet substitui duração, não soma |
| Capturas | 200/400/800/1600, teto 1600 por captura; retorno não pontua |
| Flow | +0,5 por captura até 3× por 5 s; renova sem somar; só pellets/frutas, nunca captura |
| Topologia | Até 2 gatilhos/fase, 50% pellets e primeira fruta; consolidar coincidências |
| Segurança da mudança | Aviso 1,5 s; conectividade/ocupação revalidadas; adiar até 3 s e cancelar sem penalidade |
| Portal | Par bidirecional distinto de túnel; reentrada bloqueada 500 ms; destino seguro |

Loop: escolher rota → curva/dash com risco → Power Pellet → captura → Flow
→ coleta ou nova oportunidade. Arredondamento de pontos será explicitado e
testado antes da implementação; não afirmar fidelidade sem observar a base.

## Estados e colisões

| Estado | Evento | Transição |
| --- | --- | --- |
| Na casa | Liberação por critério | Saindo pela rota válida |
| Saindo | Atinge saída | Perseguindo/Dispersando pela fase vigente |
| Perseguindo/Dispersando | Ciclo normal | Alternar com reversão documentada |
| Normal/Saindo | Power Pellet | Vulnerável |
| Vulnerável | Contato | Retornando, captura única |
| Vulnerável | Tempo termina | Fase normal vigente |
| Retornando | Casa | Atraso e imunidade à mesma janela |
| Retornando | Power Pellet | Continua retornando |
| Na casa | Power Pellet | Memoriza janela; não libera antes da hora |
| Todos | Pausa/foco perdido | Congela estado e relógios |
| Todos | Reinício/fase | Reset sem timers herdados |

Hitboxes planares explícitas; malha 3D não altera colisões. Ordem do passo:
input → trajetórias legais → paredes/portais → pickups → Power Pellet →
encontros → pontos → morte/conclusão → topologia no próximo passo.
Ordenar eventos pelo instante de impacto; Power Pellet só vence contato em
empate real. Morte interrompe coleta e movimento. Testar cruzamento entre
fantasmas/jogador, saída de portal e velocidades máximas contra tunneling.
IA: vermelho projeta 2 células; rosa até 3 interseções usando intenção já
registrada; ciano combina alvo e outro fantasma com semente; laranja patrulha
atalhos/frutas. Todos têm fallback legal e orçamento de busca configurável.

## Modos, dificuldade e persistência

Clássico mantém somente regras observadas, sem drift/dash/Flow/topologia Neo.
Neo tem ≥3 fases completas; Easy/Normal/Hard terão tabelas explícitas de
velocidade e vulnerabilidade calibradas após a base. Time Attack 3/5 min,
3 vidas, termina por tempo/vidas, relógio congela na pausa.
Rogue: 5 fases conectadas, semente visível, validação em runtime e ≥200 sementes
automatizadas; fallback forçado em teste. Upgrades distintos elegíveis,
Power Pellet +1 s até +3, dash −5 até 25, fruta atraída por até 1 célula acessível.
Upgrades nunca vazam ao Clássico.
Coop: 6 vidas compartilhadas, energia individual, pickups únicos, renascimento
protegido 1,5 s; congelar política Flow e câmera antes dos testes. Versus:
rodadas 3 min, alternância, desempate 60 s, estados restritivos respeitados.
Sem internet. Recordes separados por regras, modo, dificuldade, assistência,
duração, jogadores, versão e semente Rogue. Gravação segura no perfil do usuário;
arquivo corrompido preservado quando possível e defaults recuperados.

## Storyboard e orçamento audiovisual

| Momento conceitual | Evento real a demonstrar |
| --- | --- |
| 0,5 s | Câmera oblíqua, protagonista volumétrica e rastro no corredor |
| 2,5 s | Coleta/fruta e sinalização de mudança segura |
| 4,5 s | Fantasmas vulneráveis translúcidos com olhos e animação |
| 6,5 s | Captura e Flow com pontos ligados à simulação |
| 8,5 s | Partículas em profundidade e mudança válida de parede |

Esse storyboard deriva do texto do prompt; o vídeo não foi inspecionado nesta
sessão. A direção visual permanece **não validada**. Exigir volumes suaves,
laço/boca animados, paredes chanfradas, neon com cor preservada, piso reflexivo,
câmera próxima e vista superior da mesma cena. Sem sprites planos como entrega.
Forward+ e driver devem ser observados no runtime; SSR não reflete fantasmas
transparentes, que precisam de técnica complementar demonstrada e medida.
Hipótese de orçamento: 60 FPS/16,67 ms, CPU até 6 ms e GPU até 13,5 ms
separados, não somados. Medir p95/p99 após aquecimento, mesma rota ≥60 s,
SSR desligado/meia/full, presets Baixo/Médio/Alto preservando geometria.
Limites concretos de luzes/partículas só serão fixados com GPU disponível.
Áudio em camadas: exploração/ameaça/Flow, histerese, vozes limitadas;
112/128/144 BPM em fronteira musical em M2. Silêncio não muda simulação.
Redução de flashes/movimento/glow, volume/mudo persistentes e fallback sem áudio.
