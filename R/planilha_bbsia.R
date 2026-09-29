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
RADAR_LICENCAS_ABERTAS <- c("mit", "apache-2.0", "bsd-2-clause", "bsd-3-clause", "gpl-2.0", "gpl-3.0",
                            "lgpl-2.1", "lgpl-3.0", "agpl-3.0", "mpl-2.0", "cc-by-4.0", "cc-by-sa-4.0",
                            "cc0-1.0", "unlicense", "openrail", "llama2", "llama3")

radar_montar_planilha_formulario <- function(candidatos, decifra, run_id, codebook_path = "config/codebook.yml",
                                             referencia = Sys.Date()) {
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

radar_planilha_revisao <- function(corpus, candidatos, decifra, max_chars = 4000L) {
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
    "Preencha a aba 'codificar' ANTES de abrir a aba 'maquina', para não se deixar influenciar.",
    "Use só sim, nao ou incerto em e_ia, brasileira e ptbr, com as regras de config/codebook.yml (v0.2.2).",
    "Silêncio da documentação é incerto, nunca nao. Abra o link quando o trecho não bastar.",
    "Deixe em branco o que não quiser codificar; linhas em branco não entram na comparação.",
    "Depois compare com a aba 'maquina' e anote divergências em 'observacao'."
  ))
  list(instrucoes = instrucoes, codificar = codificar, maquina = maquina)
}
