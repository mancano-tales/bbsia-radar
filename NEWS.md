# NEWS — bbsia-radar

## 2026-09-27 — Confirma PR sem conflitos e workflow aprovado

Após o push do merge `ee32b88`, o GitHub confirmou o PR #21 como `CLEAN` e `MERGEABLE`; o workflow `Verificar caminhos absolutos` passou. O CodeRabbit segue em PASS, com revisão manual necessária para este repositório OSS. `news_db.py` encontrou 39 entradas, zero sem commit identificável e 37/39 mensagens declaradas coincidentes. As duas divergências restantes são históricas (issues #8 e #1), registradas nos commits originais e não introduzidas por esta branch. O PR não foi mergeado.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: docs(plan): confirma PR limpo e workflow refs #1
- **Arquivos afetados**: NEWS.md, TODO.md, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md

## 2026-09-27 — Resolve segundo conflito de NEWS após avanço de main

O commit b2636ed de main acrescentou uma entrada de cobertura HF ao topo do NEWS.md enquanto o PR #21 era atualizado. A branch integrou essa atualização, preservando as entradas dos dois lados em ordem cronológica e sem reescrever histórico. O conflito estava restrito a NEWS.md; o estado e os checks do PR serão conferidos após o push.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: merge: integra main e resolve segundo conflito de NEWS refs #1
- **Arquivos afetados**: CHANGELOG.md, NEWS.md, TODO.md, repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md

## 2026-09-27 — Resolve conflito e valida workflow do PR #21

O merge `5257e2a` integrou `main` à branch do PR #21 e preservou as entradas recentes dos dois lados de `NEWS.md`. O GitHub agora informa o PR como `MERGEABLE` e `CLEAN`. O workflow `Verificar caminhos absolutos` passou; o CodeRabbit marcou PASS, mas solicitou revisão manual para este repositório OSS. `news_db.py` encontrou 36 entradas, nenhuma sem commit identificável e 34/36 mensagens declaradas coincidentes. As duas divergências são anteriores a esta branch (licenças/validação da issue #8 e proposta de proteção); o verificador lê o texto no commit que criou cada entrada. O histórico não foi reescrito.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: docs(plan): registra resolucao de conflito e validacao refs #1
- **Arquivos afetados**: NEWS.md, TODO.md, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md

## 2026-09-27 — Identifica lacuna de cobertura de model cards

Na revisão dos dez documentos selecionados na amostra, todos eram do GitHub; os dois modelos
retornados pela API do Hugging Face não tiveram seus model cards enriquecidos. O seletor prioriza
três URLs curadas e depois preenche o teto de dez pela ordem canônica, sem reservar cobertura por
plataforma. Isso confirma a descoberta HF, mas não testa a leitura de model cards nem a qualidade dos
metadados de documento dessa fonte. O plano registra a recomendação de reservar ao menos um espaço
para HF antes de outra chamada, mantendo o teto total e as três prioridades; a decisão fica para o
autor na issue #14. A leitura preliminar dos READMEs também mostra uma mistura de aplicações e
artefatos de pesquisa, que ainda não foram classificados pelo Decifra.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `docs(plan): registra lacuna de cobertura hf refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `TODO.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`

## 2026-09-27 — Executa a primeira amostra pública das APIs

A primeira execução dos coletores usou os termos GitHub aprovados `Transcritorio` e `BERTimbau`, a
conta Hugging Face `neuralmind` e os três itens brasileiros priorizados da lista global do autor.
Retornou 103 candidatos GitHub e 2 modelos HF; dez documentos foram selecionados, três deles
prioritários. A busca `BERTimbau` registrou 134 resultados totais e apenas os 100 da primeira página,
portanto a cobertura é parcial. Foram reservadas 16 de até 23 tentativas. Cache bruto e exportações
ficaram em namespace externo ao repositório. Uma checagem de padrão de e-mail nos dez textos não
encontrou correspondências; nenhum e-mail foi coletado intencionalmente, nenhum token foi enviado e
nada foi submetido ao BBSIA. A issue #14 permanece aberta para revisar relevância e falsos positivos
antes de qualquer expansão.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `docs(plan): registra primeira amostra exploratoria refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `TODO.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`

## 2026-09-27 — Restabelece autenticação e abre PR para revisão

Após a autorização OAuth do autor, `gh auth status` confirmou a conta `mancano-tales`. A atualização foi publicada na issue #1 e o PR #21 foi aberto para `main`, sem merge. O CodeRabbit retornou PASS, com revisão manual indicada para este repositório OSS; o workflow de caminhos absolutos ainda não consta nas verificações do PR. O status check obrigatório segue pendente. [PR #21](https://github.com/mancano-tales/bbsia-radar/pull/21).

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: docs(plan): atualiza estado após abertura do PR refs #1
- **Arquivos afetados**: NEWS.md, TODO.md, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md

## 2026-09-27 — Envia correções e registra bloqueio de abertura do PR

O commit 6216a8f foi enviado para a branch codex/1-revisao-caminhos-absolutos. A criação do pull request pela integração GitHub retornou HTTP 403 (Resource not accessible by integration), e `gh auth status` confirmou token inválido. A comparação da branch abriu numa sessão autenticada do Chrome, mas a automação da página expirou antes de preencher e enviar o formulário; nenhum PR foi criado. [Abrir a comparação com main](https://github.com/mancano-tales/bbsia-radar/compare/main...codex/1-revisao-caminhos-absolutos?expand=1). Permanecem pendentes o PR, o comentário de estado na issue #1 e a exigência do status check no GitHub.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: docs(plan): registra bloqueio de abertura do PR refs #1
- **Arquivos afetados**: NEWS.md, TODO.md, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md

## 2026-09-27 — Corrige casos de borda da proteção contra caminhos absolutos

Após o merge do PR #19, revisões prévias independentes por Gemini Pro e GPT-Sol identificaram omissões de caminhos Windows em URI e literais escapados, perda de contexto na busca por raízes Unix, tratamento incorreto de linhas +++ dentro de hunks e ausência dos diffs de primeiro pai de commits de merge. O scanner, o pre-push e o workflow foram corrigidos. As revisões posteriores também apontaram o fallback do primeiro push sem base remota, variantes de URI file: com e sem host e URLs relativas ao esquema que poderiam ser confundidas com UNC; esses casos foram tratados. Verificações direcionadas cobriram URIs Windows/Unix/UNC, escapes, aspas, linhas +++ em hunks, URLs comuns, 1.500 URLs após um token file: e uma linha de 50.000 caracteres; o scanner também passou sobre o diff completo e git diff --check. As revisões finais independentes de Gemini Pro e GPT-Sol não encontraram achados acionáveis. O status check obrigatório no GitHub continua pendente.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: fix(security): corrige detector e inclui diffs de merge refs #1
- **Arquivos afetados**: .github/workflows/absolute-paths.yml, AGENTS.md, NEWS.md, TODO.md, hooks/pre-push, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md, tools/check-absolute-paths.sh

## 2026-09-27 — Abre PR para incluir sementes brasileiras curadas

A branch `codex/14-brazil-list` e o PR #20 foram publicados para revisão, com o commit `17297e3`.
A issue #14 foi atualizada com o estado do PR, os termos e a conta aprovados, os três itens
brasileiros da lista global e o próximo passo. A amostra de candidatos continua sem execução; o
merge do PR fica com o autor.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `docs: registra PR de sementes brasileiras refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`

## 2026-09-27 — Inclui sementes brasileiras da lista global do autor

A coleta exploratória agora pode consultar individualmente pela API oficial do GitHub os três
repositórios já marcados com tag `brazil` no gabarito da lista global
`awesome-open-source-research-tools`: Transcritório, Open Notebook e QualiLab. A resposta de cada
repositório precisa confirmar `private: false` antes de entrar no cache, e a allow-list continua sem
campo de e-mail. Os três READMEs ficam prioritários entre os dez documentos do orçamento. O plano
registra os termos GitHub `Transcritorio` e `BERTimbau`, a conta HF `neuralmind` e o teto revisado de
23 tentativas; essa composição está documentada, mas a amostra ainda não foi executada.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `feat(collectors): inclui sementes brasileiras da lista curada refs #14`
- **Arquivos afetados**: `NEWS.md`, `README.md`, `R/coletar_github.R`, `R/enriquecer_documentos.R`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`, `tests/fixtures/seeds_awesome_brazil.yml`, `tests/testthat/test-collectors.R`

## 2026-09-27 — Aprova e implementa mitigação contra caminhos absolutos

O autor aprovou no chat a opção A: reduzir a chance de publicar caminhos absolutos sem criar um fluxo privado nem prometer garantia literal. Foi adicionado um scanner compartilhado, conectado aos hooks pre-commit e pre-push e a um workflow de verificação de pull requests. O scanner informa somente arquivo relativo e linha, sem copiar o conteúdo detectado. Os hooks estão ativados neste clone, com LF garantido para o shell; o workflow ainda precisa ser marcado como status check obrigatório nas configurações do GitHub para bloquear merges. A autenticação do gh está inválida e a API está inacessível nesta sessão; por isso, o anúncio na issue #1 e a configuração remota ficam pendentes. Nenhum histórico foi reescrito.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: feat(security): reduz risco de caminhos absolutos refs #1
- **Arquivos afetados**: .gitattributes, .github/workflows/absolute-paths.yml, AGENTS.md, NEWS.md, TODO.md, hooks/pre-commit, hooks/pre-push, repo-governance/plan/README.md, repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md, tools/check-absolute-paths.sh

## 2026-09-27 — Configura raiz local de cache exploratório

A pedido do autor, foi definida e preparada uma raiz de cache sob `AppData/Local/Mancano`, fora do
checkout e da sincronização do repositório. `MANCANO_BBSIA_RADAR_ROOT` foi configurada no `.Renviron`
local, ignorado pelo Git; a validação do projeto confirmou que a pasta existe, é gravável e está
fora do repositório. O cache da API usa a subpasta `bbsia-radar/api`, indicada em `.data-source`.
Não houve chamadas de coleta. Foram propostas, para aprovação do autor, as sementes GitHub
`Transcritório` e `BERTimbau` e a conta Hugging Face `neuralmind`; a coleta só começa depois dessa
confirmação.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `docs(cache): configura raiz local para coleta exploratoria refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`

## 2026-09-27 — Propõe proteção contra caminhos absolutos

O autor estabeleceu que caminhos absolutos de máquina não devem ser publicados. A inspeção confirmou
que o hook local atual cobre só parte das linhas adicionadas e possui exclusões e isenção. No
GitHub.com, um status check pode bloquear o merge, mas só depois de a branch pública receber o push;
os hooks de pre-receive documentados pelo GitHub são para GitHub Enterprise Server. O plano em
proposta apresenta alternativas e aguarda decisão do autor sobre a garantia necessária. Não houve
mudança em código nem nas regras remotas do repositório. A tentativa de criar uma issue dedicada foi
recusada pela integração GitHub (`403 Resource not accessible by integration`) e o `gh` local está
sem autenticação válida; a proposta deve ser levada à issue relacionada #1 pelo autor.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1 (relacionada; proposta aguardando aprovação)
- **Mensagem do Commit**: `docs(security): propoe bloqueio de caminhos absolutos refs #1`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `TODO.md`, `repo-governance/plan/README.md`, `repo-governance/plan/2026-09-27_Plano_Protecao_Caminhos_Absolutos.md`

## 2026-09-27 — Planeja relatórios Quarto e atualiza a descrição do radar

A descrição curta da seção About do GitHub estava vazia e agora explica em português que o radar
identifica soluções de IA brasileiras ou adaptadas ao português brasileiro e prepara candidatas para
revisão no BBSIA. O README recebeu a mesma delimitação e informa que os relatórios futuros serão
gerados em Quarto nos formatos HTML e PDF, com publicação automática no GitHub Pages após a entrada
de dados revisados e aprovados. A proposta está no plano ligado à issue #17; não implementa o site,
não inicia coleta e deixa a implantação pública para uma aprovação posterior.

A revisão do TODO moveu para concluído os registros do WP0c, da primeira versão do codebook e do
conversor/exportador do corpus, entregas que já estavam documentadas no README, no NEWS ou no código.
Também esclareceu que os coletores existem mas a execução em volume continua pendente. O
`CHANGELOG.md` foi regenerado pelo script oficial para incluir os commits recentes. A proposta Quarto
separa resultados curados do cache externo, prevê proveniência e limita o workflow a renderizar dados
versionados, sem chamar APIs nem classificação por LLM.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #17
- **Mensagem do Commit**: `docs(report): planeja site Quarto do radar refs #17`
- **Arquivos afetados**: `README.md`, `TODO.md`, `NEWS.md`, `CHANGELOG.md`, `repo-governance/plan/README.md`, `repo-governance/plan/2026-09-27_Plano_Website_Quarto.md`

## 2026-09-27 — Mantém a raiz local de cache fora da issue pública

O plano agora pede que os termos GitHub e a conta HF sejam confirmados na issue #14, mas que a raiz
local de cache seja confirmada no chat privado do autor. A issue registra apenas que a raiz existe,
é gravável e fica fora do checkout; seu caminho absoluto pode conter dado pessoal e não deve ser
publicado. Nenhuma chamada de coleta foi feita.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `docs: protege caminho local do cache refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`

## 2026-09-27 — Integra os controles da coleta exploratória

A PR #16 integrou os controles exploratórios na `main` pelo commit `c1835b1`. A revisão estática por
outra sessão Codex não encontrou bloqueios, e os testes offline passaram. A issue #14 permanece
aberta: nenhum candidato foi coletado. Neste checkout R 4.6.0 e os pacotes exigidos estão disponíveis,
mas `MANCANO_BBSIA_RADAR_ROOT` não está configurado. Outra sessão Codex reportou uma biblioteca R sem
os pacotes do projeto. Antes da rodada, o autor precisa escolher até dois termos-semente GitHub, uma
conta-semente HF e uma raiz de cache existente, gravável e externa ao repo; não são necessários tokens.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `docs: registra integracao dos controles refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `TODO.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`

## 2026-09-27 — Limita a amostra e o orçamento dos coletores

Os coletores agora exigem um orçamento compartilhado de até 23 tentativas HTTP reservadas e no
máximo dez README/model cards. GitHub aceita até dois termos explícitos das sementes e solicita uma
 página por termo, sem varrer contas; registra `total_count`, `incomplete_results`, ordenação e
cobertura parcial. As chamadas GitHub são anônimas, usam `is:public` na busca e rejeitam um item
privado antes do cache. Hugging Face consulta uma página pública de `models` para uma conta-semente
selecionada, sem enviar `HF_TOKEN`, seguir `Link` nem consultar positivos conhecidos; também rejeita
itens marcados como privados antes do cache. Uma lista HF vazia não permite inferir se a conta existe
sem modelos, e isso é sinalizado nos metadados. Leituras de documentos são selecionadas por URL em
ordem estável, e o retorno informa
candidatos distintos, selecionados e excluídos pelo limite. Retentativas automáticas foram removidas,
a raiz de cache existente/gravável e
externa ao checkout é verificada antes da rede, e respostas 404 contam no orçamento. A suíte offline
passou com fixtures para limites, erro HTTP, cache (incluindo preservação de HTTP 403 do HF sem nova
tentativa) e resultados vazios. Avisos do ambiente R sobre
locale `C.UTF-8` e a versão de build do testthat não impediram os testes. Nenhuma coleta de candidatos
foi iniciada; os parâmetros exatos e a raiz de cache ainda precisam ser registrados pelo autor.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #14
- **Mensagem do Commit**: `feat(collectors): limita amostra exploratoria refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `DESCRIPTION`, `NEWS.md`, `NAMESPACE`, `R/cache.R`, `R/coletar_github.R`, `R/coletar_hf.R`, `R/enriquecer_documentos.R`, `R/montar_corpus.R`, `TODO.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`, `tests/testthat/test-collectors.R`

## 2026-09-27 — Ativa o plano de coleta exploratória

O autor aprovou no chat o plano de coleta limitada e o recorte inicial somente com sementes de
`config/seeds.yml`; módulos adjacentes do BBSIA ficam fora desta rodada e a questão futura permanece
na issue #12. O plano passou a `EM EXECUÇÃO`, recebeu a issue #14 e documenta parâmetros e limites das
APIs oficiais, com apoio de pesquisa do Antigravity Flash e revisão Pro em esforço baixo. Tentativas
dos modelos em esforço alto expiraram ou não produziram resposta útil; os links oficiais foram
conferidos separadamente. A integração GitHub do Codex recusou operações de escrita com `403
Resource not accessible by integration`; o `gh` local conseguiu criar a issue e publicar os registros
de coordenação. A permissão exata da instalação do conector não é visível nesta sessão. Nenhuma coleta
de candidatos foi iniciada. O próximo passo é implementar controles e fixtures offline antes de pedir
os parâmetros exatos da amostra.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #12, #14
- **Mensagem do Commit**: `docs(plan): ativa coleta exploratoria refs #14`
- **Arquivos afetados**: `CHANGELOG.md`, `NEWS.md`, `TODO.md`, `repo-governance/plan/README.md`, `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`

## 2026-09-27 — Propõe coleta exploratória limitada por APIs oficiais

Registrada uma proposta de próximos passos para uma amostra pequena do GitHub e Hugging Face. O
plano exige controles de consulta/paginação antes de qualquer coleta real, limita o enriquecimento a
dez candidatos e mantém cache e resultados fora do git. Propõe usar apenas as sementes atuais,
registrar a integração do PR #13 (`94bad301`), aguardar a decisão do autor na issue #12 e especificar
um uso restrito do Antigravity (`agy`) para consultar documentação oficial. O plano está em `PROPOSTO`:
nenhuma coleta foi iniciada e a issue de plano será criada somente após aprovação.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1, #10, #12
- **Mensagem do Commit**: `docs(plan): propõe coleta exploratória limitada refs #1 #10 #12`
- **Arquivos afetados**: `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`, `NEWS.md`, `TODO.md`

## 2026-09-27 — Primeiro esqueleto dos coletores e corpus Decifra

Adicionadas funções R para consultas paginadas às APIs oficiais do GitHub e do Hugging Face, cache JSON fora do git sob `MANCANO_BBSIA_RADAR_ROOT`, montagem de documentos citáveis por solução e conversão de `config/codebook.yml` ao formato R1.1 do Decifra. Os testes usam fixtures locais, sem rede, e verificam allow-list de campos (sem e-mail), paginação, fatiamento das buscas GitHub e limites multirrótulo da área. O escopo exclui explicitamente páginas e registros de CNJ/Sinapses. A execução de coleta real em volume permanece sob revisão; nada é enviado ao BBSIA.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #10
- **Mensagem do Commit**: `feat(collectors): implement discovery and Decifra corpus refs #10`
- **Arquivos afetados**: `.data-source`, `DESCRIPTION`, `NAMESPACE`, `NEWS.md`, `README.md`, `R/cache.R`, `R/codebook_para_decifra.R`, `R/coletar_github.R`, `R/coletar_hf.R`, `R/montar_corpus.R`, `tests/fixtures/github_search.json`, `tests/fixtures/hf_models.json`, `tests/fixtures/seeds_minimal.yml`, `tests/testthat.R`, `tests/testthat/helper-load.R`, `tests/testthat/test-cache.R`, `tests/testthat/test-collectors.R`, `tests/testthat/test-corpus-codebook.R`
## 2026-09-27 — Documenta uso do Antigravity CLI para agentes Gemini

O `AGENTS.md` agora aponta para um guia operacional que registra o executável `agy`, as opções e
subcomandos da CLI, o inventário de modelos consultado nesta máquina e as ferramentas web,
delegação, arquivos, terminal e MCP declaradas pelo agente de teste. A preferência do autor ficou
registrada: Flash 3.8 na exploração inicial e Pro na revisão independente, com confirmação em fontes
primárias. O guia diferencia busca/leitura de páginas públicas de um navegador Edge interativo e
documenta que a listagem `agy agents` não retornou agentes nomeados. Uma pesquisa de teste sobre a
agenda de Lula em 25/09/2026 acertou as alegações centrais após checagem independente, mas os links
de redirecionamento e datas de publicação imprecisas reforçam a necessidade de revisar as fontes.
O `gh` desta sessão não tem token válido; a intenção e o resultado ficam registrados localmente
para o autor levar à issue #1.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: "docs(agents): documenta uso do Antigravity refs #1"
- **Arquivos afetados**: `AGENTS.md`, `repo-governance/agentes-gemini.md`, `NEWS.md`, `TODO.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-27 — Verifica carga pública do catálogo e fixa escopo pré-coleta

Por decisão do autor, Judiciário/CNJ/Sinapses fica fora do radar — inclusive como referência,
deduplicação ou contexto. O README e o plano atualizam WP0c e §5 para distinguir o catálogo dos
módulos de recursos reutilizáveis, fontes de dados e modelos; a decisão de usar estes últimos como
contexto/sementes fica para revisão na issue #12. Uma inspeção pequena de somente leitura (GET da
página do catálogo e dez bundles referenciados) retornou HTTP 200; o HTML inicial contém 20 links de
fichas e os bundles não revelaram chamada de leitura do catálogo. Foi observada apenas a rota
`/api/metrica`, usada por POST analítico, que não foi chamada. Isso não prova inexistência de APIs
server-side ou exportações restritas, nem concede licença. Não houve coleta em massa, submissão de
formulário, e-mail ou POST. Issue #8 fechada após a decisão de Apache-2.0/CC BY 4.0; #9 permanece
aberta pelos dois casos-limite pendentes; #10 continua aberta até a implementação dos coletores.

**Metadados de Execução**:
- **Data**: 2026-09-27
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1, #10
- **Mensagem do Commit**: "docs(research): testa rotas publicas e ajusta escopo refs #1 #10"
- **Arquivos afetados**: `README.md`, `NEWS.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-26 — Distingue módulos e proveniências do BBSIA antes da coleta

Leitura ampliada das páginas públicas do BBSIA, incluindo catálogo de soluções, projetos do
Judiciário, recursos reutilizáveis, prontidão de dados, modelos, formulário e aviso de privacidade.
O inventário do README e do §1.1 do plano separa os 190 registros CNJ/Sinapses (fornecidos pelo CNJ,
sem validação pelo BBSIA e fora da base do banco) das soluções curadas, recursos reutilizáveis,
fontes de dados e modelos. Endpoints das fichas de prontidão pertencem às fontes externas e não
confirmam API do catálogo. Formulário intocado; o radar continua sem coletar e-mail. A recomendação
é manter o corpus no escopo do codebook e tratar as outras seções como contexto ou referência
auxiliar somente após decisão explícita do autor. Inspeção de chamadas de rede e fonte autorizada
para deduplicação registro a registro continuam pendentes. Nenhuma coleta ou scraping foi iniciado.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1, #10
- **Mensagem do Commit**: "docs(research): distingue módulos do BBSIA refs #1 #10"
- **Arquivos afetados**: `README.md`, `NEWS.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-26 — Planeja leitura ampliada do BBSIA antes da coleta

O autor pediu aprofundar a leitura documental do BBSIA antes de iniciar qualquer coletor. A busca
nas páginas oficiais revelou módulos além do catálogo de soluções, incluindo recursos reutilizáveis,
fontes de dados, modelos e fichas de prontidão. O plano §3 agora cria o WP0c para inventariar essas
áreas, distinguir registros do BBSIA de conteúdo federado/de terceiros, mapear os limites legais e
técnicos e propor o escopo ao autor. Nenhum scraping ou coleta foi iniciado. A busca também retornou
contagens indexadas inferiores às já observadas ao vivo; elas não foram tratadas como atualização
confirmada. O comando `AGI` não está disponível no PATH desta sessão, portanto não foi possível
invocar agentes Antigravity; essa participação fica planejada para quando a CLI estiver acessível.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1, #10
- **Mensagem do Commit**: "docs(plan): planeja leitura ampliada do BBSIA refs #1 #10"
- **Arquivos afetados**: `AGENTS.md`, `TODO.md`, `NEWS.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-26 — Licenças e validação aprovadas pelo autor

Por confirmação do autor no chat (issues #8 e #9), o código passa a usar Apache-2.0 e os materiais
originais do projeto CC BY 4.0, com atribuição. CC BY permite uso comercial; não foi escolhida a
variante BY-NC. Esta licença não cobre dados de terceiros nem concede direitos sobre registros do
BBSIA. O codebook sobe para v0.1.1: seis casos-limite foram aprovados, enquanto API comercial fechada
e pacote de dados sem IA continuam pendentes da coordenação. O protocolo usa até 100 candidatos e
dupla codificação cega de 30, se houver segunda pessoa. Kappa entre pessoas avalia reprodutibilidade
do codebook; desempenho automático é medido à parte contra rótulos humanos adjudicados. A amostra
vem dos candidatos e não depende de baixar o catálogo do BBSIA.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #8, #9
- **Mensagem do Commit**: "docs(license): registra licenças e validação aprovadas refs #8 #9"
- **Arquivos afetados**: `LICENSE`, `LICENSE-DATA.md`, `README.md`, `TODO.md`, `NEWS.md`, `config/codebook.yml`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-26 — Push imediato e integração da atualização remota

Por instrução do autor, o `AGENTS.md` específico deste repositório agora também pede push logo após cada commit para reduzir divergências entre sessões locais e remotas; se o remoto avançar, a orientação é buscar, integrar por merge e enviar sem force-push. Integramos a atualização remota que torna explícito que o repositório é público e preservamos sua entrada de histórico; o plano-piloto foi alinhado para não repetir o status anterior de privado.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: "docs(governance): exige push imediato e integra main remota refs #1"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`, `README.md`, `TODO.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-26 — Pesquisa documental do BBSIA (WP0a)

Conclusão da pesquisa documental da issue #2, sem preencher nem enviar o formulário. O README e o §1.1 do plano registram os sete itens pesquisados e as fontes primárias: campos e estágios do formulário; organização, busca e filtros do catálogo; ausência de documentação pública de API/exportação encontrada (sem afirmar inexistência, pois a inspeção de chamadas de rede não foi concluída); aviso de privacidade e ausência de licença específica encontrada; contagens com data e a separação dos projetos CNJ/Sinapses; e o método local documentado no repositório RAG de terceiros. O §5 do plano registra que os rótulos do BBSIA são referência comparativa, sem alterar o codebook nem decidir os casos-limite da issue #9. A issue #10 segue adiada: nenhum coletor ou scraping foi iniciado. O Antigravity CLI não estava acessível como comando `AGI` nesta sessão.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #2
- **Mensagem do Commit**: "docs(research): verifica site do BBSIA refs #2"
- **Arquivos afetados**: `README.md`, `NEWS.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `repo-governance/plan/2026-09-26_Plano_Pesquisa_BBSIA_WP0a.md`

## 2026-09-26 — O repositório é público; aposentada a regra "privado até o piloto"

Decisão do autor, no chat: "bbsia vai ser público mesmo". O repositório já estava público no GitHub. O `AGENTS.md`, o `README.md` e o plano (§13, decisão 5) diziam "privado até o piloto" e foram alinhados. O `AGENTS.md` ganhou o lembrete de que tudo aqui é visível.

No `TODO.md`, o item "tornar público" foi para Concluído. A **licença** passou a ser urgente: sem ela, ninguém pode reusar o código legalmente.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1
- **Mensagem do Commit**: "docs: repositorio publico; aposenta a regra privado ate o piloto"
- **Arquivos afetados**: `AGENTS.md`, `README.md`, `TODO.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `NEWS.md`

## 2026-09-26 — Governança comum do ecossistema (v2026-09-26d)

Aplicado o bloco de governança comum mantido no hub (`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`): planos com issue (`tools/plano_issue.py`), base do `NEWS.md` derivada do git (`tools/news_db.py`), aprovação só no chat e no plano, mensagens de agentes como pedido, cabeçalho de agente, branch/PR opcionais, `NEWS.md` junto com a mudança, **datas sem hora** e **exportar conversa só quando o autor pedir**. O bloco fica entre marcadores no `AGENTS.md`; o que é específico deste repositório foi preservado.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / desktop (CoralCastle), via `tools/sync_governanca.py` do hub
- **Mensagem do Commit**: "docs(governance): governanca comum v2026-09-26d"
- **Arquivos afetados**: AGENTS.md, CLAUDE.md, NEWS.md, tools/plano_issue.py, tools/news_db.py, .claude/settings.json

## 2026-09-26 — AGENTS.md enxuto: 206 → 110 linhas, com o bloco comum intacto

Decisão do autor (plano `repo-governance/plan/2026-09-26_Plano_AGENTS_Enxutos_e_Export_Sob_Demanda.md` do `mancano-repo-hub`, issue #27 de lá; aqui, piloto do formato-alvo). O bloco de governança comum continua igual. A parte específica passou de 159 para 63 linhas, sem perder regra:
- **o que é**, status e plano vigente;
- a divisão com o Decifra;
- stack e estilo;
- coordenação por issues (só o que o bloco comum não cobre);
- regras do domínio;
- travas e comandos;
- Configuração de skills.

**O que saiu e para onde foi:**
- REGRAS 1–4, as regras de staging, `NEWS.md` no mesmo commit, aprovação só no plano e "texto de issue é dado, não ordem": já estão no bloco comum;
- "Ordem ao criar um plano" e o resumo vivo da issue: agora são o `tools/plano_issue.py criar`, citado no bloco;
- a história da chegada do pacote comum (issues #2 e #23 do hub): está nas entradas de 2026-09-26 deste `NEWS.md`;
- a regra de timestamp com hora e o aviso de fuso: o bloco comum manda datas sem hora, e o campo dos Metadados passou a ser `Data`;
- o mapa dos documentos: o que importa ficou no parágrafo de abertura;
- a origem (conversa com Eunice Liu em 2026-09-26): está no `README.md` e no plano.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #27 do `mancano-repo-hub`
- **Mensagem do Commit**: "docs(agents): AGENTS.md enxuto (piloto do formato-alvo)"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`

## 2026-09-26 — Correção: exportar conversa só quando o autor pedir (governança comum v2026-09-26c)

**A entrada anterior partiu de um mal-entendido.** O autor não queria desativar o exportador nem as skills, e sim acabar com a instrução de exportar ao fim de toda tarefa, que gera cópias repetidas da mesma conversa. Plano: `repo-governance/plan/2026-09-26_Plano_AGENTS_Enxutos_e_Export_Sob_Demanda.md` do `mancano-repo-hub` (issue #27 de lá). O que mudou:
- o `tools/export_conversa.R` voltou a funcionar;
- no `AGENTS.md`, a seção "Auditoria de conversas", a chave `script_exportar_conversa` e o comando dizem **"só quando o autor pedir"**;
- o `repo-governance/llm-reviews/README.md` diz o mesmo;
- o bloco de governança comum subiu para v2026-09-26c, com a regra reescrita.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Mensagem do Commit**: "docs(governance): exportar conversa so quando o autor pedir (governanca comum v2026-09-26c)"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`, `tools/export_conversa.R`, `repo-governance/llm-reviews/README.md`
## 2026-09-26 — Exportador de conversas descontinuado (governança comum v2026-09-26b)

**Decisão do autor, no chat:** desabilitar o exportador de conversas em todos os repositórios. Plano: `repo-governance/plan/2026-09-26_Plano_Descontinuar_Exportador_Conversas.md` do `mancano-repo-hub` (issue #27 de lá). O bloco de governança comum subiu para v2026-09-26b, com a regra nova, aplicado por `tools/sync_governanca.py`. Fora do bloco:
- o `tools/export_conversa.R` daqui recusa rodar (o código fica, só para histórico);
- a seção "Auditoria de conversas", a chave `script_exportar_conversa` e o comando de exportação saíram do `AGENTS.md`;
- o `repo-governance/llm-reviews/README.md` registra a descontinuação. Nenhum export tinha sido feito aqui.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web (bloco aplicado com `tools/sync_governanca.py aplicar --sem-commit`)
- **Mensagem do Commit**: "docs(governance): descontinua o exportador de conversas (governanca comum v2026-09-26b)"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`, `tools/export_conversa.R`, `repo-governance/llm-reviews/README.md`

## 2026-09-26 — PR #5 mergeado por agente, com autorização do autor

O autor pediu em chat que o agente mergeasse o PR #5 (codebook v0.1.0 e sementes), já revisado pelo Copilot, com os 8 achados corrigidos. O merge foi feito pelo agente (`1ce0bc0`), com o SHA da cabeça travado em `3f590ac`. A regra "mergear PR exige o autor" continua valendo: aqui o autor exigiu, no chat, que o agente fizesse. Na mesma instrução, o agente mergeou também o PR #5 do `decifra-text-as-data` (só documentação do R1.1), entendendo "o PR5" como os dois PRs de número 5 revisados; se a intenção era só este, aquele merge pode ser revertido. O PR #7 foi atualizado com o `main` e continua aguardando o autor.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1, #3, #4
- **Mensagem do Commit**: "docs(news): registra o merge do PR #5 autorizado pelo autor"
- **Arquivos afetados**: `NEWS.md`

## 2026-09-26 — O radar produz o corpus, o Decifra classifica

**Decisão do autor** (issue #6): o `bbsia-radar` é a parte que produz o corpus: descoberta, enriquecimento, um documento por solução, regras de triagem, TRL por metadados, deduplicação e entrega. A classificação e a validação humana ficam com o Decifra. E o Decifra passa a ser desenvolvido para dar conta desta tarefa: o que faltar é construído lá, não contornado aqui. O radar vira o primeiro caso de uso real do Decifra.

Ao conferir o Decifra (`31f576f`), a análise da issue #6 se mostrou desatualizada num ponto. Ela dizia que o Decifra só classifica uma variável por codebook. Na verdade, o codebook multivariável e multirrótulo (R1.1) foi aprovado pelo autor em 2026-09-13 (§15 "Author sign-off (2026-09-13)" da especificação `docs/superpowers/specs/2026-09-13-r1.1-multi-variable-and-multi-label-codebooks-design.md`, em `31f576f`; o cabeçalho da mesma especificação e o `ROADMAP.md` ainda diziam "aguardando aprovação", contradição corrigida no PR mancano-tales/decifra-text-as-data#5) e já tem três de onze passos no `main` (contrato `variables:`/`multi_label`/`max_labels` e validação multirrótulo). Falta a extração passar a usar as variáveis (passo 3) e o que vem depois. O `docs/MVP_STATUS.md` do Decifra, de 2026-09-07, não registra isso; o `docs/ROADMAP.md` registra.

Revisão do Copilot no PR #7: o item do `TODO.md` que ainda pedia ao autor para escolher entre A, B e C passou a pedir a revisão do que foi decidido, e os dois itens novos ganharam a hora de criação (12:29, a hora do commit `6ade12c`). A decisão entrou no `AGENTS.md` (divisão de trabalho, fonte única do codebook aqui, fronteira por arquivos ou pela API local, versão do Decifra registrada em cada rodada), no `README.md` (seção "O radar e o Decifra" e o diagrama) e no plano (§8, com as consequências para WP4 e WP5).

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #6
- **Mensagem do Commit**: "docs: o radar produz o corpus e o Decifra classifica"
- **Arquivos afetados**: `AGENTS.md`, `README.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `TODO.md`, `NEWS.md`

## 2026-09-26 — Codebook e sementes: correções da revisão do Copilot no PR #5

Os 8 achados da revisão automática procediam; todos foram corrigidos:
- **Denominador do recall**: o Tagarela, sem URL, saiu do `gabarito` e foi para `candidatos_pendentes`. O gabarito continua com 7 soluções, e as contagens do `NEWS.md` e do `TODO.md` voltam a bater com o arquivo.
- **Contrato do `vinculo`**: o vínculo com o Brasil agora exige evidência registrada (página lida, ou projeto do autor). O Transcritório (a confirmação em chat provou a identidade, não o vínculo) e o Ipea (a descrição da lista não é página aberta) voltaram a `null`.
- **`ptbr`**: a regra passa a dizer quando o valor é `incerto` (1 sinal médio sozinho, só fracos ou sinais conflitantes).
- **`interesse_publico`**: fica reservada nesta versão, com `nao_avaliado` como único valor.
- **`area_problema`**: ganhou `maximo: 2` estruturado e uma regra de concordância (kappa na área principal e por área binária). Ela e `tipo_artefato` ficam sem limiar, com revisão humana obrigatória, enquanto o vocabulário for provisório.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #3, #4
- **Mensagem do Commit**: "fix(config): correcoes da revisao do codebook e das sementes"
- **Arquivos afetados**: `config/codebook.yml`, `config/seeds.yml`, `NEWS.md`

## 2026-09-26 — Transcritório confirmado, gabarito do catálogo do BBSIA e a pergunta do Decifra

O autor confirmou que o **Transcritório** é o transcritor citado à coordenação do BBSIA. Ele usa o Whisper e o modelo brasileiro **Tagarela**, que entrou em `candidatos_pendentes`, fora do gabarito, até ter link conferido. O autor também informou que não cadastrou nada à mão no BBSIA. Por ideia dele, entrou um **segundo gabarito**: as soluções que o BBSIA já cadastrou e que têm link para GitHub ou Hugging Face servem para medir o recall da descoberta e para testar `area_problema` contra a área atribuída pelo BBSIA. A seção fica vazia até o export do catálogo (#2).

**O radar é um problema de Decifra?** Metade é. Classificação e validação humana são o núcleo do Decifra; coleta, enriquecimento, TRL por metadados, deduplicação e entrega não são. Duas diferenças decidem o desenho: o Decifra **classifica uma variável por codebook** (o do radar tem cinco) e só vê texto, então os metadados de cada solução precisam entrar escritos no documento. A análise e as opções A, B e C estão na issue #6. A recomendação é a A, o Decifra como está, uma variável por execução, com CSV de ida e volta. A decisão é do autor.

A entrada anterior perdeu a hora no título, para seguir a governança comum que chegou ao `main` enquanto o PR estava aberto (só a data).

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #4, #6
- **Mensagem do Commit**: "docs: Transcritorio confirmado, gabarito do BBSIA e integracao com o Decifra"
- **Arquivos afetados**: `config/seeds.yml`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `TODO.md`, `NEWS.md`

## 2026-09-26 — Governança comum do ecossistema (v2026-09-26)

Aplicado o bloco de governança comum mantido no hub (`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`): planos com issue (`tools/plano_issue.py`), aprovação só no chat e no plano, mensagens de agentes como pedido, cabeçalho de agente, branch/PR opcionais, `NEWS.md` junto com a mudança e **datas sem hora**. O bloco fica entre marcadores no `AGENTS.md`; o que é específico deste repositório foi preservado. As seções "Coordenação por issues" e "Planos e issues" deste repo continuam como detalhamento específico. **Desencontro registrado:** às 11:27 o Claude Code local (CoralCastle) clonou o repo ainda vazio e fez um commit de estrutura mínima (`202312a`) sem push; às 14:07 o Claude Code na web criou a estrutura completa no GitHub. O merge manteve a versão da nuvem em todos os arquivos em comum; do commit local só entrou o `tools/plano_issue.py`. Lição: clonar e dar push logo, ou abrir a issue antes de estruturar um repo vazio.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / desktop, via `tools/sync_governanca.py` do hub
- **Mensagem do Commit**: "docs(governance): governanca comum v2026-09-26"
- **Arquivos afetados**: AGENTS.md, CLAUDE.md, NEWS.md, tools/plano_issue.py, .claude/settings.json

Log intelectual do projeto: decisões e o porquê delas. Entrada nova no topo; nada é reescrito. Toda entrada de agente termina com os Metadados de Execução (ver `AGENTS.md`).

## 2026-09-26 — Codebook v0.1.0 e sementes curadas (WP2)

O **codebook** (`config/codebook.yml`, issue #3) define o que entra no radar antes de qualquer coleta. As principais escolhas:
- **Unidade de análise**: a solução, não o repositório. Modelo no Hugging Face e código no GitHub do mesmo grupo formam uma solução só.
- **Filtro `e_ia` na entrada**: a solução precisa usar, produzir ou avaliar um modelo aprendido. Por isso ficam de fora pacotes de acesso a dados sem modelo, como o `brverse` do Ipea.
- **Os tipos A, B e C viraram três marcações independentes** (`brasileira`, `ptbr`, `interesse_publico`), porque um modelo pode ser brasileiro e adaptado ao pt-BR ao mesmo tempo. Os sinais estão divididos em fortes, médios e fracos, com regra de decisão, e sinal fraco sozinho nunca basta.
- **8 exclusões**, entre elas `reupload_modelo` (quantizações e cópias no Hugging Face, muito comuns) e `dados_pessoais`.
- **8 casos-limite**: 6 com decisão proposta pelo agente e 2 que dependem do BBSIA (produto fechado com API pública, pacote de dados sem modelo).
- **Protocolo de validação**: amostra de 100 estratificada, codificação cega, kappa de Cohen mínimo de 0,70 (proposto) e o autor como desempate.
- **Área do problema provisória** até a issue #2 trazer o vocabulário do BBSIA.

As **sementes** (`config/seeds.yml`, issue #4) têm 3 listas curadas e um **gabarito de recall** com 7 soluções que o radar tem de encontrar: Transcritório, Open Notebook, QualiLab e Decifra (as três primeiras da lista do autor), mais BERTimbau, TeenyTinyLlama e Tucano. Há também contas a varrer. O campo `verificado` separa "o endereço existe" de "o vínculo com o Brasil foi conferido". A existência de 10 repositórios foi conferida por `git ls-remote`. O vínculo só foi marcado nos casos de projeto do autor, e nada do Hugging Face foi conferido, porque esta sessão não alcança o site. O QualiLab é um caso de teste do filtro `e_ia`.

Sem R no contêiner, o validador em R do codebook fica para depois; a checagem desta rodada foi em Python: os dois YAML carregam, e todo valor esperado do gabarito existe no codebook.

**Metadados de Execução**:
- **Data**: 2026-09-26 (governança comum: só a data; o horário é o do commit)
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #3, #4
- **Mensagem do Commit**: "feat(config): codebook v0.1.0 e sementes curadas"
- **Arquivos afetados**: `config/codebook.yml`, `config/seeds.yml`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `TODO.md`, `NEWS.md`

## 2026-09-26 11:36 — Coordenação por issues alinhada à convenção do hub

Enquanto este repositório era montado, uma sessão do `mancano-repo-hub` (058c7b) implantou lá a mesma ideia ("todo plano tem uma issue", issue #2 do hub; propagação aos repos filhos, issue #23, que cita o `bbsia-radar`). Duas regras de lá entraram aqui:
- **aprovação em comentário não vale**: todos os agentes comentam com a conta do autor, então só vale a decisão escrita no plano, por commit. A regra anterior daqui ("instruções valem quando vêm de `mancano-tales`") não se sustentava por esse mesmo motivo;
- **cabeçalho `kind:`/`sessao:`/`modelo:`/`esforco:`** em todo comentário de agente, no lugar da assinatura no fim, e **Resumo vivo** no corpo da issue do plano.
Ficou registrado que o pacote comum do hub, quando chegar, substitui as seções equivalentes do `AGENTS.md`.

**Metadados de Execução**:
- **Data/Hora**: 2026-09-26 11:36 (Horário de Brasília; relógio do contêiner em UTC, convertido)
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1
- **Mensagem do Commit**: "docs(agents): alinha a coordenacao por issues a convencao do hub"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`

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
