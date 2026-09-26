# TODO — bbsia-radar

> **Append-only.** Itens nunca são apagados: concluídos são **movidos** para o topo de "Concluído". Todo item tem data+hora de criação (Brasília) e quem criou; ao concluir, data+hora e quem concluiu. Cada item cita a issue (`#N`) quando houver: o TODO é o índice curto, a issue é a conversa, o plano é o detalhe.
>
> **Pendente** = pronto para ser trabalhado. **Prospectivo** = identificado, mas falta decisão ou dependência. **Concluído** = feito.

## Pendente

- [ ] **Decifra: requisitos do caso de uso bbsia-radar** — terminar o R1.1 (passo 3 em diante) e os outros itens da issue aberta no `decifra-text-as-data`; desenvolvido lá.
  - Criado: 2026-09-26 por Claude Opus 5.5 (decisão de Tales Mançano: o radar produz o corpus, o Decifra classifica)
  - Issue: #6 (aqui) e a issue correspondente no Decifra
- [ ] **Conversor do codebook para o formato do Decifra e exportador do corpus** (WP4/WP5) — `config/codebook.yml` → YAML `variables:`; documento por solução com metadados em texto → CSV `id_solucao,text`.
  - Criado: 2026-09-26 por Claude Opus 5.5
  - Issue: #6 · Plano §7–§8
- [ ] **Verificar o site e o formulário do BBSIA** (agente com acesso à rede) — campos e quais são obrigatórios, escala TRL, API ou importação por planilha, export do catálogo, termos de uso, filtros e áreas do catálogo. Com fonte para cada resposta; depois, reescrever o `README.md` (seção "A verificar") e os §1.1 e §5 do plano.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5 (a pedido de Tales Mançano)
  - Issue: #2 · Plano: `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md` (WP0a)
- [ ] **Autor: configurar credenciais na máquina** — `GITHUB_PAT` (token fino, só leitura de repositórios públicos) e `HF_TOKEN` (leitura) no `.Renviron` local; nunca no repositório.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
- [ ] **Autor: ativar o hook de pre-commit no clone local** — `git config core.hooksPath hooks`.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
- [ ] **Autor: revisar o codebook v0.1.0 e as sementes** — decisões `proposta` dos casos-limite, limiar de kappa (0,70), tamanho da amostra (100); decidir a integração com o Decifra (issue #6: opções A, B ou C) e se o teste com o catálogo do BBSIA entra no piloto.
  - Criado: 2026-09-26 11:45 por Claude Opus 5.5
  - Progresso 2026-09-26 (Claude Opus 5.5): autor confirmou o Transcritório (usa Whisper e o modelo Tagarela) e informou que não cadastrou nada à mão no BBSIA.
  - Issues: #3, #4, #6 · PR #5
- [ ] **WP2 — Escrever o codebook** (`config/codebook.yml`): tipos A (brasileira), B (adaptada ao pt-BR), C (interesse público), fora; sinais observáveis; unidade = solução, não repositório.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Progresso 2026-09-26 11:45 (Claude Opus 5.5): v0.1.0 em `config/codebook.yml`, aguardando revisão do autor.
  - Issue: #3 · Plano §5
- [ ] **Sementes curadas** (`config/seeds.yml`): listas awesome de NLP em português, `awesome-open-source-research-tools` do autor, organizações conhecidas do Hugging Face e do GitHub (cada uma conferida antes de entrar), soluções que o autor já cadastrou à mão (ex.: o transcritor com Whisper). Servem também de gabarito para medir o recall dos coletores.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Progresso 2026-09-26 11:45 (Claude Opus 5.5): v0.1.0 em `config/seeds.yml`, com 3 listas, 7 soluções no gabarito, 3 contas GitHub com existência conferida e 6 do Hugging Face não conferidas; `instituicoes` vazia.
  - Issue: #4 · Plano §6

## Prospectivo

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
- [ ] **Autor: licença do repositório** — decidir antes de tornar público (MIT ou Apache-2.0 para o código; CC BY 4.0 para a planilha de candidatos, se o BBSIA concordar).
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
- [ ] **Autor: tornar público ou transferir para uma organização do BBSIA/LIIA** — depois de apresentar o piloto.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5

## Concluído

- [x] **Criar o repositório com governança** — `AGENTS.md` (coordenação por issues), `README.md` provisório, `NEWS.md`, `TODO.md`, plano do piloto com issue, `tools/`, `hooks/`, modelos de issue e de PR.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5 (a pedido de Tales Mançano)
  - Concluído: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
