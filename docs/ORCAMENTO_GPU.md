# Orçamento e observações de renderização

| Item | Observado |
| --- | --- |
| Motor | Godot 4.6.3 estável oficial |
| Host | Linux x86_64, X11 em Xvfb 1280×720 |
| Dispositivo | llvmpipe (LLVM 19.1.7, 256 bits), renderizador por CPU |
| Backend real | Vulkan 1.4.305 / Forward+ confirmado no startup |
| GPU física/VRAM | Não disponíveis/não medidas; não são valores zero |
| Preset da gravação | Alta, 1280×720, MSAA 2×, glow/SSAO/SSR |
| Duração do filme | 240 frames a 24 FPS = 10 s, produzidos offline |
| Perfil de 60 FPS | Não aprovado; software está muito abaixo da meta |

`runtime_movie.json` contém p95/p99 de intervalos reais entre frames após
2 s simulados de aquecimento, além de dispositivo, resolução e eventos.
`gameplay_movie.log` traz as medidas agregadas do Movie Maker. O campo
`gpu_time_ms` do relatório próprio é null: não se inferiu medição GPU separada
por frame. As estatísticas do renderer software não são um benchmark de GPU
física nem garantem requisitos mínimos de hardware. Compilação inicial de
shaders e tarefas concorrentes do host podem afetar esses números.

## Técnica e limites

O piso usa camada escura parcialmente transmissiva sobre fundo opaco e
geometria de personagens espelhada em Y, atualizada com transformações e
animação. Isso produz reflexos estilizados de opacos e translúcidos e não
depende de o fantasma aparecer no SSR. Os materiais espelhados têm opacidade
reduzida e não emitem sombras. SSR/SSAO acrescentam acabamento aos materiais
opacos; não se afirma que SSR resolve transparências ou objetos fora da tela.

Não é ray tracing ou captura planar física. Sobreposição de múltiplas camadas
transparentes, interseção com paredes, elementos fora de tela e limites de
clipping ainda precisam de comparação controlada e medição. O acabamento
reflexivo principal é classificado parcial, não aprovado automaticamente.

Baixa preserva todas as malhas/câmeras/reflexos estilizados e reduz partículas,
SSR/SSAO e atlas de sombra. Média usa SSR até 16 passos; Alta, 32. O método
obsoleto environment_set_ssr_roughness_quality foi removido após o motor
avisar que não fazia efeito; não se descreve esse controle como funcional.
A sequência de fixtures comparou Alta/Baixa e a vista superior no mesmo host.

## Ensaio pendente para homologação

Executar em GPU física a mesma rota/semente por ≥60 s após aquecimento,
SSR desligado/meia resolução/resolução completa quando a API da versão permitir;
registrar o parâmetro real. Testar protagonista opaca, parede emissiva,
fantasma translúcido e saída de objetos pela borda da tela, com técnica
complementar ligada/desligada. Comparar transparências no pior momento de
Flow/captura, presets, CPU e GPU separadas, p95/p99. Não somar diretamente
CPU/GPU como previsão de FPS. A meta inicial segue 16,67 ms por frame,
CPU 6 ms e GPU 13,5 ms como hipóteses a calibrar, não medições desta entrega.
