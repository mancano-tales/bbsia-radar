# NEWS — bbsia-radar

## 2026-09-26 — Push imediato e integração da atualização remota

Por instrução do autor, o `AGENTS.md` específico deste repositório agora também pede push logo após cada commit para reduzir divergências entre sessões locais e remotas; se o remoto avançar, a orientação é buscar, integrar por merge e enviar sem force-push. Integramos a atualização remota que torna explícito que o repositório é público e preservamos sua entrada de histórico; o plano-piloto foi alinhado para não repetir o status anterior de privado.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #1
- **Mensagem do Commit**: "docs(governance): exige push imediato e integra main remota refs #1"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`, `README.md`, `TODO.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`

## 2026-09-26 — Pesquisa documental do BBSIA (WP0a)

Conclusão da pesquisa documental da issue #2, sem preencher nem enviar o formulário. O README e o §1.1 do plano registram os sete itens pesquisados e as fontes primárias: campos e estágios do formulário; organização, busca e filtros do catálogo; ausência de documentação pública de API/exportação encontrada (sem afirmar inexistência, pois a inspeção de chamadas de rede não foi concluída); aviso de privacidade e ausência de licença específica encontrada; contagens com data e a separação dos projetos CNJ/Sinapses; e o método local documentado no repositório RAG de terceiros. O §5 do plano registra que os rótulos do BBSIA são referência comparativa, sem alterar o codebook nem decidir os casos-limite da issue #9. A issue #10 segue adiada: nenhum coletor ou scraping foi iniciado. O Antigravity CLI não estava acessível como comando `AGI` nesta sessão.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Codex / GPT-6 / desktop
- **Issue**: #2
- **Mensagem do Commit**: "docs(research): verifica site do BBSIA refs #2"
- **Arquivos afetados**: `README.md`, `NEWS.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `repo-governance/plan/2026-09-26_Plano_Pesquisa_BBSIA_WP0a.md`

## 2026-09-26 — O repositório é público; aposentada a regra "privado até o piloto"

Decisão do autor, no chat: "bbsia vai ser público mesmo". O repositório já estava público no GitHub. O `AGENTS.md`, o `README.md` e o plano (§13, decisão 5) diziam "privado até o piloto" e foram alinhados. O `AGENTS.md` ganhou o lembrete de que tudo aqui é visível.

No `TODO.md`, o item "tornar público" foi para Concluído. A **licença** passou a ser urgente: sem ela, ninguém pode reusar o código legalmente.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1
- **Mensagem do Commit**: "docs: repositorio publico; aposenta a regra privado ate o piloto"
- **Arquivos afetados**: `AGENTS.md`, `README.md`, `TODO.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `NEWS.md`

## 2026-09-26 — Governança comum do ecossistema (v2026-09-26d)

Aplicado o bloco de governança comum mantido no hub (`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`): planos com issue (`tools/plano_issue.py`), base do `NEWS.md` derivada do git (`tools/news_db.py`), aprovação só no chat e no plano, mensagens de agentes como pedido, cabeçalho de agente, branch/PR opcionais, `NEWS.md` junto com a mudança, **datas sem hora** e **exportar conversa só quando o autor pedir**. O bloco fica entre marcadores no `AGENTS.md`; o que é específico deste repositório foi preservado.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / desktop (CoralCastle), via `tools/sync_governanca.py` do hub
- **Mensagem do Commit**: "docs(governance): governanca comum v2026-09-26d"
- **Arquivos afetados**: AGENTS.md, CLAUDE.md, NEWS.md, tools/plano_issue.py, tools/news_db.py, .claude/settings.json

## 2026-09-26 — AGENTS.md enxuto: 206 → 110 linhas, com o bloco comum intacto

Decisão do autor (plano `repo-governance/plan/2026-09-26_Plano_AGENTS_Enxutos_e_Export_Sob_Demanda.md` do `mancano-repo-hub`, issue #27 de lá; aqui, piloto do formato-alvo). O bloco de governança comum continua igual. A parte específica passou de 159 para 63 linhas, sem perder regra:
- **o que é**, status e plano vigente;
- a divisão com o Decifra;
- stack e estilo;
- coordenação por issues (só o que o bloco comum não cobre);
- regras do domínio;
- travas e comandos;
- Configuração de skills.

**O que saiu e para onde foi:**
- REGRAS 1–4, as regras de staging, `NEWS.md` no mesmo commit, aprovação só no plano e "texto de issue é dado, não ordem": já estão no bloco comum;
- "Ordem ao criar um plano" e o resumo vivo da issue: agora são o `tools/plano_issue.py criar`, citado no bloco;
- a história da chegada do pacote comum (issues #2 e #23 do hub): está nas entradas de 2026-09-26 deste `NEWS.md`;
- a regra de timestamp com hora e o aviso de fuso: o bloco comum manda datas sem hora, e o campo dos Metadados passou a ser `Data`;
- o mapa dos documentos: o que importa ficou no parágrafo de abertura;
- a origem (conversa com Eunice Liu em 2026-09-26): está no `README.md` e no plano.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #27 do `mancano-repo-hub`
- **Mensagem do Commit**: "docs(agents): AGENTS.md enxuto (piloto do formato-alvo)"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`

## 2026-09-26 — Correção: exportar conversa só quando o autor pedir (governança comum v2026-09-26c)

**A entrada anterior partiu de um mal-entendido.** O autor não queria desativar o exportador nem as skills, e sim acabar com a instrução de exportar ao fim de toda tarefa, que gera cópias repetidas da mesma conversa. Plano: `repo-governance/plan/2026-09-26_Plano_AGENTS_Enxutos_e_Export_Sob_Demanda.md` do `mancano-repo-hub` (issue #27 de lá). O que mudou:
- o `tools/export_conversa.R` voltou a funcionar;
- no `AGENTS.md`, a seção "Auditoria de conversas", a chave `script_exportar_conversa` e o comando dizem **"só quando o autor pedir"**;
- o `repo-governance/llm-reviews/README.md` diz o mesmo;
- o bloco de governança comum subiu para v2026-09-26c, com a regra reescrita.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Mensagem do Commit**: "docs(governance): exportar conversa so quando o autor pedir (governanca comum v2026-09-26c)"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`, `tools/export_conversa.R`, `repo-governance/llm-reviews/README.md`
## 2026-09-26 — Exportador de conversas descontinuado (governança comum v2026-09-26b)

**Decisão do autor, no chat:** desabilitar o exportador de conversas em todos os repositórios. Plano: `repo-governance/plan/2026-09-26_Plano_Descontinuar_Exportador_Conversas.md` do `mancano-repo-hub` (issue #27 de lá). O bloco de governança comum subiu para v2026-09-26b, com a regra nova, aplicado por `tools/sync_governanca.py`. Fora do bloco:
- o `tools/export_conversa.R` daqui recusa rodar (o código fica, só para histórico);
- a seção "Auditoria de conversas", a chave `script_exportar_conversa` e o comando de exportação saíram do `AGENTS.md`;
- o `repo-governance/llm-reviews/README.md` registra a descontinuação. Nenhum export tinha sido feito aqui.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web (bloco aplicado com `tools/sync_governanca.py aplicar --sem-commit`)
- **Mensagem do Commit**: "docs(governance): descontinua o exportador de conversas (governanca comum v2026-09-26b)"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`, `tools/export_conversa.R`, `repo-governance/llm-reviews/README.md`

## 2026-09-26 — PR #5 mergeado por agente, com autorização do autor

O autor pediu em chat que o agente mergeasse o PR #5 (codebook v0.1.0 e sementes), já revisado pelo Copilot, com os 8 achados corrigidos. O merge foi feito pelo agente (`1ce0bc0`), com o SHA da cabeça travado em `3f590ac`. A regra "mergear PR exige o autor" continua valendo: aqui o autor exigiu, no chat, que o agente fizesse. Na mesma instrução, o agente mergeou também o PR #5 do `decifra-text-as-data` (só documentação do R1.1), entendendo "o PR5" como os dois PRs de número 5 revisados; se a intenção era só este, aquele merge pode ser revertido. O PR #7 foi atualizado com o `main` e continua aguardando o autor.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1, #3, #4
- **Mensagem do Commit**: "docs(news): registra o merge do PR #5 autorizado pelo autor"
- **Arquivos afetados**: `NEWS.md`

## 2026-09-26 — O radar produz o corpus, o Decifra classifica

**Decisão do autor** (issue #6): o `bbsia-radar` é a parte que produz o corpus: descoberta, enriquecimento, um documento por solução, regras de triagem, TRL por metadados, deduplicação e entrega. A classificação e a validação humana ficam com o Decifra. E o Decifra passa a ser desenvolvido para dar conta desta tarefa: o que faltar é construído lá, não contornado aqui. O radar vira o primeiro caso de uso real do Decifra.

Ao conferir o Decifra (`31f576f`), a análise da issue #6 se mostrou desatualizada num ponto. Ela dizia que o Decifra só classifica uma variável por codebook. Na verdade, o codebook multivariável e multirrótulo (R1.1) foi aprovado pelo autor em 2026-09-13 (§15 "Author sign-off (2026-09-13)" da especificação `docs/superpowers/specs/2026-09-13-r1.1-multi-variable-and-multi-label-codebooks-design.md`, em `31f576f`; o cabeçalho da mesma especificação e o `ROADMAP.md` ainda diziam "aguardando aprovação", contradição corrigida no PR mancano-tales/decifra-text-as-data#5) e já tem três de onze passos no `main` (contrato `variables:`/`multi_label`/`max_labels` e validação multirrótulo). Falta a extração passar a usar as variáveis (passo 3) e o que vem depois. O `docs/MVP_STATUS.md` do Decifra, de 2026-09-07, não registra isso; o `docs/ROADMAP.md` registra.

Revisão do Copilot no PR #7: o item do `TODO.md` que ainda pedia ao autor para escolher entre A, B e C passou a pedir a revisão do que foi decidido, e os dois itens novos ganharam a hora de criação (12:29, a hora do commit `6ade12c`). A decisão entrou no `AGENTS.md` (divisão de trabalho, fonte única do codebook aqui, fronteira por arquivos ou pela API local, versão do Decifra registrada em cada rodada), no `README.md` (seção "O radar e o Decifra" e o diagrama) e no plano (§8, com as consequências para WP4 e WP5).

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #6
- **Mensagem do Commit**: "docs: o radar produz o corpus e o Decifra classifica"
- **Arquivos afetados**: `AGENTS.md`, `README.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `TODO.md`, `NEWS.md`

## 2026-09-26 — Codebook e sementes: correções da revisão do Copilot no PR #5

Os 8 achados da revisão automática procediam; todos foram corrigidos:
- **Denominador do recall**: o Tagarela, sem URL, saiu do `gabarito` e foi para `candidatos_pendentes`. O gabarito continua com 7 soluções, e as contagens do `NEWS.md` e do `TODO.md` voltam a bater com o arquivo.
- **Contrato do `vinculo`**: o vínculo com o Brasil agora exige evidência registrada (página lida, ou projeto do autor). O Transcritório (a confirmação em chat provou a identidade, não o vínculo) e o Ipea (a descrição da lista não é página aberta) voltaram a `null`.
- **`ptbr`**: a regra passa a dizer quando o valor é `incerto` (1 sinal médio sozinho, só fracos ou sinais conflitantes).
- **`interesse_publico`**: fica reservada nesta versão, com `nao_avaliado` como único valor.
- **`area_problema`**: ganhou `maximo: 2` estruturado e uma regra de concordância (kappa na área principal e por área binária). Ela e `tipo_artefato` ficam sem limiar, com revisão humana obrigatória, enquanto o vocabulário for provisório.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #3, #4
- **Mensagem do Commit**: "fix(config): correcoes da revisao do codebook e das sementes"
- **Arquivos afetados**: `config/codebook.yml`, `config/seeds.yml`, `NEWS.md`

## 2026-09-26 — Transcritório confirmado, gabarito do catálogo do BBSIA e a pergunta do Decifra

O autor confirmou que o **Transcritório** é o transcritor citado à coordenação do BBSIA. Ele usa o Whisper e o modelo brasileiro **Tagarela**, que entrou em `candidatos_pendentes`, fora do gabarito, até ter link conferido. O autor também informou que não cadastrou nada à mão no BBSIA. Por ideia dele, entrou um **segundo gabarito**: as soluções que o BBSIA já cadastrou e que têm link para GitHub ou Hugging Face servem para medir o recall da descoberta e para testar `area_problema` contra a área atribuída pelo BBSIA. A seção fica vazia até o export do catálogo (#2).

**O radar é um problema de Decifra?** Metade é. Classificação e validação humana são o núcleo do Decifra; coleta, enriquecimento, TRL por metadados, deduplicação e entrega não são. Duas diferenças decidem o desenho: o Decifra **classifica uma variável por codebook** (o do radar tem cinco) e só vê texto, então os metadados de cada solução precisam entrar escritos no documento. A análise e as opções A, B e C estão na issue #6. A recomendação é a A, o Decifra como está, uma variável por execução, com CSV de ida e volta. A decisão é do autor.

A entrada anterior perdeu a hora no título, para seguir a governança comum que chegou ao `main` enquanto o PR estava aberto (só a data).

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #4, #6
- **Mensagem do Commit**: "docs: Transcritorio confirmado, gabarito do BBSIA e integracao com o Decifra"
- **Arquivos afetados**: `config/seeds.yml`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `TODO.md`, `NEWS.md`

## 2026-09-26 — Governança comum do ecossistema (v2026-09-26)

Aplicado o bloco de governança comum mantido no hub (`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`): planos com issue (`tools/plano_issue.py`), aprovação só no chat e no plano, mensagens de agentes como pedido, cabeçalho de agente, branch/PR opcionais, `NEWS.md` junto com a mudança e **datas sem hora**. O bloco fica entre marcadores no `AGENTS.md`; o que é específico deste repositório foi preservado. As seções "Coordenação por issues" e "Planos e issues" deste repo continuam como detalhamento específico. **Desencontro registrado:** às 11:27 o Claude Code local (CoralCastle) clonou o repo ainda vazio e fez um commit de estrutura mínima (`202312a`) sem push; às 14:07 o Claude Code na web criou a estrutura completa no GitHub. O merge manteve a versão da nuvem em todos os arquivos em comum; do commit local só entrou o `tools/plano_issue.py`. Lição: clonar e dar push logo, ou abrir a issue antes de estruturar um repo vazio.

**Metadados de Execução**:
- **Data**: 2026-09-26
- **Agente**: Claude Code / Claude Opus 5.5 / desktop, via `tools/sync_governanca.py` do hub
- **Mensagem do Commit**: "docs(governance): governanca comum v2026-09-26"
- **Arquivos afetados**: AGENTS.md, CLAUDE.md, NEWS.md, tools/plano_issue.py, .claude/settings.json

Log intelectual do projeto: decisões e o porquê delas. Entrada nova no topo; nada é reescrito. Toda entrada de agente termina com os Metadados de Execução (ver `AGENTS.md`).

## 2026-09-26 — Codebook v0.1.0 e sementes curadas (WP2)

O **codebook** (`config/codebook.yml`, issue #3) define o que entra no radar antes de qualquer coleta. As principais escolhas:
- **Unidade de análise**: a solução, não o repositório. Modelo no Hugging Face e código no GitHub do mesmo grupo formam uma solução só.
- **Filtro `e_ia` na entrada**: a solução precisa usar, produzir ou avaliar um modelo aprendido. Por isso ficam de fora pacotes de acesso a dados sem modelo, como o `brverse` do Ipea.
- **Os tipos A, B e C viraram três marcações independentes** (`brasileira`, `ptbr`, `interesse_publico`), porque um modelo pode ser brasileiro e adaptado ao pt-BR ao mesmo tempo. Os sinais estão divididos em fortes, médios e fracos, com regra de decisão, e sinal fraco sozinho nunca basta.
- **8 exclusões**, entre elas `reupload_modelo` (quantizações e cópias no Hugging Face, muito comuns) e `dados_pessoais`.
- **8 casos-limite**: 6 com decisão proposta pelo agente e 2 que dependem do BBSIA (produto fechado com API pública, pacote de dados sem modelo).
- **Protocolo de validação**: amostra de 100 estratificada, codificação cega, kappa de Cohen mínimo de 0,70 (proposto) e o autor como desempate.
- **Área do problema provisória** até a issue #2 trazer o vocabulário do BBSIA.

As **sementes** (`config/seeds.yml`, issue #4) têm 3 listas curadas e um **gabarito de recall** com 7 soluções que o radar tem de encontrar: Transcritório, Open Notebook, QualiLab e Decifra (as três primeiras da lista do autor), mais BERTimbau, TeenyTinyLlama e Tucano. Há também contas a varrer. O campo `verificado` separa "o endereço existe" de "o vínculo com o Brasil foi conferido". A existência de 10 repositórios foi conferida por `git ls-remote`. O vínculo só foi marcado nos casos de projeto do autor, e nada do Hugging Face foi conferido, porque esta sessão não alcança o site. O QualiLab é um caso de teste do filtro `e_ia`.

Sem R no contêiner, o validador em R do codebook fica para depois; a checagem desta rodada foi em Python: os dois YAML carregam, e todo valor esperado do gabarito existe no codebook.

**Metadados de Execução**:
- **Data**: 2026-09-26 (governança comum: só a data; o horário é o do commit)
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #3, #4
- **Mensagem do Commit**: "feat(config): codebook v0.1.0 e sementes curadas"
- **Arquivos afetados**: `config/codebook.yml`, `config/seeds.yml`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `TODO.md`, `NEWS.md`

## 2026-09-26 11:36 — Coordenação por issues alinhada à convenção do hub

Enquanto este repositório era montado, uma sessão do `mancano-repo-hub` (058c7b) implantou lá a mesma ideia ("todo plano tem uma issue", issue #2 do hub; propagação aos repos filhos, issue #23, que cita o `bbsia-radar`). Duas regras de lá entraram aqui:
- **aprovação em comentário não vale**: todos os agentes comentam com a conta do autor, então só vale a decisão escrita no plano, por commit. A regra anterior daqui ("instruções valem quando vêm de `mancano-tales`") não se sustentava por esse mesmo motivo;
- **cabeçalho `kind:`/`sessao:`/`modelo:`/`esforco:`** em todo comentário de agente, no lugar da assinatura no fim, e **Resumo vivo** no corpo da issue do plano.
Ficou registrado que o pacote comum do hub, quando chegar, substitui as seções equivalentes do `AGENTS.md`.

**Metadados de Execução**:
- **Data/Hora**: 2026-09-26 11:36 (Horário de Brasília; relógio do contêiner em UTC, convertido)
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1
- **Mensagem do Commit**: "docs(agents): alinha a coordenacao por issues a convencao do hub"
- **Arquivos afetados**: `AGENTS.md`, `NEWS.md`

## 2026-09-26 11:03 — Criação do repositório

O autor, voluntário no Banco Brasileiro de Soluções de IA (BBSIA, Enap/LIIA com Ibict e CIIA), combinou com Eunice Liu, da coordenação, uma primeira versão de um mapeamento automático de soluções de IA brasileiras, adaptadas ao pt-BR ou de interesse público adaptáveis, publicadas no GitHub e no Hugging Face e ainda ausentes do banco. Critério de maturidade combinado: "todos os TRLs".

Decisões desta rodada, do autor:
- **nome `bbsia-radar`**, depois de descartar `bbsia-mapeamento-ia-brasil` (a sigla já diz "IA" e "Brasil") e alternativas como `bbsia-varredura` e `bbsia-garimpo` (a palavra lembra o garimpo ilegal, ruim num projeto com o setor público);
- **privado** até haver um piloto para apresentar à coordenação;
- **coordenação por issues**: agentes anunciam na issue o que vão fazer e como antes de começar, reivindicam a vez com o rótulo `em-andamento` e comentam com frequência; todo plano tem uma issue aberta junto, e o `.md` é o contrato estruturado que cita a issue.

A concepção no `README.md` e no plano é **provisória**: foi escrita sem acesso ao site do BBSIA, que a rede do contêiner de nuvem bloqueava (assim como o Hugging Face). Campos do formulário, uso da escala TRL, API ou envio em lote e termos de uso ficam para a issue #2, com um agente que tenha acesso à rede. O plano vem do `mancano-repo-hub` (`repo-governance/plan/2026-09-26_Plano_Mapeamento_Solucoes_IA_Brasileiras_BBSIA.md`), adaptado para cá.

Do template do ecossistema vieram a trava de comandos git destrutivos (`tools/guard-git-command.*` + `.claude/settings.json`), o exportador de conversas e o gerador de changelog. O `hooks/pre-commit` é novo e sem dependências: exige `NEWS.md` no mesmo commit e recusa caminho absoluto de máquina.

**Metadados de Execução**:
- **Data/Hora**: 2026-09-26 11:03 (Horário de Brasília; relógio do contêiner em UTC, convertido)
- **Agente**: Claude Code / Claude Opus 5.5 / Claude Code on the web
- **Issue**: #1
- **Mensagem do Commit**: "chore: cria o repositorio com governanca e o plano do piloto"
- **Arquivos afetados**: `AGENTS.md`, `CLAUDE.md`, `README.md`, `NEWS.md`, `TODO.md`, `.gitignore`, `.claude/settings.json`, `.github/ISSUE_TEMPLATE/plano.md`, `.github/ISSUE_TEMPLATE/tarefa.md`, `.github/pull_request_template.md`, `hooks/pre-commit`, `tools/guard-git-command.sh`, `tools/guard-git-command.py`, `tools/export_conversa.R`, `tools/render-changelog.R`, `repo-governance/plan/README.md`, `repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`, `repo-governance/llm-reviews/README.md`, `R/`, `scripts/`, `config/`, `data/`, `report/`, `tests/` (`.gitkeep`)
