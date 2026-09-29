---
tipo: Plano
titulo: "Identidade visual e ativos da logo BBSIA para o site Quarto e relatórios"
issue: 17
status: PROPOSTO
criado: "2026-09-28"
concluido: null
autor_humano: "Tales Mançano"
autorizacao_atual: "No chat em 2026-09-28, o autor solicitou a elaboração de um subplano do website (#17) para a logo e ativos visuais do BBSIA com qualidade máxima, e solicitou submeter o plano à auditoria do Codex via CLI."
agentes:
  orquestrador: "Antigravity / Gemini 3.8 Flash (High) / desktop"
  executor: "Antigravity / Gemini 3.8 Flash (High) / desktop"
  auditor: "Codex / GPT-6 / desktop"
tarefas:
  - { desc: "WP1 — Especificação e geração dos ativos vetoriais SVG (mestre, transparente e banner)", status: pendente }
  - { desc: "WP2 — Pipeline de renderização em alta definição para PNGs e favicons via Chromium headless", status: pendente }
  - { desc: "WP3 — Validação de integridade visual, conferência de dimensões e integração ao Quarto", status: pendente }
relacionados: ["repo-governance/plan/2026-09-27_Plano_Website_Quarto.md"]
---

# Subplano: identidade visual e ativos da logo BBSIA

> **Issue relacionada: #17.** Subplano técnico vinculado ao WP2 do plano de website Quarto (`repo-governance/plan/2026-09-27_Plano_Website_Quarto.md`).

## 1. Objetivo e contexto

Incorporar ao repositório os ativos visuais oficiais do Banco Brasileiro de Soluções de IA (BBSIA) para uso no futuro site público Quarto e nos relatórios exportados em PDF.

O autor manifestou a preocupação de garantir a marca na mais alta qualidade visual possível. Como a marca geométrica oficial ("IA") presente no portal `bancobrasileiro.ia.br` já foi calculada e vetorizada em SVG puro, o projeto possui acesso à qualidade matemática infinita (independente de resolução de tela ou escala de impressão).

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
   * Símbolo mestre oficial com viewBox `0 0 512 512`.
   * Preserva a moldura arredondada e o gradiente oficial.
   * Uso: Favicons de alta precisão, ícone de cabeçalho, capas de relatórios em PDF.
2. `report/assets/bbsia-logo-transparent.svg`:
   * viewBox adaptado para o contorno do símbolo "IA", sem o fundo gradiente.
   * Uso: Barra de navegação (navbar) do site Quarto quando configurada com cor de fundo própria (ex.: fundo azul institucional).
3. `report/assets/bbsia-radar-horizontal.svg`:
   * Composição horizontal (proporção ~4:1) contendo o símbolo "IA" à esquerda e o texto institucional "BBSIA Radar" à direita em fonte geométrica legível e limpa.
   * Uso: Topo da página inicial e cabeçalho de documentos PDF.

---

## 3. Pipeline de renderização em alta definição (WP2)

Para suprir contextos em que o formato SVG não é suportado (como metatags de compartilhamento OpenGraph/Twitter ou aplicações legadas), o repositório incluirá um script reproduzível:

* **Script**: `tools/render_assets.R` (ou utilitário em PowerShell/Node usando Chromium headless).
* **Mecanismo**: Invocação não interativa do Chrome/Edge local via CLI (`--headless --screenshot --window-size`), garantindo fidelidade de antialiasing Skia/Blink e renderização determinística sem dependência de bibliotecas nativas C pesadas.
* **Saídas geradas**:
  * `report/assets/bbsia-logo-512.png` (512×512 px)
  * `report/assets/bbsia-logo-1024.png` (1024×1024 px — definição para mídias impressas ou telas Retina)
  * `report/assets/apple-touch-icon.png` (180×180 px — atalhos móveis)
  * `report/assets/favicon-32x32.png` (32×32 px — navegador desktop)
  * `report/assets/og-image.png` (1200×630 px — cartão de compartilhamento social com proporção 1.91:1)

---

## 4. Critérios de aceite e integridade

* Todos os SVGs são autônomos, válidos perante o padrão W3C e livres de tags ou scripts maliciosos.
* Nenhuma imagem bitmap apresenta distorção de aspecto ou interpolação com artefatos borrados.
* Todos os caminhos nos scripts e no Quarto são relativos à raiz do repositório (em conformidade estrita com o `AGENTS.md` e os hooks de caminhos absolutos).
* Os arquivos finais são compactos (<500 KB no total de todas as variantes PNG/SVG somadas), respeitando a política de dados leves do repositório.

---

## 5. Dossiê para auditoria independente (Codex)

Conforme a governança do repositório e a skill `request-audit`, este plano é submetido à revisão do auditor **Codex (`CobaltCanyon`)**.

### Fragilidades e autocrítica:
1. **Fidelidade da tipografia horizontal**: No banner horizontal, deve-se usar fonte nativa do sistema ou converter fontes para curvas (`<path>`) no SVG para evitar que máquinas sem a fonte instalada exibam texto desconfigurado.
2. **Dependência do Chromium para o render**: O script de rasterização depende da presença do executável do Chrome ou Edge na máquina local. O script deve detectar ambos os caminhos padrão do Windows e falhar com mensagem explicativa se nenhum estiver acessível.
3. **Escopo isolado**: Os ativos visuais não devem introduzir páginas ou deploys antes que os dados da rodada do radar sejam aprovados no plano principal (#17).
