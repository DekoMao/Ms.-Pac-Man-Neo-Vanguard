# M0 retomado com prompt v3.2

O checkpoint M0 original foi conferido pelos bytes e extraído separadamente
em `/workspace/checkpoints/M0_preservado`; não foi alterado. O ZIP conserva
SHA-256 `0001f1e27cdc4e6b82750d3133aee81ac53182094931358aff6dcebd1ce8a9af`.
GDD, roadmap e diagnóstico anteriores foram reutilizados como documentos
`M0_*`; o prompt v3.2 substitui a condição antiga de parada. Todos os hashes
do manifesto do kit conferiram antes da implementação.

Projeto próprio real: **`/workspace/NeoGrid`**. A origem `D:\Ms PACMan` e
`/mnt/d/Ms PACMan` continuam inacessíveis; nenhum inventário dessa pasta foi
inventado. Essa pendência não bloqueou as fontes, cenas, testes e exportação.
Não há Git worktree novo, push, lançamento ou publicação remota.

## Artefatos novos recebidos

`mspacman.zip` contém 13 entradas binárias (incluindo `pacman.6e`, `5e`, `u5`,
`u6`, `u7` e PROMs). Não é um executável PE ou projeto Godot. É um conjunto
candidato de ROMs: seu conteúdo foi inventariado e teve CRC e hashes lidos,
mas não foi auditado/executado no MAME. Não afirmar validação histórica.

Foi usada a CLI **REA 6.7.0**, já instalada no cache do diagnóstico anterior:

```text
rea inspect-artifact <anexo mspacman.zip> --json
```

A operação terminou com código 0, provedor `rea-artifact-graph`, política de
integridade `fail`, inspeção ZIP concluída. Evidence raiz
`ev_14e821e40716b9e4ee872988b3b2fcbcd26e809e97d9cc91944fd6c48cf83cb4`;
SHA-256 do ZIP `8374fafe9f0053a2e0f6de0b3b62088a0a48cb2115219b9507ddd63145acc131`.
Resultado completo em `evidencias/rea_mspacman_zip.json`; hashes por entrada
em `retomada_v3_2.json`. Nenhuma ROM foi incorporada ao novo projeto ou pacote.

O MAME inspecionado em M0 continua sendo apenas emulador, separado do jogo
novo. A integração MCP/decompilador ausente não foi exigida para o código
próprio, nem o diagnóstico antigo foi repetido sem nova evidência. Documentação
REA oficial consultada em M0: commit
`e4c3d72396bf925a45724ce8b18b238b0d23d787`, versão de pacote 6.7.0.

## Pipeline efetivamente usado

Godot `4.6.3.stable.official.7d41c59c4`, GDScript, cenas e malhas originais.
Os templates `4.6.3.stable` vieram da release oficial godotengine/godot-builds;
o TPZ completo passou pelo SHA-512 oficial antes da extração. URLs e hashes
estão em `evidencias/templates.json`. Nenhuma verificação TLS/checksum foi
removida. A documentação Godot 4.6 foi consultada pelo repositório oficial
GitHub após o domínio de documentação retornar 403.

Foram preparados Xvfb e Mesa localmente com pacotes Debian obtidos de índice
APT assinado em deb.debian.org; nada foi instalado sobre o sistema. O snapshot
Debian configurado inicialmente retornou 403. O mirror oficial foi usado com
listas/cache locais. GPU física continua ausente, mas **Forward+ real iniciou
via Vulkan no llvmpipe LLVM 19.1.7**. Não houve fallback para Compatibility.

O EXE produzido é PE32+ AMD64 GUI, com PCK embutido, ícone próprio e versão
0.1.0.0. Recursos Windows são escritos pelo helper Python sobre espaços de
recursos existentes do export unsigned; tamanho/layout/PCK são preservados.
O pacote embutido foi executado pelo Godot do host fora da pasta fonte,
em diretório temporário com espaço e acento. Isso é teste de conteúdo,
**não execução nativa do PE**. Hash final em `build_artefato.json` e SHA256SUMS.
