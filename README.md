# NeoGrid — MV ação 0.2.0

Refinamento da primeira versão aprovada: o mesmo demonstrador Godot 3D recebe
perseguição progressiva anunciada, resposta audiovisual de dash/escape, reversão
FUGA/CAÇA, capturas/Flow crescentes e uma aposta opcional por fase.

A base está preservada em `fontes/mv-base-20261019`, commit
`f28df2ff46465d1a3df88d343b258f5d3c0348e5`. O ZIP Windows original continua
na branch `entrega/mv-20261019`, commit `c623b5323f21a873ccd1202d1ea50a609eab24ea`.
Não há expansão de modos, multiplayer ou ROMs neste refino.

## Jogar e ajustar

Extraia o pacote Windows inteiro, leia `LEIA-ME.txt` e execute
`MsPacMan_Aperfeicoado.exe`. O jogador não precisa instalar Godot ou Python.

- WASD/setas: mover e antecipar curvas; Espaço: dash (40E).
- Q durante Power com pelo menos 2s restantes e 20E: aposta opcional.
  Duas novas capturas na mesma janela rendem +600 pontos/+35E; uma tentativa por fase.
- C: câmera oblíqua/superior; P/Esc: pausa; F11: tela cheia.
- Configurações: câmera 0–100%; zero desativa impulsos/FOV. “Reduzir efeitos e
  movimento” também elimina anéis, partículas, bobbing e piscadas decorativas.
- Fantasmas que voltaram à cor original já são perigosos, mesmo durante Power.

## Abrir fontes, testar e exportar

Godot **4.6.3 stable**, com templates oficiais da mesma versão. Abra `project.godot`.
Cenas em `scenes/`; regras e malhas/materiais procedurais em `scripts/`;
shaders, WAVs originais e fonte licenciada em `assets/`; perfil Windows x86_64
com PCK embutido em `export_presets.cfg`.

```bash
python scripts/build.py --godot godot
```

O builder importa, executa as três suítes, faz smoke do projeto, exporta e
verifica o PCK do próprio executável em diretório temporário fora das fontes.
Em Windows, também existe `scripts/build_windows.ps1`.

Neste host Linux, o HOME é somente leitura; antes do builder configure:

```bash
export XDG_CONFIG_HOME=/workspace/toolchains/config
export XDG_CACHE_HOME=/workspace/toolchains/cache
export XDG_DATA_HOME=/workspace/toolchains/data
```

Para testar separadamente:

```bash
godot --headless --path . --script res://tests/test_rules.gd
godot --headless --path . --script res://tests/test_action.gd
godot --headless --path . --script res://tests/test_integration.gd
```

O ambiente de cada tarefa já é isolado; use o checkout existente, sem criar
Git worktree a menos que solicitado. Caches `.godot`, credenciais de exportação
ou ambiente, executáveis e vídeos de entrega são excluídos da branch de fontes.
Metadados `.import` são configurações de importação Godot, não caches binários.

## Evidências e limites

**87 verificações aprovadas, zero falhas.** Mais smoke do projeto, do pacote e
replay completo de 45s pelo PCK do EXE, carregado no Godot Linux. A gravação real
contínua tem **45,166667s**, 1084 frames, 1280×720/24fps e áudio AAC; controle
é automatizado, renderer Forward+/Vulkan no llvmpipe. Não é filmagem do Gemini.

A base e o refino receberam a mesma fita de 5400 comandos, fase e condições iniciais.
A gravação coincidiu com a simulação e o PCK: 6500 pontos, 3 vidas, 10 capturas,
2 quase colisões e aposta concluída. Não é avaliação humana ou prova estatística
sobre diversão. Windows nativo, GPU física e desempenho 60fps permanecem pendentes.

- [Mudanças e comparação](docs/REFINO_ACAO.md)
- [Testes e limites](docs/VALIDACAO.md)
- [Reproduzir a captura](docs/CAPTURA_ACAO.md)
- [Créditos e licenças](docs/CREDITOS_E_LICENCAS.md)

O material Gemini em `referencias/` foi inspecionado como direção visual e é
excluído do executável. As capturas e a música entregues são do jogo implementado.
