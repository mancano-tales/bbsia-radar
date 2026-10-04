# Pilot spreadsheets / Planilhas do piloto.
#
# (pt) Duas saídas, ambas gravadas só no cache externo (contêm trechos de
#      README e model cards de terceiros):
#      1. a planilha de REVISÃO, para o autor codificar e_ia, brasileira e ptbr
#         sem ver a proposta da máquina (aba "codificar"), e depois comparar
#         (aba "maquina");
#      2. a planilha no formato do FORMULÁRIO do BBSIA, uma linha por solução,
#         com a classificação do Decifra, o TRL provável e o estado de cada
#         campo do formulário. Nada aqui é enviado ao BBSIA.
#      O radar lê a exportação do Decifra pelo `document_external_id`, nunca
#      pela posição das linhas (Decifra #10), e não importa código do Decifra.
# (en) Both workbooks stay in the external cache. Results are joined to the
#      corpus by the external id Decifra preserves.

RADAR_MARCACOES <- c("e_ia", "brasileira", "ptbr")

radar_ler_decifra <- function(path) {
  export <- readr::read_csv(path, col_types = readr::cols(.default = "c"),
                            locale = readr::locale(encoding = "UTF-8"), progress = FALSE)
  required <- c("document_external_id", "variable", "category", "rationale", "evidence_span")
  if (!all(required %in% names(export))) {
    stop("A exportação do Decifra precisa de ", paste(required, collapse = ", "), ".", call. = FALSE)
  }
  if (anyNA(export$document_external_id) || any(!nzchar(export$document_external_id))) {
    stop("Há linhas do Decifra sem document_external_id; não junto resultados por posição.", call. = FALSE)
  }
  # The CSV export defuses ids starting with = + - @ with an apostrophe.
  export$document_external_id <- sub("^'(?=[=+@-])", "", export$document_external_id, perl = TRUE)
  labels <- export$category
  if ("selections_json" %in% names(export)) {
    multi <- !is.na(export$selections_json) & nzchar(export$selections_json)
    labels[multi] <- vapply(export$selections_json[multi], function(x) {
      parsed <- jsonlite::fromJSON(x, simplifyVector = FALSE)
      paste(vapply(parsed, function(s) as.character(s$label %||% s), character(1)), collapse = "; ")
    }, character(1))
  }
  # Decifra records a failed extraction as the category `__error__`; it is a
  # missing answer, never a label.
  failed <- !is.na(export$category) & export$category == "__error__"
  labels[failed] <- NA_character_
  tibble::tibble(id = export$document_external_id, variavel = export$variable,
                 valor = labels, justificativa = export$rationale, evidencia = export$evidence_span,
                 falhou = failed)
}

radar_decifra_largo <- function(decifra) {
  if (anyDuplicated(decifra[c("id", "variavel")])) {
    stop("O Decifra devolveu mais de uma linha por documento e variável.", call. = FALSE)
  }
  wide <- tidyr::pivot_wider(decifra[c("id", "variavel", "valor", "evidencia")], id_cols = "id", names_from = "variavel",
                             values_from = c("valor", "evidencia"), names_glue = "{variavel}_{.value}")
  names(wide) <- sub("_valor$", "", names(wide))
  wide
}

radar_ler_mapas <- function(codebook_path = "config/codebook.yml") {
  codebook <- yaml::yaml.load(readr::read_file(codebook_path, locale = readr::locale(encoding = "UTF-8")))
  list(versao = codebook$versao,
       tipo = unlist(codebook$tipo_artefato$mapeamento_formulario),
       area = unlist(codebook$area_problema$mapeamento_formulario))
}

radar_mapear_formulario <- function(valores, mapa, sem_mapa = "mapeamento_manual") {
  vapply(valores, function(value) {
    if (is.na(value) || !nzchar(value)) return("nao_verificavel_publicamente")
    first <- trimws(strsplit(value, ";", fixed = TRUE)[[1]][[1]])
    if (first %in% names(mapa)) mapa[[first]] else sem_mapa
  }, character(1), USE.NAMES = FALSE)
}

# (pt) Licenças abertas reconhecidas pelo SPDX mais comuns em código e
#      modelos. "Aberta" aqui é só a licença declarada: o formulário pergunta
#      se outro órgão pode reusar, e isso exige revisão (codebook, campo aberta).
#      Licenças com restrição de uso (Llama, RAIL/OpenRAIL) ficam fora: não
#      equivalem a "código aberto" e dependem de leitura humana.
RADAR_LICENCAS_ABERTAS <- c("mit", "apache-2.0", "bsd-2-clause", "bsd-3-clause", "gpl-2.0", "gpl-3.0",
                            "lgpl-2.1", "lgpl-3.0", "agpl-3.0", "mpl-2.0", "cc-by-4.0", "cc-by-sa-4.0",
                            "cc0-1.0", "unlicense")

# (pt) O documento do corpus é o README (se houver) seguido do bloco de
#      metadados que montar_corpus() escreve começando por "Nome:" e
#      "Artefatos:". O TRL precisa só do README; os metadados não são
#      documentação de uso. Corta-se a partir do último bloco desse formato.
# (en) Strip the trailing metadata block so only README text is measured.
radar_readme_do_documento <- function(text) {
  vapply(text, function(doc) {
    if (is.na(doc)) return(NA_character_)
    if (grepl("^Nome: [^\n]*\nArtefatos: ", doc, perl = TRUE)) return(NA_character_)
    # (?s): `.` also matches newlines; the greedy prefix keeps everything up
    # to the LAST metadata block.
    stripped <- sub("(?s)^(.*)\n\nNome: [^\n]*\nArtefatos: .*$", "\\1", doc, perl = TRUE)
    if (nzchar(stripped)) stripped else NA_character_
  }, character(1), USE.NAMES = FALSE)
}

# (pt) Uma linha por SOLUÇÃO, como no corpus: um documento pode reunir vários
#      artefatos (ex.: código no GitHub e modelo no Hugging Face), e o Decifra
#      só conhece o id do documento. Os metadados vêm do artefato principal.
# (en) One row per corpus document; extra artifacts stay in source_urls.
radar_candidatos_por_solucao <- function(candidatos, corpus) {
  base <- candidatos[match(corpus$id, candidatos$id), , drop = FALSE]
  if (anyNA(base$id)) stop("Há documentos do corpus sem candidato correspondente.", call. = FALSE)
  base$url <- corpus$source_urls
  base$readme <- radar_readme_do_documento(corpus$text)
  base
}

radar_montar_planilha_formulario <- function(candidatos, decifra, run_id, codebook_path = "config/codebook.yml",
                                             referencia = Sys.Date(), corpus = NULL) {
  if (!is.null(corpus)) candidatos <- radar_candidatos_por_solucao(candidatos, corpus)
  mapas <- radar_ler_mapas(codebook_path)
  wide <- radar_decifra_largo(decifra)
  base <- dplyr::left_join(candidatos, wide, by = "id")
  trl <- radar_estimar_trl(base, referencia = referencia)
  # Not named `licenca`: inside tibble() the column of that name would shadow it.
  licenca_spdx <- tolower(base$license %||% rep(NA_character_, nrow(base)))
  nvp <- "nao_verificavel_publicamente"
  col <- function(name) if (name %in% names(base)) base[[name]] else rep(NA_character_, nrow(base))
  tibble::tibble(
    id_solucao = base$id,
    nome = base$name,
    plataforma = base$platform,
    url = base$url,
    responsavel = base$owner,
    e_ia = col("e_ia"), e_ia_evidencia = col("e_ia_evidencia"),
    brasileira = col("brasileira"), brasileira_evidencia = col("brasileira_evidencia"),
    ptbr = col("ptbr"), ptbr_evidencia = col("ptbr_evidencia"),
    tipo_artefato = col("tipo_artefato"),
    area_problema = col("area_problema"),
    problema_resumo = NA_character_,
    trl_provavel = trl$trl_provavel, trl_sinais = trl$trl_sinais, ativo = trl$ativo,
    licenca = base$license %||% NA_character_,
    form_tipo_ativo = radar_mapear_formulario(col("tipo_artefato"), mapas$tipo),
    form_area = radar_mapear_formulario(col("area_problema"), mapas$area),
    form_aberta = ifelse(is.na(licenca_spdx), "Não sei",
                         ifelse(licenca_spdx %in% RADAR_LICENCAS_ABERTAS, "Sim, código aberto", "Não sei")),
    form_ja_usado = nvp, form_ponto_atual = nvp, form_recursos_publicos = nvp,
    form_soberania = nvp, form_dado_sensivel = nvp, form_disposicao_aberto = nvp,
    form_nivel_governo = nvp,
    estado_revisao = "proposto",
    versao_codebook = mapas$versao,
    rodada = run_id
  )
}

radar_planilha_revisao <- function(corpus, candidatos, decifra, max_chars = 4000L, ids = NULL) {
  # `ids` fixes which documents enter and in what order (e.g. the shuffled
  # sample of radar_amostra_revisao()); default: the whole corpus.
  if (!is.null(ids)) corpus <- corpus[match(ids, corpus$id), , drop = FALSE]
  if (anyNA(corpus$id)) stop("Há ids da revisão fora do corpus.", call. = FALSE)
  base <- dplyr::left_join(corpus[c("id", "text", "source_urls")],
                           candidatos[c("id", "name", "url")], by = "id")
  codificar <- tibble::tibble(
    id = base$id, nome = base$name, url = base$url,
    documento = substr(base$text, 1L, max_chars),
    e_ia = "", brasileira = "", ptbr = "", observacao = ""
  )
  maquina <- radar_decifra_largo(decifra)
  maquina <- maquina[c("id", intersect(c(rbind(RADAR_MARCACOES, paste0(RADAR_MARCACOES, "_evidencia"))),
                                       names(maquina)))]
  instrucoes <- tibble::tibble(passo = 1:5, instrucao = c(
    "Preencha a aba 'codificar' ANTES de abrir o arquivo separado com as respostas da máquina.",
    "Use só sim, nao ou incerto em e_ia, brasileira e ptbr, com as regras de config/codebook.yml (v0.2.2).",
    "Silêncio da documentação é incerto, nunca nao. Abra o link quando o trecho não bastar.",
    "Deixe em branco o que não quiser codificar; linhas em branco não entram na comparação.",
    "Depois compare com o arquivo da máquina e anote divergências em 'observacao'."
  ))
  # Two workbooks, so the machine's answers are not one click away while coding.
  list(autor = list(instrucoes = instrucoes, codificar = codificar), maquina = list(maquina = maquina))
}

# (pt) Amostra da revisão de inclusão (protocolo do autor, 2026-10-03): todos
#      os documentos que a máquina propõe incluir (e_ia = sim e brasileira ou
#      ptbr = sim) mais uma amostra aleatória dos demais, para estimar o que a
#      máquina deixou passar. A ordem é embaralhada e o grupo não aparece na
#      planilha, para a codificação continuar cega. Semente fixa: reprodutível.
# (en) All machine-included documents plus a random sample of the rest,
#      shuffled so the reviewer cannot tell which group a row came from.
radar_amostra_revisao <- function(maquina_larga, n_amostra = 30L, semente = 20261003L) {
  sim <- function(v) !is.na(v) & v == "sim"
  propostos <- maquina_larga$id[sim(maquina_larga$e_ia) & (sim(maquina_larga$brasileira) | sim(maquina_larga$ptbr))]
  resto <- setdiff(maquina_larga$id, propostos)
  set.seed(semente)
  amostra <- if (length(resto) <= n_amostra) resto else sample(resto, n_amostra)
  ids <- c(propostos, amostra)
  ordem <- sample(ids)
  # The group stays in this table for the agreement analysis; the review
  # workbook must not show it.
  tibble::tibble(id = ordem, grupo = ifelse(ordem %in% propostos, "proposto_pela_maquina", "amostra_do_resto"))
}

# (pt) Trecho curto de evidência para publicação: no máximo `max_chars`
#      caracteres, em uma linha, com reticências se cortado. Citação curta com
#      link para a fonte, como prevê o plano #24; nunca o documento inteiro.
# (en) Short single-line quotation, truncated with an ellipsis.
radar_trecho_curto <- function(x, max_chars = 300L) {
  if (length(max_chars) != 1L || is.na(max_chars) || max_chars < 2L) {
    stop("max_chars precisa ser pelo menos 2.", call. = FALSE)
  }
  x <- gsub("[[:space:]]+", " ", trimws(x))
  ifelse(is.na(x) | !nzchar(x), NA_character_,
         ifelse(nchar(x) > max_chars, paste0(substr(x, 1L, max_chars - 1L), "…"), x))
}

# (pt) Planilha de revisão das fichas: uma linha por artefato incluído, com a
#      proposta para cada campo e o trecho que a sustenta, e colunas em branco
#      para o autor confirmar ("ok") ou escrever a correção.
# (en) One row per included artifact: proposal, short evidence, blank review.
radar_planilha_fichas <- function(incluidos, maquina, candidatos, corpus, resumos = NULL,
                                  referencia = Sys.Date(), max_resumo = 400L) {
  wide <- radar_decifra_largo(maquina)
  base <- candidatos[match(incluidos, candidatos$id), , drop = FALSE]
  if (anyNA(base$id)) stop("Há artefatos incluídos sem candidato correspondente.", call. = FALSE)
  # The candidates table keeps only README size; TRL needs the README text,
  # taken from the corpus document without its metadata block.
  base$readme <- radar_readme_do_documento(corpus$text[match(incluidos, corpus$id)])
  # Summaries are written by the radar team, one or two plain sentences; a
  # long one is likely copied documentation and must not reach publication.
  if (!is.null(resumos) && any(nchar(stats::na.omit(resumos)) > max_resumo)) {
    stop("Resumo do problema acima de ", max_resumo, " caracteres: reescreva, não copie a documentação.", call. = FALSE)
  }
  trl <- radar_estimar_trl(base, referencia = referencia)
  col <- function(nome) if (nome %in% names(wide)) wide[[nome]][match(incluidos, wide$id)] else rep(NA_character_, length(incluidos))
  tibble::tibble(
    id = incluidos, nome = base$name, url = base$url,
    tipo_proposto = col("tipo_artefato"), tipo_trecho = radar_trecho_curto(col("tipo_artefato_evidencia")),
    tipo_revisao = "",
    area_proposta = col("area_problema"), area_trecho = radar_trecho_curto(col("area_problema_evidencia")),
    area_revisao = "",
    trl_proposto = trl$trl_provavel, trl_sinais = trl$trl_sinais, trl_revisao = "",
    resumo_proposto = if (is.null(resumos)) NA_character_ else unname(resumos[incluidos]),
    resumo_revisao = "",
    e_ia_trecho = radar_trecho_curto(col("e_ia_evidencia")),
    brasileira_trecho = radar_trecho_curto(col("brasileira_evidencia")),
    ptbr_trecho = radar_trecho_curto(col("ptbr_evidencia"))
  )
}
