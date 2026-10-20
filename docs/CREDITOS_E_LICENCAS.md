# Procedência

- Rodada 0.2: novos sinais de risco, pressão e Power e camadas musicais de 112 BPM
  sintetizados por `scripts/generate_action_audio.py`, sem áudio de terceiros.
  WAVs e código gerador incluídos nos fontes. A referência Gemini permanece
  identificada em `referencias/` e é excluída do executável de distribuição.

- Código GDScript/Python/PowerShell e malhas procedurais: implementação própria
  produzida neste trabalho. Personagens, paredes, reflexos, ícone e HUD não
  reutilizam sprites/ROMs do original.
- Efeitos e música: síntese original offline, PCM WAV, loop de 112 BPM;
  nenhum áudio comercial ou de MAME/ROM foi inserido.
- Godot 4.6.3: MIT; licença e inventário de terceiros oficiais em `licencas/`.
  O executável inclui o motor; as licenças acompanham o pacote portátil.
- DejaVu Sans: fonte instalada no host e copiada com seu aviso de licença em
  `licencas/DejaVu_copyright.txt`. Usada para interface portátil legível.
- REA 6.7.0: ferramenta de inspeção local MIT; não integrada ao jogo.
- Mesa/Xvfb/FFmpeg: ferramentas do host para renderização/captura, não
  distribuídas dentro do executável/ZIP portátil.
- Referências Gemini: fornecidas pelo usuário no kit v3.2, preservadas no
  pacote-fonte para comparação. Não são texturas de jogo nem evidência do motor.
- `mspacman.zip` e MAME: anexos do usuário inventariados separadamente.
  Nenhum binário, ROM, licença ou lógica de jogo foi atribuído ao produto novo.

Os nomes e conceitos do briefing não atribuem licenças de terceiros ao novo
código. A licença do REA não licencia jogos analisados. Não houve contorno
ou remoção de proteção de licença nem publicação/distribuição pública.


A versão 0.8 acrescenta seis sinais sonoros originais sintetizados por
`scripts/generate_reward_audio.py`. A trilha aprovada anterior foi preservada.
Fruta móvel, seguidores e Colosso reutilizam malhas procedurais próprias.


A 0.9 usa o projeto MauricioSuporte/Super-Bomberman-6-Unity como benchmark
de mecanicas, commit 79bffa5accfd519f9be40235b1353fd4502d9493. Nao incorpora
codigo, sprites, cenas ou audio daquele projeto. Bombas, caches e explosoes
foram reimplementados em Godot; efeitos sonoros originais sao sintetizados
por scripts/generate_fusion_audio.py. Analise e links em FUSAO_BOMBER_CHASE.md.
