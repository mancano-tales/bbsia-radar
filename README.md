# bbsia-radar

**Radar de soluções de inteligência artificial brasileiras que ainda não estão no Banco Brasileiro de Soluções de IA.**

> **Verificação documental (2026-09-26; issue #2).** O site e o formulário foram consultados sem enviar dados. As respostas e os limites da evidência estão registrados abaixo e na issue. Contagens são retratos da data, não dados exportados.

---

## O problema

O [Banco Brasileiro de Soluções de IA (BBSIA)](https://bancobrasileiro.ia.br/) reúne soluções de IA úteis ao setor público (ministérios, prefeituras, universidades, institutos de pesquisa) e as organiza **pelo problema que resolvem**, não pela tecnologia usada. É mantido pelo Laboratório de Inovação em Inteligência Artificial (LIIA) da Enap, com o Ibict e o CIIA. O objetivo é que uma solução criada num lugar possa ser reaproveitada em outro.

Hoje, uma solução entra no banco quando alguém preenche o formulário à mão. Mas muita coisa relevante já está publicada, aberta, em plataformas como o **GitHub** (código) e o **Hugging Face** (modelos e bases de dados de IA): transcritores para o português, modelos de linguagem treinados em português brasileiro, softwares livres de pesquisa, ferramentas feitas por universidades e órgãos públicos. Essas soluções ficam dispersas, e quem precisa delas no setor público muitas vezes não sabe que existem.

## A proposta

Usar as interfaces oficiais (APIs) do GitHub e do Hugging Face para **encontrar, descrever e organizar** essas soluções, e entregar ao BBSIA uma lista de candidatos pronta para revisão, no formato do formulário. A ideia foi combinada com a coordenação do BBSIA (Eunice Liu, Enap) em 26/09/2026.

Três tipos de solução interessam:

| | Tipo | Exemplo |
|---|---|---|
| **A** | **Brasileira**: feita por pessoa, grupo, empresa ou órgão do Brasil | um sistema de triagem de processos feito por um tribunal |
| **B** | **Adaptada ao português brasileiro**: treinada, ajustada ou avaliada para pt-BR | um modelo de reconhecimento de fala ajustado para o português do Brasil |
| **C** | **De interesse público, adaptável**: aberta e útil ao setor público, mesmo sem vínculo com o Brasil | uma ferramenta de anonimização de documentos que poderia ser traduzida |

O piloto começa por **A** e **B**. O tipo **C** exige um critério mais preciso, a combinar com o BBSIA, porque sem ele a lista fica grande demais para ser útil.

## Princípios

- **Todas as maturidades entram.** Combinado com o BBSIA ("todos os TRLs"): uma prova de conceito também pode ser útil. Mas cada solução leva uma **estimativa de maturidade** (a escala TRL, de 1 = ideia a 9 = em operação) e indicadores de manutenção (se ainda é atualizada, quantas pessoas contribuem). Isso responde a um problema real: muito projeto aberto para cedo ou deixa de ser mantido.
- **Critério escrito antes da coleta.** O que conta como "brasileira" ou "adaptada ao pt-BR" fica definido num livro de códigos (*codebook*) antes de qualquer busca em volume.
- **A máquina sugere, pessoas conferem.** A classificação automática (regras + modelo de linguagem) é comparada com a classificação humana de uma amostra. A taxa de acerto sai no relatório. Sem essa conferência, nada é enviado ao BBSIA.
- **Sem repetir o que já está no banco.** Os candidatos são comparados com o catálogo atual.
- **Coleta responsável.** Só APIs oficiais, respeitando os limites de uso; só dados públicos dos repositórios; **nenhum e-mail ou dado pessoal** (LGPD).

## Como vai funcionar

```
  sementes curadas          GitHub API             Hugging Face API
 (listas, orgs conhecidas)  (tópicos, texto,       (modelos, datasets e
          │                  local do autor)        spaces em português)
          └──────────────┬──────────┴───────────────────┘
                         ▼
              1. DESCOBERTA  → lista bruta de candidatos
                         ▼
              2. ENRIQUECIMENTO → descrição, README, licença, atividade
                         ▼
              3. CLASSIFICAÇÃO → brasileira? pt-BR? é IA? tipo, área
                         │        (regras do radar + Decifra, conferido
                         │         por amostra humana no próprio Decifra)
                         ▼
              4. MATURIDADE → TRL provável + sinais de manutenção
                         ▼
              5. DEDUPLICAÇÃO → já está no BBSIA?
                         ▼
              6. ENTREGA → planilha no formato do formulário + relatório
```

Antes de rodar tudo, um **piloto com cerca de 30 soluções** vai para a coordenação do BBSIA, para ajustar os campos e o critério.

## O radar e o Decifra

O radar é **a parte que produz o corpus**: encontra as soluções, junta o que se sabe de cada uma e escreve um documento por solução. A **classificação** fica com o [Decifra](https://github.com/mancano-tales/decifra-text-as-data), ferramenta do mesmo autor que transforma texto em dados categóricos com um modelo de linguagem guiado por um livro de códigos explícito e **validado contra codificação humana**. O que o Decifra ainda não faz para este caso (por exemplo, várias perguntas por documento e mais de uma área por solução) é desenvolvido no próprio Decifra, que ganha com isso seu primeiro uso real. Decisão de 26/09/2026 ([issue #6](../../issues/6)).

## O que verificamos no BBSIA (issue #2)

1. **Formulário:** pede identificação de contato e instituição, localização, descrição e tipo da solução,
   área, estágio de desenvolvimento, uso por outras organizações, abertura/reutilização, links e
   disposição para compartilhar conhecimento ou código. Há campos opcionais sobre tecnologia,
   financiamento, soberania, dados e resultados; e consentimento de privacidade. Os menus incluem
   nível de governo, UF, tecnologia, tipo de ativo, área, uso, estágio e abertura. Não preenchemos nem
   enviamos o formulário. [Formulário](https://bancobrasileiro.ia.br/contribuir).
2. **Maturidade:** o formulário apresenta estágios descritivos — de pesquisa/PoC a uso em produção —,
   não uma seleção numérica de TRL 1–9. “Todos os TRLs” continua sendo o escopo conversado com a
   coordenação; a coluna TRL do radar será uma estimativa própria, claramente identificada.
3. **Catálogo:** organiza as soluções pelo problema que resolvem e permite busca por problema, título,
   órgão e tags. Os filtros são público (“quero usar” ou “quero desenvolver/integrar”), tipo
   (aplicação, código/biblioteca, API, agente, modelo, pipeline e guia/metodologia) e área (Saúde,
   Educação, Segurança Pública, Meio Ambiente, Gestão Pública, Administração/Processos e Outro).
   Na consulta, a página indicava 20 publicadas; a página de números mostrava 154 no catálogo,
   divididas em 20 publicadas e 134 em análise. [Catálogo](https://bancobrasileiro.ia.br/catalogo).
4. **API e exportação:** não encontramos documentação nem botão público de exportação CSV/JSON ou
   importação em lote nas páginas públicas consultadas. `sitemap.xml` e `robots.txt` não estavam
   disponíveis no site na consulta; a inspeção das chamadas de rede não foi concluída. Portanto,
   **não está confirmado** que não exista endpoint, exportação interna ou acesso restrito. O aviso de
   privacidade menciona exportações administrativas, o que não equivale a download público.
5. **Termos, privacidade e licença:** o [aviso de privacidade](https://bancobrasileiro.ia.br/privacidade)
   diz que informações sobre as soluções podem ser publicadas e reutilizadas e que contatos não são
   públicos. Não encontramos termo de uso ou licença específica do catálogo nas páginas consultadas.
   Isso não decide a licença deste repositório (#8).
6. **Contagens em 2026-09-26:** a home e a página “Números do banco” mostravam 541 soluções mapeadas
   (351 curadas e 190 integradas), 313 disponíveis e 228 em curadoria. A seção de catálogo mostrava
   154 no total (20 publicadas, 134 em análise); os números variam com a atualização e resultados
   indexados podem estar defasados.
   Os 190 projetos do Judiciário (CNJ/Sinapses) aparecem em seção própria e têm origem distinta; não
   os somamos ao catálogo curado. [Números do banco](https://bancobrasileiro.ia.br/numeros) ·
   [Judiciário](https://bancobrasileiro.ia.br/judiciario).
7. **Repositório `Roger-Quinelato/BBSIA`:** a documentação e o código consultados descrevem um RAG
   local que indexa PDFs e um JSON curado local de soluções para busca; não encontramos evidência de
   que ele baixe o banco de produção ou use API do BBSIA. Isso descreve o repositório público
   consultado, não exclui processos privados ou outros sistemas.
   [Repositório e documentação](https://github.com/Roger-Quinelato/BBSIA).

**Implicação para o piloto:** a deduplicação depende de uma fonte autorizada e reproduzível para o
catálogo atual. Até que isso seja esclarecido, o radar não deve tratar contagens agregadas como uma
lista de registros nem iniciar scraping do site. A pesquisa sobre o BBSIA foi separada da futura
implementação dos coletores (#10).

## Estado

Repositório **público** e em fase inicial: governança e plano prontos, nenhum código ainda. Plano vigente: [`repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md`](repo-governance/plan/2026-09-26_Plano_Piloto_bbsia-radar.md) ([issue #1](../../issues/1)).

## Estrutura

```
bbsia-radar/
├── R/                 funções (coleta, enriquecimento, classificação, TRL, deduplicação)
├── scripts/           etapas numeradas do pipeline, que só chamam as funções
├── config/            consultas, sementes e codebook (YAML)
├── data/              só saídas pequenas e revisadas; dados brutos ficam fora do git
├── report/            relatório (Quarto)
├── tests/             testes
├── repo-governance/   planos e registro das conversas com agentes de IA
├── tools/, hooks/     utilitários e verificações de governança
├── AGENTS.md          regras para agentes de IA (coordenação por issues)
├── NEWS.md            histórico das decisões
└── TODO.md            pendências
```

## Como participar

O trabalho é coordenado pelas **issues** deste repositório, tanto entre pessoas quanto entre os agentes de IA que ajudam no projeto: cada tarefa tem uma issue, e quem vai trabalhar nela avisa antes o que vai fazer e como. As regras completas estão em [AGENTS.md](AGENTS.md).

Responsável: Tales Mançano ([@mancano-tales](https://github.com/mancano-tales)), voluntário no BBSIA.
