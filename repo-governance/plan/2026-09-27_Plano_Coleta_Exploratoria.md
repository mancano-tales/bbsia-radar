---
tipo: Plano
titulo: "Coleta exploratória limitada nas APIs do GitHub e Hugging Face"
issue: null
status: PROPOSTO # aguardando aprovação do autor; ainda não é plano ativo
criado: "2026-09-27"
concluido: null
autor_humano: "Tales Mançano"
planos_relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"]
issues_relacionadas: [1, 10, 12]
---

# Proposta: coleta exploratória limitada

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
   API; se não existir, interromper e escolher outra semente já registrada antes de repetir.
4. Enriquecer no máximo dez candidatos com README/model card. A seleção dos dez deve ser registrada
   no relatório local; não buscar todos os documentos retornados.
5. Limite esperado: até três páginas de descoberta (duas do GitHub e uma do HF) e dez documentos de
   enriquecimento. Retentativas de rede seguem os limites e o backoff dos clientes; erro de
   autenticação, `403`, `429` persistente ou ausência de cache externo interrompe a execução.

Antes da primeira requisição, os coletores precisam oferecer parâmetros explícitos para termos,
tipo de artefato, conta, inclusão de varredura por contas e máximo de páginas. O código deve falhar
fechado se o limite for excedido; truncar a saída depois de uma coleta sem limites não conta como
controle. Implementar os controles na branch da issue deste plano, após conferir o código integrado,
com fixtures e testes offline.

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

1. **Sincronizar e revisar o PR #13 integrado.** Atualizar esta branch a partir da `main` que já
   contém o merge e confirmar quais controles faltam no código integrado antes de editar.
2. **Aprovar o escopo.** O autor aprova este plano no chat e registra a decisão da issue #12. Para a
   primeira coleta, recomenda-se manter fora os módulos adjacentes do BBSIA e usar somente
   `config/seeds.yml`; qualquer opção diferente altera a seleção de fontes e precisa estar escrita
   aqui antes da coleta.
3. **Abrir a issue do plano.** Após a aprovação, mudar o status para `ATIVO` e executar
   `python tools/plano_issue.py criar repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`.
   A issue #1 registra o plano-piloto; a issue própria resume estado, responsável e próximo passo.
4. **Preparar controles e verificar sem rede.** Implementar limites nos coletores e cobri-los com
   fixtures. Rodar os testes offline antes de configurar as chamadas.
5. **Checar o ambiente sem expor segredos.** Confirmar que R/pacotes estão prontos, a raiz de cache
   está fora do repo e credenciais públicas opcionais estão disponíveis sem exibir seus valores.
6. **Executar a amostra aprovada.** Usar apenas os termos/conta definidos na issue e os limites
   acima. Se o limite não puder ser imposto antes da requisição, não iniciar a coleta.
7. **Revisar e decidir.** Avaliar relevância, duplicatas entre plataformas, campos ausentes, erros e
   ruído. O autor decide se a próxima rodada amplia consultas e tamanho. Coleta ampliada, uso de dados
   dos módulos do BBSIA e deduplicação registro a registro ficam fora desta aprovação inicial.

## Critério de conclusão

A primeira exploração termina com o cache e os arquivos de candidatos fora do git, testes offline
aprovados para os limites, um resumo metodológico reproduzível no plano/NEWS e uma recomendação
fundamentada para ampliar, ajustar ou parar. Nenhum registro é enviado ao BBSIA.

## Aprovação do autor

**Aguardando aprovação no chat.** Até isso ser registrado, este arquivo permanece `PROPOSTO`, não
recebe issue própria e nenhuma chamada de coleta dos candidatos é iniciada.
