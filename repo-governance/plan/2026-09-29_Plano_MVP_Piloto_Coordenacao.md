---
tipo: Plano
titulo: "MVP do radar para a coordenação do BBSIA: piloto revisado de ~30 soluções, publicado no site"
issue: 28
status: EM EXECUÇÃO
criado: "2026-09-29 13:44"
concluido: null
agentes:
  orquestrador: "Claude Code / Claude Opus 5.5 / desktop"
  executor: "Claude Code / Claude Opus 5.5 / desktop; Codex / GPT-6 Sol (coleta, revisões)"
  auditor: "Codex no GitHub (@codex review) para PRs do Claude; Claude para PRs do Codex"
autor_humano: "Tales Mançano"
tarefas:
  - { desc: "WP-A — Auditoria independente dos merges #27, #26, #18 e #25", status: concluido, data: "2026-09-29" }
  - { desc: "WP-B — Decifra: external_id na importação CSV/XLSX e nos resultados (decifra-text-as-data#4)", status: pendente, data: null }
  - { desc: "WP-C — Rodada de coleta do piloto: nova descoberta + enriquecimento de até 40 documentos (Sol)", status: pendente, data: null }
  - { desc: "WP-D — Codebook e série: casos de aceitação comportamentais e eventos longitudinais", status: pendente, data: null }
  - { desc: "WP-E — Corpus → Decifra → Radar com Antigravity (Gemini 3.8 Flash)", status: pendente, data: null }
  - { desc: "WP-F — Revisão humana do piloto pelo autor (planilha de recodificação)", status: pendente, data: null }
  - { desc: "WP-G — TRL provável por metadados e planilha no formato do formulário", status: pendente, data: null }
  - { desc: "WP-H — Site: reescrita dos textos, marca com aviso, descrição do repo e publicação no Pages", status: pendente, data: null }
  - { desc: "WP-I — Guia de agentes via CLI (agy, codex, claude) e proposta de padrão no hub", status: pendente, data: null }
relacionados:
  - "repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md (WP5–WP8)"
  - "repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md (#14)"
  - "repo-governance/plan/2026-09-27_Plano_Website_Quarto.md (#17)"
  - "repo-governance/plan/2026-09-28_Plano_Codebook_Publico_e_Serie_Longitudinal.md (#24)"
  - "decifra-text-as-data#4"
---

# MVP do radar para a coordenação do BBSIA

> **Issue: #28.** Este plano coordena, até a entrega do MVP, os planos do piloto (#1), da coleta (#14),
> do site (#17) e do codebook (#24). Não os substitui: cada entrega também é registrada no plano de
> origem.

## 1. O que é o MVP

Um piloto de cerca de 30 soluções de IA brasileiras ou adaptadas ao português do Brasil, descobertas
no GitHub, no Hugging Face e no GitLab.com, classificadas pelo Decifra contra o codebook e **revisadas
pelo autor**. O piloto é entregue de duas formas:

1. uma planilha com as colunas do formulário do BBSIA, a estimativa de maturidade (TRL provável) e a
   evidência de cada campo;
2. o site público do projeto (GitHub Pages), com o método, os resultados agregados e as fichas
   revisadas, sob o aviso de que se trata de proposta independente de um voluntário.

Só entram no site e na planilha registros revisados pelo autor. Os demais candidatos continuam no
cache externo.

## 2. Decisões do autor (chat, 2026-09-29)

1. **MVP:** piloto revisado, **público no GitHub Pages** ("pode publicar"). O aviso de proposta
   independente já existe no site. Esta autorização cobre ativar `PAGES_PUBLISH_APPROVED` e publicar o
   site com os textos reescritos e, depois, o piloto revisado.
2. **Textos do site:** reescrever pelo Claude, sem o jargão de IA da versão atual, de acordo com a
   concepção do projeto; atualizar a descrição do repositório no GitHub.
3. **Marca do BBSIA:** pode aparecer no site se o aviso for apropriado ("Eu não acho que tem problema a
   marca do BBSIA estar dentro do Site se o disclaimer estiver apropriado"). Isso substitui a decisão 9
   do §13 do plano do piloto (marca desativada até decisão da coordenação). Execução: a marca
   acompanha o aviso e não se apresenta como identidade oficial do site.
4. **Coleta:** enriquecer e fazer novas descobertas, delegando ao GPT-6 Sol enquanto o Claude avança
   no resto. Os tetos da rodada (§4, WP-C) são proposta do orquestrador dentro dessa autorização; o
   autor pode vetá-los.
5. **Classificação:** Decifra em modo CLI com o Antigravity (`agy`, Gemini 3.8 Flash); o GPT-6 Luna
   pelo Codex é alternativa aceita.
6. **Guia de agentes via CLI:** ampliar `repo-governance/agentes-gemini.md` para cobrir Antigravity,
   Codex e Claude, e depois propor onde padronizar (hub, skill ou repositório próprio).
7. **Revisão de código:** todo PR do Claude recebe `@codex review` no GitHub antes do merge.
8. **Merges:** o agente pode mergear os próprios PRs e os do Codex quando os checks estiverem verdes e a revisão cruzada não tiver achado bloqueante pendente ("pode mergear você mesmo").
9. **Português europeu:** documentação que declara só pt-PT dá `ptbr = nao`, não `incerto` ("pt-PT explícito deve ser nao"). Aplicado no codebook v0.2.2 (PR #31).
10. **Agrupamento (2026-10-03):** variantes da mesma família viram uma solução (Aira-2, Sabiá, BERTimbau), em `config/solucoes_piloto.yml`: os 13 artefatos incluídos viram 8 soluções.
11. **Publicação com rótulos (2026-10-03):** publicar já o piloto; os rótulos `e_ia`, `brasileira` e `ptbr` saem como revisados pelo autor, e tipo, área, TRL e resumo do problema como proposta da máquina, não revisada.
12. **Adjudicação Aira-2 (2026-10-03):** `ptbr` sim → não nos três modelos, que declaram inglês no card; `brasileira = sim` se mantém. A planilha original do autor fica intacta; a adjudicada fica ao lado, no cache.
13. **Classificar todos os candidatos (2026-10-03):** o piloto leu só 40 dos 379; o autor decidiu ler e classificar todos antes de apresentar. Token fino só de leitura de repositórios públicos, criado pelo autor e guardado em `BBSIA_RADAR_GITHUB_TOKEN` (o `GITHUB_PAT` geral continua nunca herdado). O documento enviado ao Gemini ganha o contexto do GitHub: releases, contribuidores e perfil de organizações; de pessoas físicas, nada além do login.
14. **Modelo e paralelismo (2026-10-03):** "pode até manter no low", com chamadas paralelas e intervalo aleatório. Validação nos 39 do piloto contra o gabarito do autor: κ 0,94 (IA), 0,70 (brasileira) e 0,87 (pt-BR), sem falhas, em cerca de 10 minutos; o Low foi adotado.
15. **Protocolo de revisão da rodada completa (2026-10-03):** o autor revisa todos os documentos que a máquina propõe incluir mais uma amostra aleatória de cerca de 30 dos demais, embaralhados e às cegas. Só o que o autor confirmar é publicado.
16. **Fichas (2026-10-03):** publicar trechos curtos de evidência (até 300 caracteres, com link) e revisar os demais campos (tipo, área, TRL e resumo) das soluções incluídas.
17. **Tarefas fora do radar** (autorizações inválidas; inventário dos repositórios do MancanoSync):
   sessões separadas.

## 3. Ordem e caminho crítico

```
WP-B (Decifra external_id) ─┐
WP-C (coleta, Sol) ─────────┼─> WP-E (classificar) ─> WP-F (autor revisa) ─> WP-G (TRL + planilha) ─> WP-H (piloto no site)
WP-D (codebook/série) ──────┘
WP-H parte 1 (textos, marca, publicação inicial) e WP-I correm em paralelo.
```

O único passo que depende do tempo do autor é o WP-F. Tudo antes dele pode avançar sem perguntas.

## 4. Pacotes de trabalho

**WP-A — Auditoria dos merges (concluído).** Parecer na issue #24, com evidências. Nenhuma regressão
bloqueante; as melhorias entram nos WPs abaixo.

**WP-B — `external_id` no Decifra.** O banco do Decifra já tem `DocumentRecord.external_id` (usado pela
interoperabilidade com o QualiLab). Falta: parâmetro opcional `id_column` em `POST /corpora/csv` e
`/corpora/xlsx`, recusa de IDs vazios ou repetidos, e `external_id` em `/runs/{id}/results`,
`/runs/{id}/export` e na importação de rótulos-ouro, com teste de ida e volta. O trabalho é feito no
repositório do Decifra, com plano e issue de lá, em PR do Claude revisado por `@codex review`.

**WP-C — Rodada de coleta do piloto (delegada ao Sol).** Branch `codex/14-coleta-piloto` em worktree
próprio. Transformar os tetos fixos da amostra exploratória (25 tentativas, 10 documentos, uma página
do HF) em parâmetros de uma rodada declarada em `config/rodadas/`, com tetos máximos de **150
tentativas HTTP e 40 documentos**, e criar `scripts/01_coletar.R`. Nova descoberta: contas-semente do
Hugging Face ainda não conferidas em `config/seeds.yml` (conferir a existência antes de usar),
tópicos GitHub `portuguese-nlp`, `brazilian-portuguese` e `pt-br` cruzados com termos de IA, e as três
contas GitHub já verificadas. Enriquecimento estratificado por plataforma. Tudo no cache externo, sem
e-mail, com testes offline. O Claude revisa o PR.

**WP-D — Codebook e série longitudinal (plano #24, WP2–WP3).** Casos de aceitação comportamentais:
`brasileira` com um e com dois sinais médios, só português europeu (`so_pt_pt`), multilíngue genérico
que inclui português. Série: ordem cronológica das rodadas, reaparição com conteúdo alterado,
ausências repetidas e 404 separados de encerramento.

**WP-E — Classificação.** Corpus com `external_id` persistente e documentos cortados para caber no
limite de linha de comando do Windows no modo `arg` do `agy` (cerca de 32 mil caracteres por prompt),
com o corte registrado. Classificar no Decifra com `agy` e Gemini 3.8 Flash; registrar o commit do
Decifra, o modelo e a versão do codebook. Os resultados voltam ao radar por `external_id`, nunca por
posição.

**WP-F — Revisão humana.** O Claude prepara uma planilha de recodificação com os ~30 candidatos
(evidência, proposta da máquina oculta na primeira passada) para o autor codificar `e_ia`,
`brasileira` e `ptbr`. Nenhum rótulo humano é inventado. Com um só codificador, o relatório declara que
não há kappa entre pessoas; mede-se o classificador contra os rótulos do autor (precisão, recall, F1).

**WP-G — TRL e planilha.** TRL provável por metadados (faixas 1–3, 4–6 e 7–9 do plano do piloto, §9),
marcado como estimativa, mais `ativo` (push em 12 meses). Planilha no formato de
`config/formulario_bbsia.yml`, com os campos que só o responsável pode responder marcados como
`nao_verificavel_publicamente`. Deduplicação: sem exportação do catálogo, o relatório declara a
limitação; nenhuma raspagem do BBSIA.

**WP-H — Site.** Parte 1 (já): reescrever índice, proposta, método e relatório em linguagem direta;
ativar a marca junto ao aviso; ampliar a checagem de marca do CI para refletir a decisão; atualizar a
descrição do repositório; ativar `PAGES_PUBLISH_APPROVED` e publicar. Parte 2 (após WP-G): integrar os
resultados revisados.

**WP-I — Guia de agentes via CLI.** Reescrever `repo-governance/agentes-gemini.md` como guia de
Antigravity, Codex e Claude via CLI (comandos, modelos permitidos, modos somente leitura e escrita,
quando delegar). Depois, propor ao autor o destino padrão (hub `mancano-repo-hub`, skill ou repositório
próprio) e a regra `@codex review` no bloco comum do hub.

## 5. Limites

- Nada é enviado ao BBSIA. Nenhum dado do catálogo do BBSIA é coletado.
- Só registros revisados pelo autor vão a público; os 104 candidatos exploratórios não são publicados
  como lista.
- Sem e-mail e sem dado pessoal além do nome público do dono do repositório.
- Commits com `Agent:` e `Refs:`; sem `NEWS.md`; sem editar `deprecated/`; merge sem force-push.

## 6. Registro

- 2026-09-29 — Plano criado pelo Claude a pedido do autor, com as decisões do §2 tomadas no chat.
