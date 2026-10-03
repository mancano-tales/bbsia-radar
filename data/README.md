# Série longitudinal do radar

**Primeira rodada publicada: `2026-09-29_piloto`** (plano #28). Oito soluções
que o autor revisou como IA brasileira ou em português do Brasil, agrupadas por
família em `config/solucoes_piloto.yml`. Nos arquivos abaixo, os rótulos
`e_ia`, `brasileira` e `ptbr` têm `revisao = revisado` (autor); tipo, área, TRL
e o resumo do problema têm `revisao = proposto` (máquina ou radar, sem revisão),
por decisão do autor em 2026-10-03. Nenhum texto de README, model card ou
resposta de API é copiado: só links, rótulos e contagens. Os arquivos são
gerados por `scripts/03_publicar.R`; não edite à mão.

A concordância humano × máquina da rodada está em
`relatorios/2026-09-29_piloto-concordancia.csv`. As 104 ocorrências da
sondagem exploratória de 2026-09-27 continuam fora deste diretório: eram
candidatos de buscas limitadas, não soluções verificadas.

## Contrato público proposto (v1)

| Arquivo | Chave | Conteúdo |
|---|---|---|
| `solutions.csv` | `solution_id` | Entidade curada, nome e primeira/última observação. ID opaco; URL não é identidade. |
| `solution_artifacts.csv` | `solution_id`, `artifact_id`, `data_inicio` | Vínculos entre solução e artefato, plataforma, tipo, URL observada, vigência e justificativa de fusão/cisão. |
| `runs/<run_id>.json` | `run_id` | Janela, horário UTC, commits do Radar e do Decifra, versões, consultas e parâmetros exatos, páginas, totais, status HTTP agregado, falhas e referência ao cache externo. |
| `evidence/<run_id>.jsonl` | `run_id`, `artifact_id`, `campo`, `valor`, `fonte_url` | Um fato por linha, com `solution_id`, `estado`, `trecho_ou_campo`, `observado_em`, data declarada da fonte, `revisor`, estado da revisão, confiança, versão do codebook e hash da revisão efetivamente lida. Valores múltiplos têm evidências próprias. |
| `snapshot_atual.csv` | `solution_id` | Visão derivada para o site; nunca editada manualmente. |

`artifact_id` usa `github:<repository_id>`, `gitlab:<project_id>` ou
`huggingface:<models|datasets|spaces>:<namespace/repo_id>`. O identificador do
Hugging Face pode mudar com renomeações; vínculos e aliases preservam o histórico.
O mapa versionado de renomeações verificadas é `config/aliases.yml`; a lista
começa vazia e não cria vínculos automaticamente. O `content_hash` combina
a revisão imutável lida (blob SHA no GitHub, commit SHA no Hugging Face,
`last_commit_id` no GitLab) com SHA-256 do texto. Sem essa revisão, o hash
fica ausente e a observação não pode ser registrada como `ok`.
`solution_id` é atribuído por curadoria e pode reunir vários artefatos. A
migração dos IDs provisórios por URL do corpus é requisito anterior à primeira
rodada longitudinal integrada.
`radar_propor_vinculos()` gera chaves provisórias sem URL a partir do ID da
plataforma e preserva os IDs das sementes já curadas; a proposta não faz fusão
automática entre plataformas e precisa de revisão antes de entrar em `data/`.

Os eventos `novo`, `alterado`, `inalterado`, `reapareceu`, `ausente_da_busca` e
`http_404` não afirmam encerramento. Um 404 pode indicar remoção, privacidade ou
restrição; a causa só entra como fato com evidência independente. Erros HTTP
distintos de 404 ficam no manifesto e não viram desaparecimento. Cada rodada é
imutável; correções criam novo evento ligado ao anterior.

## Porta de publicação

As respostas brutas de APIs, documentos completos e fichas com dados de
contato ficam fora deste diretório. Propostas sem revisão só entram rotuladas
como `proposto`, por decisão do autor em 2026-10-03. A preparação semanal
grava manifestos no cache externo por padrão. Antes do primeiro dado real no Git,
é preciso testar a ida e volta do `external_id` no Decifra, revisar uma amostra
humana, confirmar direitos de uso e obter a autorização específica da primeira
publicação prevista no plano do site. O site lê somente a saída revisada.
