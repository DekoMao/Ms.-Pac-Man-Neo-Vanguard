# NeoGrid 0.8 — Circuito Vivo

Arcade 3D para Windows que preserva o visual neon aprovado da 0.5 e acrescenta:

- Capturas com quatro níveis sonoros, faíscas e animações expressivas.
- Frutas móveis opcionais, com tempo limitado, recompensa e marcador próprio.
- **Circuito de seis áreas**, 18 medalhas e 18 extras de habilidade.
- Escolha de melhoria temporária entre áreas: escudo, ímã ou dash.
- **Overdrive de três minutos**, recorde próprio e revanche imediata.
- **Trem Fantasma**, modo cronometrado com seguidores em cadeia, limitado a oito.
- **Colosso** ao fim do Circuito: rotas anunciadas, núcleos e pulsos táticos.
- Teclado e suporte a controle com zona morta. Diagnóstico opcional local.

A protagonista fica parada até o primeiro comando. Túneis, casa de regeneração,
Flow, música, mapa e contador de itens obrigatórios foram preservados. A fruta
móvel não impede completar a área. O visual clássico orienta o layout; o cenário
continua metálico, ciano/magenta, com piso polido e câmera em perspectiva.

Extraia o ZIP e execute `MsPacMan_Aperfeicoado.exe`. O jogador não precisa de Godot
ou Python. C alterna visão superior/perspectiva; M abre o mapa com pausa.
WASD/setas movem; Espaço dash; E escudo; R ímã (fase 2+); Q aposta; F pulso do Colosso.
No controle: direcional/analógico, X/A/Y/LB/RB, Start pausa, Back mapa.

## Reconstrução e evidências

Godot 4.6.3 stable, templates oficiais 4.6.3.stable e Python 3.10+:

```bash
python scripts/build.py --godot godot
```

O builder exige sete suítes, realiza smoke, exporta Windows, aplica ícone/versão e
abre o PCK embutido no motor do host fora das fontes. **340 verificações aprovadas.**
Capturas reais em Linux/X11, Forward+/Vulkan por software. Execução Windows,
controle físico, GPU física e equilíbrio com jogadores ainda estão pendentes.

- [Regras completas e condições de validação](docs/CIRCUITO_VIVO.md)
- [Teste no Windows e relatório local](docs/VALIDACAO_WINDOWS.md)
- [Direção visual aprovada da 0.5](docs/DIRECAO_VISUAL_NEON.md)
- [Histórico](CHANGELOG.md)
- [Créditos e licenças](docs/CREDITOS_E_LICENCAS.md)

Save migrado sem perder medalhas anteriores. O recorde do Circuito de três fases
fica arquivado em Recordes; os três modos novos usam placares separados. Não há
telemetria em servidor. Implementação própria, sem ROMs/MAME. Entregas anteriores
preservadas; binários, caches e credenciais ficam fora da branch de fontes.
