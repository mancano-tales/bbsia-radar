# Agentes Gemini pelo Antigravity CLI

Este guia registra como descobrir e usar o Antigravity CLI local para pesquisa e revisão no
`bbsia-radar`. Foi conferido em 2026-09-27; modelos, ferramentas, autenticação e permissões podem
mudar entre sessões. O executável encontrado nesta máquina chama-se `agy` (não `agi`).

## Descobrir o CLI e o que está disponível

No PowerShell:

```powershell
Get-Command agy
agy --help
agy models
agy agents
```

`agy --help` lista as opções e os subcomandos instalados. `agy models` consulta os modelos
disponíveis para a conta atual. `agy agents` é descrito pela ajuda como a listagem de agentes
disponíveis; nesta verificação saiu com código 0, mas sem nomes na saída. Portanto, não presuma que
existam agentes nomeados: confirme a lista na sessão em que for trabalhar.

Na consulta de 2026-09-27, `agy models` retornou:

| Identificador | Modelo |
|---|---|
| `gemini-3.8-flash-high` | Gemini 3.8 Flash (High) |
| `gemini-3.8-flash-medium` | Gemini 3.8 Flash (Medium) |
| `gemini-3.8-flash-low` | Gemini 3.8 Flash (Low) |
| `gemini-3.7-flash-high` | Gemini 3.7 Flash (High) |
| `gemini-3.7-flash-medium` | Gemini 3.7 Flash (Medium) |
| `gemini-3.7-flash-low` | Gemini 3.7 Flash (Low) |
| `gemini-3.6-flash-high` | Gemini 3.6 Flash (High) |
| `gemini-3.6-flash-medium` | Gemini 3.6 Flash (Medium) |
| `gemini-3.6-flash-low` | Gemini 3.6 Flash (Low) |
| `gemini-3.1-pro-high` | Gemini 3.1 Pro (High) |
| `gemini-3.1-pro-low` | Gemini 3.1 Pro (Low) |
| `claude-sonnet-4-6` | Claude Sonnet 4.6 (Thinking) |
| `claude-opus-4-6-thinking` | Claude Opus 4.6 (Thinking) |
| `gpt-oss-120b-medium` | GPT-OSS 120B (Medium) |

Esses valores são um retrato da conta no dia da consulta, não uma lista permanente. Rode `agy
models` novamente antes de escolher um modelo. O identificador pode incluir o nível High/Medium/Low;
`--effort` também é uma opção separada do CLI.

## Executar uma tarefa

Para uma consulta não interativa que retorna uma resposta JSON:

```powershell
$prompt = @'
Responda em português. Pesquise [pergunta específica] usando fontes primárias e atuais.
Separe a data do acontecimento da data de publicação e inclua links diretos para as fontes.
Informe as incertezas. Não altere arquivos nem execute comandos externos.
'@
agy --model gemini-3.8-flash-high --mode plan --output-format json --print-timeout 180s --print $prompt
```

O primeiro teste do projeto usou `--mode plan` e `--output-format json`; o agente respondeu com um
`conversation_id`, status e texto final. Para tarefas de pesquisa, mantenha `--mode plan` e declare
no prompt que não deve escrever arquivos, executar comandos ou contatar terceiros. O modo e o prompt
reduzem o escopo da tarefa; ainda assim, confira o resultado e o estado do repositório.

Opções úteis confirmadas pela ajuda:

| Opção | Uso |
|---|---|
| `--agent <nome>` | Seleciona um agente nomeado, se a sessão listar algum. |
| `--model <id>` | Seleciona um dos modelos retornados por `agy models`. |
| `--effort low\|medium\|high\|max` | Ajusta o esforço de raciocínio. |
| `--mode plan\|accept-edits` | Define o modo da sessão. Prefira `plan` para pesquisa e revisão. |
| `--print` / `--prompt` / `-p` | Envia uma tarefa não interativa. |
| `--prompt-interactive` / `-i` | Inicia uma sessão interativa com um prompt. |
| `--continue` / `-c` | Continua a conversa mais recente. |
| `--conversation <id>` | Retoma uma conversa identificada. |
| `--project <id-ou-nome>` | Seleciona o projeto da sessão. |
| `--add-dir <diretório>` | Acrescenta um diretório ao espaço de trabalho; pode ser repetido. Só acrescente diretórios necessários e autorizados. |
| `--new-project` | Cria um projeto para a sessão. |
| `--output-format text\|json\|stream-json` | Escolhe o formato de saída. |
| `--input-format text\|stream-json` | Escolhe o formato de entrada. `stream-json` exige saída `stream-json`. |
| `--json-schema <JSON-ou-arquivo>` | Solicita saída final estruturada conforme um esquema. |
| `--print-timeout <duração>` | Define o tempo máximo da execução não interativa, por exemplo `180s`; o valor sem unidade foi rejeitado no teste. |
| `--disable-slash-commands` | Desativa expansão de slash commands/skills em modo print. |
| `--log-file <caminho>` | Define o arquivo de log da execução. |
| `--remote-control` | Inicia a sessão com conexão de controle remoto. |
| `--sandbox` | Executa com restrições de terminal habilitadas. |
| `--dangerously-skip-permissions` | Aprova automaticamente pedidos de permissão. **Não usar.** |

Subcomandos apresentados pela ajuda: `agent`/`agents`, `changelog`, `help`, `install`, `mcp`,
`mic-serve`, `models`, `plugin`/`plugins`, `remote-control` e `update`. A ajuda de cada subcomando
mostra seu uso; não é necessário atualizar nem instalar componentes para fazer pesquisa.

## Ferramentas observadas na sessão de pesquisa

Ao ser perguntado sobre seus recursos, o agente Gemini desta sessão declarou ter:

- `search_web` para buscar na web e `read_url_content` para ler páginas públicas;
- `view_file`, `write_to_file` e `replace_file_content` para ler e editar arquivos locais;
- `run_command` e `manage_task` para comandos e processos locais;
- `invoke_subagent`, `define_subagent`, `manage_subagents` e `send_message` para delegação e comunicação entre subagentes;
- `call_mcp_tool`, com acesso observado ao servidor `mcp-agent-mail` para identidades e caixas de mensagens de agentes;
- `schedule` para agendamento, `generate_image` para geração de imagens e `ask_question` para perguntas de múltipla escolha.

Essa lista foi declarada pelo agente; não significa que cada ferramenta tenha sido testada, nem que
esteja disponível em toda sessão. Na consulta concreta, o agente usou pesquisa web e leitura de
páginas. Ele disse não ter navegador interativo, login em sites, execução de JavaScript ou acesso a
conteúdo atrás de paywall. Portanto, “pesquisa web” aqui significa busca e leitura de páginas
públicas; não é controle do Microsoft Edge nem um navegador visual.

O CLI também oferece o comando `agy agents`, mas não listou agentes nomeados nesta máquina na data
da conferência. A sessão Gemini afirmou poder invocar subagentes; ainda assim, peça que reporte quais
subagentes conseguiu iniciar e o resultado de cada um, sem presumir que eles foram criados.

## Escolha de modelo e revisão

Preferência do autor registrada em 2026-09-27: usar Gemini 3.8 Flash para exploração e coleta
inicial, e Gemini Pro como revisor. A preferência orienta o fluxo, mas não substitui avaliação da
evidência. A primeira execução de teste escolheu Gemini 3.1 Pro (High) como modelo padrão; a lista
de modelos também confirmou as variantes Gemini 3.8 Flash High, Medium e Low.

Para pesquisa:

1. Flash pode localizar candidatos e resumir fontes públicas; peça citações diretas, data do fato,
   data de publicação e indicação explícita do que não conseguiu verificar.
2. Pro revisa a pergunta, a evidência, os links e as contradições de forma independente. Dê-lhe as
   fontes originais, não apenas a resposta do Flash.
3. Abra as fontes primárias e confirme manualmente as afirmações relevantes. A saída do modelo não é
   fonte. Para notícias, leis ou fatos recentes, não aceite links de redirecionamento como evidência
   final; registre o endereço canônico e a data de publicação.
4. Se os modelos discordarem ou a evidência for fraca, exponha a discordância e mantenha a conclusão
   como incerta até validação humana.

No teste de 25/09/2026, o Gemini 3.1 Pro (High) pesquisou a agenda de Lula. A checagem independente
confirmou a caminhada no Recife ([Itatiaia](https://www.itatiaia.com.br/politica/eleicoes/agenda-dos-candidatos/lula-vai-a-recife-para-ato-com-joao-campos-marilia-e-humberto-nesta-sexta-25/)),
os atos sobre bets e Desenrola ([Ministério da Justiça](https://www.gov.br/mj/pt-br/assuntos/noticias-1/governo-federal-proibe-bets-em-todo-o-pais-e-lanca-pacote-de-protecao-as-familias-endividadas-1))
e o jantar com empresários ([Poder360](https://www.poder360.com.br/poder-eleicoes-2026/lula-brinca-e-chama-joesley-da-jbs-de-empresario-desaforado/)).
O agente acertou as alegações centrais, mas retornou links opacos de redirecionamento e não
distinguiu com precisão algumas datas de publicação. Esse teste mostra que a busca funcionou; não é
uma garantia geral de acurácia.

## Delegação de subtarefas

Quando a ferramenta de subagentes estiver disponível, divida a pesquisa em tarefas independentes
(por exemplo, fontes oficiais, cobertura jornalística e checagem de datas). Peça ao agente principal
que apresente a saída de cada subagente com conclusão, evidência e limites. Evite distribuir a mesma
edição de arquivo a vários agentes. Para instruções e autorização de mensagens entre agentes, siga a
seção de coordenação deste `AGENTS.md` e a governança do hub.

## Limites para este repositório

- O repositório é público: não passe tokens, credenciais, e-mails, rascunhos pessoais nem material
  não público no prompt, no MCP ou em arquivos versionados.
- Para pesquisa, use páginas públicas e fontes primárias. Não peça ao agente que preencha ou envie
  formulários, publique mensagens, contate pessoas, altere o BBSIA ou faça scraping do site.
- Não conceda diretórios extras sem necessidade e não use `--dangerously-skip-permissions`. Se uma
  alteração de arquivo for explicitamente autorizada, limite-a aos arquivos citados na tarefa e
  revise `git diff` antes de aceitar o resultado.
- A pesquisa do agente não substitui os coletores oficiais do radar: coleta de repositórios e modelos
  continua usando as APIs oficiais do GitHub, Hugging Face e GitLab.com, com rate limits e cache
  externo conforme este `AGENTS.md`.
- Em uma sessão Codex restrita, o Antigravity CLI pode falhar ao acessar o perfil/configuração local
  e reportar que não há login. No teste deste projeto, a execução pelo shell restrito também mostrou
  `Access is denied`; uma execução autorizada fora da sandbox conseguiu usar o CLI. Não altere arquivos
  de autenticação nem tente contornar as permissões: reporte o erro e solicite a permissão apropriada.
