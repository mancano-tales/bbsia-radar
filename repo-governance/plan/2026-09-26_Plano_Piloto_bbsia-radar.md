---
tipo: Plano
titulo: "Piloto do bbsia-radar: soluções de IA brasileiras no GitHub e no Hugging Face para o BBSIA"
issue: 1
status: ATIVO # aprovado pelo autor em 2026-09-26; WP0a concluído documentalmente; execução do piloto segue pendente
criado: "2026-09-26 09:15"
concluido: null
agentes:
  orquestrador: "Claude Opus 5.5 (Claude Code on the web)"
  executor: null
  auditor: null
autor_humano: "Tales Mançano"
tarefas:
  - { desc: "WP0a — Verificar site e formulário do BBSIA com fontes (issue #2)", status: concluido, data: "2026-09-26" }
  - { desc: "WP0b — Perguntas à coordenação do BBSIA (Eunice Liu), depois do piloto ou do WP0a", status: pendente, data: null }
  - { desc: "WP1 — Repositório público mancano-tales/bbsia-radar com governança: AGENTS.md, README, TODO, plano, tools, hooks", status: concluido, data: "2026-09-26 11:03" }
  - { desc: "Guia operacional do Antigravity CLI para pesquisa e revisão de agentes Gemini (autorizado pelo autor no chat; issue #1)", status: concluido, data: "2026-09-27" }
  - { desc: "WP0c — Leitura ampliada e inspeção pública pequena do BBSIA (issue #1; revisão de escopo na #12)", status: concluido, data: "2026-09-27" }
  - { desc: "WP2 — Codebook: o que conta como solução 'brasileira', 'adaptada ao pt-BR' e 'de interesse público adaptável' (issue #9; v0.1.1 com dois casos pendentes)", status: em_revisao, data: "2026-09-27" }
  - { desc: "WP3 — Descoberta: coletores GitHub, Hugging Face e GitLab.com + sementes curadas (listas awesome, orgs conhecidas)", status: pendente, data: null }
  - { desc: "WP4 — Enriquecimento: metadados, README/model card, sinais de manutenção", status: pendente, data: null }
  - { desc: "WP5 — Classificação (regras + LLM contra o codebook) e validação humana por amostra", status: pendente, data: null }
  - { desc: "WP6 — Maturidade estimada (TRL provável) a partir de metadados", status: pendente, data: null }
  - { desc: "WP7 — Deduplicação contra o catálogo do BBSIA", status: pendente, data: null }
  - { desc: "WP8 — Entrega: planilha no formato do formulário + relatório; piloto com ~30 soluções antes do volume", status: pendente, data: null }
relacionados:
  - "mancano-repo-hub: repo-governance/plan/2026-09-26_Plano_Mapeamento_Solucoes_IA_Brasileiras_BBSIA.md (versão original deste plano, escrita na raiz do ecossistema)"
  - "awesome-open-source-research-tools (lista curada do autor; sementes e possível destino de parte dos achados)"
  - "decifra-text-as-data (classificação por LLM contra codebook, validada contra codificação humana — candidata ao WP5)"
news:
  - "2026-09-26 11:03 — Criação do repositório e deste plano (NEWS.md)"
---

# Piloto do bbsia-radar

> **Issue: #1.** Discussão, anúncios e coordenação acontecem na issue; este arquivo é o contrato estruturado e o status oficial (ver `AGENTS.md` § Planos e issues). Versão original: plano de 2026-09-26 09:15 no `mancano-repo-hub`, escrito antes de o repositório existir.

## 1. Contexto

O **Banco Brasileiro de Soluções de IA (BBSIA)** (https://bancobrasileiro.ia.br/) é mantido pelo
Laboratório de Inovação em Inteligência Artificial (LIIA) da Enap, com o Ibict e o CIIA. Reúne
soluções de IA para o setor público (ministérios, prefeituras, universidades, ICTs) e as organiza
**pelo problema que resolvem, não pela tecnologia**. Quem cadastra informa o nível de reuso e a
dependência tecnológica da solução.

Em 2026-09-26 o autor, voluntário no BBSIA, combinou com **Eunice Liu** (Enap, gerente de programas
de IA na gestão pública e coordenadora do BBSIA) uma primeira versão de um mapeamento automático:

> "Mapear soluções nacionais, via crawling e raspagem de repositórios (Gits, HuggingFace etc.) seria
> bem legal! Soluções brasileiras ou adaptadas para português brasileiro, ou de interesse público que
> poderiam ser adaptadas." — Eunice Liu
>
> Sobre o critério de maturidade: **"todos os TRLs"**. Sobre envio via API: **"com certeza!"** (a
> resposta não deixa claro se já existe uma API ou se a ideia é bem-vinda; ver §3).

Três escopos, então: (a) soluções brasileiras; (b) soluções adaptadas ao português brasileiro;
(c) soluções de interesse público que poderiam ser adaptadas. Nenhuma é descartada por maturidade:
a maturidade vira **coluna**, não filtro.

### 1.1 O que foi verificado e o que não foi

Pesquisa documental no site público e no formulário, sem envio de dados, em 2026-09-26 (issue #2).
As fontes primárias consultadas estão ligadas em cada item e detalhadas no comentário de resultado
da issue.

| Item | Evidência e limite |
|---|---|
| Formulário | A página pública lista dados de contato/instituição, localização, solução, estágio, uso, abertura/reuso, links e consentimento; os campos de escolha e os obrigatórios foram inspecionados sem submissão. Ver [formulário](https://bancobrasileiro.ia.br/contribuir). |
| Maturidade | Há estágios descritivos de pesquisa/PoC até uso em produção, mas não campo numérico TRL 1–9. “Todos os TRLs” permanece como orientação verbal da coordenação; TRL no radar é estimativa própria. |
| Catálogo | Busca por problema, título, órgão e tags; filtros por público (usar ou desenvolver/integrar), tipo (aplicação, código/biblioteca, API, agente, modelo, pipeline, guia/metodologia) e área (Saúde, Educação, Segurança Pública, Meio Ambiente, Gestão Pública, Administração/Processos, Outro). A página mostrava 20 publicadas; `/numeros` mostrava 154 no total, sendo 20 publicadas e 134 em análise. Ver [catálogo](https://bancobrasileiro.ia.br/catalogo). |
| API/exportação/importação | Em 2026-09-27, GET da página `/catalogo` e dos dez bundles que ela referencia retornaram HTTP 200. O HTML inicial contém 20 links/identificadores de fichas públicas; nos bundles não apareceu chamada de leitura do catálogo. A única rota de API observada foi `/api/metrica`, usada por um POST analítico; não foi chamada. Evidência compatível com listagem renderizada no servidor, mas não prova que não exista API, exportação administrativa/restrita ou rota interna. Sem botão/documentação pública de CSV/JSON ou importação em lote. |
| Termos, privacidade, licença | O [aviso de privacidade](https://bancobrasileiro.ia.br/privacidade) prevê publicação/reuso das informações das soluções e mantém contatos fora das páginas públicas. Não foi encontrada licença específica do catálogo nem termo geral nas páginas consultadas. Isso não concede ao radar direitos sobre dados do BBSIA; consulte WP0b antes de reutilizá-los. A licença deste projeto está decidida no §13. |
| Contagem | Na consulta direta de 2026-09-26, home e `/numeros` exibiam 541 mapeadas (351 curadas + 190 integradas), 313 disponíveis e 228 em curadoria. A página aberta do catálogo indicava 20 publicadas e `/numeros` mostrava 154 no total, sendo 20 publicadas e 134 em análise. Os valores são instantâneos e resultados de busca indexados podem estar desatualizados. |
| `Roger-Quinelato/BBSIA` | Documentação/código descrevem indexação local de PDFs e JSON curado em RAG; não foi observada chamada à base de produção ou API do BBSIA. A ausência de evidência no repositório acessível não exclui sistemas privados. Ver [repositório](https://github.com/Roger-Quinelato/BBSIA). |

**Leitura ampliada do site (WP0c; consulta direta em 2026-09-26):** além de `/catalogo`, foram
consultados `/judiciario`, `/fundacao`, `/prontidao`, `/modelos`, `/contribuir` e `/privacidade`.
Os módulos não são intercambiáveis:

| Módulo | Evidência pública observada | Proveniência e implicação |
|---|---|---|
| Catálogo de soluções | 20 itens publicados na listagem; busca por problema/título/órgão/tags, filtros por público, tipo e área. Exemplos de ficha mostram origem declarada, tipo de ativo, uso de IA, modalidade, soberania, supervisão, impacto e risco. | É a comparação primária para o radar, mas pode incluir registros em revisão, autodeclarados e itens marcados sem IA. Registrar status e URL da ficha; não tratar aprovação ou validação como implícita. |
| Recursos reutilizáveis | 51 itens em quatro grupos de esforço (21 instalar/usar, 12 conectar, 10 desenvolver, 8 estudar), incluindo software, APIs, dados e recursos internacionais; nem todos são IA. | Vitrine de recursos amplos, com URLs externas e proveniência heterogênea; contexto/sementes opcionais, não linha automaticamente incluída no corpus. |
| Dados para IA / prontidão | 52 fichas com método e data de verificação, forma de acesso, autenticação, licença, granularidade, cadência, restrição legal e limites técnicos. Régua N1 (direto), N2 (engenharia) e N3 (mediado), com marca “parcial”. | Descreve fontes de dados governamentais e não governamentais. Endpoints documentados são das fontes de dados; não constituem prova de API/exportação para o cadastro de soluções BBSIA. |
| Modelos abertos | 13 modelos; filtros de finalidade, ambiente e abertura; distinção explícita entre “Open source” e “Pesos abertos”, com orientação para verificar a licença de cada modelo. | Recurso potencialmente relacionado ao radar, mas pesos disponíveis não provam open source, origem brasileira nem enquadramento como solução. A licença é individual e deve ser lida na fonte original. |
| Formulário e privacidade | A contribuição pede e-mail institucional e nome, além de organização/localização, problema, solução, tipo, estágio, abertura, soberania, dados, links e resultados. O aviso diz que dados de contato não são públicos e recomenda não inserir dados pessoais de terceiros, segredos, credenciais ou bases completas. | Formulário permaneceu intocado. O radar nunca coleta e-mail; dados de contato da submissão humana não fazem parte da coleta automatizada de metadados públicos. Não enviar candidatos ou preencher em nome de terceiros. |

**Escopo vigente por decisão do autor (2026-09-27):** manter o corpus como soluções de IA que passem pelo
codebook, descobertas por APIs oficiais do GitHub, Hugging Face e GitLab.com. Excluir a seção do Judiciário/CNJ/Sinapses
de descoberta, contexto, validação e deduplicação. Recursos reutilizáveis, fontes de dados e modelos não
passam a ser soluções por aparecerem no mesmo site; uma possível função contextual ou como sementes será
submetida ao autor na issue #12. A decisão não altera o codebook.

**Consequência para WP7:** contagens agregadas não permitem deduplicação registro a registro. Antes do piloto, será preciso obter uma lista pública/exportação autorizada ou decidir com o autor um método alternativo e explicitar a limitação. Não iniciar scraping do BBSIA com base nesta pesquisa.

## 2. Resultado esperado

1. Uma **tabela de candidatos** (CSV/planilha), uma linha por solução, com as colunas do formulário
   do BBSIA preenchidas no que for possível, mais: fonte, URL, escopo (a/b/c), TRL provável,
   sinais de manutenção, confiança da classificação e se já está no BBSIA.
2. Um **relatório curto** (Quarto): quantas soluções por escopo, área de problema, maturidade e
   fonte, com os limites do método.
3. Se o BBSIA aceitar: **envio em lote** (API ou planilha de importação), sem preenchimento manual
   um a um. Esse é o gargalo que o autor apontou.

## 3. WP0 — Verificar o BBSIA e perguntar à coordenação

**WP0a (issue #2)**: concluído como pesquisa documental em 2026-09-26. As respostas aos sete itens e as fontes estão no comentário de resultado da issue, no `README.md` (“O que verificamos no BBSIA”) e no §1.1. Permanecem não comprovadas a existência de API/exportação pública, a inspeção das chamadas de rede e uma licença específica do catálogo. A investigação não autoriza scraping nem contato com a coordenação.

**WP0b**: decisão do autor de 2026-09-26: o repositório é **público desde já** e a coordenação verá o projeto **quando houver um piloto para mostrar**. A pesquisa documental não encontrou API/exportação pública nem licença específica do catálogo; essas lacunas ficam para confirmar quando o piloto estiver pronto, sem contatar a coordenação agora:

1. **Envio/deduplicação**: existe API, importação por planilha ou export público/autorizado (nome + URL)? Sem uma lista registro a registro, não deduplicar usando apenas contagens agregadas.
2. **Termos/licença**: que licença ou termos se aplicam aos dados públicos do catálogo e às informações submetidas? O aviso de privacidade, sozinho, não define licença de reutilização.
3. **Proponente**: cadastramos em nome de terceiros (o dono do repositório não pediu para entrar)? A equipe avisa os autores? A recomendação de minimização permanece: não coletar e-mail nem dado pessoal além do nome público do dono do repositório/organização.
4. **Escopo (c)**: "de interesse público que poderia ser adaptado" inclui projetos estrangeiros sem
   nenhum vínculo com o Brasil? Isso muda o volume em uma ordem de grandeza. Recomendação: só entram
   no piloto os escopos (a) e (b); o (c) vem depois, com critério escrito.
5. **Momento de apresentação**: decisão vigente: mostrar o projeto à coordenação somente quando houver piloto, salvo se o autor decidir diferente.

**WP0c — Leitura ampliada do BBSIA antes da coleta (issue-mãe #1).** A verificação de sete itens da issue #2 está concluída. A navegação pública aponta para recursos reutilizáveis, fontes de dados, modelos e páginas individuais de prontidão, além do catálogo. O autor autorizou inspeção técnica pequena, somente de leitura, de páginas e rotas públicas; continuam fora de escopo chamadas em massa, POSTs, submissão de formulário e contato com a coordenação. A seção do Judiciário/CNJ/Sinapses foi excluída por decisão do autor em 2026-09-27.

Entregáveis da leitura ampliada:

1. Um inventário do catálogo de soluções/ideias, recursos reutilizáveis, fontes de dados, modelos e fichas de prontidão, distinguindo o que integra o catálogo de soluções do que é conteúdo federado ou de terceiro. Não inventariar nem usar a seção excluída do Judiciário.
2. Para cada módulo, uma ficha com propósito, campos e filtros, origem/proveniência, status de curadoria, direitos/licença declarados, data da consulta, URL canônica e limites de evidência. Reconfirmar no site ao vivo as contagens e registrar divergências entre páginas atuais e resultados de busca indexados sem misturá-los.
3. Uma matriz que compare os objetos incluídos do BBSIA ao escopo do radar e ao codebook: solução de IA, software reutilizável, API, modelo ou fonte de dados não são categorias intercambiáveis. Registrar na issue #12 a pergunta ao autor sobre usar recursos, fontes de dados e modelos apenas como contexto/sementes ou deixá-los fora do plano.
4. Uma matriz de dependências pré-coleta: acesso autorizado ao catálogo registro a registro para deduplicação; licença/termos para reutilização; endpoints e documentação oficiais; limites de uso; e campos mínimos compatíveis com o formulário. Distinguir existência documentada de API, chamadas observadas no navegador e exportação administrativa/restrita.
5. Revisão do README, deste plano e das issues relacionadas quando a pesquisa fechar, com fontes primárias e data; lacunas ficam como perguntas ao autor ou para o momento do piloto, sem contato com o BBSIA agora.

**Marco documental e teste técnico observado em 2026-09-26/27:** foram lidas as páginas públicas
incluídas no inventário e fichas representativas de soluções, prontidão de dados e modelos, além do
aviso de privacidade e do formulário (sem submissão). Em 2026-09-27, uma consulta GET à lista do
catálogo e aos dez bundles nela referenciados mostrou HTTP 200 e 20 links de ficha no HTML inicial;
nos bundles, não foi localizada chamada de leitura da lista. A rota `/api/metrica` encontrada é um
POST de evento analítico e não foi chamada. Essa inspeção pequena não exclui APIs server-side,
exportações administrativas/restritas nem comprova autorização para reutilização. Não foi feita
coleta em massa. O autor excluiu Judiciário/CNJ/Sinapses do escopo; a decisão pendente sobre outros
módulos está na issue #12. WP0c fica documentalmente concluído; acesso/termos registro a registro
permanecem uma dependência para a deduplicação do WP7.

**Porta de saída para WP3/WP4:** a inspeção pública pequena não equivale a autorização para coletar o catálogo. A implementação dos coletores GitHub/Hugging Face pode seguir após registrar a decisão de escopo da issue #12; priorizar APIs oficiais, apoio Antigravity se a CLI estiver disponível, fontes primárias, cache externo e testes offline com fixtures. Não implementar um coletor HTML do BBSIA nem reutilizar fichas do catálogo sem resolver acesso e termos. Nenhum formulário ou POST do site será enviado.

**Agentes Gemini / Antigravity CLI (autorizado pelo autor no chat em 2026-09-27; issue #1):** o executável local confirmado é `agy`. A referência operacional está em [`../agentes-gemini.md`](../agentes-gemini.md) e registra as opções da CLI, os modelos e ferramentas observados, os limites de acesso web e as salvaguardas. Instrução atual do autor: usar somente Gemini 3.8 Flash em toda chamada ao CLI, inclusive revisões, preferindo High para revisar; toda descoberta deve trazer evidência direta, passar por checagem de fontes primárias e receber validação humana quando relevante. A listagem atual não retornou agentes nomeados, embora a sessão Gemini tenha informado ferramentas de subagentes.

## 4. WP1 — Repositório do projeto (feito em 2026-09-26)

- **Nome**: `bbsia-radar` (decisão do autor, 2026-09-26). O prefixo identifica o projeto na conta pessoal; "radar" diz o que ele faz e continua fazendo sentido se a coleta virar periódica.
- **Dono e visibilidade**: `mancano-tales/bbsia-radar`, **público** por decisão do autor em 2026-09-26. Transferir para uma organização do BBSIA/LIIA é decisão do autor, depois de apresentar à coordenação.
- **Natureza**: `projeto`. Linha no catálogo do `README.md` do `mancano-repo-hub`.
- **Governança**: `AGENTS.md` (com a coordenação por issues), `CLAUDE.md` → `@AGENTS.md`, `README.md` para humanos, `NEWS.md`, `TODO.md`, `repo-governance/` (planos e llm-reviews), `tools/` (trava git, export de conversas, changelog), `hooks/pre-commit` (NEWS.md e caminhos absolutos).
- **Licença**: código sob Apache-2.0 (`LICENSE`); codebook, sementes, documentação e dados originais do projeto sob CC BY 4.0 (`LICENSE-DATA.md`). Conteúdo de terceiros conserva seus próprios termos.
- **Estrutura proposta**:

  ```
  bbsia-radar/
  ├── R/             # funções: coletores, enriquecimento, classificação, TRL, dedup
  ├── scripts/       # 01_descobrir.R, 02_enriquecer.R, 03_classificar.R, 04_exportar.R
  ├── config/        # consultas (queries.yml), sementes (seeds.yml), codebook.yml
  ├── data/          # só saídas pequenas e revisadas (candidatos.csv); cache bruto fora do git
  ├── report/        # relatório Quarto
  └── tests/
  ```

  O cache bruto (JSON das APIs) fica fora do git, via `.data-source` + `MANCANO_<DESTINO>_ROOT`,
  como no resto do ecossistema. Token do GitHub só em `GITHUB_PAT` (variável de ambiente), nunca no
  código. Nada de caminho absoluto.

- **Stack**: R com tidyverse (`gh` e `httr2` para as APIs, `purrr`, `dplyr`, `tidyr`, `stringdist`
  para deduplicação, `targets` para o pipeline se crescer). O Hugging Face não tem cliente R oficial;
  a API REST (`/api/models`, `/api/datasets`, `/api/spaces`) é simples o bastante para `httr2`.

## 5. WP2 — Codebook: o que é "brasileira"

> **2026-09-26 — v0.1.1** em [`config/codebook.yml`](../../config/codebook.yml): o autor aprovou seis casos-limite e o protocolo inicial de validação (issue #9); dois casos seguem dependentes de alinhamento com o BBSIA. As métricas de reprodutibilidade humana são separadas do desempenho da máquina contra os rótulos humanos adjudicados. A amostra vem dos candidatos e não depende de uma exportação do catálogo. A v0.1.0 introduziu marcações A/B/C independentes, o filtro `e_ia` e exclusões para reuploads e dados pessoais. Sementes em [`config/seeds.yml`](../../config/seeds.yml) (issue #4).

Escrito **antes** da coleta, porque é ele que decide o que entra. Rascunho:

> **Referência observada no BBSIA (issue #2, 2026-09-26):** o formulário oferece estágios
> descritivos (pesquisa/PoC, desenvolvimento/protótipo, em teste e em produção), não uma escala
> numérica TRL 1–9. O catálogo público usa áreas e tipos próprios e busca orientada ao problema;
> consultar o comentário da issue #2 e o `README.md` para os valores observados. Isso serve de
> comparação para o mapeamento, mas não altera automaticamente o codebook. Recursos reutilizáveis,
> fontes de dados e modelos têm proveniência, direitos, finalidade e status próprios, e não devem
> ser achatados como “soluções”. O autor excluiu a seção do Judiciário/CNJ/Sinapses deste projeto.
> Ver §1.1 e README para o inventário da consulta ampliada. Os dois casos-limite pendentes da issue #9
> continuam reservados ao autor; nenhum módulo novo entra no codebook por inferência.

| Escopo | Critério | Sinais observáveis |
|---|---|---|
| (a) brasileira | feita por pessoa, grupo, empresa ou órgão sediado no Brasil | `location` do dono (usuário/org) no Brasil; org conhecida (universidade, ICT, órgão `gov.br`); README em português que cita instituição brasileira |
| (b) adaptada ao pt-BR | modelo, dataset ou software treinado, ajustado ou avaliado para português brasileiro | tag `language:pt` no HF + menção a pt-BR/Brasil; tópicos `portuguese-nlp`, `brazilian-portuguese`; benchmarks brasileiros |
| (c) interesse público adaptável | resolve um problema típico do setor público e é código aberto | licença aberta + tema (saúde, educação, justiça, transparência, atendimento) — **só depois do piloto** |
| fora | pt-PT sem uso no Brasil, conta pessoal sem conteúdo, fork sem mudança, tutorial/curso, lista "awesome" | cuidado com PORTULAN (Portugal) e forks |

Unidade de análise: **uma solução**, não um repositório. Um modelo no HF e o código no GitHub do
mesmo grupo viram uma linha, com as duas URLs.

## 6. WP3 — Descoberta (onde procurar)

**GitHub** (Search API: 30 req/min autenticado; teto de 1.000 resultados por consulta, então cada
consulta é fatiada por `created:` ou `pushed:` até ficar abaixo de 1.000):

1. Repositórios por tópico: `brazil`, `brasil`, `portuguese`, `pt-br`, `portuguese-nlp`,
   `brazilian-portuguese`, cruzados com termos de IA (`machine-learning`, `llm`, `nlp`, `whisper`,
   `computer-vision`...).
2. Repositórios por texto em português na descrição ("inteligência artificial", "aprendizado de
   máquina", "modelo de linguagem", "transcrição"...).
3. Usuários e organizações com `location:Brazil`/`Brasil`/cidades e seus repositórios de IA. É o
   sinal mais forte para (a) e o mais caro; fazer depois de 1 e 2.
4. Organizações de universidades, ICTs e órgãos públicos (lista semente escrita à mão).

**Hugging Face**: modelos, datasets e spaces com `language:pt`; autores de uma lista semente
(`neuralmind`, `nicholasKluge`/TeenyTinyLlama/Tucano, `recogna-nlp`, `maritaca-ai`, grupos de
universidades — **cada um conferido antes de entrar na semente**; a pesquisa desta sessão não
confirmou todos). Busca textual por "brazil", "brasil", "pt-br".

**Sementes curadas**: `davidsbatista/awesome-Portuguese-NLP`, `ajdavidl/Portuguese-NLP`, a
`awesome-open-source-research-tools` do autor e as soluções que o autor já está cadastrando à mão
(transcritor com Whisper etc.). As sementes também servem de **gabarito**: um coletor que não acha o
que já sabemos que existe está mal calibrado (medir recall contra elas).

**Fora do piloto**: BigQuery `github_repos` e GH Archive (úteis para volume, mas o piloto não
precisa); GHTorrent (status atual não confirmado).

Boas práticas: respeitar os limites e os cabeçalhos de rate limit, cache local de toda resposta
(nunca repetir chamada), `User-Agent` identificado, só dados públicos.

## 7. WP4 — Enriquecimento

Para cada candidato: descrição, README ou model card, licença, linguagem, tópicos, estrelas/likes,
downloads (HF), data de criação e do último push, número de contribuidores, releases, existência de
documentação e de testes, dono (usuário ou org) e a `location` dele.

## 8. WP5 — Classificação e validação

> **2026-09-26 — Decisão do autor (em chat; issue #6): o radar produz o corpus e o Decifra classifica.**
> O Decifra é desenvolvido para dar conta desta tarefa, e o radar é o primeiro caso de uso real dele.
> Na prática, isso junta as opções A e B da issue #6: o piloto usa o que já existe, e o que faltar é
> construído **no Decifra**, não contornado aqui. Estado do Decifra conferido em `31f576f`: o codebook
> multivariável e multirrótulo (R1.1) foi aprovado pelo autor em 2026-09-13 (§15 da especificação de
> 2026-09-13; o cabeçalho dela e o `ROADMAP.md` ainda diziam "aguardando", corrigido em
> decifra-text-as-data#5), e os passos 1, 2 e 4 já
> estão no `main` (contrato `variables:`/`multi_label`/`max_labels`, validação multirrótulo); **falta o
> passo 3** (extração, estimativa e banco consumirem as variáveis) e os seguintes (API e interface).
> Consequências para este plano:
> - **WP4** passa a entregar o **corpus do Decifra**: um documento por solução, com os metadados em
>   texto, mais um CSV com `id_solucao` e o texto;
> - **WP5** passa a ser: regras de triagem aqui; conversor `config/codebook.yml` → YAML `variables:` do
>   Decifra; execução e validação humana no Decifra; importação dos resultados de volta;
> - requisitos do radar abertos como issue no `decifra-text-as-data`.
> O texto abaixo é o desenho original do WP5, mantido como histórico.

1. **Regras** (baratas) para os casos óbvios: org na lista semente → (a); `language:pt` + "pt-BR"
   → (b); fork sem commits próprios → fora.
2. **LLM contra o codebook** para o resto: lê descrição e README e devolve escopo, área de problema
   (vocabulário do BBSIA, quando tivermos) e um resumo de 1–2 frases **em forma de problema**, que é
   como o BBSIA organiza o catálogo. É exatamente o que o `decifra-text-as-data` faz; usar como
   biblioteca ou copiar o método. Decidir no WP1.
3. **Validação humana (desenho inicial substituído pela decisão do autor no §13, issue #9)**:
   a amostra é tirada do próprio corpus de candidatos, não do catálogo do BBSIA. A dupla codificação
   humana mede reprodutibilidade do codebook; a avaliação do classificador contra os rótulos humanos
   adjudicados é outra métrica. O protocolo aprovado e seus limiares constam em `config/codebook.yml`.

## 9. WP6 — Maturidade (TRL provável)

"Todos os TRLs" entram, mas cada linha leva uma **estimativa**, marcada como estimativa, para a
equipe revisar. Proposta de faixas, a calibrar com o autor e a Eunice:

| TRL provável | Sinais em metadados |
|---|---|
| 1–3 (ideia, prova de conceito) | notebook ou repo recente, sem release, sem documentação, 1 contribuidor |
| 4–6 (protótipo validado) | README com instruções, exemplos ou avaliação, algum uso (estrelas/downloads), atividade no último ano |
| 7–9 (em operação) | releases, pacote publicado (CRAN/PyPI/HF com muitos downloads), vários contribuidores, uso institucional declarado |

Mais duas colunas, que respondem à preocupação inicial do autor com projetos parados: **ativo**
(push nos últimos 12 meses) e **manutenção** (contribuidores, issues respondidas). OpenSSF Scorecard
fica como opcional para os candidatos de TRL alto.

## 10. WP7 — Deduplicação contra o BBSIA

Com export do catálogo: casar por URL e, depois, por nome (distância de strings) com revisão manual
dos casos próximos. Sem export: casar por nome contra uma lista coletada à mão, com erro maior e
declarado no relatório.

## 11. WP8 — Piloto e entrega

> **2026-09-26 — Teste com o catálogo do BBSIA (ideia do autor).** As soluções já cadastradas no BBSIA
> que tenham link para GitHub ou Hugging Face formam um segundo gabarito (`config/seeds.yml`,
> `gabarito_bbsia`): medem o recall da descoberta e servem de gabarito externo para `area_problema`.
> Depende do export do catálogo (#2). Se entra no WP8 é decisão do autor (issue #6).

1. **Piloto**: uma fonte de cada (um recorte do GitHub e um do HF), ~30 soluções, planilha completa
   no formato do formulário. Mandar à Eunice e **ajustar campos e codebook com o retorno dela antes
   do volume**.
2. **Volume**: todas as consultas, relatório, planilha final.
3. **Envio**: pela via que o BBSIA indicar (pergunta 2). Envio automatizado a um sistema de terceiros
   é ação externa: só com o autor no momento.

## 12. Riscos

- **Critério frouxo gera lista enorme e inútil**: o piloto e a validação humana existem para isso.
- **Falso "brasileiro"**: `location` é texto livre e declarado; pt-PT se passa por pt-BR. Por isso a
  coluna de confiança.
- **Dados pessoais**: só metadados públicos de repositórios; nada de e-mail; perguntar à equipe se os
  donos são avisados (pergunta 4).
- **Rede**: este contêiner de nuvem não chega ao BBSIA nem ao Hugging Face. A coleta roda na máquina
  do autor, ou a rede do ambiente de nuvem precisa ser liberada para esses domínios.
- **Termos de uso**: rever os da API do GitHub e do Hugging Face antes do volume.

## 13. Decisões do autor

1. ~~Aprovar o plano~~: aprovado em 2026-09-26, com o repositório `bbsia-radar`.
2. Quando mandar as perguntas do §3 à coordenação: com o piloto, ou antes, se o WP0a não bastar.
3. Licença do repositório.
4. R puro ou R + Python (recomendação: R, e Python só se o `huggingface_hub` fizer falta).
5. **Visibilidade (2026-09-26, no chat, depois da decisão 1):** "bbsia vai ser público mesmo". O repositório é **público** desde já, e a regra "privado até o piloto" (§3 WP0b e §4) está aposentada. A coordenação continua vendo o projeto com o piloto.
6. **Licenças (2026-09-26, confirmação do autor no chat; issue #8):** código sob Apache-2.0; materiais originais do projeto (incluindo `config/codebook.yml`, `config/seeds.yml` e futuras tabelas revisadas) sob CC BY 4.0, com atribuição. CC BY permite uso comercial; a opção não comercial seria BY-NC e não foi escolhida. Isso não licencia dados coletados de terceiros nem resolve os termos de reutilização do catálogo do BBSIA.
7. **Validação e casos-limite (2026-09-26, aprovação do autor no chat; issue #9):** protocolo inicial de amostra de até 100 candidatos, dupla codificação cega de 30 se houver segundo codificador e kappa humano mínimo de 0,70 em `brasileira`, `ptbr` e `e_ia`. A concordância humana mede consistência do codebook; o desempenho do classificador será avaliado separadamente contra rótulos humanos adjudicados, com precisão, recall, F1 e kappa. Se não houver segundo codificador, relatar a limitação, não inventar kappa humano. Seis casos-limite estão aprovados; API comercial fechada e pacote de dados sem IA permanecem pendentes da coordenação do BBSIA.
8. **`NEWS.md` sem exceção de pacote R (2026-09-29, no chat):** "Não quero exceção no pacote R". Embora o repositório tenha `DESCRIPTION`, a exceção do bloco comum (hub #37) não se aplica aqui: o `NEWS.md` foi movido para `repo-governance/deprecated/NEWS.md` e `hooks/pre-commit` recusa recriá-lo na raiz. O histórico fica nos planos, commits, PRs, issues e no `CHANGELOG.md` gerado.
9. **Arquivos da marca BBSIA (2026-09-29, no chat):** "Pode deixar os arquivos da marca." Os ativos preparados no PR #25 (`report/assets/`) podem ficar no repositório público, desativados no site, no PDF e nos metadados sociais, com a fonte e o hash registrados e a ressalva de que a licença do repositório não cobre a marca de terceiros. Ativá-los continua dependendo de decisão da coordenação do BBSIA.
10. **Marca do BBSIA no site (2026-09-29, no chat; substitui a decisão 9):** "Eu não acho que tem problema a marca do BBSIA estar dentro do Site se o disclaimer estiver apropriado." A marca pode ser ativada no site junto ao aviso de proposta independente, sem se apresentar como identidade oficial. Execução no plano do MVP (#28, WP-H). O mesmo chat autorizou publicar o piloto revisado no GitHub Pages.

### Rascunho de mensagem para a Eunice

> Oi Eunice! Comecei a planejar o mapeamento. Antes de rodar em volume, queria alinhar umas coisas:
> 1. Você me passa a lista de campos do formulário (quais são obrigatórios e como é o campo de TRL)?
> 2. Existe API ou importação por planilha? Se não, posso entregar uma planilha já no formato dos campos.
> 3. Dá para me mandar um export (nome + link) das soluções já cadastradas, para eu não repetir?
> 4. Quando eu cadastro um projeto de terceiros, vocês avisam os autores? Minha ideia é não coletar
>    e-mail nem dado pessoal, só o que está público no repositório.
> 5. "Interesse público que poderia ser adaptado" inclui projetos estrangeiros sem vínculo com o
>    Brasil? Pensei em começar pelos brasileiros e pelos adaptados ao pt-BR.
> 6. O repositório do projeto pode ficar na minha conta do GitHub (público), ou vocês preferem numa
>    organização do BBSIA/LIIA?
> Minha proposta é mandar um piloto com umas 30 soluções, ajustar com o retorno de vocês e depois rodar tudo.
