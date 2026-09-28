---
tipo: Plano
titulo: "Codebook público do formulário BBSIA e série longitudinal do radar"
issue: null
status: PROPOSTO
criado: "2026-09-28"
concluido: null
autor_humano: "Tales Mançano"
autorizacao_atual: "O autor solicitou um codebook mais completo, uma arquitetura semanal e a relação das chamadas da coleta; a execução desta arquitetura aguarda aprovação deste plano no chat."
agentes:
  orquestrador: "Codex / modelo da sessão / desktop"
  executor: null
  auditor: null
tarefas:
  - { desc: "WP1 — especificar campos observáveis e regras de evidência do codebook", status: pendente, data: null }
  - { desc: "WP2 — codificar e validar o codebook ampliado e seu contrato com o Decifra", status: pendente, data: null }
  - { desc: "WP3 — definir identificadores, eventos e saídas revisadas da série semanal", status: pendente, data: null }
  - { desc: "WP4 — publicar série e método no site após revisão e primeira publicação autorizada", status: pendente, data: null }
relacionados:
  - "repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"
  - "repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md"
  - "repo-governance/plan/2026-09-27_Plano_Website_Quarto.md"
---

# Plano: codebook público e série longitudinal do radar

> **Proposto em 2026-09-28.** Este plano detalha e coordena WP2/WP8 do piloto e WP1 do site. Não autoriza executar esses trabalhos antes da aprovação do autor no chat e do registro da issue do plano.

## Decisão proposta

Manter a série pública, pequena e revisada em `data/` do próprio `bbsia-radar` durante o piloto. O mesmo repositório contém coletores, codebook, validação, dados publicados e gerador do site; cada mudança de método e de dados fica vinculada ao commit que a produziu. Manter respostas de API e textos completos no cache externo ao Git. Reavaliar um repositório de dados separado quando o volume, as permissões, os consumidores independentes ou a cadência de publicação justificarem isso. Uma eventual migração deve preservar IDs, datas, hashes e referência aos commits originais.

O site em GitHub Pages lê somente saídas revisadas. A primeira publicação exige a autorização já prevista no plano do site. A rotina semanal coleta e prepara candidatos; não transforma automaticamente candidatos em fichas verificadas nem em envios ao formulário BBSIA.

## Vocabulário de evidência

Cada campo codificado guarda `valor`, `estado`, `fonte_url`, `trecho_ou_campo`, `observado_em`, `revisor`, `versao_codebook` e `confianca`. Estados: `declarado_na_fonte`, `inferido`, `nao_verificavel_publicamente`, `nao_se_aplica`, `conflitante`. Ausência de menção não vira `não`. Texto livre gerado por LLM é proposta até revisão; nenhuma inferência é apresentada como declaração de um responsável. Links e trechos de evidência são curtos, sem copiar documentos completos para o Git.

## Matriz proposta a partir do formulário público

| Campo do formulário | O que o radar pode registrar com fontes públicas | Limite de inferência |
|---|---|---|
| Nome curto; problema; funcionamento; tecnologia | Nome, problema em linguagem comum, função e tecnologia documentada, com trechos citáveis | Descrição ausente ou só nome de tecnologia: desconhecido; não inventar problema ou uso. |
| Tipo de ativo; área de atuação | Tipo principal e até duas áreas, com vocabulário do formulário após conferir as opções reais | `tipo_artefato` atual é vocabulário do radar; manter mapeamento explícito, sem assumir equivalência. |
| Quem usa; estágio atual | Uso institucional nomeado, implantação, release, demonstração e atividade observáveis | Estrelas, downloads, commits e README não provam uso externo nem TRL 7–9. Registrar TRL apenas como estimativa separada. |
| Abertura e reuso | Licença de código/modelo/dados, acesso ao artefato, documentação, dependências e restrições explícitas | Repositório visível não garante licença, direitos de dados nem capacidade real de reuso. |
| Recursos públicos | Edital, financiamento, contrato ou órgão financiador declarado e citável | Instituição pública autora não prova que o desenvolvimento foi majoritariamente financiado com recursos públicos. |
| Infraestrutura externa | Serviços, modelos, APIs, nuvem ou execução local declarados; licença e hospedagem quando documentadas | Não inferir soberania ou ausência de dependência a partir do silêncio da documentação. |
| Dados pessoais ou sensíveis | Tipo de dado que a documentação diz processar e controles publicamente descritos | Não certificar conformidade, risco efetivo, ausência de dados sensíveis nem práticas internas. Não republicar exemplos pessoais. |
| Links; resultado numérico | URLs da própria solução e resultados acompanhados de fonte, população e método quando houver | Métrica sem contexto é relato da fonte, não efeito verificado. |
| Órgão, nível de governo, UF e município | Afiliação institucional e localização declaradas oficialmente | Conta pessoal, idioma ou domínio não bastam para atribuir órgão/local; evitar cadastro de dados pessoais. |
| Nome, e-mail, cargo e telefone do respondente | Nenhum campo pessoal no conjunto público do radar | São dados de contato do formulário, não da solução; coleta exploratória não autoriza inventar respondente. |
| Disposição da instituição para fornecer código, documentação ou conhecimento | Declaração institucional pública e específica, se existir | Licença aberta não equivale à disposição institucional; em geral `nao_verificavel_publicamente`. |
| Observações e consentimento do formulário | Notas metodológicas do radar separadas da ficha | Consentimento só pode ser dado por quem submete o formulário; o radar não envia fichas automaticamente. |

Consultar novamente o formulário antes de congelar categorias e opções de seleção. Não substituir um campo do formulário por proxy só porque é fácil obtê-lo da API. A política pública da solução difere dos dados privados de contato descritos no aviso de privacidade do BBSIA.

## Contrato longitudinal proposto

1. Uma rodada tem `run_id`, data UTC, janela, versão dos coletores, commit do radar, versões do codebook e do Decifra, consultas e parâmetros exatos, status HTTP agregado, totais reportados, páginas lidas, limites, falhas e referência ao cache externo. Reexecução com mesmos parâmetros é auditável, mas resultados de plataformas mutáveis não são prometidos idênticos.
2. `artifact_id` é a identidade estável da plataforma (GitHub repository ID, GitLab project ID ou identificador de repositório HF) e suas URLs são atributos que podem mudar. `solution_id` é a entidade curada que pode reunir vários artefatos. Manter tabela de vínculo `solution_id`–`artifact_id` com início, fim e justificativa, inclusive para fusões/cisões; nunca contar URLs como soluções.
3. A observação por rodada guarda metadados e classificação com valores, evidências, estado de revisão e `content_hash`. Mudança de classificação ou de codebook gera novo evento; não sobrescreve o passado. Registrar primeira/última observação, desaparecimento da busca e 404 separadamente de encerramento do projeto.
4. O conjunto público contém manifestos por rodada, tabelas pequenas de soluções e observações revisadas e um retrato atual derivado. Preferir CSV/JSONL legíveis e esquema versionado; evitar uma cópia integral de todos os registros em cada semana quando bastam eventos e snapshots periódicos. O CI valida unicidade, chaves, datas, links de evidência e ausência de campos privados.
5. Antes da publicação, resolver a codificação dos CSV da rodada exploratória e preservar `external_id` no fluxo Radar → Decifra → Radar. A importação CSV atual do Decifra não preserva esse identificador; corrigir no repo do Decifra por plano próprio antes de depender da ligação longitudinal.
6. A primeira rodada pública apresenta método, cobertura parcial e amostra realmente revisada. Os 104 registros exploratórios são URLs/candidatos, ainda não 104 soluções verificadas. O site separa `descoberto`, `triado`, `classificado`, `revisado` e `publicado`.

## Etapas e critérios de aceite

- WP1: conferir opções do formulário; fechar dicionário e regras para desconhecido, conflito e fonte; aprovar matriz com o autor e registrar os campos que só um responsável pode responder.
- WP2: ampliar `config/codebook.yml` sem apagar decisões existentes; atualizar conversor/saída do Decifra apenas para campos que o Decifra realmente classifica; revisar exemplos reais de todas as plataformas e ambiguidades.
- WP3: implementar esquema, IDs, registro de consultas, importação com identificador persistente e um ensaio de duas rodadas que demonstre alteração, ausência e deduplicação sem perda do histórico.
- WP4: publicar somente após revisão dos registros e autorização da primeira publicação; mostrar contagens por etapa, histórico, proveniência, limites de cobertura e download das tabelas públicas.

## Fontes verificadas

- Formulário: https://bancobrasileiro.ia.br/contribuir
- Aviso de privacidade: https://bancobrasileiro.ia.br/privacidade
- Plano da primeira coleta: `repo-governance/plan/2026-09-27_Plano_Coleta_Exploratoria.md`
