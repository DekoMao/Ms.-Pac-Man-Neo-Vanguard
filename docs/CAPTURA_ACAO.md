# Reproduzir a captura contínua de ação

Requisitos: Godot 4.6.3, renderer Forward+, X11/GPU ou ambiente gráfico compatível,
FFmpeg para transcodificar AVI completo em MP4. Nesta máquina foi usado llvmpipe
com Xvfb, sem GPU física. O jogador Windows não precisa dessas ferramentas.

O Xvfb foi iniciado apenas para este trabalho e não deve ser presumido ativo:

```bash
/workspace/toolchains/graphics/usr/bin/Xvfb :95 -screen 0 1280x720x24 -nolisten tcp
```

Com o checkout em `/workspace/NeoGrid_Refino` e o servidor gráfico disponível:

```bash
DISPLAY=:95 LP_NUM_THREADS=4 \
VK_DRIVER_FILES=/workspace/toolchains/graphics/lvp-local.json \
XDG_CONFIG_HOME=/workspace/toolchains/config \
XDG_CACHE_HOME=/workspace/toolchains/cache \
XDG_DATA_HOME=/workspace/toolchains/data \
godot --path /workspace/NeoGrid_Refino --audio-driver Dummy \
  --write-movie /tmp/NeoGrid_Acao_45s.avi --fixed-fps 24 --quit-after 1120 \
  --script /workspace/NeoGrid_Refino/tests/replay_capture.gd -- \
  --tape=/workspace/NeoGrid_Refino/evidencias/replay_45s.json \
  --capture=/workspace/NeoGrid_Refino/entrega/capturas_acao \
  --report=/workspace/NeoGrid_Refino/evidencias/runtime_acao_45s.json \
  --replay-report=/workspace/NeoGrid_Refino/evidencias/replay_captura_45s.json
```

O driver encerra após 5.400 ticks/45s mais quatro frames para drenar o áudio,
mantendo a última imagem visível. O limite 1120 é uma proteção superior,
não a duração pretendida. O vídeo não é cortado, acelerado ou montado.

```bash
ffmpeg -i /tmp/NeoGrid_Acao_45s.avi -c:v libx264 -crf 20 \
  -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart NeoGrid_Acao_45s.mp4
```

Para a comparação lógica, execute o mesmo runner com `--path` apontando para
cada projeto e `--read-tape` apontando para o mesmo arquivo. O script externo
localiza `rules.gd` e `balance.json` no projeto escolhido. Os arquivos da base
não são modificados para essa comparação. A fita e o runner estão nos fontes.
