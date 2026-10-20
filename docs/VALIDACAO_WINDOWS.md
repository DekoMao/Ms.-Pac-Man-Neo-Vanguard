# Validação nativa no Windows — pendente

Extraia o pacote inteiro. `MsPacMan_Aperfeicoado.exe` roda sem instalar Godot ou
Python. Para guardar diagnóstico local, abra `TESTAR_WINDOWS.cmd`, jogue e feche
pelo menu. O arquivo `validacao_windows.json` é criado na mesma pasta. Nada é
enviado pela rede. Se a pasta não permitir escrita, extraia em outra pasta pessoal.

Verifique no seu computador:

1. A abertura e a troca manual de fase aguardam uma seta/WASD ou direcional.
2. Percorra túneis nos dois sentidos, faça curvas/dash e pause por P/Start.
3. Use M/Back, alterne C, teste perda de foco e retomada sem comandos presos.
4. Compare contador com itens reais. Deixe uma fruta móvel expirar e capture outra.
5. Teste X=dash, A=escudo, Y=ímã, LB=aposta e RB=pulso; analógico solto não pode iniciar movimento.
6. Termine Overdrive/Trem Fantasma ou perca todas as vidas. Recordes devem ser
   separados, e Enter/A deve reiniciar o mesmo modo. Na troca automática de área,
   o relógio acumulado e o movimento já comandado devem continuar.
7. Escolha cada melhoria e confira seu efeito apenas na área seguinte.
8. Conclua a sexta área. Evite a faixa vermelha anunciada, carregue pulsos e use
   F/RB apenas na recuperação do Colosso. Uma carga por ciclo; três acertos vencem.
9. Em Fusao, plante B/B pad, saia e tente reentrar. Confira o pavio de 2,3s,
   aviso no piso, parede bloqueando raios, caches abrindo e cadeia entre bombas.
   Verifique dano proprio, escudo, atordoamento e captura por explosao com Power.
   Colete os pontos escondidos e melhorias; siga de fase e depois use revanche.
10. Observe legibilidade, resposta dos controles, quedas de quadros e volume dos
   efeitos em relação à música. Use a qualidade e a redução de movimento se desejar.

O relatório identifica sistema, renderizador e adaptador e registra p95/p99 de
tempo de quadro. Para avaliar desempenho, compare a mesma resolução/qualidade em
sessões suficientemente longas, sem menus excessivos. Controles físicos, sensação
de resposta e defeitos visuais exigem observação humana; teste automatizado não os
substitui. Esta entrega não declara esses itens aprovados no Windows.
