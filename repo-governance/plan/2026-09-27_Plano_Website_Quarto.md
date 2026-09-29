---
tipo: Plano
titulo: "Relatórios públicos do bbsia-radar em site Quarto (HTML e PDF)"
issue: 17
status: ATIVO
criado: "2026-09-27 10:52"
concluido: null
autor_humano: "Tales Mançano"
autorizacao_atual: "Em 2026-09-27, o autor aprovou a estrutura do site sem dados reais. Em 2026-09-29, pediu continuar a versão independente para apresentar à coordenação, com nota de proposta em HTML e PDF. Nenhum candidato ou primeira publicação pública está autorizado sem revisão posterior do autor."
agentes:
  orquestrador: "Codex / GPT-6 / desktop"
  executor: "Codex / GPT-6 / desktop"
  auditor: "Gemini 3.1 Pro High e GPT-6-Sol"
tarefas:
  - { desc: "WP1 — fechar o contrato dos dados públicos e da proveniência", status: pendente }
  - { desc: "WP2 — criar páginas e relatórios Quarto em HTML e PDF", status: em andamento }
  - { desc: "WP3 — renderizar e revisar o site e o PDF em CI", status: em andamento }
  - { desc: "WP4 — preparar publicação do Pages protegida por aprovação", status: em andamento }
relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md", "repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md"]
news: ["2026-09-27 — Incorpora revisões da PR Quarto", "2026-09-27 — Cria o site Quarto em estado vazio"]
---

# Plano: site Quarto para relatórios do radar

> **Issue: #17.**

## Objetivo

Criar a estrutura de um site público em português e um relatório Quarto/Markdown em `report/`,
gerável em HTML e PDF. Quando houver resultados revisados, o relatório mostrará as soluções, os
metadados publicáveis, a classificação devolvida pelo Decifra, a estimativa de TRL, a proveniência e
as limitações da rodada. Até lá, a página informará que não há rodada pública e não exibirá registros
inventados. Após a aprovação explícita da primeira publicação pelo autor, novos arquivos públicos
revisados poderão acionar automaticamente a renderização e o deploy no GitHub Pages.

O autor aprovou no chat em 2026-09-27 a implementação do esqueleto, do estado sem dados e da
automação protegida por uma condição de aprovação. A primeira amostra real foi coletada; o esquema
final da tabela pública depende da classificação no Decifra e da revisão humana desses resultados.
A revisão de plano ocorre primeiro com Gemini 3.1 Pro e depois com GPT-6-Sol; a implementação segue
em branch e será entregue em PR.

## Revisão do plano

Em 2026-09-27, Gemini 3.1 Pro High apontou: especificar o mecanismo TeX do PDF; usar o fluxo moderno
de artefatos do GitHub Pages com permissões mínimas; esclarecer como testar antes de existir uma
amostra sem inventar um esquema; e considerar cache de dependências R. A revisão independente em
documentação oficial confirmou `quarto install tinytex`, os artefatos `upload-pages-artifact` e
`deploy-pages` com `pages: write` e `id-token: write`, e a ação `setup-renv` como opção para dependências
R travadas em lockfile. O plano incorpora esses detalhes. Para evitar um contrato fictício, o build
inicial validará a página de estado vazio; fixtures de linhas de candidatos só serão criadas depois
que o esquema público for derivado de uma amostra real. O filtro de publicação continuará ligado à
pasta reservada apenas a arquivos já revisados.

Em 2026-09-27, GPT-6-Sol também não encontrou bloqueios para implementar o estado vazio e recomendou
explicitar quatro limites que agora fazem parte do plano: só publicar artefatos gerados pela `main`,
inclusive nos disparos manuais; colocar o PDF dentro do diretório de saída enviado ao Pages e conferir
o link; distinguir o corpus atual do contrato público futuro; e deixar claro que a coleta não publica
dados por si só. O revisor também recomendou condicionar R/`renv` ao uso efetivo de chunks R e revisar
trechos textuais e atribuição antes de publicar conteúdo de README/model card. Esses pontos foram
incorporados abaixo. Equivalência dos resultados e filtros continua dependendo da amostra real.

## Revisão da implementação

A PR #18 foi revisada por Gemini 3.1 Pro High, que não encontrou achados bloqueadores. GPT-6-Sol
revisou o diff de forma independente e também não encontrou bloqueios de segurança ou publicação.
Suas observações acionáveis foram incorporadas: a data exibida agora corresponde à geração do
relatório e é distinguida da data da coleta; a página inicial mantém um único `h1`; e o CI confere o
`href="relatorio.pdf"` além da presença do arquivo no artefato.

O primeiro build da PR passou. Depois das correções, a execução manual do mesmo workflow na branch
final `f42fb2a` também passou (run [#36329907257](https://github.com/mancano-tales/bbsia-radar/actions/runs/36329907257)):
gerou e conferiu as três páginas HTML, o PDF e o link. O deploy foi ignorado porque a execução não
era da `main` e a condição de aprovação permanece fechada. O PDF foi inspecionado visualmente após a
renderização local. Em 2026-09-28, depois de integrar o PR #22 à branch do site, `quarto render report`
terminou com sucesso. As páginas inicial, método e relatório foram abertas pelo navegador em servidor
local; a inspeção visual na largura móvel não encontrou cortes ou sobreposição. O relatório mostrou
corretamente que a amostra exploratória ainda não é uma rodada pública. O HTML aponta para
`relatorio.pdf`, presente no artefato local. A revisão do artefato final e a aprovação do autor
continuam necessárias antes de ativar o Pages.

## Diagnóstico do repositório em 2026-09-27

- O `README.md` e a descrição About do GitHub explicam o radar em português. Esta entrega acrescenta
  páginas Quarto e workflow de renderização; uma amostra foi coletada, mas não há resultados públicos.
- A coleta exploratória da issue #14 foi executada com GitHub/GitLab `Transcritorio` e `BERTimbau`
  e HF `neuralmind`: 104 URLs únicas (101 GitHub, 1 GitLab e 2 HF); dez documentos selecionados,
  nove lidos e 17/25 tentativas reservadas. A consulta de BERTimbau ao GitHub foi parcial (100 de
  134). Esses agregados ainda não representam uma lista de soluções validadas: Decifra, TRL,
  comparação com o BBSIA e revisão humana seguem pendentes. A issue #14 não pôde receber atualização
  nesta sessão por bloqueio 403 de escrita.
- A política do repositório permite em `data/` somente saídas pequenas e revisadas. O cache bruto
  das APIs permanece fora do Git. Conteúdo de terceiros não recebe automaticamente a licença dos
  arquivos do projeto, e nada do catálogo BBSIA deve ser publicado sem resolver a proveniência e os
  direitos de reutilização.

## Arquitetura proposta

1. **Fontes do relatório.** Depois de uma rodada, avaliar uma tabela pequena e revisada com os campos
   públicos necessários para identificar a solução, apontar a origem, mostrar classificações e
   evidências aprovadas, estimar TRL e declarar o estado da revisão e a data da coleta. Registrar por
   rodada a versão do codebook, o commit do Decifra e a cobertura/limites observados. `id_solucao`,
   título, resumo e demais nomes citados neste plano são grupos/candidatos a avaliar, não um schema
   fechado. Hoje `montar_corpus()` retorna `id`, `text` e `source_urls`, e `salvar_corpus_decifra()`
   grava por padrão fora do Git; esse corpus de trabalho, que pode conter texto de README/model card,
   não é o dataset público. Fechar o esquema exato só com resultados reais do Decifra e revisão humana.
   A estrutura inicial do site e o estado vazio não dependem desse esquema.
2. **Arquivo público versionado.** Guardar somente saídas já revisadas e aceitas para publicação em
   `data/relatorios/`; esse diretório é a fronteira pública (rascunhos ficam fora dele). Manter data,
   autoria/proveniência e histórico por rodada para que o relatório possa ser reproduzido. Não copiar
   para lá respostas brutas, texto integral de README/model card, dados pessoais, tokens, logs locais
   ou registros do BBSIA cuja reutilização não esteja autorizada. Resumos e eventuais trechos curtos
   passam por revisão de direitos, necessidade, atribuição e link para a fonte.
3. **Renderização única.** O projeto Quarto em `report/` lerá os dados curados e usará as mesmas
   tabelas e resumos para renderizar HTML e PDF. O HTML será navegável e poderá oferecer busca/filtros
   úteis conforme o tamanho do corpus; o PDF terá paginação, tabelas legíveis, data de geração e uma
   versão estática dos mesmos resultados. As páginas terão método, cobertura, limitações e links às
   fontes originais, para que um número agregado não pareça mais conclusivo que a evidência. Enquanto
   não existir uma rodada pública, a página de relatório exibirá um estado vazio em vez de dados de
   exemplo.
4. **Build separado da coleta.** O workflow de publicação apenas instala as dependências de render,
   Quando o leitor for implementado, o workflow apenas instalará dependências de render e lerá arquivos públicos versionados; ele não chamará as APIs do GitHub, Hugging Face ou GitLab nem acessará o cache externo, não executa classificação por LLM e não precisa de `GITHUB_PAT` ou
   `HF_TOKEN`. A publicação não altera nem envia dados ao BBSIA.
5. **Atualização automática com controle de entrada.** Mudanças em `data/relatorios/**` (ou nos
   arquivos Quarto/workflow) na branch principal iniciam o build; manter também um disparo manual
   para correções/republicação. O job de deploy só executa quando a variável de repositório
   `PAGES_PUBLISH_APPROVED` for explicitamente definida como `true`. Ela começa ausente/falsa e só
   deve ser ativada pelo autor depois de inspecionar o primeiro artefato. O radar poderá preparar os
   dados ao fim de uma execução, mas somente uma versão revisada e aceita para publicação entra em
   `data/relatorios/`. A coleta apenas prepara dados no armazenamento/cache de trabalho; hoje não
   existe exportador para essa pasta, e uma execução do radar não aciona deploy. A atualização começa
   quando a saída revisada for explicitamente preparada e versionada nessa pasta. Assim, cada rodada
   aceita produz nova versão sem expor cache ou resultados não revisados.

Até que WP1 feche o esquema e o leitor dos resultados reais, o build desta entrega renderiza somente
as páginas informativas e o estado sem dados. Um arquivo de dados pode acionar um novo build, mas não
aparecerá no relatório automaticamente antes dessa integração. A publicação não deve ser ativada
como pipeline de dados enquanto essa etapa estiver pendente.

## Etapas

### WP1 — contrato público e rastreabilidade

- Usar os campos de saída já aprovados do radar e do Decifra; definir um formato tabular estável,
  identificadores e representação de valores ausentes depois que a amostra coletada passar pelo
  Decifra e pela revisão humana.
- Definir em cada rodada sua data, codebook, commit do Decifra, número de itens descobertos,
  removidos, revisados e publicados, mais observações de cobertura e de execução.
- Revisar licença, atribuição e minimização de dados antes de marcar uma coluna como publicável.
- Manter resultados do BBSIA fora da tabela pública até haver fonte autorizada e termos/licença
  adequados para deduplicação e publicação.

### WP2 — site e relatório Quarto

- Criar `_quarto.yml` e páginas em `report/`, começando por visão geral, estado da rodada e método;
  quando existir um esquema público real, acrescentar a tabela de soluções.
- Adicionar filtros apenas para dimensões efetivamente preenchidas e validadas; oferecer links de
  origem e uma página ou seção de limitações. Não apresentar TRL estimado como TRL oficial.
- Renderizar o relatório em `html` e `pdf` a partir da mesma fonte Quarto. Colocar ambos em `_site/`,
  o diretório único enviado como artefato do Pages, e conferir que o link relativo de download aponta
  para o PDF incluído no artefato.
- Ajustar a saída para leitura móvel, impressão, tabelas extensas, texto alternativo e links
  funcionais. Revisar manualmente o HTML e as páginas do PDF, não só o status do build.

### WP3 — CI e validação

- Fixar a versão de Quarto. Para o PDF LaTeX, instalar TinyTeX no CI com o comando oficial
  `quarto install tinytex` antes de renderizar. Instalar R/pacotes e adicionar `renv.lock` e cache
  somente se a renderização usar chunks R; não criar dependências R artificiais para o esqueleto.
- Enquanto não houver uma rodada pública aprovada, renderizar e validar o estado sem dados públicos,
  sem criar linhas fictícias. Depois que o contrato for derivado da amostra real e passar por revisão,
  usar fixtures sintéticos apenas para exercitar esse contrato, sem publicá-las nem fazer chamadas de
  rede.
- Se o render depender de pacotes R, travar suas versões em `renv.lock` e usar cache com chave ligada
  ao lockfile e à versão do R; o cache é otimização, não fonte da verdade das dependências.
- Verificar links locais, presença dos arquivos esperados, coerência entre totais do CSV e relatório,
  ausência de campos proibidos e geração válida do PDF.

### WP4 — deploy e atualização

- Usar o fluxo atual de artefatos do GitHub Pages (`actions/upload-pages-artifact` e
  `actions/deploy-pages`), sem publicar por commit em `gh-pages`. O build recebe somente
  `contents: read`; o job de deploy recebe o mínimo documentado, `pages: write` e `id-token: write`.
- Acionar build/deploy em alterações de dados revisados e em mudanças de conteúdo/configuração do site;
  usar `workflow_dispatch` para correções e republicação. Como `data/relatorios/` contém apenas
  arquivos finais revisados, alterações nesse diretório podem ser o filtro de dados do workflow; não
  incluir diretórios de cache ou rascunho.
- Configurar a origem do Pages como GitHub Actions e validar o artefato de build. O job de deploy só
  aceita execução cuja ref seja `refs/heads/main`; um `workflow_dispatch` em outra branch pode
  renderizar para validação, mas não publicar. Ele também permanece bloqueado enquanto
  `PAGES_PUBLISH_APPROVED` estiver ausente ou diferente de `true`. Aprovação deste plano/PR não ativa
  essa variável: o autor decide ativá-la depois de inspecionar o HTML e PDF iniciais. Ao ativá-la, o
  autor autoriza também os deploys automáticos futuros dos commits elegíveis em `main`. Renderizações
  com falha não chegam ao job de deploy, preservando a versão pública anterior.

## Critérios de aceite

- O conteúdo do site e do PDF é em português, identifica claramente o radar e apresenta data,
  proveniência, método, limitações e links para as fontes públicas.
- Antes da primeira rodada pública, HTML e PDF são gerados em português e mostram claramente que
  ainda não há dados publicados; nenhuma solução fictícia é apresentada como resultado.
- Quando o contrato público estiver fechado e o leitor implementado, HTML e PDF são gerados dos
  mesmos arquivos curados e exibem as mesmas soluções e estatísticas da rodada.
- Após o autor ativar a publicação inicial, um commit de nova versão pública revisada inicia build e
  deploy sem chamadas de coleta ou classificação e publica o PDF junto do site.
- Uma falha de render não substitui silenciosamente a versão pública válida anterior.
- O build não inclui cache bruto, e-mails, tokens, dados pessoais nem dados do BBSIA sem autorização
  explícita de reutilização.
- A revisão visual confirma legibilidade em celular e impressão, tabelas sem corte importante, PDF
  com caracteres em português e navegação acessível por teclado; limitações de acessibilidade
  restantes ficam registradas.

## Dependências e limites

- A amostra exploratória da issue #14 foi coletada. Classificação no Decifra, esquema final dos
  resultados e validação humana ainda não foram concluídos. A estrutura inicial não precisa do
  esquema; fechar os nomes/tipos exatos das colunas depois que a amostra passar por revisão, sem
  publicar fixtures.
- O deploy automático só pode publicar arquivos curados e aceitos pelo autor. Dados e arquivos
  produzidos fora do Git não chegam ao Pages até serem preparados e versionados em uma mudança
  revisada.
- Um PDF impresso não reproduz interações de busca/filtro do navegador. Os filtros melhoram a versão
  HTML; o PDF deve manter a tabela ou os resultados estáticos equivalentes.
- A licença de dados do projeto não resolve os direitos de dados coletados de terceiros nem do
  catálogo BBSIA; manter atribuição e origem por registro e respeitar as pendências da issue #2.

## Referências técnicas consultadas em 2026-09-27

- [Quarto — Creating a Website](https://quarto.org/docs/websites/): estrutura, navegação e publicação
  de sites em destinos como GitHub Pages e diretório de saída `_site/`.
- [Quarto — Including Other Formats](https://quarto.org/docs/output-formats/html-multi-format.html):
  formatos adicionais podem ser ligados a uma página HTML de um documento ou site.
- [Quarto — PDF Basics](https://quarto.org/docs/output-formats/pdf-basics): opções PDF e requisitos
  do fluxo LaTeX padrão.
- [Quarto — Dates and Date Formatting](https://quarto.org/docs/reference/dates): `today` para registrar a data de geração, separada da data da rodada.
- [Quarto — PDF Engines](https://quarto.org/docs/output-formats/pdf-engine): instalação e uso de
  TinyTeX (`quarto install tinytex`).
- [Quarto — Publishing Quarto Manuscripts](https://quarto.org/docs/manuscripts/publishing.html):
  exemplo oficial de GitHub Actions acionado por push e publicação no GitHub Pages.
- [Quarto — GitHub Actions](https://github.com/quarto-dev/quarto-actions): instalação e renderização
  de projetos Quarto em workflows.
- [GitHub — Custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages): artefatos e permissões `pages: write`/`id-token: write`.
- [r-lib/actions](https://github.com/r-lib/actions): ações da comunidade R, incluindo `setup-renv` para dependências registradas em lockfile.

## Aprovação ainda necessária

- O autor aprovou o plano e autorizou a implementação em branch e PR no chat de 2026-09-27.
- Em 2026-09-29, o autor pediu concluir uma versão para mostrar à coordenação. A
  PR #25 acrescenta uma nota de apresentação em HTML/PDF, com piloto sugerido,
  estado atual e decisões pendentes, mantendo a identidade oficial desativada.
  A nota é material de discussão de uma iniciativa voluntária, sem publicar
  candidatos ou pressupor adoção pelo BBSIA.
- A primeira publicação pública ainda depende de aprovação explícita do autor depois que o artefato
  inicial HTML/PDF estiver pronto para inspeção. A variável `PAGES_PUBLISH_APPROVED` mantém o deploy
  bloqueado até essa decisão.
