# TODO — bbsia-radar

> **Append-only.** Itens nunca são apagados: concluídos são **movidos** para o topo de "Concluído". Todo item tem data+hora de criação (Brasília) e quem criou; ao concluir, data+hora e quem concluiu. Cada item cita a issue (`#N`) quando houver: o TODO é o índice curto, a issue é a conversa, o plano é o detalhe.
>
> **Pendente** = pronto para ser trabalhado. **Prospectivo** = identificado, mas falta decisão ou dependência. **Concluído** = feito.

## Pendente
- [ ] **Revisar e integrar as correções do parecer Claude no #23** — PR #26 aberto a partir de `codex/24-claude-findings`; revisão cruzada pelo Claude solicitada. O autor pediu a abertura como exceção temporária ao limite de três PRs.
  - Criado: 2026-09-29 por Codex / GPT-6 / desktop.
  - Referências: issue #24; parecer no PR #23; issue do hub #42.

- [ ] **Revisão cruzada e integração dos hooks de governança** — PR #23; branch `codex/1-governance-hooks` permanece aberta para revisão do Claude, checks, merge e remoção da branch depois da integração.
  - Criado: 2026-09-28 por Codex / GPT-6 / desktop
  - Motivo: o código deste repo entra por PR; o commit e o push já passaram pelos hooks atualizados sem exceções.
  - Referências: issue #1; plano do hub #37; PR #23.

- [ ] **Proteção contra publicação acidental de caminhos absolutos** — manter as verificações locais e a checagem de PR; falta tornar o status check obrigatório no GitHub.
  - Criado: 2026-09-27 10:53 por Codex / GPT-6 / desktop
  - Progresso 2026-09-27: a proposta foi aprovada no chat pela opção A, como mitigação simples. O scanner compartilhado, os hooks locais e o workflow de pull request estão no branch codex/1-protecao-caminhos-absolutos, baseado na main remota atualizada.
  - Próximo passo: o autor deve levar o anúncio à issue #1 e reautenticar o gh para configurar e exigir o status check no GitHub. Esta sessão não conseguiu acessar a API.
  - Plano ativo: repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md · Issue: #1


- [ ] **Issue #14 — analisar e revisar a amostra exploratória limitada** — coleta inicial concluída nas APIs GitHub, Hugging Face e GitLab.com; concluir o fluxo Decifra, estimar TRL, validar manualmente e comparar com o BBSIA antes de publicar qualquer resultado.
  - Criado: 2026-09-27 09:30 por Codex / GPT-6 / desktop
  - Progresso 2026-09-27: os controles de orçamento e validação offline foram integrados pela PR #16 em `main` (`c1835b1`); a suíte offline passou. Nenhuma coleta real foi feita. A rodada aguarda termos GitHub, conta HF e raiz de cache aprovados pelo autor.
  - Progresso 2026-09-27 16:15: o autor aprovou no chat GitHub/GitLab `Transcritorio` e `BERTimbau`, HF `neuralmind`, até 25 tentativas reservadas e dez documentos; inclusão GitLab implementada na branch `codex/14-gitlab-radar`, suíte offline com 166 testes aprovada e cache externo validado. A coleta exploratória limitada foi iniciada.
  - Atualização 2026-09-27 17:27: amostra coletada: 104 URLs únicas (GitHub 101, GitLab 1, HF 2), dez documentos selecionados e 17/25 tentativas reservadas. A busca BERTimbau do GitHub ficou parcial (100/134); a suíte offline atual passou com 181 testes após revisão de segurança/cache. Dados e relatório ficam fora do git. Decifra, TRL, revisão humana, comparação com o BBSIA e publicação continuam pendentes.
  - Atualização 2026-09-27 19:48: revisão final confirmou a correção de expiração HTTP-date no cache; suíte offline passou com 183 testes, zero falhas e zero avisos de teste.
  - Progresso 2026-09-27 (rodada GitHub/HF registrada após a PR #20): 103 candidatos GitHub e 2 modelos HF; dez documentos selecionados, todos GitHub, e 16/23 tentativas reservadas. Nenhum model card HF foi lido. Este resultado é de uma rodada distinta da amostra ampliada com GitLab descrita acima.
  - Coordenação: a PR #20 atualizou a issue #14 sobre a rodada GitHub/HF; o marco da rodada GitLab não pôde ser publicado nesta sessão (API retornou 403 e gh sem autenticação válida).
  - Atualização 2026-09-27 20:28: a integração com as mudanças recentes de main preservou a busca de sementes curadas e a cobertura GitLab; suíte offline combinada passou com 212 testes. Revisões finais Gemini/GPT-Sol e abertura do PR continuam pendentes.
  - Plano ativo: `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md` · Issue: #14

- [ ] **Decifra: requisitos do caso de uso bbsia-radar** — terminar o R1.1 (passo 3 em diante) e os outros itens da issue aberta no `decifra-text-as-data`; desenvolvido lá.
  - Criado: 2026-09-26 12:29 por Claude Opus 5.5 (decisão de Tales Mançano: o radar produz o corpus, o Decifra classifica)
  - Issue: #6 (aqui) e a issue correspondente no Decifra
- [ ] **Autor: configurar credenciais na máquina** — `GITHUB_PAT` (token fino, só leitura de repositórios públicos) e `HF_TOKEN` (leitura) no `.Renviron` local; nunca no repositório.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Issue: #1
- [ ] **Autor: acompanhar codebook v0.1.1 e as sementes** — seis casos-limite e protocolo inicial aprovados em chat (issue #9); dois casos ainda dependem de alinhamento com o BBSIA. Revisar a divisão radar × Decifra registrada no plano §8 (decidida em 2026-09-26, issue #6) e decidir se o teste com o catálogo do BBSIA entra no piloto.
  - Criado: 2026-09-26 11:45 por Claude Opus 5.5
  - Progresso 2026-09-26 (Claude Opus 5.5): autor confirmou o Transcritório (usa Whisper e o modelo Tagarela) e informou que não cadastrou nada à mão no BBSIA.
  - Issues: #3, #4, #6, #9 · PR #5
- [ ] **Sementes curadas** (`config/seeds.yml`): listas awesome de NLP em português, `awesome-open-source-research-tools` do autor, organizações conhecidas do Hugging Face e do GitHub (cada uma conferida antes de entrar), soluções que o autor já cadastrou à mão (ex.: o transcritor com Whisper). Servem também de gabarito para medir o recall dos coletores.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Progresso 2026-09-26 11:45 (Claude Opus 5.5): v0.1.0 em `config/seeds.yml`, com 3 listas, 7 soluções no gabarito, 3 contas GitHub com existência conferida e 6 do Hugging Face não conferidas; `instituicoes` vazia.
  - Issue: #4 · Plano §6

## Prospectivo
- [ ] **WP3–WP4 — ampliar coletores e enriquecimento após a amostra exploratória** — as funções de descoberta e enriquecimento já existem; a execução em volume depende da revisão dos resultados da issue #14 e dos limites acordados no plano do piloto.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Progresso 2026-09-27: a PR #13 implementou os coletores, a PR #16 limitou a rodada e a PR #20 acrescentou três sementes brasileiras. A coleta GitLab e a seleção com uma vaga por plataforma estão na branch `codex/14-gitlab-radar`; ampliar depende da revisão de qualidade.
  - Plano §6–§7
- [ ] **Website e relatório público em Quarto (HTML + PDF)** — o site está em implementação na PR #18; depois que os dados da amostra passarem por classificação e revisão humana, automatizar a publicação no GitHub Pages a partir das saídas aprovadas.
  - Criado: 2026-09-27 10:52 por Codex / GPT-6 / desktop
  - Plano aprovado no chat em 2026-09-27 e em implementação: `repo-governance/plan/2026-09-27_Plano_Website_Quarto.md` · Issue: #17 · PR: #18
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
- [x] **Autor: ativar o hook de pre-commit no clone local** — o diretório hooks está configurado como hooksPath.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Concluído: 2026-09-27 12:52 por Codex / GPT-6 / desktop
  - Verificação: a configuração local core.hooksPath já apontava para hooks neste clone.
  - Issue: #1


- [x] **Conversor do codebook para o formato do Decifra e exportador do corpus** (WP4/WP5) — `codebook_para_decifra()` gera o contrato YAML e `salvar_corpus_decifra()` exporta um texto citável por solução em CSV.
  - Criado: 2026-09-26 12:29 por Claude Opus 5.5
  - Concluído: 2026-09-27 00:41 por Codex / GPT-6 / desktop
  - Issue: #6, #10 · PR #13

- [x] **WP0c — leitura ampliada das páginas públicas do BBSIA** — inventário e limites documentados no README e no plano; Judiciário/CNJ/Sinapses excluído por decisão do autor, e nenhum dado do catálogo foi coletado em massa.
  - Criado: 2026-09-26 23:37 por Codex
  - Concluído: 2026-09-27 00:08 por Codex / GPT-6 / desktop
  - Issue: #1 · Plano §3 WP0c

- [x] **WP2 — versão inicial do codebook** (`config/codebook.yml`) — v0.1.1 registra os critérios e os casos-limite aprovados; dois pontos continuam como dependência de alinhamento com o BBSIA e são acompanhados no item de revisão acima.
  - Criado: 2026-09-26 11:03 por Claude Opus 5.5
  - Concluído: 2026-09-26 23:34 por Codex / GPT-6 / desktop
  - Issue: #3 · Plano §5

- [x] **Autor: aprovar o plano de coleta exploratória limitada** — aprovado no chat o plano e o recorte inicial somente com sementes de `config/seeds.yml`; módulos adjacentes do BBSIA ficam fora desta rodada. A issue #12 segue aberta para decisão futura.
  - Criado: 2026-09-27 08:40 por Codex / GPT-6 / desktop
  - Concluído: 2026-09-27 09:24 por Codex / GPT-6 / desktop (aprovação de Tales Mançano no chat)
  - Plano: `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md` · Issues: #12, #14

- [x] **Documentar execução do Antigravity CLI `agy` para pesquisa e revisão Gemini** — `AGENTS.md` aponta para o guia com comandos, modelos observados, ferramentas web e de delegação, limites e regra atual de uso exclusivo do Gemini 3.8 Flash.
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
