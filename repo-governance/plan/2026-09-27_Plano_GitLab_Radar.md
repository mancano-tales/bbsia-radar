---
tipo: Plano
titulo: "Adicionar descoberta de projetos públicos do GitLab ao bbsia-radar"
issue: 14
status: ATIVO
criado: "2026-09-27 15:24"
concluido: null
autor_humano: "Tales Mançano"
aprovacao_autor: "No chat em 2026-09-27, o autor aprovou a inclusao de GitLab.com antes da primeira amostra e autorizou seguir o plano e rodar analises exploratorias. Recorte aprovado: buscas GitHub/GitLab por Transcritorio e BERTimbau, conta HF neuralmind, ate 25 tentativas HTTP reservadas, 10 documentos, README GitLab ate 256 KiB e cache externo. Esta autorizacao nao inclui publicacao de candidatos, ativacao do Pages ou envio ao BBSIA."
agentes:
  orquestrador: "Codex / GPT-6 / desktop"
  executor: null
  auditor: "GPT-6-Sol (rascunho revisado em 2026-09-27)"
tarefas:
  - { desc: "WP1 — aprovar o recorte do GitLab e revisar contrato, consulta e orçamento", status: concluida }
  - { desc: "WP2 — implementar coleta pública pela API oficial do GitLab com cache e limites", status: concluida }
  - { desc: "WP3 — integrar GitLab à normalização, sementes, corpus e documentação", status: concluida }
  - { desc: "WP4 — executar a amostra aprovada e manter dados não revisados no cache externo", status: concluida }
relacionados: ["repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md", "repo-governance/plan/2026-09-27_Plano_Website_Quarto.md"]
news: []
---

# Plano: incluir GitLab nas fontes do radar

> **Issue: #14 (coordenação da coleta exploratória; o acesso de escrita à issue está bloqueado nesta sessão).**

## Objetivo

Adicionar o GitLab como terceira fonte de descoberta do `bbsia-radar`, ao lado do GitHub e do
Hugging Face. A proposta é identificar projetos relevantes publicados no GitLab.com, normalizá-los
no corpus atual e permitir que sejam avaliados pelo Decifra e pela revisão humana. A inclusão no
relatório público só ocorre depois das mesmas revisões e controles de proveniência usados para as
outras fontes.

O autor aprovou no chat, em 2026-09-27, a inclusão do GitLab.com antes da primeira amostra e a
execução exploratória com os parâmetros registrados ao fim deste plano. A autorização cobre consultas
às APIs oficiais e cache externo, mas não cobre publicação de resultados nem envio ao BBSIA.

## Estado atual e dependências

- A branch inclui um coletor GitLab.com, integração com o enriquecimento limitado e documento do
  corpus. A suíte offline confirma chamadas anônimas, cache, validação de visibilidade, limites do
  README e preservação da semântica de atividade do projeto.
- A coleta exploratória está na issue #14 e no
  [`2026-09-27_Plano_Coleta_Exploratoria.md`](2026-09-27_Plano_Coleta_Exploratoria.md). O autor
  aprovou no chat os termos `Transcritorio` e `BERTimbau` para GitHub/GitLab e a conta HF `neuralmind`;
  a primeira rodada autorizada foi executada e os resultados seguem no cache externo.
- O autor também solicitou um site Quarto. A estrutura HTML/PDF está na PR #18, que continua
  aguardando revisão do autor; ela documenta o método e registra que a amostra ainda não passou por
  classificação no Decifra nem revisão humana.
- O coletor e a documentação cobrem as três fontes. A amostra de 2026-09-27 foi executada e seus
  resultados agregados estão registrados no plano de coleta; as respostas e documentos continuam
  somente no cache externo. A issue #14 não pôde receber anúncio ou marcos porque a API retornou 403
  e `gh` não tem autenticação válida nesta sessão.

## Recorte técnico proposto

1. **Instância inicial:** GitLab.com somente. Instâncias self-managed ficam fora da primeira versão, pois cada uma pode ter configurações e limites próprios.
2. **Descoberta:** usar a API REST oficial v4, `GET /projects`, sem token, com `search=<termo>`, `visibility=public`, `simple=true`, `page=1`, `per_page=100`, `order_by=created_at` e `sort=desc`. `search` faz correspondência parcial, sem distinção entre maiúsculas e minúsculas, em nome, caminho ou descrição; não busca o conteúdo integral do repositório. Termos múltiplos são combinados com AND. Não presumir equivalência entre grafias com e sem acento. Registrar consulta, parâmetros, `Link`/página seguinte e truncamento; não seguir a segunda página nem inferir que resultado vazio significa inexistência.
3. **Acesso público e contrato de campos:** chamadas anônimas retornam somente projetos públicos e campos limitados. Exigir `visibility == "public"` antes de persistir no cache; ausência do campo ou valor diferente rejeita o registro. Confirmar em fixtures offline quais campos `simple=true` fornece; campos ausentes ficam explicitamente como NA e não podem ser completados por consultas extras fora do orçamento.
4. **Enriquecimento:** para os candidatos selecionados pelo limite global, tentar somente o arquivo `README.md` na raiz. Atualizar `HEAD /projects/:id/repository/files/README.md?ref=HEAD` em cada rodada e ler `X-Gitlab-Size`, `X-Gitlab-Commit-Id` e `X-Gitlab-Blob-Id`; o teto máximo fixo é 256 KiB. Se o arquivo não existir ou exceder o teto, não fazer GET. Para arquivo elegível, buscar pelo endpoint de arquivo usando o commit retornado no HEAD, com caminho codificado e redirecionamentos automáticos desabilitados. A chave de cache do GET inclui a revisão imutável. Validar tamanho e Base64 antes de guardar o conteúdo. Cada tentativa de rede consome o orçamento; o limite máximo continua sendo duas por documento (HEAD + GET). Não procurar nomes/caminhos alternativos, nem baixar/clonar o repositório inteiro. Erros transitórios respeitam `Retry-After` ou expiram; não há retentativa automática dentro da mesma chamada.
5. **Orçamento:** manter no máximo dez documentos enriquecidos no total entre GitHub, HF e GitLab. Reservar até 25 tentativas HTTP na rodada: duas buscas GitHub + uma listagem HF + duas buscas GitLab + dez documentos com no máximo duas tentativas cada. O teto está implementado em `radar_novo_orcamento()` e nos validadores; registrar tentativas reservadas, respostas e cobertura. Interromper em `429` e nunca ampliar o orçamento local usando o limite amplo do serviço.
6. **Normalização e deduplicação:** mapear a origem GitLab no contrato comum (plataforma, ID, nome, descrição, URL canônica, proprietário/grupo, tópicos e atividade quando presentes). Manter `last_activity_at` com sua origem e semântica; não tratá-lo como data de commit/atualização de código nem como evidência de TRL. Não fundir registros entre plataformas por semelhança de nome: até existir associação explícita e revisada de URLs em `config/seeds.yml`, cada projeto GitLab fica como candidato provisório, com proveniência preservada.
7. **Cache e privacidade:** guardar respostas aprovadas e documentos somente na raiz externa já configurada, com chave de cache por endpoint, parâmetros, projeto, caminho e revisão imutável. Guardar apenas cabeçalhos necessários de paginação, tamanho, revisão e limite de chamadas. Não enviar tokens, não coletar e-mails ou dados privados e não publicar texto integral de README. A tabela pública continua condicionada a revisão de direitos, atribuição, Decifra e validação humana.

## Etapas

### WP1 — decisões e contrato

- O autor aprovou no chat GitLab.com como terceira fonte antes da amostra; os termos exatos `Transcritorio` e `BERTimbau` para GitHub/GitLab; e a conta HF `neuralmind`.
- O autor aprovou também GitLab anônimo, uma página por busca, `created_at desc`, README raiz até 256 KiB via HEAD + GET, até dez documentos e orçamento de 25 tentativas reservadas. A aprovação está registrada neste plano e no histórico.

### WP2 — coletor e controle

- Criado `R/coletar_gitlab.R` para busca, validação fail-closed de visibilidade, cache externo, paginação limitada, HEAD/GET limitado a 256 KiB, revisão imutável e normalização.
- Integrar cada tentativa ao orçamento compartilhado e aos registros de cobertura/erro das fontes atuais.
- Criados fixtures e testes offline para visibilidade, truncamento, `HEAD`/`GET`, tamanho/Base64, cabeçalhos, erros temporários e limites. A suíte passou após os ajustes finais.

### WP3 — corpus e documentação

- Integrar `gitlab` ao vocabulário de plataformas e ao fluxo do corpus; só associar URLs multiplataforma depois de vínculo explícito revisado em sementes.
- Conferir `coletar → enriquecer → documento citável → Decifra`, preservando candidatos provisórios e suas origens.
- Atualizados README, descrição do pacote, instruções de agentes e NEWS para enumerar GitLab e explicar limites de cobertura. A documentação de método na PR #18 também passou a incluir GitLab e a amostra exploratória.

### WP4 — primeira amostra

- A rodada foi executada em 2026-09-27 com os termos GitHub/GitLab `Transcritorio` e `BERTimbau`, HF `neuralmind`, até 25 tentativas e dez documentos. Foram encontrados 104 registros: GitHub 101, GitLab 1 e HF 2, com 104 URLs únicas. Uma busca GitHub por BERTimbau foi parcial (100 de 134); as demais buscas retornaram 0–2 resultados conforme a fonte e o termo.
- Foram selecionados dez documentos: oito GitHub, um GitLab e um HF. Nove foram lidos e um README GitHub estava ausente. A rodada reservou 17 de 25 tentativas, não teve erros HTTP e o escaneamento dos arquivos exportados não encontrou e-mails. Quatorze candidatos vieram sem descrição; dois ficaram ligados a sementes existentes.
- Respostas, documentos e relatório exploratório permanecem somente no cache externo. A amostra não foi classificada pelo Decifra, revisada por pessoa, comparada registro a registro com o BBSIA ou publicada. A issue #14 continua sem os marcos porque a API retornou 403 e `gh` não tem autenticação válida; o autor pode copiar este resumo para a issue ao revisar o PR.

## Critérios de aceite

- O coletor usa somente a API oficial do GitLab.com, sem token, e falha fechado se não confirmar `visibility=public`.
- Cada consulta usa termos, ordenação e página aprovados; o método explica a busca parcial por nome/caminho/descrição, o truncamento e o que não pode ser inferido.
- O README passa por HEAD e pelo teto em bytes antes do GET; o GET usa o commit imutável anunciado no HEAD. Cada tentativa real de rede consome o orçamento, limitado a duas por documento. O cache armazena apenas cabeçalhos permitidos e erros temporários expiram conforme `Retry-After` ou prazo de segurança.
- Metadados mantêm URL e semântica da fonte. Só há fusão multiplataforma com vínculo revisado explícito; sem isso, os candidatos ficam provisórios.
- README, About e método listam GitLab sem afirmar cobertura completa.
- A amostra real foi executada com a aprovação do autor registrada neste plano e no plano de coleta; seus dados continuam privados no cache externo até revisão.

## Referências oficiais consultadas em 2026-09-27

- [GitLab Projects API](https://docs.gitlab.com/api/projects/): campos de busca, visibilidade, ordenação, termos múltiplos e resultado anônimo limitado.
- [GitLab Repository Files API](https://docs.gitlab.com/api/repository_files/): acesso anônimo a arquivos públicos, HEAD com `X-Gitlab-Size`, `X-Gitlab-Commit-Id` e `X-Gitlab-Blob-Id`, conteúdo Base64 e `ref=HEAD`.
- [GitLab REST API — paginação](https://docs.gitlab.com/api/rest/): `per_page` máximo 100 e cabeçalhos/páginas.
- [Visibilidade pública no GitLab](https://docs.gitlab.com/user/public_access/): projetos públicos acessíveis sem autenticação.

A revisão do plano por GPT-6-Sol e a revisão independente da implementação foram incorporadas. O Antigravity CLI está instalado, mas nesta sessão reportou que não há login; não foi possível obter revisão Gemini.

## Aprovação do autor registrada

- No chat de 2026-09-27, o autor aprovou este plano, a inclusão de GitLab.com antes da primeira amostra e a execução das análises exploratórias limitadas.
- Consultas autorizadas: GitHub e GitLab com os termos exatos `Transcritorio` e `BERTimbau`; Hugging Face com a conta-semente pública `neuralmind`.
- Limites autorizados: GitLab.com anônimo, somente uma página por busca com ordenação `created_at desc`, README da raiz até 256 KiB via HEAD + GET, no máximo dez documentos no total e 25 tentativas reservadas por rodada.
- A aprovação autoriza coleta exploratória e cache externo, mas não autoriza publicar candidatos, ativar o GitHub Pages ou enviar qualquer dado ao BBSIA.
