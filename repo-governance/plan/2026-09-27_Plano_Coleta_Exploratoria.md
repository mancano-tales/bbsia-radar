---
tipo: Plano
titulo: "Coleta exploratória limitada nas APIs do GitHub, Hugging Face e GitLab.com"
issue: 14
status: EM EXECUÇÃO # aprovado pelo autor no chat em 2026-09-27
criado: "2026-09-27 08:40"
concluido: null
autor_humano: "Tales Mançano"
aprovacao_autor: "2026-09-27 no chat: aprovou a coleta inicial com termos GitHub/GitLab Transcritorio e BERTimbau, conta HF neuralmind, GitLab.com anônimo, até 25 tentativas reservadas e 10 documentos. Aprovou armazenar a exploração somente no cache externo; não autoriza publicação nem envio ao BBSIA."
planos_relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"]
issues_relacionadas: [1, 10, 12]
---

# Plano: coleta exploratória limitada

> **Issue: #14.**

## Objetivo

Verificar, com uma amostra pequena e reproduzível, se os coletores do radar conseguem descobrir
candidatos úteis nas APIs oficiais do GitHub, do Hugging Face e do GitLab.com. A rodada deve testar consultas,
cache, privacidade e qualidade dos metadados; não é a coleta do piloto de 30 soluções nem uma
submissão ao BBSIA.

## Estado observado em 2026-09-27

- O PR #11 está integrado em `main`.
- O PR #13, da issue #10, foi integrado durante a preparação desta proposta no merge
  `94bad301563c153e4be64cba3cc9b99e2b52203c`; a issue #10 foi fechada. A implementação dos
  coletores está disponível. Os limites explícitos para a amostra foram integrados pela PR #16 e
  GitLab foi implementado no commit `1eb2f16` da branch `codex/14-gitlab-radar`; a integração com `main` está sendo concluída para revisão.
- A documentação aprovada foi integrada pela PR #15 no commit `fa7c5e5462808ee6ead0ae977809ecab7cefc5d1`.
- A implementação dos limites foi integrada pela PR #16 em `main` no commit
  `c1835b1d6d126420bb85636dae9b28eafa9e1bb3`; a suíte offline cobre orçamento compartilhado,
  paginação, seleção determinística, cache externo, respostas vazias, erros HTTP e bloqueios de itens
  privados. Após integrar a implementação GitLab às mudanças da PR #20, a suíte offline passou com 212 testes, sem falhas nem avisos de teste.
- A PR #20 integrou três soluções brasileiras da lista curada e registrou uma rodada distinta
  apenas com GitHub/HF: 103 candidatos GitHub, dois modelos HF, dez documentos selecionados
  (todos GitHub) e 16/23 tentativas. Nenhum model card HF foi lido, então a cobertura documental
  dessa fonte ainda não foi avaliada nessa rodada. A execução GitLab documentada neste plano é
  a rodada ampliada posterior; seus números não devem ser somados aos da rodada anterior.
- A issue #12 continua sem decisão sobre o uso dos módulos adjacentes do BBSIA como contexto ou
  sementes.
- Antes desta implementação, os coletores do PR #13 podiam percorrer vários termos, páginas e contas;
  a listagem HF cobria três tipos de artefato, sem orçamento global. A branch atual substitui esse
  caminho exploratório por chamadas explicitamente limitadas e compartilhadas por orçamento.
- O autor aprovou este plano no chat em 2026-09-27, limitado nesta primeira rodada às sementes atuais
  de `config/seeds.yml`; módulos adjacentes do BBSIA ficam fora. A aprovação está registrada aqui;
  a issue #12 continua aberta para decisões futuras sobre esses módulos.
- A PR #20 atualizou a issue #14 com a rodada GitHub/HF anterior. O marco da rodada GitLab não
  pôde ser publicado nesta sessão porque a integração retornou 403 e o `gh` local não tem
  autenticação válida. Os parâmetros aprovados para GitLab e HF estão detalhados neste plano e no
  plano GitLab associado.
- A pedido do autor no chat, a raiz externa foi definida como `%USERPROFILE%/AppData/Local/Mancano`,
  criada e verificada como gravável. `MANCANO_BBSIA_RADAR_ROOT` está configurada no `.Renviron`
  local, ignorado pelo Git; `.data-source` acrescenta `bbsia-radar/api`. O resolvedor
  `radar_validate_cache_root()` confirmou que fica fora do checkout e pode ser escrita. O caminho
  absoluto da máquina não é publicado.
- A rodada GitLab foi executada com as buscas por termos aprovados, sem a opção adicional de
  buscar individualmente a lista curada introduzida pela PR #20; os três registros dessa lista
  pertencem à rodada GitHub/HF separada acima.
- Recorte aprovado no chat: GitHub e GitLab usam os termos-semente `Transcritorio` e `BERTimbau`;
  Hugging Face consulta modelos da conta-semente `neuralmind`. Nenhuma grafia alternativa é inferida.

## Escopo aprovado para a primeira rodada

1. Usar somente sementes já mantidas em `config/seeds.yml`; não consultar módulos do BBSIA para
   descobrir ou ampliar sementes nesta rodada. Judiciário/CNJ/Sinapses, catálogo, recursos,
   prontidão e modelos do BBSIA ficam fora da coleta. Esta restrição vale para o primeiro teste e
   não decide sozinha o uso futuro desses módulos na issue #12.
2. Pesquisar GitHub e GitLab.com com os termos aprovados `Transcritorio` e `BERTimbau`, que já
   aparecem nos nomes/artefatos das sementes. Usar uma página por termo e sem varredura de contas.
   GitHub tem teto de 100 resultados por busca; GitLab usa a API REST v4 anônima, `visibility=public`,
   `simple=true`, `order_by=created_at`, `sort=desc` e uma página de até 100 resultados. Não seguir
   paginação nem subdividir automaticamente consultas grandes nesta rodada.
3. Consultar apenas `models` no Hugging Face, para uma conta já listada em `config/seeds.yml`, com
   uma página de até 100 resultados. A própria resposta confirma a conta se retornar modelos; se vier
   vazia, registrar que o endpoint não distingue uma conta sem modelos de uma conta não resolvida e
   não escolher outra conta automaticamente. Qualquer substituição precisa ser registrada na issue
   #14 antes de repetir.
4. Enriquecer no máximo dez candidatos com README/model card. Havendo candidatos das três plataformas,
   reservar primeiro um documento por plataforma e completar as vagas em ordem canônica; registrar
   a seleção e não buscar todos os documentos retornados. No GitLab, ler somente README raiz até
   256 KiB, após HEAD e conferência de `X-Gitlab-Size`; o GET usa o commit imutável retornado pelo
   HEAD e a chave do cache inclui essa revisão.
5. Orçamento máximo explícito: duas buscas GitHub, uma listagem de modelos HF, duas buscas GitLab e
   até dez leituras de README/model card com no máximo duas tentativas cada. Cada tentativa HTTP,
   inclusive respostas `404`, consome o
   orçamento; a rodada não fará retentativas automáticas. Redirecionamentos terão teto documentado e
   contabilizado. Erro de autenticação, `403`, `429`, resposta incompleta ou ausência de cache externo
   interrompe a execução ou marca a amostra como parcial, sem ampliar a consulta.

Antes da primeira requisição, os coletores validam os termos exatos (até dois), a conta HF (exatamente
uma), o tipo `models`, uma página, o limite de documentos e o orçamento HTTP global. Varredura de
contas fica desabilitada e não há consulta de positivos conhecidos fora das buscas selecionadas. A
validação da raiz de cache (existente, gravável e fora do checkout) acontece antes de qualquer chamada
de rede. Resposta do GitHub com `incomplete_results=true` ou mais resultados que os retornados na
página é registrada como cobertura parcial, sem subdividir a consulta. O orçamento compartilhado
permite até 25 tentativas reservadas: duas buscas GitHub, uma listagem HF, duas buscas GitLab e vinte
tentativas para no máximo dez documentos. Não há retentativas automáticas; erros de status encerram a
chamada e a tentativa continua contabilizada.

Exemplo de uso com os parâmetros aprovados no chat:

```r
budget <- radar_novo_orcamento()
github <- coletar_github(
  search_terms = c("Transcritorio", "BERTimbau"),
  budget = budget
)
huggingface <- coletar_hf(
  account = "neuralmind",
  budget = budget
)
gitlab <- coletar_gitlab(
  search_terms = c("Transcritorio", "BERTimbau"),
  budget = budget
)
enriquecimento <- coletar_readmes_exploratorios(
  dplyr::bind_rows(github, huggingface, gitlab),
  budget = budget
)
```

A busca GitHub inclui o qualificador `is:public`, não envia `GITHUB_PAT` em nenhuma chamada e verifica
a resposta antes de cacheá-la; a listagem HF não envia `HF_TOKEN` e também rejeita antes do cache
qualquer item marcado como privado. GitLab consulta uma página pública por termo e rejeita itens sem
`visibility=public` antes do cache; para README, usa HEAD e GET somente quando o tamanho é no máximo
256 KiB. A seleção prioriza um documento por plataforma disponível, remove URLs duplicadas sem
distinguir maiúsculas/minúsculas, escolhe no máximo dez e devolve `selected_urls`, contagens de
candidatos distintos/selecionados/excluídos pelo teto e o resumo do orçamento. As respostas de busca
incluem `total_count`, `incomplete_results`,
página, tamanho e ordenação para registrar a cobertura observada. A implementação e os fixtures
offline ficam na branch `codex/14-gitlab-radar`.

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
- **GitHub Search rate limit**: buscas têm limite separado e mais restrito que os demais endpoints;
  chamadas anônimas só podem buscar recursos públicos. A rodada fará no máximo duas buscas e para em
  `403` ou `429`.
  [Limites de taxa REST](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api).
- **GitLab Projects API**: pesquisa pública por nome, caminho ou descrição. A amostra usa uma página
  anônima, registra truncamento e não cobre conteúdo do código.
  [Projetos](https://docs.gitlab.com/api/projects/) e [paginação REST](https://docs.gitlab.com/api/rest/).
- **GitLab Repository Files API**: HEAD fornece `X-Gitlab-Size`; o coletor usa esse tamanho antes de
  GET e busca somente README.md da raiz em um commit fixado, com limite de 256 KiB.
  [Documentação oficial](https://docs.gitlab.com/api/repository_files/).
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

- Usar somente as APIs REST oficiais do GitHub e GitLab.com e a API oficial do Hugging Face Hub; não raspar páginas
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
   global de 25 tentativas reservadas e dez documentos; busca GitHub aceita até dois termos-semente,
   GitLab usa até duas consultas públicas de uma página, e HF lista uma página de `models` para uma
   conta-semente. O enriquecimento prioriza um documento por plataforma disponível e limita o total
   a dez. Chamadas são anônimas; GitHub/HF rejeitam itens marcados como privados e GitLab rejeita
   itens sem `visibility=public` antes do cache. README GitLab passa por HEAD + verificação de
   `X-Gitlab-Size`, com teto de 256 KiB. `last_activity_at` é descrito como atividade do projeto,
   não como data de commit. Retentativas automáticas foram removidas e a raiz externa de cache é
   validada antes da rede. A suíte offline passou em 2026-09-27: 166 testes.
5. **Concluído — preparar o ambiente local.** R 4.6.0 e todos os pacotes necessários estão
   disponíveis. A raiz local foi escolhida a pedido do autor, criada e verificada como gravável; o
   `.Renviron` ignorado pelo Git define `MANCANO_BBSIA_RADAR_ROOT`, e
   `radar_validate_cache_root()` confirmou que a raiz está fora do checkout. A API usa a subpasta
   indicada em `.data-source`. Chamadas públicas GitHub, Hugging Face e GitLab são anônimas; nenhum
   token é necessário ou lido pelos coletores.
6. **Concluído — executar a amostra aprovada (2026-09-27).** Foram consultados GitHub/GitLab com
   `Transcritorio` e `BERTimbau` e HF com `neuralmind`. Resultado: 104 registros e 104 URLs únicas
   (GitHub 101, GitLab 1, HF 2); a busca GitHub de BERTimbau foi parcial (100 retornados de 134
   informados). A busca GitLab de BERTimbau retornou um projeto e Transcritorio nenhum; HF retornou
   dois modelos. Dez documentos foram selecionados (oito GitHub, um GitLab, um HF); nove foram lidos
   e um README do GitHub não existia. Foram reservadas 17/25 tentativas, sem erro HTTP. Quatorze
   registros não tinham descrição (11 GitHub, 1 GitLab e 2 HF), dois foram associados a sementes e
   o escaneamento dos arquivos exportados não encontrou e-mails. Saídas e documentos ficaram só no
   cache externo, e a tabela/candidatos não foi publicada. O coletor foi publicado no commit `1eb2f16`; a integração atual também preserva a busca opcional de sementes curadas da PR #20. A revisão do código não alterou as consultas nem os registros já coletados. A suíte offline combinada passou com 212 testes.
7. **Pendente — revisar e decidir.** Avaliar relevância, duplicatas entre plataformas, campos ausentes, erros e
   ruído; classificação no Decifra, TRL, comparação registro a registro com o BBSIA e validação humana
   ainda não foram feitos. O autor decide se a próxima rodada amplia consultas e tamanho. Coleta
   ampliada, uso de dados dos módulos do BBSIA e deduplicação registro a registro ficam fora desta
   aprovação inicial.

## Critério de conclusão

A primeira exploração termina com o cache e os arquivos de candidatos fora do git, testes offline
aprovados para os limites, um resumo metodológico reproduzível no plano/NEWS e uma recomendação
fundamentada para ampliar, ajustar ou parar. Nenhum registro é enviado ao BBSIA.

## Aprovação do autor

**Aprovado por Tales Mançano no chat em 2026-09-27:** primeira rodada com as sementes existentes em
`config/seeds.yml`; termos GitHub/GitLab `Transcritorio` e `BERTimbau`; conta HF `neuralmind`;
GitLab.com anônimo, README raiz até 256 KiB, dez documentos e 25 tentativas reservadas. Módulos
adjacentes do BBSIA ficam fora desta coleta. A aprovação autoriza exploração com cache externo, não
publicação de candidatos, ativação do Pages ou envio ao BBSIA.
