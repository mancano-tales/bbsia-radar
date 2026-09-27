# bbsia-radar

**Radar que encontra e documenta soluções de IA brasileiras, adaptadas ao português brasileiro ou de interesse público que possam ser adaptadas, ainda ausentes do Banco Brasileiro de Soluções de IA (BBSIA). Busca projetos no GitHub, Hugging Face e GitLab.com e prepara candidatas para revisão humana.**

> **Verificação documental (2026-09-26; issue #2).** O site e o formulário foram consultados sem enviar dados. As respostas e os limites da evidência estão registrados abaixo e na issue. Contagens são retratos da data, não dados exportados.

---

## O problema

O [Banco Brasileiro de Soluções de IA (BBSIA)](https://bancobrasileiro.ia.br/) reúne soluções de IA úteis ao setor público (ministérios, prefeituras, universidades, institutos de pesquisa) e as organiza **pelo problema que resolvem**, não pela tecnologia usada. É mantido pelo Laboratório de Inovação em Inteligência Artificial (LIIA) da Enap, com o Ibict e o CIIA. O objetivo é que uma solução criada num lugar possa ser reaproveitada em outro.

Hoje, uma solução entra no banco quando alguém preenche o formulário à mão. Mas muita coisa relevante já está publicada, aberta, em plataformas como o **GitHub** e o **GitLab.com** (código) e o **Hugging Face** (modelos e bases de dados de IA): transcritores para o português, modelos de linguagem treinados em português brasileiro, softwares livres de pesquisa, ferramentas feitas por universidades e órgãos públicos. Essas soluções ficam dispersas, e quem precisa delas no setor público muitas vezes não sabe que existem.

## A proposta

Usar as interfaces oficiais (APIs) do GitHub, do Hugging Face e do GitLab.com para **encontrar, descrever e organizar** essas soluções, e entregar ao BBSIA uma lista de candidatos pronta para revisão, no formato do formulário. A ideia foi combinada com a coordenação do BBSIA (Eunice Liu, Enap) em 26/09/2026.

Três tipos de solução interessam:

| | Tipo | Exemplo |
|---|---|---|
| **A** | **Brasileira**: feita por pessoa, grupo, empresa ou órgão do Brasil | um sistema de triagem de processos feito por um tribunal |
| **B** | **Adaptada ao português brasileiro**: treinada, ajustada ou avaliada para pt-BR | um modelo de reconhecimento de fala ajustado para o português do Brasil |
| **C** | **De interesse público, adaptável**: aberta e útil ao setor público, mesmo sem vínculo com o Brasil | uma ferramenta de anonimização de documentos que poderia ser traduzida |

O piloto começa por **A** e **B**. O tipo **C** exige um critério mais preciso, a combinar com o BBSIA, porque sem ele a lista fica grande demais para ser útil.

## Princípios

- **Todas as maturidades entram.** Combinado com o BBSIA ("todos os TRLs"): uma prova de conceito também pode ser útil. Mas cada solução leva uma **estimativa de maturidade** (a escala TRL, de 1 = ideia a 9 = em operação) e indicadores de manutenção (se ainda é atualizada, quantas pessoas contribuem). Isso responde a um problema real: muito projeto aberto para cedo ou deixa de ser mantido.
- **Critério escrito antes da coleta.** O que conta como "brasileira" ou "adaptada ao pt-BR" fica definido num livro de códigos (*codebook*) antes de qualquer busca em volume.
- **A máquina sugere, pessoas conferem.** A amostra inicial tem até 100 candidatos. Quando houver uma segunda pessoa, 30 serão codificados às cegas por ambas para medir consistência humana (kappa ≥ 0,70 em `brasileira`, `ptbr` e `e_ia`). Isso não exige baixar a base do BBSIA: a amostra vem dos candidatos. O desempenho da máquina será medido à parte contra rótulos humanos adjudicados, com precisão, recall, F1 e kappa. Sem validação, nada é enviado ao BBSIA.
- **Sem repetir o que já está no banco.** Os candidatos são comparados com o catálogo atual.
- **Coleta responsável.** Só APIs oficiais, respeitando os limites de uso; só dados públicos dos repositórios; **nenhum e-mail ou dado pessoal** (LGPD).
- **Sementes transparentes.** Além das consultas derivadas do codebook, a primeira amostra planejada inclui somente as três soluções já marcadas como `brazil` na lista global [awesome-open-source-research-tools](https://github.com/mancano-tales/awesome-open-source-research-tools): Transcritório, Open Notebook e QualiLab. A coleta consulta cada repositório pela API oficial do GitHub; não percorre nem importa a lista inteira.

## Como vai funcionar

```
  sementes curadas       GitHub API       Hugging Face API      GitLab.com API
 (listas e soluções)  (código e texto)  (modelos e datasets)  (projetos públicos)
          └──────────────────┬──────────────────────────────┘
                             ▼
              1. DESCOBERTA  → lista bruta de candidatos
                         ▼
              2. ENRIQUECIMENTO → descrição, README, licença, atividade
                         ▼
              3. CLASSIFICAÇÃO → brasileira? pt-BR? é IA? tipo, área
                         │        (regras do radar + Decifra, conferido
                         │         por amostra humana no próprio Decifra)
                         ▼
              4. MATURIDADE → TRL provável + sinais de manutenção
                         ▼
              5. DEDUPLICAÇÃO → já está no BBSIA?
                         ▼
              6. ENTREGA → planilha no formato do formulário + relatório
```

Antes de rodar tudo, um **piloto com cerca de 30 soluções** vai para a coordenação do BBSIA, para ajustar os campos e o critério.

## O radar e o Decifra

O radar é **a parte que produz o corpus**: encontra as soluções, junta o que se sabe de cada uma e escreve um documento por solução. A **classificação** fica com o [Decifra](https://github.com/mancano-tales/decifra-text-as-data), ferramenta do mesmo autor que transforma texto em dados categóricos com um modelo de linguagem guiado por um livro de códigos explícito e **validado contra codificação humana**. O que o Decifra ainda não faz para este caso (por exemplo, várias perguntas por documento e mais de uma área por solução) é desenvolvido no próprio Decifra, que ganha com isso seu primeiro uso real. Decisão de 26/09/2026 ([issue #6](../../issues/6)).

## O que verificamos no BBSIA (issue #2)

1. **Formulário:** pede identificação de contato e instituição, localização, descrição e tipo da solução,
   área, estágio de desenvolvimento, uso por outras organizações, abertura/reutilização, links e
   disposição para compartilhar conhecimento ou código. Há campos opcionais sobre tecnologia,
   financiamento, soberania, dados e resultados; e consentimento de privacidade. Os menus incluem
   nível de governo, UF, tecnologia, tipo de ativo, área, uso, estágio e abertura. Não preenchemos nem
   enviamos o formulário. [Formulário](https://bancobrasileiro.ia.br/contribuir).
2. **Maturidade:** o formulário apresenta estágios descritivos — de pesquisa/PoC a uso em produção —,
   não uma seleção numérica de TRL 1–9. “Todos os TRLs” continua sendo o escopo conversado com a
   coordenação; a coluna TRL do radar será uma estimativa própria, claramente identificada.
3. **Catálogo:** organiza as soluções pelo problema que resolvem e permite busca por problema, título,
   órgão e tags. Os filtros são público (“quero usar” ou “quero desenvolver/integrar”), tipo
   (aplicação, código/biblioteca, API, agente, modelo, pipeline e guia/metodologia) e área (Saúde,
   Educação, Segurança Pública, Meio Ambiente, Gestão Pública, Administração/Processos e Outro).
   Na consulta, a página indicava 20 publicadas; a página de números mostrava 154 no catálogo,
   divididas em 20 publicadas e 134 em análise. [Catálogo](https://bancobrasileiro.ia.br/catalogo).
4. **API e exportação:** em 2026-09-27 fizemos uma inspeção pequena e somente de leitura da página
   pública do catálogo e dos dez bundles JavaScript que ela referenciava (GET, todos HTTP 200). O
   HTML inicial contém os links/identificadores das 20 fichas publicadas; nos bundles não apareceu
   uma chamada de leitura de catálogo nem rota pública de dados. Apareceu `/api/metrica`, usado por
   um `POST` de evento analítico; não o chamamos. Isso sugere que a listagem pública é renderizada
   pelo servidor, mas **não prova** que inexista API, exportação administrativa/restrita ou uma rota
   interna do servidor. Não encontramos documentação ou interface pública de exportação CSV/JSON ou
   importação em lote. A consulta não baixou nem guardou fichas em massa.
5. **Termos, privacidade e licença:** o [aviso de privacidade](https://bancobrasileiro.ia.br/privacidade)
   diz que informações sobre as soluções podem ser publicadas e reutilizadas e que contatos não são
   públicos. Não encontramos termo de uso ou licença específica do catálogo nas páginas consultadas.
   Isso não concede ao radar direitos sobre registros do BBSIA. As licenças escolhidas para o código
   e para os materiais originais deste projeto estão separadas em [`LICENSE`](LICENSE) e
   [`LICENSE-DATA.md`](LICENSE-DATA.md); direitos sobre conteúdo externo continuam com seus titulares.
6. **Contagens em 2026-09-26:** a home e a página “Números do banco” mostravam 541 soluções mapeadas
   (351 curadas e 190 integradas), 313 disponíveis e 228 em curadoria. A seção de catálogo mostrava
   154 no total (20 publicadas, 134 em análise); os números variam com a atualização e resultados
   indexados podem estar defasados.
   [Números do banco](https://bancobrasileiro.ia.br/numeros).
7. **Repositório `Roger-Quinelato/BBSIA`:** a documentação e o código consultados descrevem um RAG
   local que indexa PDFs e um JSON curado local de soluções para busca; não encontramos evidência de
   que ele baixe o banco de produção ou use API do BBSIA. Isso descreve o repositório público
   consultado, não exclui processos privados ou outros sistemas.
   [Repositório e documentação](https://github.com/Roger-Quinelato/BBSIA).

**Licença do projeto:** o código está sob Apache-2.0. O codebook, as sementes, a documentação e as
tabelas originais revisadas do projeto estão sob CC BY 4.0, que exige atribuição mas permite uso
comercial; “não comercial” exigiria CC BY-NC e não foi escolhido. Veja [`LICENSE-DATA.md`](LICENSE-DATA.md).
O conteúdo de terceiros e o catálogo do BBSIA não ficam automaticamente cobertos por essas licenças.

**Implicação para o piloto:** a deduplicação depende de uma fonte autorizada e reproduzível para o
catálogo atual. Os identificadores que aparecem no HTML público não são uma autorização para copiar
ou reutilizar as fichas. Até esclarecer acesso e termos, não tratar contagens como registros nem fazer
coleta em massa. A inspeção técnica pequena foi autorizada como pesquisa e não inicia a implementação
dos coletores (#10).

### Seções adjacentes consultadas (WP0c, 2026-09-26/27)

O site reúne módulos com finalidades e proveniências diferentes. Esta leitura amplia o contexto do
projeto, mas não amplia automaticamente a unidade de análise do radar nem autoriza copiar os dados.

| Seção | O que a página declara | Relação com o radar e limite |
|---|---|---|
| [Soluções de IA](https://bancobrasileiro.ia.br/catalogo) | Catálogo organizado pelo problema; busca por problema, título, órgão e tags; filtros por público, tipo e área. A listagem aberta mostrou 20 soluções, com estados como Ativo e Em revisão, além de alguns itens marcados Sem IA. Fichas podem detalhar origem, tipo, IA generativa, modalidades, soberania, supervisão, impacto e risco. | É o módulo mais próximo do alvo do radar, mas sua ficha pode ser autodeclarada e incluir ideias, soluções em revisão ou itens sem IA. Preservar proveniência e status; a triagem do codebook continua necessária. |
| [Recursos reutilizáveis](https://bancobrasileiro.ia.br/fundacao) | Reúne bases, APIs, software público e repositórios, agrupados por esforço: instalar/usar (21), conectar (12), desenvolver (10) e estudar (8), 51 itens no total na consulta. Há recursos brasileiros e estrangeiros, de IA e não IA, com links externos. | É uma vitrine ampla de ativos reusáveis, não um catálogo homogêneo de soluções de IA. Pode servir para contexto ou sementes futuras, após decisão de escopo. |
| [Dados para IA / prontidão](https://bancobrasileiro.ia.br/prontidao) | 52 fichas sobre fontes públicas brasileiras, com método/data declarados e dimensões como forma de acesso, autenticação, licença, granularidade, cadência e restrições. N1 indica ingestão direta; N2 exige engenharia/autenticação/limite técnico; N3 requer acesso mediado. O rótulo parcial restringe a avaliação ao regime mais acessível. | Descreve bases de dados de terceiros, não soluções do radar nem a base cadastral do BBSIA. Endpoints que aparecem nessas fichas são das fontes de dados citadas e não provam a existência de API para consultar o catálogo BBSIA. |
| [Modelos abertos](https://bancobrasileiro.ia.br/modelos) | 13 modelos na consulta, com filtros por tarefa, ambiente de execução e grau de abertura. A página distingue “Open source” de “Pesos abertos” e orienta consultar a licença de cada modelo. | Alguns modelos podem ser componentes ou candidatos a solução, mas disponibilizar pesos não basta para presumir código aberto, origem brasileira, licença de reutilização ou aderência ao formulário. Registrar cada licença na fonte original. |
| [Contribuir](https://bancobrasileiro.ia.br/contribuir) e [aviso de privacidade](https://bancobrasileiro.ia.br/privacidade) | O formulário pede e-mail institucional e nome; cargo e telefone são apresentados como opcionais, além de órgão, localização, problema, descrição, tipo de ativo, maturidade, abertura, soberania, dados, links, resultados e disposição para compartilhar. O aviso diz que informações da solução podem ser públicas, mas contatos não; dados pessoais de contato ficam restritos à coordenação. | Formulário não foi preenchido nem enviado. O radar nunca coleta e-mail; campos de contato são uma diferença explícita entre a submissão humana e a descoberta automatizada por metadados públicos. |

**Escopo vigente por decisão do autor (2026-09-27):** o radar procura soluções que satisfaçam o
codebook em GitHub, Hugging Face e GitLab.com. A descoberta inicial no GitLab usa somente a API
oficial do GitLab.com e não cobre instâncias self-managed. A seção do Judiciário/CNJ/Sinapses está excluída: não será fonte de
descoberta, deduplicação, validação ou contexto do projeto. Recursos reutilizáveis, fontes de dados e
modelos permanecem categorias diferentes de soluções; podem informar contexto ou sementes somente
depois da decisão de escopo registrada na issue #12. Seus links e licenças continuam pertencendo às
fontes originais. A exclusão não altera automaticamente o codebook.

## Estado

Repositório **público** em fase de piloto. O primeiro conjunto de funções prepara descoberta via API e exportação do corpus ao Decifra; a coleta em volume e a classificação ainda exigem revisão de escopo e execução controlada. Plano vigente: [`repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`](repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md) ([issue #1](../../issues/1)).

### Preparar uma execução local

As funções de API e cache dependem de pacotes R descritos em [`DESCRIPTION`](DESCRIPTION), que podem ser instalados com `install.packages(c("dplyr", "digest", "gh", "httr2", "jsonlite", "purrr", "readr", "tibble", "yaml", "testthat"))`. Defina `MANCANO_BBSIA_RADAR_ROOT` no `.Renviron` local apontando para um diretório de dados fora deste checkout. Credenciais opcionais ficam no mesmo `.Renviron` como `GITHUB_PAT` e `HF_TOKEN`; nunca as coloque em YAML versionado. O cache bruto usa `bbsia-radar/api/` sob essa raiz, conforme `.data-source`.

```r
source("R/cache.R")
source("R/coletar_github.R")
source("R/coletar_hf.R")
if (file.exists("R/coletar_gitlab.R")) source("R/coletar_gitlab.R")
source("R/enriquecer_documentos.R")
source("R/montar_corpus.R")
source("R/codebook_para_decifra.R")

# Este exemplo reproduz a rodada ampliada com GitLab; a rodada GitHub/HF anterior
# consultou à parte as três URLs da lista curada. O cache bruto fica fora do repo.
# O teto desta rodada é 25 tentativas e dez documentos entre as três fontes.
budget <- radar_novo_orcamento()
github <- coletar_github(search_terms = c("Transcritorio", "BERTimbau"), budget = budget)
hf <- coletar_hf(account = "neuralmind", budget = budget)
sources <- list(github = github, huggingface = hf)
if (exists("coletar_gitlab", mode = "function")) {
  gitlab <- coletar_gitlab(search_terms = c("Transcritorio", "BERTimbau"), budget = budget)
  sources$gitlab <- gitlab
}
documents <- coletar_readmes_exploratorios(dplyr::bind_rows(sources), budget = budget)$documents
corpus_inputs <- list(
  github = dplyr::filter(documents, platform == "github"),
  huggingface = dplyr::filter(documents, platform == "huggingface")
)
if ("gitlab" %in% names(formals(montar_corpus))) {
  corpus_inputs$gitlab <- dplyr::filter(documents, platform == "gitlab")
}
corpus <- do.call(montar_corpus, corpus_inputs)
salvar_corpus_decifra(corpus)
decifra_codebook <- codebook_para_decifra()
```

Os coletores usam apenas as APIs oficiais: [GitHub REST](https://docs.github.com/en/rest), [Hugging Face Hub](https://huggingface.co/docs/hub/api) e [GitLab REST API v4](https://docs.gitlab.com/api/). O corpus exportado por padrão fica na pasta externa `bbsia-radar/exports/`, não no git, e contém um texto citável por solução; a função não classifica automaticamente e não envia nada ao BBSIA. A dimensão de interesse público permanece fora do YAML enquanto estiver marcada como não avaliável no codebook. Os testes com fixtures executam sem rede: `Rscript -e "testthat::test_dir('tests/testthat')"`.

## Relatórios e site público

O site Quarto em `report/` gera HTML e PDF a partir do mesmo conteúdo. O workflow do GitHub Actions está preparado para renderizar o site e atualizar o Pages quando dados revisados entrarem em `data/relatorios/`; por enquanto, essa mudança apenas recompila as páginas informativas, porque o leitor e o esquema dos dados ainda precisam ser implementados. A publicação continua desativada até o autor inspecionar o primeiro artefato e habilitar a aprovação. Uma amostra exploratória já foi coletada nas três plataformas, mas ainda não passou pelo Decifra nem por revisão humana e, por isso, não aparece como lista pública de candidatos. O relatório apresentará cobertura, data da rodada, fontes e limites depois da validação. O cache bruto e os READMEs continuam fora do Git.

## Estrutura

```
bbsia-radar/
├── R/                 funções (coleta, enriquecimento, classificação, TRL, deduplicação)
├── scripts/           etapas numeradas do pipeline, que só chamam as funções
├── config/            consultas, sementes e codebook (YAML)
├── data/              só saídas pequenas e revisadas; dados brutos ficam fora do git
├── report/            relatório (Quarto)
├── tests/             testes
├── repo-governance/   planos e registro das conversas com agentes de IA
├── tools/, hooks/     utilitários e verificações de governança
├── AGENTS.md          regras para agentes de IA (coordenação por issues)
├── NEWS.md            histórico das decisões
└── TODO.md            pendências
```

## Como participar

O trabalho é coordenado pelas **issues** deste repositório, tanto entre pessoas quanto entre os agentes de IA que ajudam no projeto: cada tarefa tem uma issue, e quem vai trabalhar nela avisa antes o que vai fazer e como. As regras completas estão em [AGENTS.md](AGENTS.md).

Responsável: Tales Mançano ([@mancano-tales](https://github.com/mancano-tales)), voluntário no BBSIA.
