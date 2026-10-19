# MV ação 0.2.0 — refinamento da base aprovada

- Base e ZIP 0.1 preservados; fontes correspondentes publicados em branch própria.
- Pressão em 8/20/32s com aviso de 0,8s; velocidade hostil limitada a +12%.
- Quase colisão validada por varredura relativa, premiada só depois de escapar.
- Power inverte câmera/áudio/sinalização; aviso de término e retorno à fuga.
- Capturas 200/400/800/1600 e Flow existentes recebem altura musical e impacto crescentes.
- Uma aposta opcional por fase, reutilizando energia, janela Power e capturas.
- Camadas musicais sincronizadas, oito vozes de efeitos e controles de câmera.
- Comparação reproduzível: mesma fase/semente e 5.400 comandos a 120 Hz.
- Novas verificações preservam colisão contínua e prioridade temporal de Power.

# MV 0.1.0 — implementação própria, entrega parcial

- Retomado M0 real sem alterá-lo; referências v3.2 verificadas e usadas.
- Criado projeto Godot 4.6.3, três cenas e personagens/cenário 3D procedurais.
- Implementados movimento/buffer/drift, dash, quatro fantasmas, Power Pellet,
  captura/Flow, pontuação/vidas e uma troca de parede segura.
- Menu PT-BR, HUD/minimapa, câmeras, pausa/foco, áudio próprio e persistência.
- Exportado Windows x64 real, recursos embutidos, ícone e versão próprios.
- Testes de lógica e integração, smoke do conteúdo exportado, vídeo/capturas
  do motor Linux Forward+ em llvmpipe. Nenhuma homologação Windows alegada.
- Sem Clássico histórico, expansão de fases, Time Attack, Rogue ou multiplayer.
  O gate visual/performance MV ainda está parcial; M1–M3 não iniciados.

# MV mapa 0.2.1 — clareza da coleta

- HUD mostra itens restantes, coletados/total, percentual e barra de progresso.
- Contagem separa pontos, Power Pellets e frutas exigidos pela fase atual.
- Minimapa mostra todos os itens restantes e usa a topologia atual do labirinto.
- Últimos dez itens recebem círculos brancos fixos nos dois mapas.
- M abre mapa ampliado e pausa tempo/música; M, Esc ou botão retomam a partida.
- Preservados movimento, pontuação, Flow, áudio e direção visual da versão aprovada.
- Adicionadas verificações de coleta e integração do mapa ao builder.

