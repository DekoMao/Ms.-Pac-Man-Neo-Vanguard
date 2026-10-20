# Entregas e integridade

Esta página registra o que está publicado no GitHub e o que foi entregue separadamente. A apresentação do repositório não move branches de fontes nem substitui os binários antigos.

## 1.0 — Apresentação Final

- Arquivo: `NeoGrid_1.0_ApresentacaoFinal_Windows_x64.zip`.
- Tamanho: **43.480.111 bytes**.
- SHA-256: `a7a883b0de28aa197edad125a0d0d3f4e8b8006cfdd97fda0419fca6e97005d1`.
- 33 entradas no ZIP; CRC válido na conferência da entrega.
- Nove resultados de teste no pacote: **485 verificações, zero falhas**.
- O conteúdo embutido foi aberto pelo Godot/Linux fora das fontes; o fluxo vídeo → tutorial → menu foi verificado com o relógio da simulação do jogo em zero.
- Vídeo: 9s, 768×432, 24fps, 216 quadros, Theora embutido no executável.
- [Download pela entrega ChatGPT](https://chatgpt.com/api/library/files/libfile_0e2f8bb1b3108191b69c370ded94c71f/download): requer a conta que recebeu o arquivo. Esse link não concede acesso a outras contas.

**O ZIP e os fontes 1.0 ainda não foram publicados no GitHub.** As imagens de menu e tutorial foram extraídas do pacote verificado. Não se trata de uma Release do GitHub.

## Fontes 0.9 — Fusão / Bomber Chase

- Branch: [`feature/fusao-bomber-20261019`](https://github.com/DekoMao/Ms.-Pac-Man-Neo-Vanguard/tree/feature/fusao-bomber-20261019).
- Commit: [`2e817e04f2dac703e05e29f6b65f155ae4dcc8b0`](https://github.com/DekoMao/Ms.-Pac-Man-Neo-Vanguard/commit/2e817e04f2dac703e05e29f6b65f155ae4dcc8b0).
- [PR #6 em rascunho](https://github.com/DekoMao/Ms.-Pac-Man-Neo-Vanguard/pull/6); não foi integrado por esta atualização visual.
- 445 verificações da entrega anterior; esse código não inclui a abertura 1.0.

## Binários 0.2 — distribuição anterior no GitHub

Arquivos preservados na branch [`entrega/acao-20261019`](https://github.com/DekoMao/Ms.-Pac-Man-Neo-Vanguard/tree/entrega/acao-20261019), no commit `22dfd319e19eefe73d9e2110f7c9c613b191d86a`:

- `NeoGrid_Acao_0_2_Windows_x64.zip`.
- `NeoGrid_Acao_0_2_Fontes.zip`.
- `NeoGrid_Acao_45s.mp4`.
- [Hashes dessa entrega](https://github.com/DekoMao/Ms.-Pac-Man-Neo-Vanguard/blob/22dfd319e19eefe73d9e2110f7c9c613b191d86a/SHA256SUMS.txt).

A 0.2 não contém Fusão, os seis mapas ou a abertura 1.0. O vídeo de 45s é um registro daquela versão, não da versão mais recente.

## MV original

O arquivo `MsPacMan_Aperfeicoado_Windows_x64.zip`, na raiz da página principal, continua sendo o MV original. Não foi reconstruído nem substituído nesta atualização.

- Tamanho: **36.778.905 bytes**.
- SHA-256: `147e588e183df6ccbed05a6487a77ca67ed9f0383417dca80a93275af9add79c`.
- [Texto original da entrega](ENTREGA_MV_ORIGINAL.md).

## Leitura das capturas

| Arquivo visual | Versão | Origem |
| --- | --- | --- |
| `arena-fusao.png` | 0.9 | Captura controlada do motor: explosões em cadeia. |
| `menu-inicial.png` | 1.0 | Menu extraído do pacote final verificado. |
| `tutorial.png` | 1.0 | Tutorial extraído do pacote final verificado. |
| `trem-fantasma.png` | 0.8 | Cena de QA do modo especial. |
| `colosso.png` | 0.8 | Cena de QA do confronto final. |
| `capa-neogrid.svg` | Identidade do repositório | Arte vetorial original; não é captura de gameplay. |

As capturas do motor foram feitas em Linux/Forward+/Vulkan com llvmpipe. Execução nativa Windows, controle físico, GPU física e equilíbrio com jogadores continuam pendentes. Nenhum FPS em GPU física é declarado.
