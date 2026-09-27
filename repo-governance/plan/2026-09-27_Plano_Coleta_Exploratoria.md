---
tipo: Plano
titulo: "Coleta exploratória limitada nas APIs do GitHub e Hugging Face"
issue: 14
status: EM EXECUÇÃO # aprovado pelo autor no chat em 2026-09-27
criado: "2026-09-27 08:40"
concluido: null
autor_humano: "Tales Mançano"
aprovacao_autor: "2026-09-27 no chat: aprovou o plano e o recorte da primeira rodada somente com sementes de config/seeds.yml; módulos adjacentes do BBSIA ficam fora desta coleta. Em seguida, delegou a definição da raiz local de cache fora do checkout."
planos_relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"]
issues_relacionadas: [1, 10, 12]
---

# Plano: coleta exploratória limitada

> **Issue: #14.**

## Objetivo

Verificar, com uma amostra pequena e reproduzível, se os coletores do radar conseguem descobrir
candidatos úteis nas APIs oficiais do GitHub e do Hugging Face. A rodada deve testar consultas,
cache, privacidade e qualidade dos metadados; não é a coleta do piloto de 30 soluções nem uma
submissão ao BBSIA.

## Estado observado em 2026-09-27

- O PR #11 está integrado em `main`.
- O PR #13, da issue #10, foi integrado durante a preparação desta proposta no merge
  `94bad301563c153e4be64cba3cc9b99e2b52203c`; a issue #10 foi fechada. A implementação dos
  coletores está disponível, mas ainda precisa de limites explícitos para uma amostra pequena.
- A documentação aprovada foi integrada pela PR #15 no commit `fa7c5e5462808ee6ead0ae977809ecab7cefc5d1`.
- A implementação dos limites foi integrada pela PR #16 em `main` no commit
  `c1835b1d6d126420bb85636dae9b28eafa9e1bb3`; a suíte offline cobre orçamento compartilhado,
  paginação, seleção determinística, cache externo, respostas vazias, erros HTTP e bloqueios de itens
  privados.
  Nenhuma consulta de candidatos foi executada.
- A issue #12 continua sem decisão sobre o uso dos módulos adjacentes do BBSIA como contexto ou
  sementes.
- Antes desta implementação, os coletores do PR #13 podiam percorrer vários termos, páginas e contas;
  a listagem HF cobria três tipos de artefato, sem orçamento global. A branch atual substitui esse
  caminho exploratório por chamadas explicitamente limitadas e compartilhadas por orçamento.
- O autor aprovou este plano no chat em 2026-09-27, limitado nesta primeira rodada às sementes atuais
  de `config/seeds.yml`; módulos adjacentes do BBSIA ficam fora. A aprovação está registrada aqui;
  a issue #12 continua aberta para decisões futuras sobre esses módulos.
- A issue #14 permanece aberta para implementar e revisar a inclusão das soluções brasileiras da
  lista curada e então executar a primeira amostra com os parâmetros já aprovados no chat.
- A pedido do autor no chat, a raiz externa foi definida como `%USERPROFILE%/AppData/Local/Mancano`,
  criada e verificada como gravável. `MANCANO_BBSIA_RADAR_ROOT` está configurada no `.Renviron`
  local, ignorado pelo Git; `.data-source` acrescenta `bbsia-radar/api`. O resolvedor
  `radar_validate_cache_root()` confirmou que fica fora do checkout e pode ser escrita. O caminho
  absoluto da máquina não é publicado.
- O autor aprovou no chat os termos de busca GitHub `Transcritorio` (slug do repositório
  Transcritório) e `BERTimbau`, e a conta de modelos HF `neuralmind`. Também autorizou incluir as
  soluções da lista global do autor que já estão marcadas como brasileiras no gabarito:
  Transcritório, Open Notebook e QualiLab. Os três registros já existem em `config/seeds.yml`.
  Nenhuma chamada de descoberta foi feita até esta revisão.

## Escopo proposto para a primeira rodada

1. Usar as sementes já mantidas em `config/seeds.yml`. A lista
   `awesome-open-source-research-tools` é global; desta fonte, incluir somente os três itens que já
   têm a marca `brazil` no campo `fonte`: Transcritório, Open Notebook e QualiLab. Não percorrer a
   lista inteira nem consultar módulos do BBSIA para ampliar esta amostra.
2. Pesquisar o GitHub com no máximo dois termos escolhidos entre os nomes/artefatos já registrados
   nas sementes, uma página por termo e sem varredura de contas. Cada página tem teto de 100
   resultados; não seguir paginação nem subdividir automaticamente consultas grandes nesta rodada.
3. Consultar apenas `models` no Hugging Face, para uma conta já listada em `config/seeds.yml`, com
   uma página de até 100 resultados. A própria resposta confirma a conta se retornar modelos; se vier
   vazia, registrar que o endpoint não distingue uma conta sem modelos de uma conta não resolvida e
   não escolher outra conta automaticamente. Qualquer substituição precisa ser registrada na issue
   #14 antes de repetir.
4. Consultar individualmente, pela API oficial GitHub `GET /repos/{owner}/{repo}`, os três
   repositórios aprovados da lista. Exigir `private: false` explicitamente antes de cachear a
   resposta. Essas consultas são positivos conhecidos para calibrar a descoberta, não uma varredura
   de contas.
5. Enriquecer no máximo dez candidatos com README/model card. Priorizar os três URLs da lista
   brasileira para que façam parte da amostra; escolher os demais em ordem canônica e registrar os
   dez URLs selecionados no relatório local.
6. O teto global permanece em 23 tentativas HTTP: duas buscas GitHub + uma listagem HF + três
   consultas de metadados dos repositórios curados + três leituras GitHub dos READMEs prioritários +
   até sete outros documentos, assumindo no pior caso duas tentativas para cada README de modelo HF
   por causa de redirecionamento. Essa composição cobre o limite sem retentativas automáticas.
   Respostas `404` também consomem uma tentativa. `403`, `429`, resposta incompleta ou ausência de
   cache externo interrompe a execução ou marca a amostra como parcial, sem ampliar a consulta.

Antes da primeira requisição, os coletores validam os dois termos aprovados (`Transcritorio` e
`BERTimbau`), a lista curada aprovada (`awesome-open-source-research-tools`), a conta HF aprovada
(`neuralmind`), o tipo `models`, uma página, a seleção de documentos prioritários e o orçamento HTTP
global. Não há varredura de contas. A validação da raiz de cache (existente, gravável e fora do
checkout) acontece antes de qualquer chamada de rede. Resposta do GitHub com
`incomplete_results=true` ou mais resultados que os retornados na página é registrada como cobertura
parcial, sem subdividir a consulta. O orçamento compartilhado cobre as duas buscas, a lista HF, os
três metadados e até dez documentos conforme a composição acima. Não há retentativas automáticas;
erros de status encerram a chamada e a tentativa continua contabilizada.

Exemplo reproduzível com os parâmetros que o autor aprovou no chat; o exemplo ainda não foi executado:

```r
budget <- radar_novo_orcamento()
github <- coletar_github(
  search_terms = c("Transcritorio", "BERTimbau"),
  include_curated_list = "awesome-open-source-research-tools",
  budget = budget
)
huggingface <- coletar_hf(
  account = "neuralmind",
  budget = budget
)
enriquecimento <- coletar_readmes_exploratorios(
  dplyr::bind_rows(github, huggingface),
  priority_urls = dplyr::filter(github, !is.na(seed_source)) |>
    dplyr::pull(url),
  budget = budget
)
```

A busca GitHub inclui `is:public`, não envia `GITHUB_PAT` e valida a visibilidade antes do cache; a
listagem HF não envia `HF_TOKEN` e rejeita itens marcados como privados. Os metadados diretos dos
repositórios curados exigem confirmação explícita de visibilidade pública. A seleção prioriza os três
READMEs brasileiros e ordena os demais por URL canônica, sem diferenciar maiúsculas/minúsculas.
Retorna `selected_urls`, a contagem priorizada e os candidatos excluídos pelo teto. As respostas de
busca registram total, incompletude, página, tamanho e ordenação. A implementação e os fixtures
offline estão na branch `codex/14-brazil-list`; nenhum candidato foi coletado nesta etapa.

## Documentação oficial verificada

O Antigravity ajudou a localizar e conferir parâmetros da documentação oficial; a confirmação e as
regras desta coleta ficam ancoradas nas fontes primárias abaixo. A saída dos modelos é apoio de
pesquisa, não uma fonte normativa.

- **GitHub Search Repositories**: `per_page` aceita até 100; o endpoint limita cada consulta a 1.000
  resultados e retorna `total_count` e `incomplete_results`. A amostra usa `page=1`, registra `q`,
  ordenação e contagens e não segue páginas nem divide automaticamente resultados incompletos.
  [Documentação REST oficial](https://docs.github.com/en/rest/search/search#search-repositories).
- **Visibilidade pública GitHub**: o qualificador `is:public` é suportado pela busca; além dele, o
  coletor verifica o campo `private` antes de gravar cache. Todas as chamadas exploratórias GitHub
  são anônimas para impedir que um token local amplie os dados visíveis a um README privado.
  [Qualificadores oficiais de visibilidade](https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories#search-by-repository-visibility).
- **Get a repository**: a API REST oficial expõe `GET /repos/{owner}/{repo}`, inclui a marca
  `private` no objeto do repositório e permite chamadas sem autenticação para recursos públicos.
  A coleta exige `private: false` e confirma o nome completo antes de guardar a resposta no cache.
  [Referência oficial de repositórios](https://docs.github.com/en/rest/repos/repos#get-a-repository).
- **GitHub Search rate limit**: buscas têm limite separado e mais restrito que os demais endpoints;
  chamadas anônimas só podem buscar recursos públicos. A rodada fará no máximo duas buscas e para em
  `403` ou `429`.
  [Limites de taxa REST](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api).
- **Hugging Face Models API**: o endpoint oficial aceita filtro de autor e limite; a referência do
  cliente `HfApi.list_models` documenta `author` e `limit`, e alerta que sem limite pode percorrer
  todos os resultados. A coleta usará uma chamada direta a `/api/models?author=…&limit=100` e não
  seguirá o `Link` `next`; isso define uma amostra de uma página, não cobertura total da conta.
  [Referência oficial de `list_models`](https://huggingface.co/docs/huggingface_hub/main/en/package_reference/hf_api#huggingface_hub.HfApi.list_models),
  [API do Hub](https://huggingface.co/docs/hub/api) e [paginação](https://huggingface.co/docs/hub/api#pagination).
- **Resultado do Antigravity em 2026-09-27**: `gemini-3.8-flash-high` terminou sem texto útil em modo
  JSON e expirou no modo texto; `gemini-3.1-pro-high` também expirou. As tentativas `gemini-3.8-flash-low`
  e `gemini-3.1-pro-low` retornaram parâmetros e uma revisão independente, respectivamente. Os links
  oficiais foram verificados separadamente. Não foi solicitado que os agentes executassem comandos,
  coletassem candidatos ou editassem arquivos.

## Cache, resultados e privacidade

- Usar somente a API REST oficial do GitHub e a API oficial do Hugging Face Hub; não raspar páginas
  HTML do BBSIA nem de plataformas que ofereçam API para a mesma informação.
- Manter `MANCANO_BBSIA_RADAR_ROOT` configurada no `.Renviron` local para uma pasta fora do
  checkout; antes de cada rodada, validar existência, escrita e separação do repositório com
  `radar_validate_cache_root()`. Nunca imprimir ou registrar valores de tokens.
- Cache bruto, CSV de candidatos e textos de README/model card ficam somente nessa raiz externa.
  Aplicar a redação de e-mails dos coletores e não incluir e-mails, tokens ou dados pessoais no
  relatório.
- Registrar no plano ativo a data, versão/commit dos coletores, consultas exatas, orçamento,
  contagens por fonte, falhas, cache utilizado e limite de cobertura. No repositório ficam apenas
  essas evidências metodológicas agregadas, após revisão; os dados brutos permanecem externos.
- Não classificar automaticamente, deduplicar contra fichas do BBSIA, preencher formulário, enviar
  dados ou contatar a coordenação nesta etapa.

## Uso do Antigravity (`agy`) nesta etapa

Flash 3.8 pode ajudar a conferir a documentação oficial dos parâmetros e sugerir consultas a partir
das sementes já aprovadas. Pro pode revisar a proposta e as fontes de forma independente. Esses
agentes não executam a coleta local nem substituem a API: saída do modelo só vale como pista até que
os links oficiais sejam conferidos.

Prompt de pesquisa sem escrita ou coleta:

```text
Responda em português. Consulte apenas a documentação oficial atual do GitHub REST e do Hugging
Face Hub. Para busca de repositórios no GitHub e listagem de modelos no Hugging Face, informe os
parâmetros de paginação, limites por página, limites de resultados/ordenação relevantes e URLs
canônicas da documentação. Proponha no máximo duas consultas GitHub e uma consulta HF que possam
ser derivadas de sementes já aprovadas, mas não invente novas sementes. Não consulte o BBSIA, não
retorne uma lista de candidatos, não faça coleta, não execute comandos e não altere arquivos. Separe
fatos documentados de inferências e cite links diretos.
```

Execução não interativa no PowerShell, conforme `repo-governance/agentes-gemini.md`:

```powershell
$prompt = @'
[cole aqui o prompt de pesquisa acima]
'@
agy --model gemini-3.8-flash-high --mode plan --output-format json --print-timeout 180s --print $prompt
```

Para revisão, enviar a resposta junto dos links oficiais originais ao modelo `gemini-3.1-pro-high`.
Não conceder diretórios adicionais, não pedir ao agente para executar os coletores e não usar
`--dangerously-skip-permissions`.

## Etapas e portas

1. **Concluído — sincronizar e revisar o PR #13 integrado.** A branch foi baseada na `main` que
   contém o merge `94bad301`; os coletores atuais permitem varreduras maiores que a amostra aprovada.
2. **Concluído — aprovar o recorte inicial.** O autor aprovou no chat apenas sementes de
   `config/seeds.yml`; módulos adjacentes do BBSIA ficam fora desta rodada. A decisão futura continua
   aberta na issue #12.
3. **Concluído — ativar o plano e abrir sua issue.** Plano `EM EXECUÇÃO`, issue #14 aberta e rotulada
   `em-andamento`; esta aprovação e o escopo estão registrados neste arquivo.
4. **Concluído — integrar controles e verificar sem rede.** `radar_novo_orcamento()` impõe o teto
   global de 23 tentativas reservadas e dez documentos; busca GitHub exige até dois termos-semente e
   solicita uma página cada; HF exige uma conta-semente e lista somente uma página de `models`; o
   enriquecimento escolhe até dez URLs em ordem canônica. GitHub restringe a busca a `is:public` e
   todas as chamadas são anônimas; HF não envia token. Busca GitHub e listagem HF verificam marcações
   `private` antes do cache. Uma listagem HF vazia é registrada como inconclusiva quanto à existência
   da conta e não troca a conta-semente. Retentativas automáticas foram removidas e a raiz externa de
   cache é validada antes da rede. A suíte `testthat` offline passou em 2026-09-27, e a PR #16 foi
   integrada no commit `c1835b1`.
5. **Concluído — preparar o ambiente local.** R 4.6.0 e todos os pacotes necessários estão
   disponíveis. A raiz local foi escolhida a pedido do autor, criada e verificada como gravável; o
   `.Renviron` ignorado pelo Git define `MANCANO_BBSIA_RADAR_ROOT`, e
   `radar_validate_cache_root()` confirmou que a raiz está fora do checkout. A API usa a subpasta
   indicada em `.data-source`. Chamadas públicas GitHub e Hugging Face são anônimas; nenhum token é
   necessário ou lido pelos coletores.
6. **Em execução — implementar e revisar a inclusão da lista brasileira.** A branch
   `codex/14-brazil-list` usa a API oficial para buscar somente os três repositórios já selecionados e
   prioriza seus documentos na amostra. Os testes usam fixtures locais e não fazem rede.
7. **Pendente — executar a primeira amostra aprovada.** Termos, conta e lista foram aprovados no chat.
   Após a revisão e integração do PR, executar a composição e os limites acima, guardar dados brutos
   somente no cache externo e registrar no plano as consultas, contagens, falhas e cobertura. Nenhum
   registro será enviado ao BBSIA. A ampliação da amostra permanece para decisão posterior.

## Critério de conclusão

A primeira exploração termina com o cache e os arquivos de candidatos fora do git, testes offline
aprovados para os limites, um resumo metodológico reproduzível no plano/NEWS e uma recomendação
fundamentada para ampliar, ajustar ou parar. Nenhum registro é enviado ao BBSIA.

## Aprovação do autor

**Aprovado por Tales Mançano no chat em 2026-09-27:** termos GitHub `Transcritorio` e `BERTimbau`,
conta HF `neuralmind` e inclusão somente das três soluções com tag `brazil` em
`awesome-open-source-research-tools` (Transcritório, Open Notebook e QualiLab). A execução acontece
após a integração dos controles e dos testes offline e usa a raiz de cache externa já validada.
