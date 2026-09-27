# Convert radar codebook into Decifra's approved YAML contract /
# Converte o codebook do radar para o contrato YAML aprovado no Decifra.
#
# (pt) A conversão é explícita e não altera `config/codebook.yml`. O formato do
#      Decifra tem `concept`, `description` e `variables`; cada variável contém
#      categorias com `label`, `definition`, `positive_examples`,
#      `negative_examples` e `boundary_notes`. O campo `area_problema` já declara
#      `multiplo` e `maximo`; ele vira `multi_label` e `max_labels`, respeitando
#      o contrato R1.1. Este arquivo gerado deve ser refeito pela função, nunca
#      editado à mão.
# (en) Conversion is explicit and leaves the source codebook untouched. Decifra's
#      approved schema uses `concept`, `description`, and a `variables` list whose
#      categories carry labels, definitions, examples, and boundary notes. The
#      radar's multi-label `area_problema` maps to R1.1 `multi_label`/`max_labels`.
#      Generated output is reproducible and should never be hand-edited.

radar_to_decifra_variable <- function(name, label, definition, categories, multi = FALSE, max_labels = NULL) {
  variable <- list(
    name = name,
    description = paste0(label, ": ", definition),
    multi_label = isTRUE(multi),
    categories = categories
  )
  # Decifra's validator deliberately rejects multi-label-only keys on ordinary
  # categorical variables; emit these bounds only for area_problema.
  if (isTRUE(multi)) {
    variable$min_labels <- 0L
    variable$max_labels <- as.integer(max_labels)
    variable$evidence_granularity <- "per_label"
  }
  variable
}

codebook_para_decifra <- function(codebook_path = "config/codebook.yml", output_path = NULL) {
  # readr declares the UTF-8 encoding explicitly; this also avoids relying on
  # the host's legacy Windows locale when Portuguese accents are present.
  source <- yaml::yaml.load(readr::read_file(codebook_path, locale = readr::locale(encoding = "UTF-8")))
  variables <- list()
  dimensions <- list(
    list(name = "e_ia", item = source$e_ia, question = source$e_ia$pergunta),
    list(name = "brasileira", item = source$vinculo$brasileira, question = "A solução foi feita, mantida ou financiada principalmente no Brasil?"),
    list(name = "ptbr", item = source$vinculo$ptbr, question = "A solução é adaptada especificamente ao português brasileiro?"),
    list(name = "tipo_artefato", item = source$tipo_artefato, question = "Qual é o artefato principal da solução?")
  )
  for (dimension in dimensions[1:3]) {
    name <- dimension$name
    item <- dimension$item
    if (is.null(item)) next
    values <- as.character(unlist(item$valores, use.names = FALSE))
    categories <- purrr::map(values, function(value) list(
      label = value,
      definition = paste0("Marque `", value, "` segundo os critérios da dimensão. Pergunta: ", dimension$question),
      positive_examples = as.list(item$exemplos_sim %||% character()),
      negative_examples = as.list(item$exemplos_nao %||% character()),
      boundary_notes = item$regra_de_decisao %||% item$nota %||% item$definicao %||% ""
    ))
    variables[[length(variables) + 1L]] <- radar_to_decifra_variable(
      name, item$rotulo %||% name, item$definicao %||% item$nota %||% dimension$question,
      categories, multi = FALSE
    )
  }
  artifact_values <- names(source$tipo_artefato$valores %||% list())
  if (length(artifact_values)) {
    variables[[length(variables) + 1L]] <- radar_to_decifra_variable(
      "tipo_artefato", "Tipo de artefato", source$tipo_artefato$nota %||% "Artefato principal.",
      purrr::map(artifact_values, function(value) list(
        label = value,
        definition = source$tipo_artefato$valores[[value]],
        positive_examples = list(), negative_examples = list(), boundary_notes = ""
      ))
    )
  }
  area <- source$area_problema
  area_values <- as.character(unlist(area$valores, use.names = FALSE))
  variables[[length(variables) + 1L]] <- radar_to_decifra_variable(
    "area_problema", "Área do problema", "Área principal e, opcionalmente, uma área secundária.",
    purrr::map(area_values, function(value) list(
      label = value, definition = value, positive_examples = list(),
      negative_examples = list(), boundary_notes = ""
    )), multi = isTRUE(area$multiplo), max_labels = as.integer(area$maximo %||% NA_integer_)
  )
  result <- list(
    concept = "solucoes_ia_de_interesse_do_radar_bbsia",
    description = "Classifique evidências sobre soluções de IA, vínculo brasileiro, adaptação ao português brasileiro, tipo de artefato e áreas de problema. Não infira vínculo ou características sem evidência citável.",
    prompt_strategy = "per_variable",
    variables = variables
  )
  if (!is.null(output_path)) yaml::write_yaml(result, output_path)
  result
}
