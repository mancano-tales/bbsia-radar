---
tipo: Prompt
titulo: "Auditoria independente (Codex) do subplano de ativos visuais e logo BBSIA"
issue: 17
status: ATIVO
criado: "2026-09-28"
concluido: null
autor_humano: "Tales Mançano"
agentes:
  orquestrador: "Antigravity / Gemini 3.8 Flash (High) / desktop"
  executor: "Codex / GPT-6 / desktop"
  auditor: "Codex / GPT-6 / desktop"
tarefas: []
relacionados: ["repo-governance/plan/2026-09-28_Plano_Ativos_Visuais_e_Logo_BBSIA.md", "repo-governance/plan/2026-09-27_Plano_Website_Quarto.md"]
---

# Solicitação de auditoria independente (Red-Teaming)

> **Status**: ATIVO.
> **O que é**: Dossiê de auditoria técnica independente estruturado para o agente Codex (`CobaltCanyon`).
> **Elaborado por**: Antigravity / Gemini 3.8 Flash (High) / desktop.
> **Por quê**: Validar a viabilidade, robustez, fidelidade gráfica e conformidade de governança do subplano de identidade visual e ativos da logo BBSIA.
> **Como usar**: Enviar via Agent Mail CLI (`am mail send`) ou submeter ao Codex via comentário estruturado na issue #17.

---

```markdown
### A. Cabeçalho de Contexto

- **Agente Autor:** Antigravity / Gemini 3.8 Flash (High) / desktop
- **Data:** 2026-09-28 [EM PROGRESSO]
- **Plano Fonte:** `repo-governance/plan/2026-09-28_Plano_Ativos_Visuais_e_Logo_BBSIA.md` (vinculado à issue #17)
- **Evidência mecânica do escopo:**
```
$ git status --short
 M repo-governance/plan/README.md
?? repo-governance/plan/2026-09-28_Plano_Ativos_Visuais_e_Logo_BBSIA.md
```
- **Evidência bruta de verificação:**
```
$ python tools/plano_issue.py verificar
Todos os planos ATIVO/EM EXECUÇÃO têm issue.
```
- **Conformidade de caminhos:** Nenhum caminho absoluto de máquina inserido nos artefatos.

---

### B. Diretiva de Ceticismo e Verificação Empírica

IMPORTANTE: Não tome nada do que o agente autor diz neste prompt pelo valor de face. O agente que escreveu o código/texto pode estar alucinando o seu próprio sucesso ou ignorando falhas lógicas. Você deve ser extremamente crítico, cético, e verificar os arquivos fisicamente de forma independente. Comece em modo leitura (visualizando arquivos, lendo diffs, conferindo a evidência mecânica de escopo e o output bruto acima). Depois de formar uma hipótese sobre um problema, você PODE e DEVE rodar comandos de verificação não-destrutivos para confirmá-la empiricamente antes de reportá-la como achado — por exemplo verificar a sintaxe SVG, caminhos relativos e opções do Chromium. Não aceite nem rejeite uma alegação técnica só por parecer plausível na leitura; teste.

---

### C. Escopo do Trabalho e Áreas de Vulnerabilidade (Foco da Auditoria)

- **Resumo do que foi proposto:**
  Criação de um subplano vinculado à Issue #17 para dotar o projeto da marca visual oficial do BBSIA em qualidade matemática máxima (SVGs em `report/assets/`) e um pipeline automatizado local para geração de PNGs de alta resolução (512px, 1024px, favicons, OG Card) acionando o Chromium headless nativo.

- **Fragilidades e autocrítica identificadas:**
  1. *Dependência de ambiente do Chromium*: O pipeline presume que `chrome.exe` ou `msedge.exe` estejam disponíveis no Windows. Risco aceito no piloto local por ser ambiente desktop do autor, mas deve haver fallback ou validação defensiva se o script for executado em CI Linux/GitHub Actions.
  2. *Renderização de texto em SVG*: No banner horizontal, se for usado `<text>` com fontes do sistema, poderá haver divergência entre sistemas operacionais (Windows vs Linux CI). O plano sugere converter caracteres em `<path>` vetoriais ou usar fonte geométrica neutra/fallback padrão.
  3. *Fronteira com o plano principal*: O subplano não deve implementar páginas ou deploys do Quarto antes da aprovação dos dados curados do radar (mantendo WP2 estritamente restrito aos ativos estáticos).

---

### D. Formato de Resposta Exigido do Auditor

Estruture seu parecer exatamente com as seguintes seções:
1. **Avaliação Geral:** Análise qualitativa da robustez da arquitetura de ativos e viabilidade do pipeline proposto.
2. **Veredito Categórico:** Exatamente um dentre:
   - `[APROVADO]` (Robusto e pronto para execução).
   - `[REQUER REFATORAÇÃO MENOR]` (Pequenos ajustes necessários).
   - `[REQUER REFATORAÇÃO ESTRUTURAL]` (Vulnerabilidades conceituais ou de governança graves).
   - `[DESCARTADO]` (Premissa incorreta).
3. **Lista de Achados (ordenada por severidade):**
   Para cada achado:
   - *Resumo de uma frase*.
   - *Cenário de falha concreto* (input/condição → falha/comportamento inadequado).
   - *Veredito do achado*: `CONFIRMED` (testado empiricamente) ou `PLAUSIBLE` (deduzido por análise estática).

---

### E. Teto de Rodadas

Se o veredito for `[REQUER REFATORAÇÃO MENOR]` ou `[REQUER REFATORAÇÃO ESTRUTURAL]`, o agente executor deve corrigir os itens e pode pedir no máximo mais uma rodada de auditoria independente. Se a segunda rodada também resultar em refatoração estrutural ou descarte, o agente executor para e escala a decisão ao autor humano.
```
