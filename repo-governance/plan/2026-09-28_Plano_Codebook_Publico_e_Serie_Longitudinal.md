---
tipo: Plano
titulo: "Codebook público do formulário BBSIA e série longitudinal do radar"
issue: 24
status: EM EXECUÇÃO
criado: "2026-09-28"
concluido: null
autor_humano: "Tales Mançano"
autorizacao_atual: "Em 2026-09-28, o autor autorizou a execução condicional à aprovação de duas revisões independentes. Após ajustes no commit 1cfac00, Antigravity e subagente aprovaram o plano como roteiro; condição satisfeita, issue #24 criada. A primeira publicação continua sujeita ao plano do site."
agentes:
  orquestrador: "Codex / modelo da sessão / desktop"
  executor: "Codex / GPT-6 / desktop"
  auditor: "Antigravity / Gemini 3.8 Flash High; subagente Codex independente"
tarefas:
  - { desc: "WP1 — especificar campos observáveis e regras de evidência do codebook", status: em_execucao, data: "2026-09-28" }
  - { desc: "WP2 — codificar e validar o codebook ampliado e seu contrato com o Decifra", status: pendente, data: null }
  - { desc: "WP3 — definir identificadores, eventos e saídas revisadas da série semanal", status: pendente, data: null }
  - { desc: "WP4 — publicar série e método no site após revisão e primeira publicação autorizada", status: pendente, data: null }
relacionados:
  - "repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"
  - "repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md"
  - "repo-governance/plan/2026-09-27_Plano_Website_Quarto.md"
---

# Plano: codebook público e série longitudinal do radar

> **Issue: #24. Em execução desde 2026-09-28.** Este plano detalha e coordena WP2/WP8 do piloto e WP1 do site. O autor autorizou sua execução se duas revisões independentes o aprovassem. Após revisão do commit `1cfac00`, Antigravity e subagente deram parecer favorável como roteiro. A primeira publicação requer a autorização específica prevista no plano do site.

## Revisões e autorização

- **Autorização do autor no chat (2026-09-28):** delegar a Antigravity e a outro subagente a revisão deste plano e executá-lo se os dois pareceres aprovarem.
- **Primeira rodada (2026-09-28):** ambos pediram revisão. O subagente encontrou colisão do estado `nao` por silêncio, IDs por URL, dependência do `external_id` e limites da publicação. Antigravity encontrou falta de esquema físico, de atribuição de campos entre Radar e Decifra e de trava explícita do `external_id`.
- **Correção:** commit `1cfac00` incorporou os achados ao roteiro.
- **Segunda rodada (2026-09-28):** subagente aprovou como roteiro após leitura local do plano e código; Antigravity / `gemini-3.8-flash-high` aprovou após ler somente o plano público nesse commit (conversa `9ae9f384-ee40-4a59-a944-c9e8fd106a10`). As duas aprovações validam o roteiro, não concluem WP1–WP4 nem substituem os gates do Decifra, da revisão humana e do site.

## Decisão proposta

Manter a série pública, pequena e revisada em `data/` do próprio `bbsia-radar` durante o piloto. O mesmo repositório contém coletores, codebook, validação, dados publicados e gerador do site; cada mudança de método e de dados fica vinculada ao commit que a produziu. Manter respostas de API e textos completos no cache externo ao Git. Reavaliar um repositório de dados separado quando o volume, as permissões, os consumidores independentes ou a cadência de publicação justificarem isso. Uma eventual migração deve preservar IDs, datas, hashes e referência aos commits originais.

O site em GitHub Pages lê somente saídas revisadas. A primeira publicação exige a autorização já prevista no plano do site. A rotina semanal coleta e prepara candidatos; não transforma automaticamente candidatos em fichas verificadas nem em envios ao formulário BBSIA.

## Vocabulário de evidência

Cada campo codificado guarda `valor`, `estado`, `fonte_url`, `trecho_ou_campo`, `observado_em`, `revisor`, `versao_codebook` e `confianca`. Estados: `declarado_na_fonte`, `inferido`, `nao_verificavel_publicamente`, `nao_se_aplica`, `conflitante`. Ausência de menção não vira `não`. Texto livre gerado por LLM é proposta até revisão; nenhuma inferência é apresentada como declaração de um responsável. Links e trechos de evidência são curtos, sem copiar documentos completos para o Git.

O codebook atual usa `nao` por ausência de sinais em `brasileira` e `ptbr`; WP1 deve decidir a migração explícita para `desconhecido` antes de WP2, sem apagar a versão anterior nem reclassificar silenciosamente os 104 candidatos. O teste de aceitação inclui exemplos sem evidência, contraditórios e com múltiplos valores. Para cada valor multivalorado, guardar evidência e revisão próprias. Separar `observado_em` (captura), data declarada na fonte e data da rodada; nunca inferir a data do fato pela data da coleta.

## Matriz proposta a partir do formulário público

| Campo do formulário | Responsável | O que registrar com fontes públicas | Limite de inferência |
|---|---|---|---|
| Nome curto; problema; funcionamento; tecnologia | Radar captura nome e metadados; Decifra propõe síntese textual | Nome, problema em linguagem comum, função e tecnologia documentada, com trechos citáveis | Descrição ausente ou só nome de tecnologia: desconhecido; não inventar problema ou uso. |
| Tipo de ativo; área de atuação | Decifra propõe classificação; humano valida | Tipo principal e até duas áreas, com vocabulário do formulário após conferir as opções reais | `tipo_artefato` atual é vocabulário do radar; manter mapeamento explícito, sem assumir equivalência. |
| Quem usa; estágio atual | Radar captura releases e atividade; Decifra propõe uso declarado; humano valida | Uso institucional nomeado, implantação, release, demonstração e atividade observáveis | Estrelas, downloads, commits e README não provam uso externo nem TRL 7–9. Registrar TRL apenas como estimativa separada. |
| Abertura e reuso | Radar captura licença e acesso; Decifra lê restrições textuais; humano valida | Licença de código/modelo/dados, acesso ao artefato, documentação, dependências e restrições explícitas | Repositório visível não garante licença, direitos de dados nem capacidade real de reuso. |
| Recursos públicos | Decifra localiza declarações; humano valida | Edital, financiamento, contrato ou órgão financiador declarado e citável | Instituição pública autora não prova que o desenvolvimento foi majoritariamente financiado com recursos públicos. |
| Infraestrutura externa | Radar captura dependências estruturadas; Decifra localiza declarações; humano valida | Serviços, modelos, APIs, nuvem ou execução local declarados; licença e hospedagem quando documentadas | Não inferir soberania ou ausência de dependência a partir do silêncio da documentação. |
| Dados pessoais ou sensíveis | Decifra localiza declarações; humano valida | Tipo de dado que a documentação diz processar e controles publicamente descritos | Não certificar conformidade, risco efetivo, ausência de dados sensíveis nem práticas internas. Não republicar exemplos pessoais. |
| Links; resultado numérico | Radar captura URLs; Decifra localiza resultados declarados; humano valida | URLs da própria solução e resultados acompanhados de fonte, população e método quando houver | Métrica sem contexto é relato da fonte, não efeito verificado. |
| Órgão, nível de governo, UF e município | Radar captura afiliação explícita; humano valida | Afiliação institucional e localização declaradas oficialmente | Conta pessoal, idioma ou domínio não bastam para atribuir órgão/local; evitar cadastro de dados pessoais. |
| Nome, e-mail, cargo e telefone do respondente | Fora do radar público | Nenhum campo pessoal no conjunto público do radar | São dados de contato do formulário, não da solução; coleta exploratória não autoriza inventar respondente. |
| Disposição da instituição para fornecer código, documentação ou conhecimento | Decifra localiza declaração explícita; humano valida | Declaração institucional pública e específica, se existir | Licença aberta não equivale à disposição institucional; em geral `nao_verificavel_publicamente`. |
| Observações e consentimento do formulário | Fora da ficha; Radar mantém nota metodológica | Notas metodológicas do radar separadas da ficha | Consentimento só pode ser dado por quem submete o formulário; o radar não envia fichas automaticamente. |

Consultar novamente o formulário antes de congelar categorias e opções de seleção. Não substituir um campo do formulário por proxy só porque é fácil obtê-lo da API. A política pública da solução difere dos dados privados de contato descritos no aviso de privacidade do BBSIA.

WP1 consulta as opções por leitura do formulário público, inclusive do HTML/DOM apresentado pelo navegador, sem submeter dados. Se alguma opção não estiver publicamente acessível, mantém-se o vocabulário como provisório e registra-se a lacuna; não se inventa equivalência.

## Contrato longitudinal proposto

1. Uma rodada tem `run_id`, data UTC, janela, versão dos coletores, commit do radar, versões do codebook e do Decifra, consultas e parâmetros exatos, status HTTP agregado, totais reportados, páginas lidas, limites, falhas e referência ao cache externo. Reexecução com mesmos parâmetros é auditável, mas resultados de plataformas mutáveis não são prometidos idênticos.
2. `artifact_id` tem namespace por plataforma: ID numérico de repositório GitHub, ID numérico de projeto GitLab e, no Hugging Face, o `repo_id`/nome canônico acompanhado de revisão, aliases e histórico de renomeação (não presumir imutabilidade). URLs são atributos que podem mudar. `solution_id` é uma chave opaca curada, distinta de URL e de `artifact_id`, capaz de reunir vários artefatos. Migrar a identidade provisória por URL do corpus antes do ensaio longitudinal, mantendo mapa de aliases e vínculo `solution_id`–`artifact_id` com início, fim e justificativa para fusões/cisões; nunca contar URLs como soluções.
3. A observação por rodada guarda metadados e classificação com valores, evidências, estado de revisão e `content_hash`. Mudança de classificação ou de codebook gera novo evento; não sobrescreve o passado. Registrar primeira/última observação, desaparecimento da busca e 404 separadamente de encerramento do projeto.
4. O conjunto público contém manifestos por rodada, tabelas pequenas de soluções e observações revisadas e um retrato atual derivado. Esquema versionado em formato longo: `solutions.csv` (chave curada e nome), `solution_artifacts.csv` (vínculo e vigência), `runs/<run_id>.json` (parâmetros e resultado da rodada) e `evidence/<run_id>.jsonl` (uma linha por campo, valor e evidência, com chaves da solução, artefato e rodada). `snapshot_atual.csv` é gerado e não editado à mão. Particionar eventos por rodada evita que a atualização semanal reescreva um arquivo monolítico; evitar uma cópia integral de todos os registros em cada semana. O CI valida unicidade, chaves, datas, links de evidência e ausência de campos privados.
5. Antes da publicação, resolver a codificação dos CSV da rodada exploratória e preservar `external_id` no fluxo Radar → Decifra → Radar. A importação CSV atual do Decifra não preserva esse identificador; uma issue e plano próprios no Decifra devem corrigir e demonstrar ida e volta sem perda. WP3 pode preparar esquema e fixtures no Radar, mas o ensaio integrado e qualquer ficha classificada publicada ficam bloqueados até essa correção ser integrada e testada. O Radar não contorna o importador do Decifra.
6. A primeira rodada pública apresenta método, cobertura parcial e amostra realmente revisada. Os 104 registros exploratórios são URLs/candidatos, ainda não 104 soluções verificadas. O site separa `descoberto`, `triado`, `classificado`, `revisado` e `publicado`.

## Etapas e critérios de aceite

- WP1: conferir opções do formulário; fechar dicionário, esquema físico e regras para desconhecido, conflito, valores múltiplos e fonte; documentar migração das regras atuais que usam `nao` por silêncio; aprovar matriz com o autor e registrar os campos que só um responsável pode responder.
- WP2: ampliar `config/codebook.yml` por nova versão, preservar a anterior e recodificar amostra sem sobrescrever classificações históricas; retirar a instrução obsoleta de atualizar `NEWS.md` por sessão. Atualizar conversor/saída do Decifra apenas para campos que ele realmente classifica; revisar exemplos reais de todas as plataformas e ambiguidades.
- WP3: implementar esquema, IDs, aliases, registro de consultas e fixtures; o ensaio integrado de duas rodadas que demonstre alteração, ausência e deduplicação sem perda do histórico exige antes a correção do `external_id` no Decifra e teste de ida e volta. O hash de conteúdo deve identificar a revisão efetivamente lida do documento, inclusive no Hugging Face, sem confundir leitura do ramo mutável com versão fixa.
- WP4: publicar somente após revisão dos registros e autorização da primeira publicação; mostrar contagens por etapa, histórico, proveniência, limites de cobertura e download das tabelas públicas.

## Pendências para avaliação do autor

- **Escopo público:** confirmar que o radar pode publicar metadados revisados e evidências curtas no seu próprio repositório; respostas integrais de APIs e documentos de terceiros continuam no cache externo. A licença de dados do catálogo BBSIA ainda precisa ser esclarecida antes de reproduzir seus registros.
- **Vocabulário do formulário:** conferir as opções reais dos campos de seleção e aprovar o mapeamento entre elas e o vocabulário atual do radar. O formulário público mostra os nomes dos campos, mas não expôs essas opções na leitura documental realizada.
- **Revisão humana:** definir quem aprova a primeira amostra pública e como registrar correções e discordâncias. A série semanal pode preparar observações automaticamente, mas a publicação de uma ficha depende de revisão.
- **Vínculo com o Decifra:** preservar `external_id` no importador antes de depender dele para ligar classificações e observações ao longo do tempo. Essa alteração pertence ao repositório do Decifra.
- **Ciclo de vida:** ausência na busca, erro 404 e exclusão confirmada são estados diferentes. Um 404 pode indicar remoção, privacidade ou restrição; não registrar motivo sem evidência independente.
- **Site e agenda:** a primeira publicação do GitHub Pages segue o plano próprio do site. Fixar a frequência semanal e o tratamento de semanas sem coleta válida depois do ensaio de duas rodadas.
- **Cobertura:** a rodada de 104 URLs foi limitada a sementes, uma página por consulta e dez documentos. Antes de chamar a série de abrangente, decidir estratégia de paginação, seleção de sementes e validação de recall.

## Fontes verificadas

- Formulário: https://bancobrasileiro.ia.br/contribuir
- Aviso de privacidade: https://bancobrasileiro.ia.br/privacidade
- Plano da primeira coleta: `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`
