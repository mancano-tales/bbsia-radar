---
tipo: Plano
titulo: "Identidade visual e ativos da logo BBSIA para o site Quarto e relatórios"
issue: 17
status: ATIVO
criado: "2026-09-28"
concluido: null
autor_humano: "Tales Mançano"
autorizacao_atual: "Em 2026-09-28 o autor pediu executar o subplano. Em 2026-09-29 determinou manter os ativos da identidade oficial como opção implementada, porém desativada, e identificar o radar como proposta independente de um voluntário do BBSIA para apresentação à coordenação. Ativar a marca e publicar o site dependem das decisões próprias da coordenação e do plano Quarto."
agentes:
  orquestrador: "Antigravity / Gemini 3.8 Flash (High) / desktop"
  executor: "Codex / GPT-6 / desktop"
  auditor: "Codex / GPT-6 / desktop"
tarefas:
  - { desc: "WP1 — Especificação e geração dos ativos vetoriais SVG (mestre, transparente e banner)", status: concluido }
  - { desc: "WP2 — Pipeline de renderização em alta definição para PNGs e favicons via Chromium headless", status: concluido }
  - { desc: "WP3 — Validação de integridade visual, conferência de dimensões e integração ao Quarto", status: concluido }
  - { desc: "WP4 — Desativar a identidade oficial no site e no PDF e explicitar o caráter de proposta independente", status: concluido }
relacionados: ["repo-governance/plan/2026-09-27_Plano_Website_Quarto.md"]
---

# Subplano: identidade visual e ativos da logo BBSIA

> **Issue relacionada: #17.** Subplano técnico vinculado ao WP2 do plano de website Quarto (`repo-governance/plan/2026-09-27_Plano_Website_Quarto.md`).

## 1. Objetivo e contexto

Incorporar ao repositório os ativos visuais oficiais do Banco Brasileiro de Soluções de IA (BBSIA) como opção técnica futura, **desativada na apresentação atual** do site Quarto e dos relatórios PDF.

Em 2026-09-29, o autor decidiu que o radar deve ser apresentado como proposta independente de Tales Mançano, voluntário do BBSIA, a ser levada à coordenação do programa. A identidade oficial não será exibida, distribuída no artefato do site nem aplicada aos metadados sociais antes de decisão e autorização próprias. A intenção futura de tornar o projeto oficial não representa endosso atual.

O autor manifestou a preocupação de garantir a marca na mais alta qualidade visual possível. A fonte verificável é o [ícone SVG publicado pelo próprio BBSIA](https://bancobrasileiro.ia.br/icon.svg), consultado em 2026-09-28 e preservado como `report/assets/bbsia-source-icon.svg` (SHA-256 `90ba06d6626b4b9af4719b43e7b350f94583069f9ef1755f8e4b55fc1a83c402`). O comentário do ícone informa que o portal vetorizou a marca de `bbsia.PNG` (265×184). As curvas do símbolo no radar derivam diretamente das coordenadas do ícone, não de uma aproximação descrita em prosa. A licença do código do radar não cobre a marca de terceiros nem significa endosso institucional.

Este subplano detalha duas etapas técnicas coordenadas:
1. **Opção 1 (Ativos Vetoriais SVG)**: criação dos arquivos SVG canônicos no repositório com o símbolo oficial, variação para fundo transparente (navbar) e composição horizontal com tipografia.
2. **Opção 2 (Pipeline de Renderização em Alta Definição)**: geração automatizada e reproduzível de variantes bitmap (PNGs em 512px, 1024px, favicons e cartão OpenGraph 1200x630) utilizando ferramentas locais (motor Chromium headless disponível no sistema).

---

## 2. Especificação técnica dos ativos

### 2.1. Geometria e paleta oficial

A marca oficial recuperada do portal canônico possui a seguinte composição geométrica de referência:
* **Fundo**: Quadrado com cantos arredondados e gradiente linear diagonal de `#356CAF` a `#019480`.
* **Letra "I"**: Retângulo vertical posicionado à esquerda preenchido com a cor verde `#4AAA47`.
* **Letra "A"**: Triângulo equilátero central-direito preenchido com a cor amarela `#F6BB15`, com recorte semicircular em sua base preenchido com a cor verde `#4AAA47`.

### 2.2. Pacote de ativos vetoriais (WP1)

Os arquivos serão armazenados em `report/assets/`:

1. `report/assets/bbsia-logo.svg`:
   * Símbolo mestre com viewBox `0 0 512 512`, mantendo as coordenadas do ícone fonte sob escala exata de 16.
   * Preserva a moldura arredondada e o gradiente oficial.
   * Uso: Favicons de alta precisão, ícone de cabeçalho, capas de relatórios em PDF.
2. `report/assets/bbsia-logo-transparent.svg`:
   * viewBox adaptado para o contorno do símbolo "IA", sem o fundo gradiente; a geometria interna é idêntica à fonte.
   * Uso: Barra de navegação (navbar) do site Quarto quando configurada com cor de fundo própria (ex.: fundo azul institucional).
3. `report/assets/bbsia-radar-horizontal.svg`:
   * Composição horizontal 4:1 contendo o símbolo "IA" à esquerda e o lettering "BBSIA Radar" à direita, desenhado integralmente como curvas SVG. Não depende de fontes locais nem de carregamento remoto.
   * Uso: Topo da página inicial e cabeçalho de documentos PDF.

---

## 3. Pipeline de renderização em alta definição (WP2)

Para suprir contextos em que o formato SVG não é suportado (como metatags de compartilhamento OpenGraph/Twitter ou aplicações legadas), o repositório incluirá um script reproduzível:

* **Script**: `tools/render-assets.mjs` (Node.js 24, apenas módulos nativos). Uso: `node tools/render-assets.mjs` para gerar e `node tools/render-assets.mjs --check` para validar sem navegador.
* **Mecanismo**: detecção de Edge/Chrome/Chromium no Windows e Linux, com opção `BBSIA_BROWSER` para apontar o executável. A captura headless usa HTML local autônomo, margem zero, dimensões exatas, escala de dispositivo 1 e perfil temporário isolado; o script rejeita falha do navegador, PNG inválido, dimensão incorreta e pacote acima de 500 KB. Os PNGs são versionados e podem ser verificados localmente com `--check`, sem iniciar navegador; o build Quarto/CI não os consome enquanto a marca estiver desativada. A regeneração em outro sistema pode variar nos pixels de antialiasing, mas não nas dimensões nem na geometria-fonte.
* **Composição OpenGraph**: fundo sólido claro, banner vetorial e faixa de gradiente; nenhum dado de candidatos é lido.
* **Saídas geradas**:
  * `report/assets/bbsia-logo-512.png` (512×512 px)
  * `report/assets/bbsia-logo-1024.png` (1024×1024 px — definição para mídias impressas ou telas Retina)
  * `report/assets/apple-touch-icon.png` (180×180 px — atalhos móveis)
  * `report/assets/favicon-32x32.png` (32×32 px — navegador desktop)
  * `report/assets/bbsia-radar-horizontal.png` (640×160 px — cabeçalho PDF sem conversor SVG adicional)
  * `report/assets/og-image.png` (1200×630 px — cartão de compartilhamento social com proporção 1.91:1)

---

## 4. Critérios de aceite e integridade

* Todos os SVGs são autônomos, válidos perante o padrão W3C e livres de tags ou scripts maliciosos.
* Nenhuma imagem bitmap apresenta distorção de aspecto ou interpolação com artefatos borrados.
* Os seis PNGs têm assinatura PNG válida e dimensões conferidas pelo modo `--check`; o símbolo e o cartão são inspecionados visualmente depois da geração.
* Todos os caminhos nos scripts e no Quarto são relativos à raiz do repositório (em conformidade estrita com o `AGENTS.md` e os hooks de caminhos absolutos).
* Os arquivos finais são compactos (<500 KB no total de todas as variantes PNG/SVG somadas), respeitando a política de dados leves do repositório.
* A integração não altera a coleta, o esquema público, os dados, o gatilho de deploy nem a autorização para a primeira publicação. O artefato Quarto não inclui os ativos oficiais enquanto a opção estiver desativada.

---

## 5. Dossiê para auditoria independente (Codex)

Conforme a governança do repositório e a skill `request-audit`, este plano é submetido à revisão do auditor **Codex (`CobaltCanyon`)**.

### Fragilidades e autocrítica:
1. **Fidelidade da tipografia horizontal**: resolvida com lettering em curvas SVG, independente de fonte instalada.
2. **Dependência do Chromium para o render**: restrita à regeneração local dos PNGs versionados; o modo `--check` e o build Quarto/CI não iniciam navegador. Falha local é explícita. O Edge produziu todos os PNGs no ambiente Windows do autor; a execução dentro do sandbox do agente falhou por restrições de GPU, registradas na auditoria da issue #17.
3. **Escopo isolado**: os ativos e sua validação não publicam páginas ou dados. A PR #18 contém a estrutura Quarto estática e continua protegida pela autorização de publicação; nenhuma referência à marca oficial integra a apresentação atual.

## 6. Evidência da execução

* `node tools/render-assets.mjs --check`: seis PNGs válidos, dimensões esperadas e pacote SVG/PNG de 496159 bytes. O Edge headless gerou os arquivos no ambiente Windows; após desativar a marca, o build Linux não precisa dos ativos e sua verificação fica como comando local de manutenção.
* `quarto render report`: HTML e PDF gerados. O primeiro build com SVG no PDF falhou por falta de `rsvg-convert`; o cabeçalho do PDF passou a usar o PNG horizontal derivado, e o build completo passou sem instalar conversor SVG.
* Inspeção visual da primeira implementação: símbolo 512, cartão OpenGraph, página inicial em desktop e primeira página do PDF sem distorção ou corte do logo. Naquela versão, o artefato incluía favicon, ícone Apple, banner, logo da navbar e imagem social; essa integração foi posteriormente desativada pela decisão de 2026-09-29. A configuração atual do repositório ainda não habilita Pages, e nenhuma publicação foi feita.
* A integração é baseada na branch da PR #18. O job de deploy e a condição `PAGES_PUBLISH_APPROVED` permanecem inalterados. O merge do subplano depende da integração da PR #18 e da revisão cruzada exigida pelo `AGENTS.md`.
* Entrega em PR #25, branch `codex/17-ativos-quarto`, empilhada na PR #18. As quatro WPs foram implementadas; o plano permanece `ATIVO` até a revisão cruzada e o merge.
* Atualização 2026-09-29: a PR #18 foi integrada, a PR #25 foi retargetada para `main` e a justificativa para usar Node somente na geração/verificação dos ativos foi registrada na issue #17. A revisão cruzada e a ativação institucional da marca continuam independentes.

### Decisão de apresentação em 2026-09-29

O autor apontou o risco de que a estética oficial sugira endosso institucional e determinou desativá-la até a conversa com a coordenação. A PR #25 conserva SVGs, PNGs e o gerador como opção técnica, mas retira as referências da configuração Quarto, das páginas, do PDF e do workflow de publicação. O README, a página inicial, a página de método e o relatório declaram a autoria voluntária e a ausência de caráter oficial. A ativação futura requer decisão explícita da coordenação e atualização deste plano antes de mudar a apresentação pública.
