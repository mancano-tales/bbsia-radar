---
tipo: Plano
titulo: "Relatórios públicos do bbsia-radar em site Quarto (HTML e PDF)"
issue: 17
status: PROPOSTO
criado: "2026-09-27 10:52"
concluido: null
autor_humano: "Tales Mançano"
autorizacao_atual: "No chat em 2026-09-27, o autor pediu a descrição em português, a revisão dos Markdown e este plano. A implementação e a primeira publicação do site não foram solicitadas nesta etapa."
agentes:
  orquestrador: "Codex / GPT-6 / desktop"
  executor: null
  auditor: null
tarefas:
  - { desc: "WP1 — fechar o contrato dos dados públicos e da proveniência", status: pendente }
  - { desc: "WP2 — criar páginas e relatórios Quarto em HTML e PDF", status: pendente }
  - { desc: "WP3 — renderizar e revisar o site e o PDF em CI", status: pendente }
  - { desc: "WP4 — configurar GitHub Pages e atualizar após dados revisados", status: pendente }
relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md", "repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md"]
news: []
---

# Plano: site Quarto para relatórios do radar

> **Issue: #17.**

## Objetivo

Gerar, a partir dos resultados revisados de cada rodada do radar, um site público em português e um
relatório que possa ser baixado como PDF. O relatório será escrito em Quarto/Markdown dentro de
`report/`, e mostrará os candidatos aprovados, os metadados disponíveis, a classificação devolvida
pelo Decifra, a estimativa de TRL, a proveniência e as limitações da rodada. Depois da aprovação da
primeira publicação, mudanças em dados públicos revisados poderão acionar a renderização e o deploy
automáticos no GitHub Pages.

Este é um plano proposto. Nesta etapa não serão implementados arquivos do site, workflows de deploy
nem coleta de dados para alimentá-lo.

## Diagnóstico do repositório em 2026-09-27

- O `README.md` já tem uma explicação em português, e o diretório `report/` já está reservado para
  Quarto. Ainda não há documentos `.qmd` nem workflow de publicação.
- O primeiro conjunto de coletores e o exportador do corpus já existem. A coleta exploratória da
  issue #14 ainda aguarda parâmetros e aprovação; os resultados do Decifra e a revisão humana ainda
  não formam uma base pública de relatório.
- A política do repositório permite em `data/` somente saídas pequenas e revisadas. O cache bruto
  das APIs permanece fora do Git. Conteúdo de terceiros não recebe automaticamente a licença dos
  arquivos do projeto, e nada do catálogo BBSIA deve ser publicado sem resolver a proveniência e os
  direitos de reutilização.
- O acesso de rede à página “About” do GitHub não respondeu nesta sessão. A descrição curta da
  página precisa ser conferida antes de editar; o resumo do README foi revisado nesta proposta.

## Arquitetura proposta

1. **Fontes do relatório.** Depois de uma rodada, preparar uma tabela pequena e revisada com uma
   linha por solução, preservando `id_solucao`, título, resumo, tipo de artefato, plataforma e URL de
   origem, área, rótulos e evidências do Decifra, TRL estimado, estado da revisão e datas da coleta.
   Registrar por rodada a versão do codebook, o commit do Decifra e a cobertura/limites observados.
   Fechar o esquema exato com base nos primeiros resultados reais, sem inventar colunas ausentes.
2. **Arquivo público versionado.** Guardar somente essa saída curada e de tamanho razoável em
   `data/relatorios/` ou em subdiretório equivalente aprovado no WP1. Manter data, autoria/proveniência
   e histórico por rodada para que o relatório possa ser reproduzido. Não copiar para lá respostas
   brutas, dados pessoais, tokens, logs locais ou registros do BBSIA cuja reutilização não esteja
   autorizada.
3. **Renderização única.** O projeto Quarto em `report/` lerá os dados curados e usará as mesmas
   tabelas e resumos para renderizar HTML e PDF. O HTML será navegável e poderá oferecer busca/filtros
   úteis conforme o tamanho do corpus; o PDF terá paginação, tabelas legíveis, data de geração e uma
   versão estática dos mesmos resultados. As páginas terão método, cobertura, limitações e links às
   fontes originais, para que um número agregado não pareça mais conclusivo que a evidência.
4. **Build separado da coleta.** O workflow de publicação apenas instala as dependências de render,
   lê arquivos públicos versionados e gera o site e o PDF. Ele não chama GitHub/Hugging Face, não
   acessa o cache externo, não executa classificação por LLM e não precisa de `GITHUB_PAT` ou
   `HF_TOKEN`. A publicação não altera nem envia dados ao BBSIA.
5. **Atualização automática com controle de entrada.** Após a primeira publicação autorizada, uma
   mudança em `data/relatorios/**` (ou nos arquivos Quarto/workflow) na branch principal inicia o
   render e deploy no GitHub Pages; manter também um disparo manual para correções/republicação. O
   radar poderá preparar os dados ao fim de uma execução, mas só uma versão revisada e aprovada para
   publicação será adicionada ao arquivo versionado. Assim, cada rodada aceita produz nova versão do
   relatório sem expor cache ou resultados ainda não revisados.

## Etapas

### WP1 — contrato público e rastreabilidade

- Usar os campos de saída já aprovados do radar e do Decifra; definir um formato tabular estável,
  identificadores e representação de valores ausentes depois da primeira amostra real.
- Definir em cada rodada sua data, codebook, commit do Decifra, número de itens descobertos,
  removidos, revisados e publicados, mais observações de cobertura e de execução.
- Revisar licença, atribuição e minimização de dados antes de marcar uma coluna como publicável.
- Manter resultados do BBSIA fora da tabela pública até haver fonte autorizada e termos/licença
  adequados para deduplicação e publicação.

### WP2 — site e relatório Quarto

- Criar `_quarto.yml` e páginas em `report/`, começando por visão geral, tabela de soluções e método.
- Adicionar filtros apenas para dimensões efetivamente preenchidas e validadas; oferecer links de
  origem e uma página ou seção de limitações. Não apresentar TRL estimado como TRL oficial.
- Renderizar o documento em `html` e `pdf` a partir da mesma fonte Quarto e disponibilizar o PDF
  para download a partir do site.
- Ajustar a saída para leitura móvel, impressão, tabelas extensas, texto alternativo e links
  funcionais. Revisar manualmente o HTML e as páginas do PDF, não só o status do build.

### WP3 — CI e validação

- Fixar versões de Quarto, R e pacotes do render; incluir em CI o mecanismo necessário para o PDF.
  A documentação oficial do formato PDF informa a dependência de uma distribuição TeX para o fluxo
  LaTeX padrão.
- Renderizar a partir de dados de fixture sintéticos nos checks iniciais, sem publicar esses exemplos
  nem fazer chamadas de rede. Depois, conferir o resultado com um snapshot público real aprovado.
- Verificar links locais, presença dos arquivos esperados, coerência entre totais do CSV e relatório,
  ausência de campos proibidos e geração válida do PDF.

### WP4 — deploy e atualização

- Usar GitHub Pages com GitHub Actions; limitar permissões do workflow ao build e à publicação.
- Acionar deploy em alterações de dados revisados e em mudanças de conteúdo/configuração do site;
  suportar execução manual e preservar o último site válido se o render falhar.
- Configurar a origem do Pages e as permissões de Actions no repositório. Validar primeiro o artefato
  de build; pedir ao autor a aprovação final antes da publicação pública inicial. Após essa aprovação,
  deploys de novas versões revisadas seguem automaticamente.

## Critérios de aceite

- O conteúdo do site e do PDF é em português, identifica claramente o radar e apresenta data,
  proveniência, método, limitações e links para as fontes públicas.
- HTML e PDF são gerados a partir dos mesmos arquivos curados e exibem as mesmas soluções e
  estatísticas da rodada.
- Um commit de uma nova versão pública revisada inicia o build/deploy sem chamadas de coleta ou
  classificação e publica o PDF junto do site.
- Uma falha de render não substitui silenciosamente a versão pública válida anterior.
- O build não inclui cache bruto, e-mails, tokens, dados pessoais nem dados do BBSIA sem autorização
  explícita de reutilização.
- A revisão visual confirma legibilidade em celular e impressão, tabelas sem corte importante, PDF
  com caracteres em português e navegação acessível por teclado; limitações de acessibilidade
  restantes ficam registradas.

## Dependências e limites

- A amostra exploratória da issue #14, a classificação no Decifra, o esquema final dos resultados e
  a validação humana ainda não foram concluídos. Evitar projetar o site sobre um esquema fictício.
- O deploy automático só pode publicar arquivos curados e aceitos pelo autor. Dados e arquivos
  produzidos fora do Git não chegam ao Pages até serem preparados e versionados em uma mudança
  revisada.
- Um PDF impresso não reproduz interações de busca/filtro do navegador. Os filtros melhoram a versão
  HTML; o PDF deve manter a tabela ou os resultados estáticos equivalentes.
- A licença de dados do projeto não resolve os direitos de dados coletados de terceiros nem do
  catálogo BBSIA; manter atribuição e origem por registro e respeitar as pendências da issue #2.

## Referências técnicas consultadas em 2026-09-27

- [Quarto — Creating a Website](https://quarto.org/docs/websites/): estrutura, navegação e publicação
  de sites em destinos como GitHub Pages.
- [Quarto — Including Other Formats](https://quarto.org/docs/output-formats/html-multi-format.html):
  formatos adicionais podem ser ligados a uma página HTML de um documento ou site.
- [Quarto — PDF Basics](https://quarto.org/docs/output-formats/pdf-basics): opções PDF e requisitos
  do fluxo LaTeX padrão.
- [Quarto — Publishing Quarto Manuscripts](https://quarto.org/docs/manuscripts/publishing.html):
  exemplo oficial de GitHub Actions acionado por push e publicação no GitHub Pages.

## Decisão pendente do autor

- Aprovar ou ajustar este plano antes de o tornar `ATIVO`. A primeira publicação pública e a
  configuração de Pages/Actions ficam para revisão quando houver uma amostra real, esquema estável,
  HTML e PDF prontos para inspeção.
