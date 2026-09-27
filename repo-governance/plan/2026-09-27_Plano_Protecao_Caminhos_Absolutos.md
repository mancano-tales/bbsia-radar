---
tipo: Plano
titulo: "Reduzir o risco de publicar caminhos absolutos de máquina"
issue: 1
status: EM EXECUÇÃO
criado: "2026-09-27 10:53"
concluido: null
autor_humano: "Tales Mançano"
aprovacao_autor: "Aprovado no chat em 2026-09-27: opção A como mitigação, sem garantia literal"
agentes:
  orquestrador: "Codex / GPT-6 / desktop"
  executor: "Codex / GPT-6 / desktop"
  auditor: null
tarefas:
  - { desc: "WP0 — autor escolher a mitigação e aprová-la", issue: null, status: concluido, data: "2026-09-27" }
  - { desc: "WP1 — ampliar o detector e conectá-lo aos hooks locais", issue: null, status: concluido, data: "2026-09-27" }
  - { desc: "WP2 — adicionar Actions e tornar o status check obrigatório no GitHub", issue: null, status: pendente, data: null }
  - { desc: "WP3 — documentar operação, limites e resposta à detecção", issue: null, status: concluido, data: null }
relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"]
news: ["NEWS.md"]
---

# Plano: reduzir o risco de publicar caminhos absolutos

> **Issue relacionada: #1.** A execução está registrada no TODO. A sessão não conseguiu consultar ou comentar a issue porque o token do gh está inválido e a conexão com a API foi bloqueada; o autor deve levar o anúncio a ela.

## Objetivo

Reduzir a chance de caminhos absolutos de máquina serem incluídos em alterações versionadas. Esta rodada adota verificações locais e um status check em pull requests. A abordagem é uma mitigação contra acidentes, não uma garantia de que toda publicação em qualquer ref ou cópia pública será bloqueada.

## Decisão do autor (2026-09-27)

No chat, o autor aprovou a opção A: uma proteção simples para diminuir a probabilidade de erro, sem criar um fluxo privado de publicação nem exigir uma garantia literal.

### Opção A — hooks locais e checagem de PR

Um detector compartilhado verifica linhas adicionadas em qualquer arquivo. O pre-commit verifica o conteúdo staged; o pre-push verifica os commits ainda não enviados; o GitHub Actions executa o mesmo detector nos commits de um pull request. Os controles locais só funcionam nos clones em que os hooks estão ativados. Para bloquear o merge, o GitHub precisa exigir o status check e pull requests na branch principal.

Se um push sem hook enviar uma branch pública, o Actions só poderá apontar o problema depois que o push ocorrer. Excluir a branch depois não desfaz a publicação.

### Opção B — fluxo privado para as refs do repositório principal

Uma área privada de preparação e um publicador controlado poderiam reduzir ainda mais a exposição nas refs mantidas pelo projeto, mas exigiriam configuração e operação adicionais. Isso também não controlaria cópias e forks públicos. Esta opção não foi escolhida.

### Opção C — pre-receive no GitHub Enterprise Server

Um hook administrado na instância GHES pode rejeitar conteúdo antes da atualização das refs daquela instância. Esta alternativa não se aplica ao GitHub.com usado pelo projeto e não foi escolhida.

## Estado observado

- O hook anterior verificava somente linhas adicionadas ao stage, excluía hooks/ e tools/ e aceitava uma isenção.
- Um workflow de pull request pode verificar conteúdo antes do merge, mas não antes do push para uma branch pública.
- O GitHub documenta rulesets para proteger branches e tags públicas; push rulesets por caminhos são limitados a repositórios privados ou internos nos planos aplicáveis.
- A regra que torna um check obrigatório é uma configuração do repositório no GitHub e não pode ser registrada apenas pelo arquivo de workflow.
- Na primeira tentativa, a sessão não pôde acessar a issue nem alterar regras do repositório: gh informou que o token estava inválido e a conexão à API foi bloqueada. A autenticação OAuth foi restabelecida depois.
- O PR #19 foi integrado. Revisões prévias independentes por Gemini Pro e GPT-Sol confirmaram quatro falhas no scanner e nos diffs de merge; as correções estão nesta execução.
- A integração GitHub retornou HTTP 403 na tentativa inicial de comentar a issue #1 e criar o PR. Após autorização OAuth do autor, o `gh` CLI autenticou e a atualização foi publicada na issue #1.
- Os commits 6216a8f, 060500c e 3b6cbc7 estão publicados na branch codex/1-revisao-caminhos-absolutos. O merge 5257e2a integrou `main`, resolvendo o conflito de `NEWS.md`; o PR #21 está `MERGEABLE`/`CLEAN`, sem merge. O workflow `Verificar caminhos absolutos` passou. O CodeRabbit retornou PASS, com revisão manual indicada para este repositório OSS. A exigência do status check continua pendente.
- `news_db.py`: 36 entradas, nenhuma sem commit identificável e 34/36 mensagens declaradas coincidentes. As duas divergências em entradas históricas das issues #8 e #1 são anteriores a esta branch; o verificador usa o conteúdo da entrada no commit que a criou. Nenhum commit publicado foi reescrito.
- A revisão posterior também encontrou variantes file: com/sem host ainda não cobertas, referências web relativas ao esquema confundidas com UNC e o fallback do pre-push sem diff de merge de primeiro pai. O scanner e o hook agora incluem esses casos.
- A revisão final do GPT-Sol encontrou um falso positivo quando `file://host` em string era seguido de URL relativa; o limite de autoridade e o parser UNC agora param em aspas e delimitadores.
- Revisões finais independentes de GPT-Sol e Gemini Pro sobre o diff após essa correção: sem achados acionáveis.
- Validação direcionada: `bash -n`, fixtures positivos/negativos para URIs, UNC, escapes, aspas, `+++`, URLs e stress de linha longa; scanner sobre o diff completo e `git diff --check` passaram.

## Escopo aprovado

1. Usar um scanner comum nos hooks locais e no workflow para linhas adicionadas em diffs textuais de qualquer arquivo. Ele reconhece drives Windows, inclusive em URI file: sem autoridade ou com host e em literais com separadores escapados; UNC com barras invertidas (também em literais escapados); e raízes Unix locais comuns (home, Users, root, tmp, workspace e montagens), inclusive dentro de URI file:. A busca mantém o contexto da linha original; linhas adicionadas que começam com +++ continuam sendo verificadas. Hooks e workflow também inspecionam o diff de primeiro pai de commits de merge. Referências web relativas ao esquema com barras normais não são tratadas como UNC. Não pretende reconhecer todo caminho Unix possível nem inspeciona arquivos binários. Não há diretórios excluídos nem marcador de isenção. A saída revela apenas o caminho relativo do arquivo e o número da linha, nunca o conteúdo detectado.
2. Instalar pre-commit e pre-push em hooks/, manter os arquivos com LF no Windows e ativá-los neste clone.
3. Adicionar um workflow para pull requests. A configuração remota que exige o check e restringe integração à branch principal a pull requests fica pendente até o acesso ao GitHub estar disponível.
4. Atualizar as instruções e registrar a execução neste plano, no TODO e no NEWS.
5. Não reescrever histórico publicado nesta rodada.

## Critério de conclusão

O detector local e o workflow passaram na checagem do PR #21. O plano permanece ativo até o autor revisar/mergear o PR e tornar o status check obrigatório nas regras do GitHub.

## Fontes oficiais

- [Regras disponíveis em rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets) — proteção de branches/tags e disponibilidade dos push rulesets.
- [Eventos que acionam workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows) — execução dos workflows no evento de push.
- [Hooks pre-receive no GitHub Enterprise Server](https://docs.github.com/en/enterprise-server%403.20/admin/enforcing-policies/enforcing-policy-with-pre-receive-hooks) — hooks na instância Enterprise Server.
