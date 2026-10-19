# NeoGrid — Circuito Neon 0.3.0

Arcade 3D para Windows com três fases autorais, poderes limitados, nove medalhas
e rastro cosmético desbloqueável. Movimento, música, Flow, contador e mapa ampliado
da versão aprovada foram preservados. Extraia o ZIP inteiro e execute
`MsPacMan_Aperfeicoado.exe`; o jogador não precisa instalar Godot ou Python.

| Fase | Desafio opcional | Tempo-alvo | Itens |
| --- | --- | ---: | ---: |
| Pórtico Neon | Capture 2 fantasmas | 110s | 109 |
| Jardim Iônico | Sem perder vidas | 125s | 112 |
| Reator Solar | Vença uma aposta Q | 140s | 105 |

WASD/setas: mover; Espaço: dash; **E: escudo**; **R: ímã (fase 2+)**;
Q: aposta durante Power; M: mapa/pausa; C: câmera; P/Esc: pausa; F11: tela cheia.

Uma carga por poder por fase. Morte encerra efeitos sem repor cargas.
Cada fase rende medalhas por limpeza, desafio e tempo. Desafios não bloqueiam
o avanço. Medalhas de tentativas diferentes se acumulam; três liberam rastro
turquesa no menu de fases/extras. Avanço carrega pontos e devolve uma vida, até
três. O seletor inicia nova tentativa com zero pontos/três vidas. O save guarda
fases e medalhas, sem retomar partidas interrompidas.

## Fontes e validação

Godot **4.6.3 stable**, templates oficiais **4.6.3.stable**, Python 3.10+:

```bash
python scripts/build.py --godot godot
```

O builder exige cinco suítes, faz smoke, exporta Windows, aplica ícone/versão
e testa o PCK embutido no motor do host fora das fontes.

**163 verificações aprovadas.** Inclui coleta dos três mapas por movimento
automatizado, com inimigos desativados para verificar alcançabilidade.
**Windows nativo, GPU física e equilíbrio com jogadores permanecem pendentes.**
Capturas Linux/Xvfb em Compatibility/llvmpipe não comprovam acabamento Forward+.

- [Regras e evidências da 0.3](docs/CIRCUITO_NEON.md)
- [Correção do mapa 0.2.1](docs/CORRECAO_MAPA.md)
- [Histórico](CHANGELOG.md)
- [Créditos e licenças](docs/CREDITOS_E_LICENCAS.md)

Implementação própria, sem ROMs/MAME. Entregas anteriores preservadas nos commits.
Caches, credenciais e binários ficam fora da branch de fontes.

