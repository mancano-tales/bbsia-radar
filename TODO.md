# TODO — bbsia-radar

> **Append-only.** Itens nunca são apagados: concluídos são **movidos** para o topo de "Concluído". Todo item tem data+hora de criação (Brasília) e quem criou; ao concluir, data+hora e quem concluiu. Cada item cita a issue (`#N`) quando houver: o TODO é o índice curto, a issue é a conversa, o plano é o detalhe.
>
> **Pendente** = pronto para ser trabalhado. **Prospectivo** = identificado, mas falta decisão ou dependência. **Concluído** = feito.

## Pendente

- [ ] **Decifra: requisitos do caso de uso bbsia-radar** — terminar o R1.1 (passo 3 em diante) e os outros itens da issue aberta no `decifra-text-as-data`; desenvolvido lá.
  - Criado: 2026-09-26 12:29 por Claude Opus 5.5 (decisão de Tales Mançano: o radar produz o corpus, o Decifra classifica)
  - Issue: #6 (aqui) e a issue correspondente no Decifra
- [ ] **Conversor do codebook para o formato do Decifra e exportador do corpus** (WP4/WP5) — `config/codebook.yml` → YAML `variables:`; documento por solução com metadados em texto → CSV `id_solucao,text`.
  - Criado: 2026-09-26 12:29 por Claude Opus 5.5
  - Issue: #6 · Plano §7–§8
- [ ] **Autor: configurar credenciais na máquina** — `GITHUB_PAT` (token fino, só leitura de repositórios públicos) e `HF_TOKEN` (leitura) no `.Renviron` local; nunca no repositório.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
- [ ] **Autor: ativar o hook de pre-commit no clone local** — `git config core.hooksPath hooks`.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
- [ ] **Autor: acompanhar codebook v0.1.1 e as sementes** — seis casos-limite e protocolo inicial aprovados em chat (issue #9); dois casos ainda dependem de alinhamento com o BBSIA. Revisar a divisão radar × Decifra registrada no plano §8 (decidida em 2026-09-26, issue #6) e decidir se o teste com o catálogo do BBSIA entra no piloto.
  - Criado: 2026-09-26 11:45 por Claude Opus 5.5
  - Progresso 2026-09-26 (Claude Opus 5.5): autor confirmou o Transcritório (usa Whisper e o modelo Tagarela) e informou que não cadastrou nada à mão no BBSIA.
  - Issues: #3, #4, #6, #9 · PR #5
- [ ] **WP2 — Escrever o codebook** (`config/codebook.yml`): tipos A (brasileira), B (adaptada ao pt-BR), C (interesse público), fora; sinais observáveis; unidade = solução, não repositório.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Progresso 2026-09-26 11:45 (Claude Opus 5.5): v0.1.0 em `config/codebook.yml`, aguardando revisão do autor.
  - Issue: #3 · Plano §5
- [ ] **Sementes curadas** (`config/seeds.yml`): listas awesome de NLP em português, `awesome-open-source-research-tools` do autor, organizações conhecidas do Hugging Face e do GitHub (cada uma conferida antes de entrar), soluções que o autor já cadastrou à mão (ex.: o transcritor com Whisper). Servem também de gabarito para medir o recall dos coletores.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Progresso 2026-09-26 11:45 (Claude Opus 5.5): v0.1.0 em `config/seeds.yml`, com 3 listas, 7 soluções no gabarito, 3 contas GitHub com existência conferida e 6 do Hugging Face não conferidas; `instituicoes` vazia.
  - Issue: #4 · Plano §6

## Prospectivo

- [ ] **WP0c — Leitura ampliada da documentação pública do BBSIA antes dos coletores** — inventariar catálogo, recursos reutilizáveis, fontes de dados, modelos, Judiciário e fichas de prontidão; registrar campos, proveniência, termos e limites; mapear quais objetos cabem no escopo do radar. Sem scraping nem contato com a coordenação nesta etapa.
  - Criado: 2026-09-26 23:37 por Codex
  - Issue: #1 · Plano §3 WP0c

- [ ] **WP3–WP4 — Coletores e enriquecimento** (GitHub e Hugging Face, em R com `gh`/`httr2`, cache em disco). Depende do codebook e das sementes; a coleta em volume roda onde houver rede para o Hugging Face.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Plano §6–§7
- [ ] **WP5 — Classificação e validação humana** (regras + LLM contra o codebook, método do `decifra-text-as-data`; amostra codificada pelo autor, kappa no relatório).
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Plano §8
- [ ] **WP6–WP7 — TRL provável e deduplicação contra o BBSIA**.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Plano §9–§10
- [ ] **WP8 — Piloto de ~30 soluções e apresentação à Eunice Liu**, junto com as perguntas do plano §3 (rascunho de mensagem no §13).
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Plano §11
- [x] **Licenças do projeto** — Apache-2.0 para o código e CC BY 4.0 para materiais originais do projeto; não cobre dados de terceiros ou do BBSIA (issues #8).
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5

## Concluído

- [x] **Documentar execução do Antigravity CLI `agy` para pesquisa e revisão Gemini** — `AGENTS.md` aponta para o guia com comandos, modelos observados, ferramentas web e de delegação, limites e revisão Flash 3.8/Pro.
  - Criado: 2026-09-27 00:01 por Codex / GPT-6 / desktop (pedido do autor no chat)
  - Concluído: 2026-09-27 00:12 por Codex / GPT-6 / desktop
  - Issue: #1 (esta sessão está sem token GitHub válido; o autor deve levar o anúncio e o resultado à issue)

- [x] **Verificar o site e o formulário do BBSIA** — respostas aos sete itens com fontes publicadas na issue #2; README, §§1.1 e 5 do plano, plano WP0a e NEWS atualizados; inspeção técnica de chamadas de rede permaneceu explicitamente inconclusiva.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5 (a pedido de Tales Mançano)
  - Concluído: 2026-09-26 23:37 por Codex
  - Issue: #2 · Plano: `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md` (WP0a)

- [x] **Autor: tornar público ou transferir para uma organização do BBSIA/LIIA** — decidido: **público**, na conta do autor (transferência continua possível depois).
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Concluído: 2026-09-26 por Tales Mançano (no chat), registrado por Claude Opus 5.5
- [x] **Criar o repositório com governança** — `AGENTS.md` (coordenação por issues), `README.md` provisório, `NEWS.md`, `TODO.md`, plano do piloto com issue, `tools/`, `hooks/`, modelos de issue e de PR.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5 (a pedido de Tales Mançano)
  - Concluído: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
