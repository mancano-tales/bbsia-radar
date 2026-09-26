# bbsia-radar

**Radar de soluções de inteligência artificial brasileiras que ainda não estão no Banco Brasileiro de Soluções de IA.**

> ⚠️ **Concepção provisória (2026-09-26).** Este texto foi escrito antes de conseguirmos abrir o site e o formulário do BBSIA. O que está marcado como *a verificar* depende da [issue #2](../../issues/2). Vai mudar.

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

## A verificar (issue #2)

- Quais campos o formulário do BBSIA pede, e quais são obrigatórios.
- Se o formulário usa a escala TRL, e como.
- Se existe API ou importação por planilha (para não cadastrar uma a uma, à mão).
- Se o catálogo atual pode ser exportado (para a deduplicação).
- Termos de uso dos dados do catálogo.

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
