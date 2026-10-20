# 0.8.0 — Circuito Vivo (roteiro 0.6–0.8)

- Capturas crescentes com quatro arpejos originais, faíscas e uma legenda por vez.
- Curvas/dash/capturas com expressão; redução de movimento neutraliza efeitos extras.
- Fruta bônus móvel, opcional, com coleta contínua e expiração sem bloquear conclusão.
- Overdrive de 180s, pulsos de caça, continuidade entre mapas e revanche do mesmo modo.
- Circuito com seis layouts, três pares de túneis no Anel e Mercado com fruta mais rápida.
- Melhorias de escudo, ímã e dash válidas apenas para a próxima área.
- Dezoito medalhas básicas e dezoito extras por habilidade; migração preserva progresso.
- Trem Fantasma com limite de oito seguidores e Power/contato em ordem temporal.
- Colosso final com aviso, varredura, recuperação e três pulsos carregados por núcleos.
- Placares separados; recorde do Circuito anterior de três fases arquivado.
- Gamepad com zona morta, diagnóstico local e roteiro para homologação Windows.
- 340 verificações aprovadas, exportação Windows e smoke do PCK no host.
- Capturas reais do motor em Forward+/Vulkan por software; homologação física pendente.

# MV neon 0.5.0 — arquitetura e primeira direção

- Interpretação corrigida: essência clássica no layout, com direção artística neon 3D.
- Paredes metálicas com faces recuadas, painéis, molduras, aletas e iluminação no piso.
- Fachadas instanciadas por material, mantendo redução de obstáculos perto da protagonista.
- Perspectiva próxima acompanhando a ação; C mantém a visão superior de todo o mapa.
- Piso opaco polido para SSR em Forward+, sem a antiga transparência que prejudicava reflexos.
- Detalhes na caixa de regeneração, base da arena e janelas da cidade.
- Corpos dos fantasmas com brilho de contorno, conservando rostos e estados legíveis.
- Direção inicial nula; relógio/liberação aguardam primeiro comando na abertura de cada fase.
- Direção + dash funcionam no mesmo quadro de entrada; Espaço sozinho não inicia movimento.
- 19 verificações adicionais de início, reinício, troca de fase e respawn.
- Capturas reais em Forward+/Vulkan por software; Windows nativo/GPU física ainda pendentes.

# MV essência arcade 0.4.0 — clareza, túneis e regeneração

- HUD e área 3D em retângulos separados, com câmera de visão geral.
- Menus centralizados e limitados à tela; texto ajustável e rolagem.
- Paredes escuras com contornos neon, sem os grandes blocos emissivos.
- Três mapas remodelados em torno da casa central e dois pares de túneis.
- Túneis também usados pela IA; trajetos não colidem através do centro da tela.
- Casa bloqueada ao jogador: olhos retornam, corpo regenera e sai pela porta.
- Fantasmas opacos, corpo mais alto, barra ondulada, olhos direcionais e rosto de medo.
- 33 novas verificações de navegação, casa, interface e apresentação.

# MV circuito 0.3.0 — fases, desafios e poderes

- Três mapas autorais: Pórtico Neon, Jardim Iônico e Reator Solar; paletas próprias.
- Fantasmas +0%, +6%, +12% conforme a fase, além da pressão já existente.
- E: escudo de um contato por até 8s; 1s de proteção após absorver.
- R: ímã de pontos vizinhos por 6s nas fases 2/3, sem atravessar paredes.
- Uma carga por poder por fase; morte encerra efeitos sem recarregar.
- Nove medalhas, seletor de fases desbloqueadas e rastro turquesa por três medalhas.
- Avanço conserva pontos e concede +1 vida até o limite de três.
- Save migra preservando recorde anterior/configurações; novo recorde separado.
- Mantidos contador, mapa ampliado, Flow, apostas e áudio aprovado.

# MV mapa 0.2.1 — clareza da coleta

- HUD mostra itens restantes, coletados/total, percentual e barra de progresso.
- Contagem separa pontos, Power Pellets e frutas exigidos pela fase atual.
- Minimapa mostra todos os itens restantes e usa a topologia atual do labirinto.
- Últimos dez itens recebem círculos brancos fixos nos dois mapas.
- M abre mapa ampliado e pausa tempo/música; M, Esc ou botão retomam a partida.
- Preservados movimento, pontuação, Flow, áudio e direção visual da versão aprovada.
- Adicionadas verificações de coleta e integração do mapa ao builder.

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
