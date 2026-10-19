# Diagnóstico executado — M0 parcial

## Escopo e evidência de acesso

Prompt v3.1 lido integralmente: 453 linhas, 59.650 bytes. A cópia está em
`prompt/`, com SHA-256 em `evidencias/inventario_acessivel.json`.
Esta máquina é Debian/Linux x86_64, não Windows nem uma sessão local
com acesso ao computador do usuário. Verificações de existência retornaram
falso para `D:\Ms PACMan`, `/mnt/d/Ms PACMan` e `/mnt/d`.
Veja `evidencias/ambiente.json`.

Não existe inventário da pasta original: ela não foi lida. Não se conclui
que essa pasta não existe no computador do usuário. Também não foi criado
um caminho Linux com aparência de `D:\...` para simular o destino solicitado.
O repositório acessível `DekoMao/Ms.-Pac-Man-Neo-Vanguard` permanece sem
commits ou arquivos de projeto; consulta remota não anunciou refs.

## REA e ferramentas

- Repositório oficial consultado: https://github.com/morluto/rea.
- Commit consultado: `e4c3d72396bf925a45724ce8b18b238b0d23d787`.
- Versão do package.json consultado e do pacote npm: 6.7.0.
- CLI efetivamente executada: `rea-agents@6.7.0`, via npm exec com cache
  isolado em `/tmp/rea-npm-cache`.
- Node 24.19.0, npm 11.9.0, GNU objdump 2.44, libarchive 3.7.4.
- Java informa OpenJDK 21.0.12.1; isso não confirma JDK completo. O diagnóstico
  do REA relata runtime-only e instalação Ghidra ausente.
- Documentação consultada: README, installation, CLI, native-investigation,
  windows-ghidra-p0 e reverse-engineering-tools, no commit acima.
- Não se pressupõe paridade de todos os recursos de main com o npm;
  somente os comandos realmente executados foram verificados no pacote publicado.

`doctor --client codex --json` saiu com **1**: registro Codex ausente,
classificado `config_drift`. Os checks de Ghidra/Hopper/IDA indisponíveis
aparecem como informativos nesse escopo. Isso não impede a CLI objdump,
que foi usada com sucesso. `providers --json` saiu com **0** e reportou
provedores de decompilação não configurados. Nenhum alvo de jogo foi aberto.

`setup --client codex --skill=false --dry-run --json` saiu com **0**, status
`planned`. Apenas a prévia foi executada; nenhuma integração foi aplicada,
nenhum arquivo de configuração foi substituído e nenhum novo MCP ficou
disponível nesta sessão. Não houve chamada `binary_session`, pois essa
ferramenta não está exposta no cliente. A retomada deverá usar o setup oficial.

## Inventário dos anexos acessíveis, separado da origem

| Arquivo | Observação |
| --- | --- |
| `mame0143b_64bit.exe` | 14.822.202 bytes; autoextrator PE i386 com arquivo 7z a partir do offset 162816. Não é a aplicação Neo-Grid. |
| `mame64.sym` anexado | 14.703.231 bytes; tabela ASCII de símbolos MinGW/PE, sem projeto-fonte. |
| `mame64.exe` extraído do pacote | 74.190.775 bytes; PE32+ AMD64 nativo, 17 seções. Não confundir com o anexo direto, que não pôde ser transferido. |
| `docs/mame.txt`, `docs/license.txt` internos | Identificam MAME, necessidade de imagens de jogos separadas e licença histórica do pacote. Cópias em `licencas_mame_observadas/`. |
| `roms/dir.txt` interno | Única entrada de arquivo sob `roms` no pacote; nenhum conjunto de ROMs foi encontrado nesse pacote. |

O contêiner tem 44 entradas; listagem integral em `pacote_mame_lista.json`.
Não contém projeto-fonte do jogo. Existem shaders `.fx` de pós-processamento,
que não são o código-fonte de Neo-Grid. Não se infere o conteúdo do RAR ou
do ZIP que não foram transferidos.

`Ms PACMan.rar`, o anexo direto `mame64.exe` e `mame.zip` excederam o limite
de transferência de 32 MiB. Isso não impediu extrair o emulador do autoextrator
menor. Os símbolos extraídos coincidem byte a byte com o `.sym` anexado.

A primeira extração com py7zr 1.1.4 falhou por falta de suporte a BCJ2.
A extração selecionada com libarchive 3.7.4 terminou com sucesso; o cabeçalho
7z foi validado e os executáveis não foram executados. Nenhuma verificação
de integridade foi desativada. Hash identifica os bytes, não prova procedência
autenticada pelo fabricante.

## Inspeção real pelo REA

Para o emulador extraído:

```text
SHA-256 cc9191670ba38b63dfadb34094d32f9d49546c8cfeae0e3cf4c27ddcf17847e0
rea inspect-with-objdump <mame64.exe extraído> file_headers --json
rea inspect-with-objdump <mame64.exe extraído> section_headers --json
```

Ambas as operações saíram com **0**, sem truncamento e com
`artifact_changed=false`. Arquitetura vem da saída bruta `pei-x86-64`;
o campo genérico `subject.format` do REA continua `unknown`. Não foi
reinterpretado como descoberta normalizada do REA.

- Endereço de entrada observado: VA `0x401540`.
- Leitura complementar do cabeçalho PE: Machine `0x8664`, ImageBase
  `0x400000`, RVA de entrada `0x1540`, diretório CLR zerado.
- Seções incluem `.text`, `.data`, `.rdata`, `.idata`, `.rsrc` e DWARF.
- GNU objdump `-p`, salvo integralmente, informa imports como DINPUT,
  DSOUND, GDI32, KERNEL32, USER32, WINMM e msvcrt.
- O autoextrator, separadamente inspecionado pelo REA, é PE i386 com
  entrada `0x41d262`. Sua arquitetura não é a do emulador extraído.

JSONs com IDs de Evidence, parâmetros, hashes antes/depois e resultados
brutos estão em `evidencias/rea-*.stdout.txt`; comandos, working directory,
horário UTC e códigos de saída estão em `comandos_rea.json`.
O parse PE complementar está em `mame64-pe.json` e o dump completo em
`mame64-objdump-private-headers.txt`. Não houve decompilação, recuperação
do projeto original ou execução de partida.

## Motor e decisão pendente

Godot instalado: `4.6.3.stable.official.7d41c59c4`. Templates de exportação
não foram encontrados no diretório padrão consultado. Não há Wine/PowerShell,
DISPLAY/Wayland ou dispositivos `/dev/dri` e `/dev/dxg` nesta sessão.
Forward+, SSR, driver e desempenho não foram testados; ausência de dispositivo
não é medição de um renderizador por software. Exportação cruzada Windows
é uma possibilidade do Godot, não foi descartada pela simples ausência de Windows.

Evolução versus reconstrução só pode ser decidida depois de identificar o
jogo real e observar seu comportamento. MAME é emulador/lançador; seu PE
não substitui a ROM nem o conteúdo inacessível da origem.
Nenhuma versão histórica, regra, fase ou controle do jogo foi inferido dos
binários do emulador. A preferência Godot 4/Forward+ é requisito condicional,
não decisão de implementação validada.

## Bloqueios e próxima ação

Principal: sessão sem acesso à origem Windows. Complementares: conjunto
visual obrigatório incompleto; homologação Windows e GPU não disponíveis.
Não existe `.exe` Neo-Grid, ZIP portátil ou gameplay real produzido.
Retomar em sessão local conforme `../RETOMADA_WINDOWS.md`, com origem e
referências acessíveis, preservando o checkpoint e a pasta original.
