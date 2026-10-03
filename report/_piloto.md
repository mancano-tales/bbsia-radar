<!-- Gerado por scripts/03_publicar.R a partir de data/. Não editar à mão. -->

Rodada `2026-09-29_piloto`, coletada em 2026-09-29. Classificação no Decifra (`4df06df`, modelo `gemini-3.8-flash-high`, codebook v0.2.2) e revisão humana do autor.

## Do que foi encontrado ao que entrou

| Etapa | Quantidade |
|---|---|
| Projetos encontrados nas buscas (GitHub, Hugging Face, GitLab) | 379 |
| Documentos lidos e classificados | 39 |
| Artefatos que o autor confirmou como IA brasileira ou em português do Brasil | 13 |
| Soluções, depois de agrupar as variantes da mesma família | 8 |

A busca foi pequena de propósito: poucas contas e temas conhecidos, uma página por consulta. Os números mostram como o método se comporta, não o tamanho do universo.

## As soluções do piloto

As colunas **brasileira** e **pt-BR** foram revisadas pelo autor. Tipo, área, TRL e o resumo do problema são **proposta da máquina, ainda não revisada**. O TRL é uma estimativa do radar a partir de sinais públicos; nunca chega a 7–9 sem uso institucional declarado.

| Solução | Problema que resolve (proposta) | Brasileira | pt-BR | Tipo (proposta) | Área (proposta) | TRL provável | Licença |
|---|---|---|---|---|---|---|---|
| [Transcritório](https://github.com/antrologos/Transcritorio) | Ajuda pesquisadores a transcrever entrevistas gravadas em português e separar os falantes, sem enviar o áudio para a internet. | sim | sim | Aplicação | Ciência e pesquisa; Transversal | 4-6 | MIT |
| [BERTimbau](https://github.com/neuralmind-ai/portuguese-bert) (+1) | Ajuda quem desenvolve sistemas de texto em português a partir de um modelo de linguagem já treinado em português brasileiro, para tarefas como reconhecer nomes e comparar o sentido de frases. | sim | sim | Modelo | Cultura e linguagem; Transversal | 4-6 | não declarada |
| [TeenyTinyLlama](https://github.com/Nkluge-correa/TeenyTinyLlama) | Ajuda pesquisadores e desenvolvedores com pouco recurso computacional a usar modelos de linguagem pequenos e abertos, treinados em português brasileiro. | sim | sim | Modelo | — | 1-3 | Apache-2.0 |
| [Tucano](https://github.com/Nkluge-correa/Tucano) | Ajuda pesquisadores e desenvolvedores a gerar texto em português com modelos abertos treinados desde o início nesse idioma. | sim | sim | Modelo | Ciência e pesquisa; Cultura e linguagem | 1-3 | Apache-2.0 |
| [RoBERTaCrawlPT](https://huggingface.co/eduagarcia/RoBERTaCrawlPT-base) | Ajuda quem desenvolve aplicações de texto em português a partir de um modelo de linguagem genérico, treinado do zero com textos da web em português. | sim | sim | Modelo | — | 4-6 | cc-by-4.0 |
| [RoBERTaLexPT](https://huggingface.co/eduagarcia/RoBERTaLexPT-base) | Ajuda quem desenvolve aplicações para textos jurídicos em português, com um modelo de linguagem treinado em documentos legais. | sim | sim | Modelo | Justiça e direito | 4-6 | cc-by-4.0 |
| [Sabiá (Maritaca AI)](https://huggingface.co/maritaca-ai/sabia-7b) (+2) | Ajuda quem precisa gerar texto em português com modelos de linguagem adaptados a esse idioma pela Maritaca AI. | sim | sim | Modelo | — | 4-6 | — |
| [Aira-2](https://huggingface.co/nicholasKluge/Aira-2-124M) (+2) | Ajuda pesquisadores a estudar o ajuste de pequenos modelos de linguagem para seguir instruções, com modelos abertos em três tamanhos. | sim | não | Modelo | — | 4-6 | apache-2.0 |

**Observações**

- **Sabiá (Maritaca AI).** Caso-limite pendente com a coordenação do BBSIA (codebook, API comercial fechada): o Sabiá-2 é proprietário e os tokenizadores publicados servem só para estimar o custo de uso da API.
- **Aira-2.** Os três modelos declaram inglês como idioma; entram por brasileira = sim (autor brasileiro), não por ptbr (adjudicação do autor em 2026-10-03).

## Quanto a classificação automática acertou

Comparamos a resposta da máquina com a revisão do autor em cada documento. A pergunta que decide a inclusão é: quando o autor disse *sim*, a máquina também disse? Quando a máquina não tem evidência suficiente, ela responde *incerto*, e isso conta como "não disse sim".

| Pergunta | Documentos | Precisão | Recall | F1 | kappa | Respostas *incerto* |
|---|---|---|---|---|---|---|
| É IA? | 39 | 1,00 | 1,00 | 1,00 | 1,00 | 25 |
| É brasileira? | 35 | 1,00 | 0,70 | 0,82 | 0,77 | 27 |
| É adaptada ao português do Brasil? | 38 | 1,00 | 0,73 | 0,84 | 0,79 | 29 |

A máquina nunca disse *sim* quando o autor disse *não* (precisão 1,00). Ela é conservadora: prefere *incerto* quando a documentação não basta, e por isso deixou passar algumas soluções brasileiras. 17 das 195 extrações falharam por tempo esgotado e ficaram fora da conta.

