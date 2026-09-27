---
tipo: Plano
titulo: "Coleta exploratória limitada nas APIs do GitHub e Hugging Face"
issue: 14
status: EM EXECUÇÃO # aprovado pelo autor no chat em 2026-09-27
criado: "2026-09-27 08:40"
concluido: null
autor_humano: "Tales Mançano"
aprovacao_autor: "2026-09-27 no chat: aprovou o plano e o recorte da primeira rodada somente com sementes de config/seeds.yml; módulos adjacentes do BBSIA ficam fora desta coleta."
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
- A issue #12 continua sem decisão sobre o uso dos módulos adjacentes do BBSIA como contexto ou
  sementes.
- O PR #13 implementa consultas GitHub que podem percorrer termos, páginas e contas-semente; o
  coletor HF percorre as contas-semente e três tipos de artefato, embora aceite limite de páginas por
  consulta. Ainda não há um orçamento global de requisições da rodada. Portanto, os coletores não
  devem ser executados em suas configurações completas como se fossem uma amostra pequena.
- O autor aprovou este plano no chat em 2026-09-27, limitado nesta primeira rodada às sementes atuais
  de `config/seeds.yml`; módulos adjacentes do BBSIA ficam fora. A aprovação está registrada aqui;
  a issue #12 continua aberta para decisões futuras sobre esses módulos.
- A issue #14 foi criada e recebeu o rótulo `em-andamento`. Esta branch contém a documentação e o
  plano ativado; a implementação dos limites seguirá em branch própria da issue #14.

## Escopo proposto para a primeira rodada

1. Usar somente sementes já mantidas em `config/seeds.yml`; não consultar módulos do BBSIA para
   descobrir ou ampliar sementes nesta rodada. Judiciário/CNJ/Sinapses, catálogo, recursos,
   prontidão e modelos do BBSIA ficam fora da coleta. Esta restrição vale para o primeiro teste e
   não decide sozinha o uso futuro desses módulos na issue #12.
2. Pesquisar o GitHub com no máximo dois termos escolhidos entre os nomes/artefatos já registrados
   nas sementes, uma página por termo e sem varredura de contas. Cada página tem teto de 100
   resultados; não seguir paginação nem subdividir automaticamente consultas grandes nesta rodada.
3. Consultar apenas `models` no Hugging Face, para uma conta já listada em `config/seeds.yml`, com
   uma página de até 100 resultados. Confirmar primeiro que a conta existe pela própria resposta da
   API; se não existir, interromper. Não escolher outra conta automaticamente: qualquer substituição
   precisa ser registrada na issue #14 antes de repetir.
4. Enriquecer no máximo dez candidatos com README/model card. A seleção dos dez deve ser registrada
   no relatório local; não buscar todos os documentos retornados.
5. Orçamento máximo explícito: duas requisições de busca do GitHub, uma listagem de modelos do HF e
   até dez leituras de README/model card. Cada tentativa HTTP, inclusive respostas `404`, consome o
   orçamento; a rodada não fará retentativas automáticas. Redirecionamentos terão teto documentado e
   contabilizado. Erro de autenticação, `403`, `429`, resposta incompleta ou ausência de cache externo
   interrompe a execução ou marca a amostra como parcial, sem ampliar a consulta.

Antes da primeira requisição, os coletores precisam validar os termos exatos (até dois), a conta HF
(exatamente uma), o tipo `models`, uma página, o limite de documentos e o orçamento HTTP global.
Varredura de contas fica desabilitada e não deve haver consulta de positivos conhecidos fora das
buscas selecionadas. A validação da raiz de cache (existente, gravável e fora do checkout) acontece
antes de qualquer chamada de rede. Resposta do GitHub com `incomplete_results=true` ou mais de 1.000
resultados na busca de uma página deve ser registrada como cobertura parcial, sem subdividir a
consulta automaticamente. Truncar a saída depois de uma coleta sem limites não conta como controle.
Implementar os controles na branch da issue #14, com fixtures e testes offline.

## Documentação oficial verificada

O Antigravity ajudou a localizar e conferir parâmetros da documentação oficial; a confirmação e as
regras desta coleta ficam ancoradas nas fontes primárias abaixo. A saída dos modelos é apoio de
pesquisa, não uma fonte normativa.

- **GitHub Search Repositories**: `per_page` aceita até 100; o endpoint limita cada consulta a 1.000
  resultados e retorna `total_count` e `incomplete_results`. A amostra usa `page=1`, registra `q`,
  ordenação e contagens e não segue páginas nem divide automaticamente resultados incompletos.
  [Documentação REST oficial](https://docs.github.com/en/rest/search/search#search-repositories).
- **GitHub Search rate limit**: autenticação reduz o limite de busca em relação a chamadas sem
  autenticação, mas não remove o limite. A rodada mantém seu próprio orçamento bem abaixo do teto e
  interrompe em `403` ou `429`.
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
- Definir `MANCANO_BBSIA_RADAR_ROOT` para uma pasta fora do checkout e confirmar apenas que o caminho
  existe e não está dentro do repositório. Nunca imprimir ou registrar valores de tokens.
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
4. **Em execução — preparar controles e verificar sem rede.** Implementar limites nos coletores e
   cobri-los com fixtures; rodar a suíte offline antes de qualquer chamada às APIs.
5. **Pendente — checar o ambiente sem expor segredos.** Confirmar R/pacotes, raiz de cache existente,
   gravável e externa ao repo; verificar credenciais sem exibir valores.
6. **Pendente — fixar a consulta e executar a amostra.** O autor ainda precisa confirmar os dois
   termos GitHub, a conta HF e a raiz de cache exata. Até isso estar registrado na issue #14, não fazer
   consultas de candidatos. Usar apenas os limites acima.
7. **Pendente — revisar e decidir.** Avaliar relevância, duplicatas entre plataformas, campos ausentes, erros e
   ruído. O autor decide se a próxima rodada amplia consultas e tamanho. Coleta ampliada, uso de dados
   dos módulos do BBSIA e deduplicação registro a registro ficam fora desta aprovação inicial.

## Critério de conclusão

A primeira exploração termina com o cache e os arquivos de candidatos fora do git, testes offline
aprovados para os limites, um resumo metodológico reproduzível no plano/NEWS e uma recomendação
fundamentada para ampliar, ajustar ou parar. Nenhum registro é enviado ao BBSIA.

## Aprovação do autor

**Aprovado por Tales Mançano no chat em 2026-09-27:** plano e recorte da primeira rodada com as
sementes existentes em `config/seeds.yml`; módulos adjacentes do BBSIA fora desta coleta. A questão
de uso futuro desses módulos pode permanecer aberta na issue #12. A coleta de candidatos começa
somente depois dos controles, verificações offline e cache externo descritos nas etapas 4 e 5, e da
confirmação na issue #14 dos termos GitHub, da conta HF e da raiz de cache que serão usados.
