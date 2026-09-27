---
tipo: Plano
titulo: "Proteger a publicação contra caminhos absolutos de máquina"
issue: 1
status: PROPOSTO
criado: "2026-09-27 10:53"
concluido: null
autor_humano: "Tales Mançano"
aprovacao_autor: null
agentes:
  orquestrador: "Codex / GPT-6 / desktop"
  executor: null
  auditor: null
tarefas:
  - { desc: "WP0 — autor definir o limite da garantia e aprovar uma opção", issue: null, status: pendente, data: null }
  - { desc: "WP1 — alinhar o detector local para cobrir conteúdo versionado sem exceções", issue: null, status: pendente, data: null }
  - { desc: "WP2 — configurar a verificação e o bloqueio apropriados ao limite aprovado", issue: null, status: pendente, data: null }
  - { desc: "WP3 — documentar operação, limites e resposta a uma detecção", issue: null, status: pendente, data: null }
relacionados: ["repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md"]
news: ["NEWS.md"]
---

# Plano: proteção contra caminhos absolutos de máquina

> **Issue relacionada: #1.** A proposta ainda precisa ser levada à conversa da issue pelo autor.

## Objetivo

Impedir que caminhos absolutos de máquina entrem no conteúdo público versionado do projeto. A
implementação não começa até o autor aprovar este plano no chat e escolher o nível de garantia.

## Estado observado

- O repositório é público.
- `hooks/pre-commit` verifica apenas linhas adicionadas ao stage e deixa de examinar `hooks/` e
  `tools/`; também aceita uma marca de isenção. O padrão atual reconhece só alguns formatos comuns,
  portanto não é um detector abrangente nem obrigatório para quem não o instalou.
- Não há uma verificação de conteúdo do GitHub Actions configurada como bloqueio de merge.
- Na documentação atual do GitHub, rulesets podem exigir status checks antes de um merge. Isso
  protege o destino do merge, mas a execução do Actions ocorre depois que a branch já foi enviada ao
  repositório público.
- Push rulesets para bloquear caminhos/arquivos são documentados para repositórios internos ou
  privados no plano Team; não são um filtro de conteúdo textual para este repositório público.
- O GitHub documenta hooks de pre-receive administrados na instância do GitHub Enterprise Server.
  Não foi identificado mecanismo equivalente configurável no GitHub.com para rejeitar conteúdo
  textual antes de qualquer ref pública ser atualizada.
- A tentativa de criar uma issue dedicada foi recusada pela integração GitHub com `403 Resource not
  accessible by integration`; o `gh` local informou que a autenticação expirou/é inválida. A issue
  #1 está aberta e relacionada ao plano do piloto; o autor precisa levar esta proposta até ela.

## Decisão do autor necessária

O que significa “nunca publicar” para este projeto?

### Opção A — bloquear o merge e reduzir acidentes

Unificar o detector e usá-lo no pre-commit e pre-push local; adicionar uma verificação no Actions e
exigir seu sucesso antes de integrar na branch principal. Não aceitar isenções nem excluir arquivos
de governança. Isso reduz erros acidentais e impede merge com detecção, mas **não impede a exposição
temporária em outras branches públicas**. Não satisfaz uma garantia literal para todo ref público.

### Opção B — garantir o conteúdo Git publicado por um fluxo privado

Manter alterações em uma área privada de preparação; examinar os objetos/commits que serão publicados;
permitir atualizações de refs públicas somente por um publicador controlado após aprovação do
detector. Antes de prometer a garantia, verificar que a regra do GitHub cobre criação, atualização e
exclusão de todas as refs e que não há caminho de escrita alternativo. É mais operacional e exige
configuração que o conector atual não consegue aplicar. O escopo cobre conteúdo Git do repositório;
texto digitado diretamente em issue, comentário ou outro campo público exige uma regra humana ou uma
plataforma sob controle antes da publicação.

### Opção C — pre-receive no GitHub Enterprise Server

Se o projeto migrar para uma instância administrada de GitHub Enterprise Server, configurar nela um
hook que examine e rejeite o push antes da atualização das refs. Esse recurso não está disponível
como hook de conteúdo configurável no GitHub.com.

**Recomendação:** se “nunca” for requisito literal, escolher a opção B para conteúdo Git e definir
separadamente como tratar texto público escrito diretamente na interface. A opção A pode ser adotada
como mitigação inicial, mas deve ser descrita como mitigação, nunca como garantia.

## Escopo após aprovação

1. Refinar o scanner para distinguir caminhos locais de URLs, rotas de API e caminhos relativos;
   percorrer também `hooks/` e `tools/`; eliminar o mecanismo de isenção; e não imprimir o conteúdo
   detectado em logs, mostrando apenas arquivo relativo e número da linha.
2. Conectar o mesmo detector aos hooks locais disponíveis no fluxo aprovado e à verificação remota.
3. Aplicar a configuração de proteção remota coerente com a opção escolhida. Se for preciso alterar
   rulesets, permissões ou a arquitetura pública/privada, registrar a configuração e qualquer limite
   que impeça a garantia.
4. Atualizar `AGENTS.md`, o guia de contribuição e a mensagem de bloqueio para instruir agentes e
   pessoas a corrigirem o conteúdo sem copiar o caminho detectado para logs ou comentários públicos.
5. Fazer uma varredura do conteúdo Git que já está publicado e propor correção de ocorrências antes
   de afirmar que a regra foi aplicada. Não reescrever histórico público sem autorização específica.

## Fontes oficiais

- [Regras disponíveis em rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets) — disponibilidade em repositórios públicos, status checks e limites dos push rulesets.
- [Criar rulesets para um repositório](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository) — regras de branch, atores de bypass e status checks.
- [Hooks de pre-receive no GitHub Enterprise Server](https://docs.github.com/en/enterprise-server@3.20/admin/enforcing-policies/enforcing-policy-with-pre-receive-hooks) — verificação de conteúdo antes de aceitar um push na instância Enterprise Server.
