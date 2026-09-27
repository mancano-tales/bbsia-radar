# plan/ — Planos de trabalho

Todo plano deste repositório **tem uma issue aberta junto** (rótulo `plano`). O arquivo `.md` é o contrato estruturado e guarda o status oficial; a issue é onde a discussão, os anúncios dos agentes e a coordenação acontecem. Regras completas em [`AGENTS.md`](../../AGENTS.md) § Planos e issues.

## Status

- `PROPOSTO` — submetido ao autor para aprovação; não autoriza a execução das tarefas descritas.
- `ATIVO` — aprovado pelo autor, aguardando ou em execução passiva.
- `EM EXECUÇÃO` — sendo executado agora (a issue tem o rótulo `em-andamento`).
- `PARCIAL` — pausado, com entregas parciais registradas.
- `CONCLUÍDO` — entregue; a issue foi fechada com comentário final.
- `SUPERADO` — substituído por outro plano (link para ele).
- `HISTÓRICO` — referência.

## Cabeçalho YAML

```yaml
---
tipo: Plano
titulo: "Título descritivo"
issue: 0             # número da issue do plano (obrigatório)
status: ATIVO
criado: "YYYY-MM-DD HH:MM"   # horário de Brasília
concluido: null
agentes:
  orquestrador: "Agente / modelo / plataforma"
  executor: null
  auditor: null
autor_humano: "Tales Mançano"
tarefas:
  - { desc: "WP1 — ...", issue: null, status: pendente, data: null }
relacionados: []
news: []
---
```

Logo abaixo do título do documento, a linha `> **Issue: #N.**`.

## Índice

<!-- BEGIN_PLAN_INDEX -->
| Plano | Issue | Status | Executor | O que é |
|---|---|---|---|---|
| `2026-09-27_Plano_Protecao_Caminhos_Absolutos.md` | #1 (relacionada) | EM EXECUÇÃO (criado 2026-09-27 10:53) | Codex / GPT-6 / desktop | Reduzir o risco de incluir caminhos absolutos em alterações versionadas, com hooks locais e checagem de PR. |
| `2026-09-27_Plano_Website_Quarto.md` | #17 | ATIVO (criado 2026-09-27 10:52) | Codex / GPT-6 / desktop | Site Quarto HTML/PDF na PR #18; a amostra foi coletada e a integração dos resultados aguarda Decifra e revisão humana. |
| `2026-09-27_Plano_Coleta_Exploratoria.md` | #14 | EM EXECUÇÃO (criado 2026-09-27 08:40) | Codex / GPT-6 / desktop | Preparar e executar uma amostra limitada do GitHub e Hugging Face usando somente as sementes aprovadas, com orçamento global de requisições, cache externo e documentação oficial. |
| `2026-09-26_Plano_Piloto_bbsia-radar.md` | #1 | ATIVO (criado 2026-09-26 11:03) | Claude Opus 5.5 (Claude Code on the web; desenho) | Piloto do radar: codebook, coletores GitHub e Hugging Face, classificação validada por amostra humana, TRL provável como coluna, deduplicação contra o BBSIA e ~30 soluções para apresentar à coordenação. WP0a (verificar o site do BBSIA) na issue #2. |
<!-- END_PLAN_INDEX -->
