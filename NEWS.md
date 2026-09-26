# NEWS — bbsia-radar

Log intelectual do projeto: decisões e o porquê delas. Entrada nova no topo; nada é reescrito. Toda entrada de agente termina com os Metadados de Execução (ver `AGENTS.md`).

## 2026-09-26 11:03 — Criação do repositório

O autor, voluntário no Banco Brasileiro de Soluções de IA (BBSIA, Enap/LIIA com Ibict e CIIA), combinou com Eunice Liu, da coordenação, uma primeira versão de um mapeamento automático de soluções de IA brasileiras, adaptadas ao pt-BR ou de interesse público adaptáveis, publicadas no GitHub e no Hugging Face e ainda ausentes do banco. Critério de maturidade combinado: "todos os TRLs".

Decisões desta rodada, do autor:
- **nome `bbsia-radar`**, depois de descartar `bbsia-mapeamento-ia-brasil` (a sigla já diz "IA" e "Brasil") e alternativas como `bbsia-varredura` e `bbsia-garimpo` (a palavra lembra o garimpo ilegal, ruim num projeto com o setor público);
- **privado** até haver um piloto para apresentar à coordenação;
- **coordenação por issues**: agentes anunciam na issue o que vão fazer e como antes de começar, reivindicam a vez com o rótulo `em-andamento` e comentam com frequência; todo plano tem uma issue aberta junto, e o `.md` é o contrato estruturado que cita a issue.

A concepção no `README.md` e no plano é **provisória**: foi escrita sem acesso ao site do BBSIA, que a rede do contêiner de nuvem bloqueava (assim como o Hugging Face). Campos do formulário, uso da escala TRL, API ou envio em lote e termos de uso ficam para a issue #2, com um agente que tenha acesso à rede. O plano vem do `mancano-repo-hub` (`repo-governance/plan/2026-09-26_Plano_Mapeamento_Solucoes_IA_Brasileiras_BBSIA.md`), adaptado para cá.

Do template do ecossistema vieram a trava de comandos git destrutivos (`tools/guard-git-command.*` + `.claude/settings.json`), o exportador de conversas e o gerador de changelog. O `hooks/pre-commit` é novo e sem dependências: exige `NEWS.md` no mesmo commit e recusa caminho absoluto de máquina.

**Metadados de Execução**:
- **Data/Hora**: 2026-09-26 11:03 (Horário de Brasília; relógio do contêiner em UTC, convertido)
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1
- **Mensagem do Commit**: "chore: cria o repositorio com governanca e o plano do piloto"
- **Arquivos afetados**: `AGENTS.md`, `CLAUDE.md`, `README.md`, `NEWS.md`, `TODO.md`, `.gitignore`, `.claude/settings.json`, `.github/ISSUE_TEMPLATE/plano.md`, `.github/ISSUE_TEMPLATE/tarefa.md`, `.github/pull_request_template.md`, `hooks/pre-commit`, `tools/guard-git-command.sh`, `tools/guard-git-command.py`, `tools/export_conversa.R`, `tools/render-changelog.R`, `repo-governance/plan/README.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `repo-governance/llm-reviews/README.md`, `R/`, `scripts/`, `config/`, `data/`, `report/`, `tests/` (`.gitkeep`)
