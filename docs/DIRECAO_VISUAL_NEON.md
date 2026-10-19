# NeoGrid 0.5 — direção visual e partida sob comando

A 0.4 interpretou a referência ao clássico como apresentação gráfica e usou uma
visão geral ortográfica com blocos escuros e contornos finos. O usuário rejeitou
esse resultado. Esta revisão usa como referência principal o conceito retangular
com paredes metálicas, painéis ciano/magenta, corredores escuros polidos e câmera
oblíqua. A geometria é implementada no motor; as imagens enviadas pelo usuário
não são sobrepostas à cena nem usadas como telas falsas.

## Arquitetura e leitura

- Faces expostas recuam em relação à célula de colisão, formando paredes visuais
  mais estreitas. Células adjacentes permanecem ligadas; o grafo jogável é preservado.
- Fachadas têm tampo, base, moldura, painel emissivo, montantes e aletas de serviço.
  As peças opacas de cada parede são agrupadas por material com MultiMesh.
- Piso opaco metálico com SSR no Forward+, marcas de rota e gradientes de luz no chão.
  Esses gradientes são efeitos artísticos, não medições de iluminação volumétrica.
- Perspectiva próxima acompanha a protagonista; C alterna para visão superior de
  toda a área. Paredes diante da protagonista reduzem a altura para evitar ocultá-la.
- Casa de regeneração com pilares e anel luminoso; túneis laterais continuam ativos.
- Corpo dos fantasmas recebe brilho de contorno; olhos, boca de medo e retorno
  somente com olhos conservam as regras anteriores.
- Base da arena e cidade ganham detalhes. HUD e menus permanecem fora dos corredores.

Não é uma reprodução pixel a pixel dos conceitos. Labirintos circulares e
passarelas em múltiplos níveis não foram acrescentados nesta correção. Os três
mapas retangulares, túneis, progressão, poderes, Flow e áudio são preservados.

## Início sem disparada

A causa era `reset()` criar a protagonista com direção RIGHT, mesmo sem tecla.
Agora toda reinicialização cria direção ZERO. O primeiro comando direcional
legal estabelece a direção imediatamente, inclusive quando seguido de dash no
mesmo quadro. Espaço isolado não inicia movimento nem consome energia.

A cena aguarda a primeira direção para avançar o relógio e liberar os fantasmas
em cada fase. Reiniciar limpa a pilha de teclas; avançar de fase também começa
parado. Após perder vida, o respawn continua parado até nova direção.
Uma vez iniciado o movimento, segue a condução arcade contínua já existente.

## Evidências e limites

O builder exige 215 verificações: 52 de regras/persistência, 51 de integração,
27 de ação, 16 de mapa, 36 de circuito e 33 de túneis/casa/interface.
Os testes de cinco segundos parado nas três fases isolam inimigos para testar
movimento; a integração também verifica a espera do relógio e da casa na cena.

As imagens `evidencias/neon_*_050.png` foram capturadas diretamente no motor,
Linux/X11, Forward+/Vulkan, llvmpipe. O script `tests/capture_neon.gd` documenta
as condições: fase pausada na abertura, quatro segundos de rota automatizada
com inimigos ativos, fases 2/3, inspeção central, visão superior e menu.
A inspeção central reposiciona a protagonista para observar a arquitetura;
a imagem de ação usa movimento e eventos reais das regras. Não são testes humanos.

Exportação Windows x64 com PCK embutido e recursos de versão/ícone. O conteúdo
embutido é aberto pelo motor Linux fora da pasta de fontes. Isso não equivale a
executar o PE no Windows. Execução nativa, desempenho em GPU física e validação
visual pelo usuário permanecem pendentes; nenhuma taxa de quadros é prometida.
