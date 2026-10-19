# Rastreabilidade — nenhum marco aprovado

Origem: prompt v3.1. AC-01 a AC-25 correspondem à matriz da seção 9.
Os cenários são requisitos de teste, não testes executados.

| Requisito | Marco | Teste/aceitação | Evidência existente ou necessária |
| --- | --- | --- | --- |
| R00 acesso/preservação | M0 | Origem acessível, inventário SHA-256 antes de intervir | ambiente.json: origem inacessível; bloqueado |
| R01 REA | M0 | Versão, doctor/providers, investigação compatível com alvo | comandos_rea.json e 3 Evidence objdump: parcial, só MAME |
| R02 pipeline | M0 | Base executável e export Windows precoce | Godot --version apenas; build não executado |
| R03 contratos visuais | MV | AC-21, 8 critérios da seção 6.9, duas capturas e 10 s reais | Referências completas e cena ausentes |
| R04 GPU/reflexos | MV/M2 | AC-22, SSR 3 variantes, fantasma/fora de tela, p95/p99 | Não executado |
| R05 menu/início | MV/M1 | AC-01, duplo clique e navegação | Não executado |
| R06 movimento | MV/M1 | AC-02/11, curvas, paredes, túneis, 30/60/144 FPS | Não executado |
| R07 inimigos/vidas | MV/M1 | AC-03/14, matriz de estados, captura única, ordem temporal | Não executado |
| R08 progressão | M1 | AC-04, três fases, todos itens alcançáveis | Não executado |
| R09 pausa/foco | MV/M1 | AC-05, relógios congelados e retomada explícita | Não executado |
| R10 escala/câmera | MV/M2 | AC-06, 720p/1080p, oblíqua/superior, sem corte | Não executado |
| R11 áudio | M1/M2 | AC-07/18, mudo/ausência/BPM sem alterar regras | Não executado |
| R12 persistência | M1 | AC-08, fechar/reabrir e corrupção | Não executado |
| R13 empacotamento | M0/MV/M1/M2/M3 | AC-09, offline sem admin, recursos independentes do cwd | Não executado |
| R14 estabilidade | M1/M2/M3 | AC-10, sessão real ≥20 min, memória | Não executado |
| R15 dash | MV/M1 | AC-12, energia limítrofe, parede, contato relativo, coleta | Não executado |
| R16 topologia/portais | MV/M1 | AC-13, grafo válido e ocupação, adiar/cancelar | Não executado |
| R17 Ghost Train/Flow | MV/M1 | AC-15, limites e resets, sem multiplicação recursiva | Não executado |
| R18 Time Attack | M2 | AC-16, 3 e 5 min, pausa/vidas/recordes | Não executado |
| R19 Rogue | M2 | AC-17, ≥200 sementes, fallback deliberado, upgrades | Não executado |
| R20 multiplayer | M3 | AC-19, coop e versus completos | Não executado |
| R21 regressão | M1/M2/M3 | AC-20, sem vazamento de regras entre modos | Não executado |
| R22 input M3 | M3 | AC-23, lógica e teclado físico, remap/conflitos/foco | Não executado |
| R23 câmera/HUD M3 | M3 | AC-24, extremos, vistas, custo extra sem simulação dupla | Não executado |
| R24 checkpoints estáveis | M1/M2/M3 | AC-25, extrair pacotes M1/M2, versão/hash/partida | Não executado |

Ordem obrigatória: M0 → MV → M1 → M2 → M3. Não abrir expansão enquanto
MV não cumprir a direção visual e as evidências exigidas. Não há aprovação
implícita por uma tabela ou por conseguir inspecionar um PE do emulador.
