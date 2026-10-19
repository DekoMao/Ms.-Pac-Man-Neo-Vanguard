# Ms. PAC-Man: Neo-Grid — ação 0.2.0

A base aprovada foi preservada em `fontes/mv-base-20261019`, commit
`f28df2ff46465d1a3df88d343b258f5d3c0348e5`. Esta branch refina o mesmo MV:
perseguição anunciada, resposta de dash/escape, reversão para caça, capturas/Flow
e uma aposta opcional por fase. Não acrescenta modos nem multiplayer.

Leia [mudanças e comparação](docs/REFINO_ACAO.md) e [validação atual](docs/VALIDACAO.md).
Abra `project.godot` no Godot **4.6.3**. Para importar, testar as três suítes,
exportar Windows e verificar o pacote embutido no host:
`python scripts/build.py --godot godot`. Inicialize os diretórios XDG graváveis
como indicado abaixo se o HOME do ambiente for somente leitura.

**Q durante Power:** aposta opcional de 20E por duas capturas na mesma janela.
**Configurações:** intensidade de câmera 0–100%; zero desativa impulsos/FOV,
e “Reduzir efeitos e movimento” também elimina partículas, anéis e piscadas.

As seções abaixo registram a preparação da base 0.1. A homologação nativa
Windows e o desempenho em GPU física continuam pendentes. A base foi aprovada
pelo usuário; a rodada 0.2 aguarda sua avaliação.

## Histórico da base 0.1

Demonstrador 3D próprio em Godot 4.6.3, produzido a partir do prompt v3.2 e
referências do kit. **Entrega parcial**: cena/regras/PE/vídeo existem; aprovação
visual completa, desempenho em GPU física e execução nativa Windows pendentes.
M1–M3 não foram iniciados. Nenhuma ROM ou instalação MAME é necessária.

## Jogar

No Windows x64, extraia `MsPacMan_Aperfeicoado_Windows_x64.zip` e abra
`MsPacMan_Aperfeicoado.exe`. Controles e limitações em `LEIA-ME.txt`.
Nesta máquina foi exercitado o conteúdo do EXE pelo motor Linux; o PE não foi
executado nativamente. O arquivo não tem assinatura de código.

## Desenvolver e reconstruir

Editor: **Godot 4.6.3 stable**. Templates: **4.6.3.stable**, instalados pelo
editor ou release oficial. O builder confere a versão e falha explicitamente
se importação, testes ou exportação não completarem. Python 3.10+ é necessário
somente para desenvolvimento/build; nenhum pacote Python externo é exigido.

```text
python scripts/build.py --godot godot
```

No Windows, também existe `scripts/build_windows.ps1`; o wrapper PowerShell
não foi executado neste host Linux. O equivalente Python foi executado.
Não altere permanentemente a política global de execução do PowerShell.

Neste sandbox Linux, a execução testada usa os diretórios graváveis já preparados:

```bash
cd /workspace/NeoGrid
XDG_CONFIG_HOME=/workspace/toolchains/config \
XDG_CACHE_HOME=/workspace/toolchains/cache \
XDG_DATA_HOME=/workspace/toolchains/data \
python3 scripts/build.py --godot godot
```

O script importa/parsa, executa 39 testes de regras e 14 de cena/input,
exporta o PE, insere ícone/versão sem Wine e testa o PCK embutido em diretório
com espaço/acento. Resultados antigos são removidos antes de cada suíte,
e o builder exige JSON novo com testes efetivamente executados.

Para executar os testes separadamente, no mesmo ambiente inicializado:

```text
godot --headless --path . --script res://tests/test_rules.gd
godot --headless --path . --script res://tests/test_integration.gd
```

Para abrir no editor: `godot --editor --path .`. Para jogar com renderização:
`godot --path .`. Cada tarefa já é isolada; use o checkout/workspace existente,
sem criar Git worktree a menos que solicitado.

## Captura reproduzível usada nesta máquina

O Xvfb foi iniciado localmente, sem TCP, com
`/workspace/toolchains/graphics/usr/bin/Xvfb :95 -screen 0 1280x720x24 -nolisten tcp`.
O ICD local aponta para a biblioteca Mesa verificada dos pacotes Debian;
nenhum componente gráfico é dependência do pacote Windows.

```bash
DISPLAY=:95 VK_DRIVER_FILES=/workspace/toolchains/graphics/lvp-local.json \
XDG_CONFIG_HOME=/workspace/toolchains/config \
XDG_CACHE_HOME=/workspace/toolchains/cache \
XDG_DATA_HOME=/workspace/toolchains/data \
godot --path /workspace/NeoGrid --audio-driver Dummy \
  --write-movie /tmp/NeoGrid_Gameplay.avi --fixed-fps 24 --quit-after 240 \
  -- --demo --capture-dir=/workspace/NeoGrid/entrega/capturas \
  --report=/workspace/NeoGrid/evidencias/runtime_movie.json
```

Transcodificação do arquivo inteiro, sem cortes, para MP4 H.264/AAC:

```text
ffmpeg -i /tmp/NeoGrid_Gameplay.avi -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart NeoGrid_Gameplay_Real_10s.mp4
```

Xvfb é um processo a reiniciar; não deve ser presumido ativo em outra sessão.
A captura offline não comprova 24/60 FPS em tempo real. Não há preview web.

## Organização e evidências

- `scenes/`: cena principal e atores 3D; `scripts/`: simulação, apresentação,
  UI, persistência e build; `assets/`: configuração e recursos próprios.
- `tests/`: suítes reais e fixture gráfica de comparação (não gameplay).
- `docs/`: GDD implementado, roadmap, validações, limites, créditos e retomada.
- `evidencias/`: resultados JSON/logs e hashes do código capturado/exportado.
- `referencias/`: arquivos Gemini preservados para revisão; excluídos do EXE.
- `entrega/`: EXE/ZIP, MP4 real, capturas e manifesto de entregáveis.
- `licencas/`: licenças Godot/terceiros e DejaVu.

A fonte não inclui `.godot`, templates, caches ou ROMs. Instale as versões
compatíveis antes de reconstruir em outra máquina. Veja `docs/RETOMADA.md`.
