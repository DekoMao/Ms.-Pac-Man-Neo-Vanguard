# Parâmetros MV e limites

Fonte única: `assets/balance.json`, regras `mv-0.1.0`. Hipóteses v3.2 usadas:
3,2 células/s protagonista; 2,0 fantasmas; buffer 120 ms; drift 80 ms, +10%
por 200 ms e intervalo 350 ms; dash 2 células/150 ms, custo 40/100, recarga
5 por pellet, cooldown 1 s; Power Pellet 6 s; Flow até 3× por 5 s.
O retorno usa 5 células/s. Todos usam relógio de simulação, nunca áudio/FPS.

Fantasmas liberam escalonados (2,5 + 1,2×índice s) para permitir aprender a
área. A formação inicial não é Ghost Train. O MV tem uma mudança de topologia,
um mapa e três vidas; dificuldades/curva de três fases não existem ainda.
Não foram inventadas métricas de engajamento ou ajustes a partir de usuários.

Os testes confirmam limites/correção, não o balanceamento subjetivo.
Na rota automatizada de 10 s houve duas capturas, uma morte e retomada.
Balanceamento precisa de partidas manuais no Windows antes de M1.
