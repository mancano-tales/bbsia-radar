---
tipo: Plano
titulo: "Piloto do bbsia-radar: soluções de IA brasileiras no GitHub e no Hugging Face para o BBSIA"
issue: 1
status: ATIVO # aprovado pelo autor em 2026-09-26; WP0 aberto (issue #2 e perguntas à coordenação)
criado: "2026-09-26 09:15"
concluido: null
agentes:
  orquestrador: "Claude Opus 5.5 (Claude Code on the web)"
  executor: null
  auditor: null
autor_humano: "Tales Mançano"
tarefas:
  - { desc: "WP0a — Verificar site e formulário do BBSIA com agente que tenha acesso à rede (issue #2)", status: pendente, data: null }
  - { desc: "WP0b — Perguntas à coordenação do BBSIA (Eunice Liu), depois do piloto ou do WP0a", status: pendente, data: null }
  - { desc: "WP1 — Repositório mancano-tales/bbsia-radar (privado) com governança: AGENTS.md, README, TODO, plano, tools, hooks", status: concluido, data: "2026-09-26 11:03" }
  - { desc: "WP2 — Codebook: o que conta como solução 'brasileira', 'adaptada ao pt-BR' e 'de interesse público adaptável' (issue #3; config/codebook.yml v0.1.0, em revisão pelo autor)", status: em_revisao, data: "2026-09-26 11:45" }
  - { desc: "WP3 — Descoberta: coletores GitHub e Hugging Face + sementes curadas (listas awesome, orgs conhecidas)", status: pendente, data: null }
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

A pesquisa desta sessão foi por busca na web. **O site do BBSIA, o espelho
`banco-ia-gov.vercel.app`, os domínios gov.br e o Hugging Face estão bloqueados pela rede do
contêiner de nuvem** (e o GitHub respondeu 403 sem token). Por isso:

| Item | Situação |
|---|---|
| Quem mantém, objetivo, organização por problema | confirmado por notícias (Enap, gestgov, Convergência Digital) |
| Tamanho do catálogo | um resumo de busca fala em 529 soluções mapeadas; **não conferido** no site |
| Campos exatos do formulário | **não verificado** |
| Se o formulário usa a escala TRL | **não verificado** (a conversa com a Eunice indica que sim) |
| API, exportação em CSV/JSON, envio em lote | **não encontrado** |
| Termos de uso e licença dos dados do catálogo | **não encontrado** |

Há um repositório de terceiros, `Roger-Quinelato/BBSIA` (RAG sobre o catálogo, MIT). Não é oficial,
mas pode mostrar como o catálogo é lido. Vale olhar no WP0.

## 2. Resultado esperado

1. Uma **tabela de candidatos** (CSV/planilha), uma linha por solução, com as colunas do formulário
   do BBSIA preenchidas no que for possível, mais: fonte, URL, escopo (a/b/c), TRL provável,
   sinais de manutenção, confiança da classificação e se já está no BBSIA.
2. Um **relatório curto** (Quarto): quantas soluções por escopo, área de problema, maturidade e
   fonte, com os limites do método.
3. Se o BBSIA aceitar: **envio em lote** (API ou planilha de importação), sem preenchimento manual
   um a um. Esse é o gargalo que o autor apontou.

## 3. WP0 — Verificar o BBSIA e perguntar à coordenação

**WP0a (issue #2)**: um agente com acesso à rede abre o site e o formulário do BBSIA e responde aqui, com fonte, o que a tabela do §1.1 deixou em aberto. Isso reescreve o `README.md` e o §5 deste plano.

**WP0b**: decisão do autor de 2026-09-26: o repositório fica privado e a coordenação vê o projeto **quando houver um piloto para mostrar**. As perguntas abaixo vão junto com o piloto (ou antes, se o WP0a não responder o essencial):

1. **Formulário**: pode mandar a lista de campos (ou um export em branco) e quais são obrigatórios?
   Em especial: o campo de TRL (escala 1–9?), área/problema, órgão/instituição, licença, link.
2. **Envio em lote**: existe API ou importação por planilha? Se não, a equipe prefere receber uma
   planilha no formato dos campos e importar do lado dela?
3. **Catálogo atual**: dá para receber um export (nome + URL) para deduplicar? Sem ele, a
   deduplicação (WP7) é por nome, com mais erro.
4. **Quem aparece como proponente**: cadastramos em nome de terceiros (o dono do repositório não
   pediu para entrar)? A equipe avisa os autores? Isso define se coletamos contato. **Recomendação:
   não coletar e-mail nem dado pessoal além do nome público do repositório/organização** (LGPD).
5. **Escopo (c)**: "de interesse público que poderia ser adaptado" inclui projetos estrangeiros sem
   nenhum vínculo com o Brasil? Isso muda o volume em uma ordem de grandeza. Recomendação: só entram
   no piloto os escopos (a) e (b); o (c) vem depois, com critério escrito.
6. **Onde mora o repositório**: na conta do autor, numa organização do BBSIA/LIIA, ou numa
   organização a criar? Licença preferida?

## 4. WP1 — Repositório do projeto (feito em 2026-09-26)

- **Nome**: `bbsia-radar` (decisão do autor, 2026-09-26). O prefixo identifica o projeto na conta pessoal; "radar" diz o que ele faz e continua fazendo sentido se a coleta virar periódica.
- **Dono e visibilidade**: `mancano-tales/bbsia-radar`, **privado** até o piloto. Tornar público ou transferir para uma organização do BBSIA/LIIA é decisão do autor, depois de apresentar à coordenação.
- **Natureza**: `projeto`. Linha no catálogo do `README.md` do `mancano-repo-hub`.
- **Governança**: `AGENTS.md` (com a coordenação por issues), `CLAUDE.md` → `@AGENTS.md`, `README.md` para humanos, `NEWS.md`, `TODO.md`, `repo-governance/` (planos e llm-reviews), `tools/` (trava git, export de conversas, changelog), `hooks/pre-commit` (NEWS.md e caminhos absolutos).
- **Licença**: a decidir pelo autor (ver `TODO.md`).
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

> **2026-09-26 11:45 — v0.1.0 escrita** em [`config/codebook.yml`](../../config/codebook.yml) (issue #3), que passa a ser a referência; a tabela abaixo é o rascunho original. Mudanças em relação a ela: os tipos A, B e C viraram **três marcações independentes** (um modelo pode ser brasileiro e adaptado ao pt-BR); entrou um filtro de entrada `e_ia` (o que conta como IA); as exclusões ganharam `reupload_modelo` (quantizações e cópias no Hugging Face) e `dados_pessoais`; 8 casos-limite têm decisão proposta, 2 dependem do BBSIA. Sementes e gabarito de recall em [`config/seeds.yml`](../../config/seeds.yml) (issue #4).

Escrito **antes** da coleta, porque é ele que decide o que entra. Rascunho:

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
3. **Validação humana**: o autor (e, se possível, alguém da equipe do BBSIA) codifica uma amostra
   aleatória estratificada por fonte, e comparamos com a máquina (concordância e kappa). O número
   entra no relatório. Sem essa validação, a planilha não vai para o BBSIA.

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

1. ~~Aprovar o plano~~: aprovado em 2026-09-26, com o repositório privado `bbsia-radar`.
2. Quando mandar as perguntas do §3 à coordenação: com o piloto, ou antes, se o WP0a não bastar.
3. Licença do repositório.
4. R puro ou R + Python (recomendação: R, e Python só se o `huggingface_hub` fizer falta).

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
