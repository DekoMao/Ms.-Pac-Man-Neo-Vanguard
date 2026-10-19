# Comparação visual do MV — parcial

Referências do kit v3.2 conferidas por hash: as quatro imagens e o vídeo Gemini.
Inspeção do vídeo por amostras em 0,5, 4,5 e 8,5 s e imagens de dash,
vulnerabilidade/Flow. A imagem de abertura também foi examinada na conversa.
Nenhuma dessas imagens foi apresentada como captura do nosso motor.

Capturas próprias: `entrega/capturas/NeoGrid_real_02s.png`, `..._07s.png`,
`..._4500ms.png`; comparações controladas `comparacao_*` são fixtures paradas,
não outra gravação de gameplay. Vídeo real: `NeoGrid_Gameplay_Real_10s.mp4`.
Ambiente: Godot 4.6.3, Linux, Xvfb, Vulkan/Forward+, llvmpipe. Qualidade Alta.

| Critério da seção 6.9 | Estado | Evidência/limite |
| --- | --- | --- |
| Volume e acabamento dos personagens | Parcial | Malhas 3D suaves, boca recortada animada, olhos e laço; modelagem/expressão e resposta de luz ainda menos refinadas que o conceito |
| Fantasmas translúcidos | Parcial | Domos/saia e olhos volumétricos, transparência e animação reais; sobreposição/ordenação e leitura contra todas as paredes precisam de revisão em GPU |
| Piso/material/reflexos | Parcial | Reflexos dinâmicos por geometria espelhada, inclusive fantasmas; são estilizados, sem fidelidade física integral; faltam ensaios isolados de clipping/offscreen e custo |
| Neon/cor/iluminação | Parcial | Paredes com volume/chanfro e materiais diferentes; paleta ciano/magenta/roxo; glow presente, mas contraste e exposição diferem do Gemini |
| Profundidade e escala da câmera | Parcial | Perspectiva próxima, seguimento e minimapa; vista superior da mesma cena; bordas/retorno após morte e transparência de obstáculos precisam de homologação jogada |
| Partículas/rastro | Parcial | Fita dourada e partículas em espaço 3D ligadas a dash/coleta/captura/topologia; densidade, continuidade e variedade menores que o conceito |
| Legibilidade HUD | Atendido no cenário capturado | PT-BR, pontos/vidas/Flow/energia ligados ao estado real, sem overlays de player; legibilidade em todos os cenários/resoluções Windows pendente |
| Estabilidade durante curvas/dash | Parcial | A gravação mantém a cena contínua, curvas e dash reais; software lento não comprova fluidez/ausência de artefatos em GPU alvo |

A abertura é um menu próprio sobre cena 3D, com skyline decorativo, e não
recria ainda a composição completa de gabinetes/fogos da imagem de abertura.
Não copiar textos deformados ou ícone de reprodução. Isso é diferença explícita,
não declaração de equivalência visual. Nenhuma porcentagem estética foi inventada.

MV **não recebeu aprovação integral da direção visual**. Fontes, vídeo e EXE
permitem revisão real. O projeto não voltou ao desenho 2D/isométrico rejeitado;
a expansão M1–M3 permanece suspensa no gate visual/performance/homologação.
