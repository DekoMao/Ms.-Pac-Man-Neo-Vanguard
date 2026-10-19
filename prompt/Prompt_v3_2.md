# Prompt REA para Codex v3.2 — Neo-Grid 3D com execução por dependência

Copie o texto abaixo para a sessão de execução do Codex, em Linux ou Windows. Utilize o REA de https://github.com/morluto/rea. Esta versão substitui as anteriores e distingue a investigação da origem, a implementação própria do Neo-Grid, a exportação Windows e a homologação visual/nativa. Anexe o pacote de referências ou disponibilize a pasta `referencias`. O acesso a `D:\Ms PACMan` é necessário para examinar essa origem; sua ausência não impede as tarefas independentes da implementação própria autorizada abaixo.

---

Você é o agente de execução responsável por investigar o jogo disponível e construir, testar e empacotar o Neo-Grid, usando o REA de `https://github.com/morluto/rea` para apoiar a investigação técnica. A origem informada é `D:\Ms PACMan`, quando acessível. Trabalhe como engenheiro de software e desenvolvedor de jogos para PC, com foco em jogabilidade, compatibilidade e qualidade verificável.

## 1. Missão e resultado obrigatório

Entregar uma versão aperfeiçoada do jogo para Windows x64, offline, iniciada por duplo clique em um `.exe`, com controles por teclado, experiência arcade consistente e instruções em português do Brasil. Nome de trabalho único: **Ms. PAC-Man: Neo-Grid**. Trate Neo-Vanguard como o nome anterior do briefing, sem criar um segundo produto.

Ofereça o modo Clássico e o modo Neo-Grid no mesmo produto. Preserve movimento, coleta, fuga e caça como núcleo da experiência. No modo Clássico, mantenha as regras observadas quando houver acesso suficiente à base. Se a origem não puder ser examinada, implemente uma variante arcade própria com parâmetros explícitos e identifique-a como tal, sem alegar reprodução ou validação histórica do jogo inacessível. No Neo-Grid, implemente as mecânicas modernas das seções 6 e 7. Separe recordes, configurações de regras e identidade visual dos modos para permitir comparação justa.

**Contrato visual prioritário:** o Neo-Grid exige cenário e personagens renderizados em 3D, com a linguagem visual das referências anexadas: paredes volumétricas ciano/magenta, piso escuro reflexivo, iluminação e brilho controlados, protagonista com volume e fantasmas translúcidos luminosos. A animação anterior `MsPacMan_NeoGrid_Conceito_10s.mp4`, feita com desenho isométrico simplificado, foi explicitamente rejeitada pelo usuário e não é referência estética aceitável. Arte provisória pode existir no diagnóstico, mas não satisfaz o demonstrador visual, a prévia ou a entrega final. Não prometa identidade quadro a quadro com um conceito gerado; demonstre o acabamento real no motor.

A entrega precisa incluir o executável real, todos os arquivos necessários, o código das alterações ou da implementação produzida, um processo de build repetível e evidências dos testes. Um script de compilação ou um arquivo renomeado para `.exe` não substitui o executável Windows.

Não encerre apenas com uma análise, um plano, exemplos de código ou recomendações. Execute o trabalho até a entrega, salvo impedimento concreto de acesso, ferramenta ou ambiente. Não declare como concluída uma etapa que não foi executada.

## 2. Ambiente, preservação e escopo

- Origem: `D:\Ms PACMan`.
- Destino padrão no Windows: `D:\Ms PACMan_Aperfeicoado`. Em Linux, use `NeoGrid` dentro do workspace atual gravável. Registre o caminho absoluto real. Se já existir um projeto ou checkpoint, inspecione e preserve seu conteúdo antes de continuar; não crie um projeto vazio por cima dele.
- Antes de alterar qualquer coisa, identifique sistema operacional, arquitetura, permissões, ferramentas instaladas, espaço disponível e acesso real à origem.
- Em PowerShell, trate caminhos com espaços usando aspas e `-LiteralPath`, quando aplicável. Em WSL, verifique se `/mnt/d/Ms PACMan` corresponde de fato à mesma pasta; não presuma que o disco Windows esteja disponível.
- Preserve a origem. Se houver Git, examine o estado e isole o trabalho sem descartar alterações existentes. Caso contrário, trabalhe em uma cópia no destino. Gere um manifesto SHA-256 dos arquivos originais relevantes antes da intervenção.
- Não faça publicação, envio do jogo, push, lançamento público ou criação de repositório remoto: esta tarefa é uma entrega local.
- Preserve licenças e créditos identificados. Registre a procedência dos novos recursos visuais e sonoros e as condições dos recursos reutilizados. A licença do REA não licencia o jogo analisado.
- Não remova proteções, ativação ou validações de licença. Caso isso bloqueie uma abordagem, documente o limite e avalie uma implementação própria do comportamento observável com recursos adequados ao uso pretendido.
- Se a origem estiver inacessível nesta sessão, informe exatamente o caminho e o acesso ausente e marque somente a análise dessa origem como pendente. Não invente inventário. Continue pela implementação própria autorizada da seção 2.1; inclua uma instrução para concluir a comparação com a origem em Windows posteriormente.

### 2.1. Condições de continuidade — não bloquear tarefas independentes

Está autorizada a implementação própria do Neo-Grid, em projeto separado, baseada no briefing, nas regras explícitas deste prompt e nas referências visuais fornecidas. Não depende de recuperar o código do original, de uma ROM ou de modificar um emulador. Use código e recursos próprios ou de procedência adequada e mantenha identificadas as regras novas. Essa autorização não equivale a afirmar fidelidade ao original.

Use esta matriz antes de declarar bloqueio global:

| Condição encontrada | Parte pendente/bloqueada | Trabalho que deve continuar |
| --- | --- | --- |
| `D:\Ms PACMan` e `/mnt/d/Ms PACMan` inacessíveis | Inventário/comparação da origem local. | Criar ou retomar projeto próprio Neo-Grid no workspace acessível. |
| Pacote contém MAME, sem ROM nem fontes do jogo | Execução e investigação do jogo original ausente. | Registrar o achado e implementar o Neo-Grid próprio; não analisar o MAME indefinidamente em busca de lógica específica de uma ROM ausente. |
| REA funciona por CLI, mas MCP Codex/decompilador não está disponível | Operações específicas daquela integração/provedor. | Usar CLI nas inspeções suportadas; construir e testar o código próprio sem exigir decompilação da base ausente. |
| Referências disponíveis no pacote de retomada | Nenhum impedimento de acesso a essas referências. | Usá-las diretamente; não pedir novamente arquivos que já estão acessíveis. |
| Sem Windows nativo, mas editor e templates Godot disponíveis | Homologação nativa Windows. | Implementar, testar lógica, configurar preset e tentar exportar Windows x64 pelo caminho suportado pelo motor. |
| Sem GPU/renderizador adequado ou sessão gráfica | Validação visual e medição de desempenho do perfil exigido. | Produzir projeto 3D real, materiais, cenas, testes de lógica e exportação quando disponíveis; entregar MV como parcial e preparar execução gráfica. |
| Sem engine/templates e sem acesso aos downloads necessários | Compilação/exportação que exige esses componentes. | Produzir fontes, cenas e scripts corretos até onde verificável; registrar a dependência exata, URL oficial e erro. Não simular sucesso de execução. |

Não compreenda essa matriz como garantia de que toda tarefa será possível: teste as capacidades reais. Uma falha só bloqueia as tarefas que dependem dela. Esgote o trabalho independente autorizado antes de encerrar. Evite repetir diagnóstico sem mudança de estado nem produzir apenas nova documentação quando já houver condições para escrever o projeto.

Se não houver origem, avance com a reconstrução própria sem pedir uma nova autorização para esse mesmo escopo. Não procure ROMs, não baixe cópias do jogo para preencher a lacuna e não atribua ao MAME recursos novos do Neo-Grid. Registre no diagnóstico a separação entre emulador, artefato do jogo e novo projeto.

### 2.2. Retomada de checkpoint e evidência mínima

Quando houver checkpoint acessível, examine seu manifesto e arquivos relevantes antes de reutilizar. Se o arquivo `MsPACMan_Checkpoint_M0_20261019.zip` estiver realmente disponível, extraia-o em diretório próprio e preserve o original. Caso exista só um relato textual, trate-o como informação relatada e não como inspeção de bytes realizada nesta sessão. Não invente hashes nem assuma que os caminhos de outra sessão existem aqui.

Reaproveite GDD, roadmap e evidências úteis; atualize apenas o que a implementação e o diagnóstico atual exigirem. Próxima prioridade executável: projeto Godot 3D com `project.godot`, cena inicial, lógica de movimento/colisão, personagens, materiais, configuração de input e preset de exportação. Confirme versões e opções na documentação do editor utilizado; valide importação e parsing antes de ampliar o projeto.

O projeto real deve existir mesmo se a etapa visual ficar pendente. Um roteiro, GDD ou pasta com um `.exe` do MAME não satisfaz esse requisito. Registre separadamente: fontes produzidas; importação/parsing; testes de lógica; execução gráfica; comparação visual; exportação PE; execução Windows. Nenhuma linha pode ser marcada como aprovada por inferência de outra.

## 3. Preparar e usar o REA corretamente

Consulte o README e a documentação atual do repositório oficial, especialmente instalação, CLI, investigação nativa e suporte Windows/Ghidra. Registre a versão do REA utilizada. Diferencie recursos publicados no npm de recursos disponíveis somente na branch principal.

Verifique primeiro se REA e a integração com Codex já estão configurados. Quando necessário, use o fluxo oficial de instalação/configuração, cujo ponto de entrada documentado é:

```powershell
npx rea-agents@latest setup
```

Selecione Codex e preserve configurações existentes. Siga o fluxo de revisão do instalador e não invente flags. Se a nova integração exigir reiniciar a sessão, salve um checkpoint com estado, comandos executados e próxima ação; explique em uma frase como retomar.

Use a ajuda da versão instalada para confirmar a sintaxe dos comandos. Entre os diagnósticos documentados estão:

```powershell
rea doctor --client codex --json
rea providers --json
```

Se houver MCP disponível, descubra as capacidades reais da sessão; a documentação orienta consultar `binary_session` com `{}` antes de selecionar operações. Se a integração MCP ainda não estiver disponível, use a CLI documentada quando ela permitir continuar a investigação. Não exija instalação de um decompilador para desenvolver um projeto próprio que não depende do binário original.

Selecione a rota conforme os arquivos encontrados:

- Código-fonte disponível: leia, compile e execute a base antes de refatorar. Use REA nas questões técnicas em que ele acrescentar evidência.
- Binário nativo PE: confirme arquitetura, dependências, ponto de entrada, strings, recursos e funções relevantes com um provedor disponível e compatível.
- .NET: use a rota de assemblies gerenciados; não trate metadados e CIL como recuperação integral do projeto original.
- JavaScript/Electron: use a rota de análise de aplicação/ASAR correspondente.
- DOS, ROM ou jogo acompanhado de emulador: identifique separadamente o jogo, o formato e o lançador. Não trate todos os arquivos como um executável PE moderno.

Não suponha que Ghidra, JDK, Hopper ou IDA estejam instalados. O suporte Windows/Ghidra é experimental e depende do formato e da versão; confirme a compatibilidade do alvo e do pacote utilizado. Não contorne uma recusa de suporte nem declare uma análise bem-sucedida quando o provedor falhar.

Para cada conclusão técnica importante, registre arquivo, hash, ferramenta, operação, localização relevante e evidência. Separe fatos observados, inferências e pontos desconhecidos. Pseudocódigo de um decompilador não equivale ao código-fonte original.

## 4. Diagnóstico do jogo e decisão de implementação

Produza um diagnóstico enxuto com os dados efetivamente disponíveis; para a origem inacessível, registre a pendência e prossiga conforme a seção 2.1:

1. Inventário: executáveis, fontes, recursos, configurações, dependências e licenças.
2. Forma de iniciar o jogo, requisitos e problemas reproduzíveis.
3. Resolução, proporção de tela, controles, áudio, temporização, pontuação, vidas, fases, inimigos e persistência existentes.
4. Evidências disponíveis da experiência inicial, incluindo capturas se a sessão permitir.
5. Estratégia escolhida: evolução do código existente, adaptação compatível ou reconstrução própria baseada em comportamento observado.

Preserve o comportamento da base que funciona. Se o projeto existente comportar a direção 3D exigida, evolua-o. Caso a tecnologia existente não consiga atendê-la, justifique uma nova camada de apresentação ou uma implementação própria em motor 3D. Não use a preservação da tecnologia como justificativa para repetir a simplificação visual rejeitada. Se só houver binários, não prometa recuperar o projeto completo nem editar facilmente qualquer lógica. Documente o que será preservado e o que será implementado novamente.

Para uma reconstrução, a preferência é Godot 4 em versão estável, com renderização 3D e exportação Windows x64; confirme a versão disponível, os templates de exportação e o suporte da GPU. Se a base já usar outro motor 3D adequado, avalie o reaproveitamento antes de migrar. No perfil visual de referência em Godot, configure Forward+: ele é obrigatório para usar o SSR nativo. Confirme o renderizador e o driver realmente ativos, inclusive após qualquer fallback do motor; não presuma que a configuração desejada prova sua utilização. Forward+ habilita recursos, mas não garante desempenho. REA apoia a investigação; modelagem, materiais, câmera, iluminação, áudio e exportação pertencem ao pipeline do jogo. A aplicação final deve funcionar sem exigir que o jogador instale o editor ou o ambiente de desenvolvimento.

Registre requisitos com IDs e critérios de aceitação antes de implementar. Continue autonomamente nas decisões reversíveis dentro deste escopo.

## 5. Aperfeiçoamentos obrigatórios

### Jogabilidade e regras

- Preservar a identidade arcade do jogo observado: labirinto, coleta, perseguição, pontuação, vidas e avanço de fases.
- Movimento previsível, sem atravessar paredes ou ficar preso em esquinas. Implementar buffer de direção para aceitar uma curva pouco antes da interseção.
- Separar a simulação da renderização e limitar a recuperação de tempo após travamentos/foco perdido, evitando aceleração ou saltos injustos.
- Validar túneis e transições quando existirem; impedir saídas indevidas do mapa.
- Implementar e testar estados de inimigos coerentes: comportamento normal, vulnerável e retorno após captura, conforme o projeto.
- Power-ups com duração definida, sinalização visual do término e transições consistentes.
- Evitar perda de várias vidas no mesmo evento; garantir reinício correto após morte e após game over.
- Preservar fases existentes e validar alcançabilidade de todos os itens necessários. Se a base não tiver progressão, incluir pelo menos três fases jogáveis e completas, com dificuldade gradual.
- Se o original tiver comportamentos que não puderem ser reproduzidos fielmente, documentar as diferenças em vez de afirmar fidelidade exata.

### Controles e interface no PC

- Setas e WASD para movimentação; Enter para iniciar/confirmar; P para pausar; Esc para abrir a pausa durante a partida e voltar nas telas de menu; F11 para alternar tela cheia. Espaço para dash apenas nos modos que o habilitarem.
- Reinício disponível pelo menu de pausa, evitando reinício acidental durante a partida.
- Menu em português: Jogar, Como jogar, Configurações, Recordes e Sair.
- Placar, vidas, fase e estado de pausa legíveis sem cobrir a área jogável.
- Pausa automática ao perder foco; retomada explícita e sem movimento inesperado.
- Confirmar saída durante uma partida ativa e encerrar sem deixar processo órfão.

### Apresentação, áudio e acessibilidade

- Melhorar legibilidade e acabamento com animações consistentes, sem alterar hitboxes silenciosamente.
- Escalar o jogo preservando a proporção, sem recorte do labirinto, em janela e tela cheia. Validar pelo menos 1280×720 e 1920×1080, conforme os monitores disponíveis.
- Evitar borramento indevido da arte pixelada. Diferenciar os estados importantes também por forma ou animação, além da cor.
- Efeitos de coleta, power-up, morte, avanço de fase e menu com volumes equilibrados; controles de volume e mudo persistentes.
- Não falhar quando não houver dispositivo de áudio.
- Oferecer redução/desativação de flashes e efeitos intensos.

### Recordes e estabilidade

- Salvar configurações e recordes localmente em diretório gravável do perfil do usuário, separado dos recursos empacotados.
- Usar gravação segura e recuperar arquivo ausente ou corrompido com valores padrão, preservando uma cópia quando viável.
- Resolver recursos por caminhos estáveis, sem depender da pasta atual do terminal.
- Registrar falhas em arquivo acessível, com mensagem útil ao jogador quando necessário.
- Funcionar offline e sem privilégios de administrador.

Controles adicionais e modos modernos seguem as etapas da seção 8. Editor de fases é opcional e não deve competir com a entrega do executável. Os números de balanceamento a seguir são hipóteses iniciais de projeto, não fatos descobertos pelo REA nem regras históricas do original. Centralize-os em configuração, valide-os e registre ajustes.

## 6. Redesign Neo-Grid — direção audiovisual e mecânicas

### 6.1. Direção de arte e leitura da ação

Adote cyber-art-déco com neon sintético reativo, formas geométricas, contraste alto e hierarquia visual: primeiro paredes, personagens, itens e perigos; depois efeitos. As referências PAC-Man Championship Edition DX, Tetris Effect, Dead Cells e Sayonara Wild Hearts são referências conceituais de ritmo, precisão e apresentação. Produza uma direção própria a partir delas.

No Neo-Grid, use como padrão uma cena 3D com câmera oblíqua em perspectiva, próxima o suficiente para evidenciar personagens e materiais, e enquadramento que preserve a antecipação das rotas. A lógica continua no plano do labirinto; a apresentação tem geometria, iluminação e câmera reais. Ofereça vista superior da mesma cena 3D para orientação e acessibilidade. O Clássico pode ter sua apresentação 2D própria. A opção de câmera não modifica distâncias, velocidades ou colisões.

Implemente materiais com resposta à luz e roughness definida, emissão, glow/bloom calibrado, sombras de contato e reflexos. No piso, use reflexos coerentes com personagens e luzes, por uma técnica suportada e medida no motor; documente limites de reflexos em espaço de tela e o tratamento de elementos fora de tela. Não imponha ray tracing como requisito. Paredes devem ter volume, bordas suavizadas e superfícies com acabamento, além de diferença material entre paredes opacas roxas e blocos luminosos ciano/magenta. Pintar polígonos planos com essas cores não atende ao requisito.

Modele a protagonista com volume arredondado, boca animada, expressão e laço legível. Modele fantasmas com silhueta arredondada, olhos expressivos, movimento sutil da base e material luminoso/translúcido. Resolva ordenação, profundidade e interseção dos materiais transparentes. Não use círculos e sprites planos como substitutos finais dos personagens 3D. Modelos procedurais são aceitáveis se apresentarem malha bem acabada, normais suaves, materiais e animação de qualidade.

Use partículas com variação de tamanho, tempo de vida, emissão vinculada a eventos e integração ao espaço da cena. Os rastros precisam comunicar direção e aceleração. Ajuste exposição e tone mapping para que neon preserve cor e contorno sem virar uma massa branca. Reflexos, iluminação e materiais devem responder de modo consistente durante o movimento.

Disponibilize qualidade Baixa, Média e Alta. Mesmo no preset Baixo, preserve geometria 3D, silhuetas, câmera e acabamento material; reduza quantidade de partículas, resolução de sombras e custo dos reflexos primeiro. Se a GPU não permitir o mínimo definido, declare incompatibilidade ou requisito pendente; não substitua silenciosamente a direção 3D por desenho 2D. O resultado visual depende também de recursos artísticos e validação: escolher um motor não assegura por si só o acabamento.

A protagonista deve ter expressão, animação de curvas e rastro de luz personalizável. Rastro e animação não mudam hitbox, velocidade ou regras. Disponibilize redução de movimento, tremor de tela, flashes e intensidade de brilho. Nenhuma informação essencial pode depender de um flash ou somente de uma cor.

### 6.2. Áudio adaptativo

Crie trilha original ou adequadamente licenciada em camadas de synthwave/electro-swing: exploração, ameaça e Flow. Use proximidade por distância navegável aos fantasmas e multiplicador como sinais, com suavização e histerese para evitar troca incessante de camadas.

Use a coleta como acento rítmico, limitando sobreposição e volume dos efeitos. O som pode sugerir o waka-waka, respeitando a procedência dos recursos. O jogo deve continuar plenamente jogável sem áudio.

Prefira sincronização de camadas em compasso e BPM estável no primeiro incremento. Para atender à modulação de BPM, implemente depois faixas ou segmentos preparados para três patamares iniciais: 112, 128 e 144 BPM, com transição em fronteira musical e histerese. Não altere velocidade de reprodução de forma abrupta nem exija precisão rítmica para movimentar-se.

O relógio da simulação é independente do relógio musical. Silenciar, pausar ou trocar o BPM nunca modifica colisões, velocidade, cronômetros ou dificuldade. Defina limites de vozes simultâneas e fallback quando o dispositivo de áudio estiver ausente.

### 6.3. Movimento, buffer de curva e Micro-Drift

- Use buffer inicial de direção de 120 ms, aplicado somente quando a curva for geometricamente válida.
- Uma nova solicitação de curva de 90 graus nos 80 ms anteriores à passagem pelo centro da interseção concede Micro-Drift ao completar a curva.
- Recompensa inicial: velocidade +10% por 200 ms. Limite o bônus total fora do dash a +25% da velocidade base, sem empilhamento de duração nem acúmulo multiplicativo.
- Segurar uma direção, inverter 180 graus ou repetir comandos sem completar nova curva não concede bônus. Use intervalo mínimo de 350 ms entre bônus.
- A janela usa tempo de simulação, não número de quadros. Não exija um acerto de um único milissegundo.
- Mostre retorno visual/sonoro breve e ofereça janela assistida de 140 ms em configuração de acessibilidade, com recorde identificado pelo perfil de regras.
- Teste que o jogador mantém controle e que o bônus não atravessa paredes ou interseções sem avaliação.

### 6.4. Dash tático

- Disponível no Neo-Grid e variantes, desabilitado no Clássico. Comando padrão: Espaço, remapeável.
- Energia máxima inicial: 100; custo: 40; recarga: 5 por pellet comum efetivamente coletado; intervalo mínimo: 1 segundo de simulação entre ativações.
- Avanço de até duas células ao longo do corredor atual, com duração inicial de 150 ms e parada na primeira parede. Durante o dash, não realizar curva de 90 graus; guardar a próxima intenção válida no buffer.
- Validar a energia antes de ativar e nunca permitir valor negativo. Não consumir energia se a ativação falhar por ausência total de deslocamento possível.
- Detectar colisões ao longo de toda a trajetória, incluindo movimento relativo dos fantasmas. Avaliar só o ponto final é insuficiente.
- Dash não concede invulnerabilidade. Fantasma normal causa morte ao contato; vulnerável é capturado conforme a regra; não atravessar paredes, portões fechados ou fantasmas normais.
- Coletar itens cruzados uma única vez. Energia recebida durante um dash não permite encadear outro antes do intervalo mínimo.
- Tratar túneis existentes por sua regra explícita; proibir encadeamento de portal Neo e dash no primeiro incremento para evitar alcance ilimitado.

### 6.5. Labirinto dinâmico e portais

No Neo-Grid, permita até duas mudanças de topologia por fase: uma ao atingir 50% dos pellets iniciais e uma pela primeira fruta móvel coletada. Se coincidirem, consolide em um único evento. Nenhum gatilho pode ocorrer repetidamente pelo mesmo marco.

Antes da aplicação, sinalize por 1,5 segundo quais paredes secundárias mudarão e qual rota alternativa será aberta. Valide o grafo candidato: todas as células transitáveis devem continuar conectadas à região jogável e todos os itens restantes, saídas da casa dos fantasmas e objetivos precisam permanecer alcançáveis.

Nunca feche uma célula ocupada nem uma aresta cujo entorno de uma célula contenha um personagem em trânsito. Revalide na hora da aplicação. Se a mudança se tornar insegura, adie por até três segundos e depois cancele-a sem penalidade; não teletransporte o jogador para corrigir uma escolha inválida.

Use padrões de mudança previamente validados antes de geração arbitrária. Aplique alterações de forma atômica entre passos de simulação. IA e colisão devem usar a mesma versão do grafo, sem caminhos antigos atravessando novas paredes.

Portais Neo devem ser pares sinalizados, bidirecionais e distintos dos túneis clássicos. Valide origem e destino, preserve direção de saída definida e aplique bloqueio de reentrada de 500 ms para evitar pingue-pongue. Não descarregue o jogador em parede, personagem ou perigo inevitável imediato. Se não houver destino seguro, adie a ativação. Registre critérios de segurança e teste-os.

### 6.6. Perfis táticos de fantasmas

Implemente esses perfis como decisões novas do Neo-Grid, sem atribuí-los à IA histórica do jogo. Todos respeitam o grafo e limites documentados de atualização:

| Perfil | Regra inicial | Fallback obrigatório |
| --- | --- | --- |
| Blinky/vermelho | Perseguição direta com projeção de até duas células no corredor atual da protagonista. | Célula navegável mais próxima do alvo projetado. |
| Pinky/rosa | Flanqueamento com projeção de até três interseções a partir da direção e intenção de curva já registrada. | Não ler comandos futuros; usar última intenção conhecida e depois perseguição. |
| Inky/ciano | Alvo calculado combinando posição da protagonista e de outro fantasma, com variação pseudoaleatória de semente conhecida. | Escolher rota legal; nunca usar aleatoriedade para atravessar obstáculos. |
| Sue/laranja | Patrulha e interceptação de zonas de atalhos, frutas e saídas de túneis. | Alternar zona após tempo máximo; não bloquear indefinidamente um ponto de renascimento. |

Limite a busca por passo e evite calcular caminho completo para todos os fantasmas a cada quadro. Use sementes reproduzíveis para testes e parâmetros por dificuldade. A dificuldade deve vir de escolhas e velocidade calibrada, com nenhuma aceleração oculta para anular a habilidade do jogador.

### 6.7. Ghost Trains, combos e Flow State

Ao consumir Power Pellet, inicie uma janela vulnerável com duração inicial de seis segundos no Neo-Grid, ajustável pela curva de dificuldade. Reiniciar a janela por uma nova Power Pellet substitui o tempo restante pela duração configurada, sem soma ilimitada.

No Neo-Grid, Ghost Train é um comportamento temporário de formação: fantasmas vulneráveis podem seguir um líder por rotas válidas, com distância mínima configurada e busca de rota própria se a formação ficar bloqueada. Nenhuma ligação visual concede invulnerabilidade ou altera colisões. O Clássico preserva seu comportamento observado.

Combo inicial de capturas dentro da mesma janela: 200, 400, 800 e 1.600 pontos; capturas adicionais ficam limitadas a 1.600. Uma nova janela reinicia o índice. Fantasma em retorno não pontua novamente e permanece imune à reaplicação da mesma Power Pellet após renascer até a próxima janela, evitando farming da casa.

Cada captura aumenta o multiplicador Flow em 0,5, de 1,0 até 3,0, por cinco segundos de simulação. Nova captura renova essa duração, sem acumular tempo. Ao terminar, volte a 1,0. Flow multiplica somente pontos de pellets e frutas; não multiplica os pontos de captura. Arredonde pontos por uma regra única documentada.

Flow intensifica trilha e efeitos. Não aumenta automaticamente a velocidade da simulação nem diminui a janela de input. Se desejar um bônus de velocidade, ele deve ser uma variante explícita posterior, com limite e testes próprios.

Recompensa esperada: escolher uma rota, executar curvas e dash, assumir risco de aproximação, capturar com Power Pellet, ganhar Flow e decidir entre manter coleta ou buscar nova oportunidade. Não confunda engajamento com efeitos incessantes ou recompensas sem decisão.

### 6.8. Referência visual do vídeo fornecido

O usuário forneceu `gemini_generated_video_5f8c45ac.mp4`, de aproximadamente dez segundos, 1280×720 e 24 FPS. Use-o como referência de apresentação; não como captura de uma implementação funcional ou comprovação de regras. A taxa de quadros do vídeo não define a meta do jogo.

Os aspectos observados em amostras visuais são:

| Momento aproximado | Referência observada | Tradução para o jogo executável |
| --- | --- | --- |
| 0,5 s | Labirinto em perspectiva oblíqua, paredes ciano/magenta, piso escuro reflexivo e protagonista com rastro amarelo. | Paleta por função, profundidade 3D, reflexos coerentes com qualidade ajustável e rastro que não encobre obstáculos. |
| 2,5 s | Fruta, placas de luz e efeitos de coleta próximos à personagem. | Feedback breve de coleta e preview de alteração de parede, distinguindo decoração de obstáculos reais. |
| 4,5 s | Paredes roxas escuras e fantasmas azuis com contorno luminoso. | Estado vulnerável legível por cor, forma/animação e temporizador consistente. |
| 6,5 s | Pontuação flutuante, rastros e indicador Flow State. | Feedback de combo sem ocluir corredores; valor exibido deve coincidir com o evento real de pontuação. |
| 8,5 s | Surto de partículas, linhas luminosas e mudança visual de paredes. | Transição de fase/topologia com intensidade configurável e todas as verificações de segurança da seção 6.5. |

O HUD de referência inclui pontuação, barra de dash e medidor de Flow. Refaça textos e números de forma legível em português, com valores ligados ao estado real do jogo. Não copie textos deformados nem números inconsistentes do vídeo. Os símbolos de controle mostrados no vídeo não substituem as teclas de PC definidas neste prompt; use prompts de teclado por padrão e de gamepad somente quando houver suporte ativo.

A câmera próxima e os efeitos intensos do conceito podem ocultar informações necessárias à decisão. Preserve visão suficiente das próximas interseções e ofereça vista superior da cena 3D. Na vista oblíqua, use redução de opacidade/recorte de paredes à frente de personagens, câmera estável e enquadramento que não esconda ameaças no mesmo corredor. Não aplique tremor ou zoom compulsório durante uma manobra crítica. Evite enquadrar o tabuleiro inteiro permanentemente como uma miniatura distante; a câmera principal deve mostrar o acabamento de materiais e personagens. Use minimapa ou ajuste de câmera quando necessário para manter orientação.

Além do vídeo, use as imagens enviadas posteriormente como referências específicas:

| Arquivo | Aspectos a preservar no desenvolvimento |
| --- | --- |
| `image(20261019-042538).png` | Abertura com universo arcade, gabinetes luminosos, cenário urbano noturno, perspectiva e composição de título. Criar título Neo-Grid e botões legíveis; não reproduzir os textos deformados do conceito nem o ícone de reprodução sobreposto. |
| `image(20261019-042558).png` | Blocos ciano/magenta com volume e brilho, piso reflexivo, dash dourado integrado à cena e painéis de luz com profundidade. |
| `image(20261019-042609).png` | Fantasmas azuis translúcidos com contorno luminoso, olhos expressivos, paredes roxas, reflexos e protagonista arredondada. |
| `image(20261019-042623).png` | Flow com rastro intenso, partículas distribuídas em profundidade, HUD discreto nas bordas e ponto focal na ação. |

O vídeo reapresentado como `gemini_generated_video_5f8c45ac(1).mp4` pertence ao conjunto de referência aceito. Trate imagens e vídeo como intenção artística, não como prova de física, desempenho ou pontuação. Não copie overlays de player, bordas de captura ou números incoerentes.

No GDD, monte um storyboard desses momentos e associe cada efeito a um evento real: coleta, dash, vulnerabilidade, combo e mudança segura de topologia. No executável, reproduza cenas equivalentes e registre capturas reais de validação, indicando preset e hardware. Não apresente frames do vídeo ou imagens geradas como screenshots do jogo desenvolvido. Se uma característica visual importante não puder ser atendida, marque a etapa visual como incompleta e resolva a limitação antes de ampliar os modos. Apenas registrar uma diferença não torna aceitável uma regressão ao estilo rejeitado.

### 6.9. Critério de qualidade visual antes da expansão

Construa primeiro um demonstrador jogável de uma pequena área do labirinto com acabamento próximo à referência, antes de produzir todas as fases e modos. O demonstrador deve incluir protagonista 3D controlável, quatro fantasmas, pellets, uma Power Pellet, dash, captura, Flow e uma mudança de parede segura. Pode ter escopo pequeno; não pode depender de arte provisória para avaliar o resultado final.

Grave dez segundos reais da cena em execução, com câmera oblíqua, HUD discreto e sem cortes que escondam defeitos. Entregue também o `.exe` correspondente e capturas da cena em pelo menos dois instantes. Se a gravação ocorrer fora de Windows, identifique o ambiente e não alegue validação do executável Windows. Não use a prévia renderizada como vídeo separado do jogo para demonstrar que o executável alcançou esse nível.

Compare referência e implementação nos seguintes critérios, com evidência visual do motor: volume e acabamento dos personagens; transparência dos fantasmas; resposta material e reflexos do piso; iluminação e cor do neon; profundidade e escala da câmera; integração de partículas/rastro; legibilidade do HUD; estabilidade visual durante curvas e dash. Registre cada critério como atendido, parcial ou não atendido, com justificativa concreta. Não fabrique uma porcentagem de similaridade estética.

O demonstrador visual só passa à expansão quando os critérios obrigatórios tiverem evidência de atendimento; funcionalidade sozinha não encerra essa etapa. Enquanto houver arte provisória, ausência de reflexos essenciais, personagens planos ou enquadramento que esconda o acabamento, continue corrigindo o demonstrador. Se a qualidade não puder ser atingida no ambiente, entregue o diagnóstico preciso e mantenha o marco visual incompleto. Não declare equivalência ao Gemini só porque a paleta tem neon.

### 6.10. GPU, SSR e custo do acabamento

Separe os conceitos: reflexo de superfície, emissão, bloom e iluminação/neblina volumétrica são efeitos distintos. A aparência do vídeo não demonstra qual técnica produziu cada efeito. Não use o termo reflexo volumétrico para tratar SSR como uma solução universal de iluminação.

No Godot, o SSR nativo está disponível somente no Forward+. Ele usa a informação visível na tela e não resolve objetos fora do enquadramento ou ocultos. Além disso, materiais transparentes não aparecem nesse SSR. Isso é especialmente relevante aos fantasmas translúcidos: não prometa seus reflexos apenas habilitando SSR.

No MV, faça um teste explícito com protagonista opaca, parede emissiva, fantasma translúcido e objeto saindo da tela. Selecione e implemente a técnica complementar adequada: por exemplo, captura planar com geometria refletida para os elementos necessários, ou outra solução suportada que demonstre o resultado exigido. Reflection probes podem complementar o ambiente; não afirme que uma probe pré-calculada reflete corretamente o fantasma em movimento. Compare resultado e custo, incluindo transparência, clipping e atualização. Reflexos estilizados são aceitáveis se coerentes com o movimento e se passarem pelo critério visual; não é necessário impor simulação física integral.

Defina o orçamento no hardware real de teste, antes de expandir a cena:

| Item | Regra operacional |
| --- | --- |
| Inventário | Registrar GPU, driver, backend gráfico, memória disponível quando mensurável, resolução, escala interna e versão do motor. Distinguir dado não medido de valor zero. |
| Meta temporal | 60 FPS corresponde a aproximadamente 16,67 ms por quadro. Usar como hipótese inicial CPU até 6 ms e GPU até 13,5 ms, medidos separadamente; CPU e GPU podem sobrepor execução e esses tempos não devem ser somados como previsão direta do FPS. Ajustar metas com dados. |
| SSR | Medir a mesma sequência com SSR desligado, em meia resolução e em resolução completa. Registrar o parâmetro real, os limites de passos e o custo observado; começar em meia resolução e subir somente com margem. |
| Reflexos complementares | Limitar resolução, elementos capturados e frequência de atualização, verificando se o reflexo permanece coerente durante dash e câmera em movimento. |
| Transparências e partículas | Medir sobreposição e custo nos piores momentos de Flow, captura múltipla e dash. Limitar partículas, luzes com sombra e camadas transparentes simultâneas. |
| Presets | Manter geometria e linguagem 3D nos três presets; documentar qualidade de reflexos, sombras, partículas e escala interna por preset. Não apresentar o preset Baixo como reprodução exata do Alto. |
| Repetibilidade | Usar mesma semente, rota, câmera e duração de pelo menos 60 segundos por comparação após aquecimento; registrar separadamente a primeira execução e eventuais travadas de compilação de shaders. |

Registre média, p95/p99 dos tempos de quadro e custo de CPU/GPU quando o profiler permitir. Não valide desempenho por FPS médio isolado. Se os percentis ultrapassarem a meta, relate o problema e ajuste efeitos antes de reduzir fidelidade dos personagens ou substituir o pipeline. Não invente requisitos mínimos a partir de um computador não testado.

O perfil de referência não pode trocar silenciosamente para Mobile/Compatibility e continuar marcado como Forward+ com SSR. Um perfil alternativo só pode ser considerado validado após comparação visual e medições próprias, mantendo o contrato 3D. Se a GPU não suportar o perfil exigido, informe a limitação concreta; não prometa que Forward+ elimina o custo dos reflexos.

## 7. Modos, estados e regras de colisão

### 7.1. Modos de jogo

| Modo | Regras e encerramento | Critério mínimo |
| --- | --- | --- |
| Clássico | Regras observadas no original, sem dash, drift, topologia dinâmica ou Flow novos. | Partida completa e diferenças de fidelidade documentadas. |
| Neo-Grid | Mecânicas da seção 6, progressão de fases e dificuldade calibrada. | Pelo menos três fases completas e diferentes entre si. |
| Overdrive/Time Attack | Partidas de três ou cinco minutos, três vidas iniciais; termina no tempo ou no esgotamento de vidas. | Cronômetro da simulação congela na pausa; recordes separados por duração. |
| Rogue Arcade | Cinco fases geradas por semente, com escolha de um entre três upgrades distintos após cada fase, exceto a última. | Toda fase solucionável; upgrades valem só para a run; morte final ou vitória encerra a run. |
| Cooperativo local | Dois personagens coletam em labirinto compartilhado, com pontuação e reserva de seis vidas compartilhadas. | Teclas sem conflito, renascimento seguro e regra explícita de conclusão com dois jogadores. |
| Versus assimétrico local | Um jogador controla a protagonista; outro comanda um fantasma selecionado, enquanto a IA controla os demais. | Rodadas de três minutos, alternância de papéis e vencedor por pontuação como protagonista. |

No cooperativo, use WASD + Espaço para jogador 1 e IJKL + Ctrl direito para jogador 2, com remapeamento. Cada contato letal consome no máximo uma vida por personagem por evento; mortes simultâneas podem consumir duas. Se restarem vidas, renasça em posição segura com proteção sinalizada de 1,5 segundo. Se ambos estiverem fora de jogo e não houver vidas para retorno, encerre a partida. A fase termina quando os itens comuns forem coletados por qualquer um, sem pontuação duplicada. Power Pellet afeta o estado global; energia de dash é individual. Documente a regra de Flow compartilhado e congele-a antes dos testes.

No versus, use IJKL para o fantasma selecionado e teclas 1–4 para seleção. Comandos humanos não podem ignorar paredes, estados vulnerável/retorno nem os mesmos limites de velocidade. A IA assume os não selecionados e o fantasma selecionado quando entrada humana for suspensa por uma regra documentada. Após morte, a rodada continua com as vidas restantes. Troque os papéis ao final; em empate, use a mesma fase para desempate de 60 segundos. Não chame esse modo de cooperativo. Não incluir multiplayer pela internet nesta versão.

**Contrato operacional de M3:** mantenha a simulação e os comandos de cada jogador isolados desde as interfaces de código, sem antecipar a implementação completa de multiplayer em M0–M2. No M3, use ações nomeadas por jogador, política explícita para direções opostas, remapeamento com detecção de conflitos e limpeza do estado de teclas ao perder foco. Eventos consumidos por menus não podem acionar movimento ou dash por baixo da interface.

Teclados podem não registrar certas combinações simultâneas por limitação física de rollover/ghosting. Não prometa resolver esse limite no software. Inclua uma tela simples de teste dos comandos dos dois jogadores, valide combinações reais no teclado disponível e ofereça remapeamento. Separe falha de roteamento de input de ausência de evento enviada pelo dispositivo. Caso uma configuração continue inviável, registre a limitação e valide outra combinação ou um gamepad disponível, sem exigir compra de equipamento nem alegar compatibilidade não testada.

Escolha e registre a política de câmera antes de concluir M3. No cooperativo, a câmera compartilhada deve manter os dois personagens visíveis, com zoom limitado para preservar leitura. Se isso não atender à separação permitida pelo mapa, implemente tela dividida com regras de entrada/saída e histerese; não force teletransporte ou morte para resolver enquadramento. No versus, defina qual informação cada papel vê e mantenha essa regra estável nas rodadas. Tela dividida não é pressuposto obrigatório se uma câmera compartilhada satisfizer os cenários, mas a decisão precisa de teste, não de omissão.

Se houver duas vistas, compartilhe uma única simulação e renderize câmeras/HUDs separados; não avance física ou timers duas vezes por quadro. Identifique claramente vida/energia individual, reserva e Flow compartilhados, jogador ativo e papel no versus. Pausa e reinício são comandos globais, sem eventos duplicados. Teste a janela inteira e, quando aplicável, cada viewport nas resoluções declaradas.

Para Rogue, gere um grafo conectado e valide todo item obrigatório antes de iniciar. Se a geração falhar após tentativas limitadas, use um mapa conhecido válido e registre o fallback. Exiba a semente. Upgrades iniciais: +1 segundo de Power Pellet, limitado a +3; custo do dash -5, mínimo 25; atração de frutas por até uma célula acessível, sem puxar através de paredes. Preveja substitutos elegíveis para oferecer três opções quando algum upgrade atingir o limite. Não altere permanentemente o Clássico por upgrades de uma run.

Separe recordes por modo, dificuldade, duração, assistência, número de jogadores e versão das regras; no Rogue registre também a semente. Use valores padrão de dificuldade Fácil, Normal e Difícil, com tabela de velocidades, janelas e duração de vulnerabilidade. Evite partidas impossíveis por sobreposição de multiplicadores.

### 7.2. Máquina de estados dos fantasmas

Implemente uma matriz de transição executável e documentada. Perfis táticos escolhem alvos; estados controlam comportamento e colisão. Flow é estado de recompensa do jogador, não estado de fantasma.

| Estado | Evento/condição | Próximo estado e efeito |
| --- | --- | --- |
| Na casa | Temporizador/critério de liberação | Saindo; seguir rota de saída válida. |
| Saindo | Atinge saída | Perseguindo ou Dispersando, conforme fase normal vigente. |
| Perseguindo/Dispersando | Troca do ciclo normal | Alternar entre ambos; aplicar política explícita de reversão. |
| Perseguindo/Dispersando/Saindo | Power Pellet válida | Vulnerável; interromper tática ofensiva e iniciar janela. |
| Vulnerável | Contato com jogador | Retornando; conceder captura uma única vez. |
| Vulnerável | Janela termina | Retomar fase normal vigente. |
| Retornando | Atinge casa | Na casa; cumprir atraso de reaparecimento e imunidade à mesma janela. |
| Retornando | Power Pellet | Manter retorno, sem pontuar nem virar vulnerável no caminho. |
| Qualquer estado | Pausa/perda de foco | Manter estado e congelar relógios e movimento. |
| Qualquer estado | Reinício de fase/partida | Reset definido, sem timers ou alvos herdados. |

Defina também o caso de Power Pellet enquanto Na casa: memorize a janela, mas não libere o fantasma imediatamente; ao sair, aplique vulnerabilidade somente se a janela ainda estiver ativa e se ele não estiver imune a ela.

### 7.3. Precedência e colisões

Use um passo de simulação fixo inicial de 1/120 segundo, com interpolação visual e limite de recuperação. Se a base exigir outra frequência, justifique e comprove equivalência temporal. Defina uma ordem única: consumir input; calcular trajetórias legais; resolver paredes e portais; processar pickups ao longo do movimento; aplicar transições de Power Pellet; resolver encontros jogador–fantasma; pontuar; atualizar mortes e conclusão; agendar mudança de topologia para o passo seguinte.

Dentro do passo, ordene contatos pelo instante de impacto. Só em empate real pickup da Power Pellet tem precedência sobre contato com fantasma. Uma Power Pellet localizada depois de um encontro letal no trajeto não pode salvar retroativamente o jogador. Interrompa coleta e movimento após morte. Garanta contagem única de eventos, inclusive com vários fantasmas sobrepostos e dois jogadores.

Represente explicitamente hitboxes e distâncias; volume visual e altura dos modelos 3D não mudam as regras da simulação planar. Especifique o efeito do cruzamento em sentidos opostos, encontro na saída de portal, início de vulnerabilidade e fim do dash. Priorize colisão contínua ou subdivisão limitada com garantia contra tunneling na velocidade máxima suportada.

## 8. Etapas de implementação e controle de escopo

Implemente em ordem, com build Windows verificável e checkpoint em cada etapa:

1. **M0 — Diagnóstico e infraestrutura:** investigação REA possível, preservação da origem/checkpoint acessíveis, identificação do motor/pipeline, criação ou retomada do projeto e verificação precoce da exportação Windows. Origem ausente mantém sua análise pendente, mas não impede o projeto próprio e suas verificações. Não desenvolver todos os modos nesta fase.
2. **MV — Demonstrador visual jogável obrigatório:** cena 3D da seção 6.9, materiais e personagens acabados, câmera e HUD próximos às referências, captura real de dez segundos, `.exe` correspondente e relatório de comparação visual. Este marco antecede a expansão do jogo.
3. **M1 — Neo-Grid e Clássico:** consolidar as regras na apresentação validada, três fases, drift, dash, perfis de IA, Ghost Train, combos/Flow, mudanças seguras de topologia, portais e opção Clássica; menu temático e persistência.
4. **M2 — Modos e acabamento:** Time Attack 3/5 minutos, Rogue de cinco fases, upgrades, trilha adaptativa/BPM, presets 3D, acessibilidade, balanceamento e desempenho. Não adiar o acabamento visual principal para esta fase: ele já deve estar demonstrado em MV.
5. **M3 — Jogo local para dois:** cooperativo e versus assimétrico, roteamento e remapeamento por jogador, teste físico de teclas simultâneas, política de câmera/HUD, regras de rodada, desempenho com a quantidade real de vistas e testes de dois jogadores; pacote final integrado.

As etapas fracionam a execução e não tornam M1–M3 promessas vagas. O pedido completo inclui M0–M3 e o marco visual MV obrigatório entre M0 e M1. Não encerre a tarefa no primeiro `.exe` se puder prosseguir. A pendência de análise de uma origem ausente não impede entrar em MV pela implementação própria. A pendência de GPU pode deixar a homologação visual de MV incompleta, mas não dispensa produzir e verificar o código, cenas e exportação viáveis desse demonstrador. Não avance para expansão de fases/modos enquanto o demonstrador visual não cumprir a seção 6.9. Havendo limite concreto, entregue o trabalho real e marque precisamente o restante como parcial ou bloqueado. Não exponha no menu botões que só exibem mensagens de recurso futuro.

Ao concluir M1 e M2, produza versões locais independentes e utilizáveis, em diretórios próprios, com `.exe`, dependências, código correspondente, hash e registro de validação. Não deixe a exportação e os testes da versão de um jogador esperando por M3. Se o usuário pausar o escopo após M1 ou M2, ou se M3 encontrar impedimento concreto, mantenha a última versão jogável disponível e informe precisamente o que ela inclui. Ela pode estar concluída no escopo daquele marco, enquanto o projeto completo permanece parcial. Não exponha botões multiplayer sem implementação e não altere o estado da versão aprovada para justificar falhas da expansão.

M3 deve ser acrescentado sobre uma versão estável, isolando configurações por modo e preservando os testes de regressão de um jogador. Se M3 falhar, preserve seu trabalho separado e entregue a última versão estável; não descarte as alterações nem reduza o acabamento da versão de um jogador para declarar todo o escopo pronto.

Antes do primeiro incremento, gere `docs\GDD_NEO_GRID.md`, enxuto e operacional, contendo pilares, modos, regras, controles, curva de dificuldade, matriz de estados, colisões, loop de recompensa, orçamento de efeitos e parâmetros de balanceamento. Gere `docs\ROADMAP.md` com requisito → marco → teste → evidência. Atualize ambos conforme a implementação real; documentação não substitui o jogo.

## 9. Implementar, testar e corrigir

Siga M0, MV e M1–M3 da seção 8, mantendo cada incremento executável. Construa regras e apresentação do demonstrador em conjunto e valide ambas, sem deixar a qualidade visual como item final. Distribua apenas localmente os pacotes de checkpoint. Mantenha atualizações curtas em português.

Crie testes significativos para regras e falhas de maior impacto: paredes e curvas, pontuação por coleta única, duração de power-up, colisões e vidas, pausa, reinício, avanço de fase, alcançabilidade de itens e persistência corrompida. Use relógio e semente controlados quando aplicável.

Execute uma matriz de aceitação com IDs, cenário, resultado esperado, resultado observado e evidência. Ela deve cobrir:

1. Início por duplo clique e navegação completa pelo menu.
2. Setas/WASD, curvas antecipadas, colisões e túneis existentes.
3. Power-ups, captura de inimigos, morte, game over e reinício.
4. Conclusão e transição das fases.
5. Pausa manual, perda de foco e retorno ao jogo.
6. Janela, tela cheia, escala e legibilidade.
7. Volume, mudo e ausência de dispositivo de áudio.
8. Recordes/configurações após fechar e abrir; recuperação de arquivo corrompido.
9. Execução offline e por usuário sem privilégios administrativos.
10. Sessão contínua de pelo menos 20 minutos, observando travamentos e crescimento de memória.
11. Micro-Drift dentro e fora da janela; direção segurada sem farming; comportamento temporal equivalente em renderização a 30, 60 e 144 FPS com o mesmo input gravado e semente.
12. Dash sem energia, energia insuficiente, energia exata, parede no percurso, fantasma cruzando o trajeto, portal e coleta múltipla sem duplicação.
13. Mudança de topologia com rota válida, item isolado, jogador perto da parede, mudança adiada e cancelada; nenhum fechamento inválido é aceito.
14. Máquina de estados completa, captura única, retorno à casa, imunidade à mesma janela e Power Pellet simultânea ao encontro com fantasma, incluindo ordem temporal dentro do passo.
15. Combos e Flow nos limites, sem multiplicação recursiva; reset correto após morte, nova janela, nova fase e nova partida.
16. Time Attack de ambas as durações, encerramento por tempo/vidas, pausa e recordes segregados.
17. Rogue: pelo menos 200 sementes de validação automatizada, mapa impossível rejeitado, fallback alcançado deliberadamente, opções de upgrade válidas nos limites e cinco fases concluíveis. A amostra não substitui a validação de cada mapa gerado em runtime.
18. Áudio em transições de ameaça, Flow, BPM, mudo, pausa e falha de dispositivo, sem modificar a simulação; qualidade visual Baixa/Alta com sinais de perigo equivalentes.
19. Cooperativo: coleta simultânea, mortes simultâneas, energia individual, vida compartilhada, renascimento e transição de fase; versus: seleção de fantasma, estados restritivos, alternância e desempate.
20. Ausência de regressão no Clássico depois de habilitar as mecânicas Neo; reiniciar cada modo não conserva upgrades, controles ou cronômetros da partida anterior.
21. Comparação visual com vídeo e quatro imagens: modelos 3D, acabamento, transparência dos fantasmas, reflexos do piso, rastro integrado, câmera próxima e HUD discreto. Compare a vista oblíqua com a superior da mesma cena 3D e os presets Baixo/Alto. Semelhança estética não comprova correção funcional; testes funcionais não comprovam cumprimento da direção artística.
22. Perfil de GPU: confirmar renderer/backend ativos, comparar SSR desligado/meia resolução/resolução completa, testar reflexos de personagem opaco e fantasma translúcido, passagem pelas bordas da tela e sobreposição de partículas. Registrar aquecimento, p95/p99 e limitações do profiler.
23. M3/input: ambos movendo-se e usando dash simultaneamente, teclas opostas, remapeamento em conflito, seleção de fantasma durante input do outro jogador, pausa, foco perdido e retorno sem tecla presa. Executar testes de lógica e um teste físico no teclado disponível; um não substitui o outro.
24. M3/câmera e HUD: jogadores em extremos do mapa, encontro, renascimento e mudança de fase; zoom mínimo/máximo, transição de viewport se existir e leitura dos valores individuais/compartilhados. Com duas vistas, verificar que timers e simulação mantêm a mesma velocidade e medir o custo extra de renderização e reflexos.
25. Entregas M1/M2: extrair e abrir cada pacote independente, confirmar versão e hash, navegar sem botões futuros e concluir partida de um jogador após alterações de M3. Manter a versão estável recuperável se a expansão ainda não passar nos testes.

Use 60 FPS como meta de renderização, mantendo as regras independentes da taxa. Registre hardware, resolução, preset, duração, FPS e percentis p95/p99 dos tempos de quadro medidos. Faça comparação com efeitos reduzidos e completos. Limite partículas, luzes, vozes simultâneas e buscas da IA por orçamento configurável. Não garanta desempenho em computadores que não foram testados.

Separe testes automatizados, inspeção visual e testes manuais. Um teste de lógica ou execução sem interface gráfica não comprova uma partida completa no Windows. Se faltar acesso à interface, marque os cenários correspondentes como pendentes e prepare um roteiro curto de homologação.

## 10. Gerar e validar o executável Windows

Escolha o empacotamento conforme o motor 3D efetivamente usado. Se usar Godot, configure o preset Windows Desktop x64 e templates compatíveis com a versão do editor; inclua o PCK quando externo e valide o conjunto. Um `.exe` do protótipo 2D anterior não satisfaz o pacote Neo-Grid. Se preservar ferramentas auxiliares Python, elas podem usar empacotamento próprio; não confunda a ferramenta auxiliar com o jogo final.

Use ferramentas de build com versões registradas e dependências fixadas. Produza `scripts\build_windows.ps1`, ou equivalente documentado, compatível com o PowerShell disponível e com tratamento explícito de falhas. Não altere permanentemente a política global de execução.

Entregue preferencialmente um pacote portátil com um executável principal chamado `MsPacMan_Aperfeicoado.exe`. Se a tecnologia exigir DLLs ou recursos externos, mantenha-os junto do executável e explique que a pasta inteira deve ser preservada. Executável único é desejável somente se não prejudicar estabilidade ou tempo de abertura.

O pacote precisa ter ícone apropriado, recursos incluídos, identificação de versão e abertura sem terminal desnecessário. Não exija Node.js, Python ou SDK no computador do jogador. Caso algum runtime seja indispensável, inclua-o quando permitido ou trate a dependência explicitamente antes de considerar a entrega pronta.

Valide o pacote extraído em diretório diferente do desenvolvimento, com espaço e acento no caminho, por exemplo `D:\Teste do Jogo\Versão Final`. Valide também uma sessão limpa de Windows sem o ambiente de desenvolvimento; se isso não estiver disponível, registre essa verificação como pendente.

Se estiver em WSL/Linux, diferencie exportação cruzada suportada pelo motor de execução nativa no Windows. Um export Windows pode ser produzido em outro host quando a documentação e os templates permitirem; confirme que é um artefato PE real e depois teste-o em Windows acessível ou em um runner já disponível e autorizado. A criação de um workflow, sozinha, não comprova que o build ocorreu. Não renomeie binários Linux para `.exe`. Não afirme que assinatura de código, teste gráfico ou compatibilidade foi validada sem evidência.

Se não existir ambiente Windows para teste, conclua a exportação quando tecnicamente possível e entregue o artefato real, scripts e checkpoint, mas marque a homologação Windows como PENDENTE e o pedido como parcial. Se nem a exportação for possível, marque a entrega do executável como BLOQUEADA. Não invente o executável nem resultados de homologação.

## 11. Pacote final e definição de pronto

Organize no destino:

- `entrega\MsPacMan_Aperfeicoado\MsPacMan_Aperfeicoado.exe` e seus arquivos necessários.
- `entrega\MsPacMan_Aperfeicoado_Windows_x64.zip`, contendo o pacote portátil completo.
- Código produzido e arquivos necessários para reconstrução, organizados conforme a tecnologia.
- `scripts\build_windows.ps1`, ou equivalente, com comando de uso.
- `LEIA-ME.txt`: como abrir, controles, requisitos e solução de problemas comuns.
- `CHANGELOG.md`: melhorias e diferenças conhecidas em relação à base.
- `docs\DIAGNOSTICO_REA.md`: inventário, versões, estratégia, evidências e limites.
- `docs\VALIDACAO.md`: requisitos, resultados, medições e pendências.
- `docs\GDD_NEO_GRID.md`: especificação efetivamente implementada, curva de dificuldade, estados, colisões e loop de recompensa.
- `docs\ROADMAP.md`: M0, MV e M1–M3, com rastreabilidade entre requisitos, marcos, testes e evidências.
- `docs\VALIDACAO_VISUAL.md`: comparação com as referências aceitas, cenas equivalentes, critérios atendidos/parciais e limitações. Não usar o vídeo simplificado rejeitado como referência de qualidade.
- `docs\ORCAMENTO_GPU.md`: hardware, renderer/backend, presets, técnica para reflexos de transparências, configuração de SSR, CPU/GPU e percentis medidos.
- `docs\M3_INPUT_CAMERA_HUD.md`: ações por jogador, combinações físicas testadas, câmera compartilhada/dividida, regras de HUD, limitações e matriz de dois jogadores.
- Versões locais M1 e M2 preservadas, com identificador e pacote independente para uso se M3 estiver pendente ou o escopo for pausado.
- `entrega\NeoGrid_Gameplay_Real_10s.mp4`: gravação de dez segundos do motor executando a cena, com ambiente e versão registrados. Incluir capturas reais para verificar materiais e câmera.
- Configuração de balanceamento versionada e `docs\BALANCEAMENTO.md`: hipóteses iniciais, mudanças justificadas e resultados observados, sem inventar métricas de engajamento.
- `docs\CREDITOS_E_LICENCAS.md` e `entrega\SHA256SUMS.txt`.

O hash final deve corresponder aos arquivos realmente entregues, após o último build. Não inclua arquivos temporários, configurações pessoais ou dependências de desenvolvimento desnecessárias no ZIP.

Considere o pedido completo CONCLUÍDO somente quando M0, MV e M1–M3 estiverem implementados, houver executável Windows real, pacote completo, testes críticos aprovados, critérios visuais da seção 6.9 demonstrados e validação funcional do artefato empacotado. A comparação com a origem, quando indisponível e substituída pela implementação própria autorizada, deve constar como não realizada; não é prova de fidelidade histórica. Diferencie marco aprovado de projeto completo. Havendo funcionalidades, qualidade visual obrigatória ou cenários de homologação pendentes, declare ENTREGA PARCIAL e liste-os. Havendo impossibilidade de gerar o executável, declare BLOQUEADO PARA ENTREGA FINAL, mas entregue antes fontes, cenas e verificações independentes que tiver sido possível concluir.

Na resposta final, informe de forma direta: estado da entrega; caminho completo do `.exe` e do ZIP; principais melhorias; testes executados e pendentes; comando de reconstrução; limitações relevantes. Não substitua a entrega por uma promessa.

Comece agora pela identificação do ambiente, acesso à origem/checkpoint e referências disponíveis. Registre o diagnóstico REA possível. Se a origem não estiver acessível ou houver apenas um emulador sem o jogo, siga imediatamente pela implementação própria autorizada. Reutilize o GDD existente, estabeleça M0 e construa MV com o padrão das referências antes de expandir até M3. Não deixe a geração do executável nem a demonstração do acabamento visual para o fim do projeto.

---

## Referências utilizadas na elaboração

- REA: https://github.com/morluto/rea
- Instalação e diagnóstico: https://github.com/morluto/rea/blob/main/docs/installation.md
- Investigação nativa: https://github.com/morluto/rea/blob/main/docs/native-investigation.md
- Limites Windows/Ghidra: https://github.com/morluto/rea/blob/main/docs/windows-ghidra-p0.md
- CLI: https://github.com/morluto/rea/blob/main/docs/cli.md
- PyInstaller: https://pyinstaller.org/en/stable/
- Godot — ambiente e pós-processamento: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- Godot — exportação Windows: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html
- Godot — recursos de cada renderizador: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot — inputs e limitação de keyboard ghosting: https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html
- Godot — exportação de projetos: https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html
- Godot — exportação pela linha de comando: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Briefing de redesign Neo-Vanguard/Neo-Grid fornecido pelo usuário nesta conversa: referência de intenção; números de balanceamento e prioridades são propostas operacionais desta versão do prompt.
- Vídeo conceitual fornecido pelo usuário: `gemini_generated_video_5f8c45ac.mp4`; inspeção visual por amostras, usada somente como direção de arte e apresentação.
- Referências visuais reapresentadas pelo usuário: `gemini_generated_video_5f8c45ac(1).mp4` e as quatro imagens listadas na seção 6.8. Elas substituem o vídeo simplificado do assistente como critério de aparência.

Nota: este arquivo é o prompt de execução. O jogo e o executável serão produzidos pela sessão do Codex que executar as instruções com acesso ao projeto local.
