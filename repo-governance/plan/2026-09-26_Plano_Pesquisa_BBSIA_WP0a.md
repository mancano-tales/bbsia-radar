---
tipo: Plano
titulo: "WP0a — Pesquisa documental do BBSIA"
issue: 2
status: CONCLUIDO # aprovado e concluído no chat em 2026-09-26
criado: "2026-09-26"
autor_humano: "Tales Mançano"
---

# WP0a — Pesquisa documental do BBSIA

Este plano detalha a etapa imediata do plano-piloto #1. A proposta anterior agrupava a pesquisa
da issue #2 e a implementação da issue #10; após o alinhamento com o autor, as etapas ficam
separadas. **Agora:** pesquisar e registrar evidências sobre o BBSIA. **Depois:** planejar e
implementar a coleta, com participação dos agentes Antigravity, usando APIs oficiais quando
disponíveis.

## Aprovação do autor

Em 2026-09-26, no chat, o autor aprovou seguir com a pesquisa documental e pediu que o planejamento
fosse melhorado. Esclareceu que a implementação de scraping/coletores não começa nesta etapa e que,
quando começar, serão usados agentes Antigravity (preferência pelo modelo Gemini 3.8 Flash, conforme
informado pelo autor), além das APIs do GitHub e do Hugging Face. A aprovação aqui se limita à
pesquisa e à documentação do WP0a; não autoriza decisões reservadas nem envio de dados ao BBSIA.

## Objetivo e critério de pronto

Responder aos sete itens da issue #2 com fontes diretas e acessíveis, registrar limites de evidência,
e atualizar `README.md` (“A verificar”), §§1.1 e 5 do plano-piloto e `NEWS.md`, com `refs #2`.

## Perguntas de pesquisa

1. Quais são todos os campos do formulário, quais são obrigatórios e quais opções aparecem em cada
   campo de escolha?
2. Há campo de maturidade? Que escala/estágios são usados e como se relacionam (ou não) com TRL 1–9?
3. Quais áreas, categorias e filtros estão disponíveis no catálogo? Como o BBSIA organiza soluções
   pelo problema que resolvem?
4. Há API, exportação CSV/JSON, dados abertos ou importação em lote? Investigar páginas públicas,
   documentação, chamadas de rede observáveis e sitemap; não interpretar ausência de acesso como
   prova de inexistência.
5. Quais termos de uso, aviso de privacidade e licença se aplicam ao catálogo e aos seus dados?
6. Qual é a contagem atual do catálogo, com data e definição da contagem (incluídas/omitidas as
   categorias que a própria interface distingue)?
7. Como o repositório público `Roger-Quinelato/BBSIA` obtém e lê os dados? Registrar fonte, método,
   data/commit observados e limitações; não executar código do repositório.

## Método e evidências

1. Ler a página inicial, páginas ligadas de catálogo, recursos, dados, modelos abertos, contribuição,
   aviso de privacidade e demais documentos oficiais ligados pelo site.
2. Inspecionar os formulários sem enviar dados. Para campos dinâmicos, examinar a interface pública e
   suas opções; não submeter o formulário nem aceitar termos em nome do autor.
3. Consultar sitemap/robots e documentação pública; procurar meios oficiais de acesso a dados.
   Inspecionar tráfego de rede apenas no navegador para entender endpoints públicos da própria página;
   não contornar controles de acesso.
4. Conferir o catálogo e seus contadores em páginas próprias, anotar data de observação e reconciliar
   contagens por seção antes de comparar com números de terceiros.
5. Ler o repositório `Roger-Quinelato/BBSIA` como código/documentação, sem executá-lo. Separar fatos
   observados no código de inferências sobre os dados que ele consome.
6. Usar fontes primárias; cada resposta deve ter link direto e, quando possível, captura/trecho local
   com contexto. Registrar “não encontrado” só após descrever os caminhos consultados.
7. Consultar o Antigravity CLI como apoio de pesquisa somente se o executável já estiver instalado e
   acessível sem instalar software ou alterar permissões. Confirmar a sintaxe e o modelo disponível;
   nenhuma credencial será repassada ao agente. Verificar independentemente todas as afirmações e
   fontes geradas pelo agente.

## Entregas

- Comentário de andamento na issue #2 e rótulo `em-andamento` (se as permissões do GitHub permitirem).
- Respostas numeradas aos itens 1–7, cada uma apoiada por fonte no comentário da issue #2.
- Atualização do README e dos §§1.1 e 5 do plano vigente, sem transformar lacunas em fatos.
- Entrada nova no topo do `NEWS.md`, datada apenas como `2026-09-26`, com metadados de execução e
  referência `refs #2`.
- Ao concluir ou bloquear, atualizar o corpo/comentários da issue e remover `em-andamento`, quando
  houver permissão; conferir o diff e os links antes de encerrar a etapa.

## Limites e etapa futura

- **Não implementar agora** coletores, scraping ou conversor da issue #10; não criar branch de código,
  abrir PR ou coletar repositórios/modelos.
- A etapa futura de descoberta deve escolher a abordagem (agentes Antigravity para pesquisa assistida,
  APIs oficiais GitHub/Hugging Face e combinação entre eles), definir responsabilidades, rate limits,
  cache local, reprodução, validação e custo de uso antes de executar consultas em volume.
- Não decidir licença do projeto (#8) nem casos-limite do codebook (#9).
- Não enviar formulário, e-mail, arquivos ou dados ao BBSIA, nem contatar a coordenação.
- Se GitHub não permitir comentar ou rotular issues, registrar o impedimento técnico e deixar o texto
  pronto no repo para o autor publicar.

## Registro de execução

- 2026-09-26: leitura inicial da home e da página de contribuição. A extração textual mostrou os
  títulos dos campos, mas ainda não revelou valores dos menus. Página de contribuição:
  <https://bancobrasileiro.ia.br/contribuir>.
- 2026-09-26: tentativa de comentar/rotular a issue #2 pelo conector GitHub recebeu HTTP 403
  (`Resource not accessible by integration`). Investigar o navegador autenticado antes de concluir
  que o agente não consegue escrever na issue.
- 2026-09-26: `Get-Command AGI`/`Get-Command agi` não encontrou comando no PATH desta sessão.
- 2026-09-26: respostas aos sete itens da issue #2 consolidadas no README e no plano-piloto. A consulta pública não encontrou documentação de API/exportação, mas a inspeção de tráfego não foi concluída; a inexistência de acesso público não é afirmada como fato.
- 2026-09-26: decisões da issue #8 (licença) e da issue #9 (casos-limite e limiar de concordância) permanecem com o autor; nenhuma decisão foi tomada nesta pesquisa.
