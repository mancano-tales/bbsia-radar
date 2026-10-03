# Public pilot dataset / Conjunto público do piloto.
#
# (pt) Escreve em `data/` o contrato público v1 descrito em data/README.md:
#      solutions.csv, solution_artifacts.csv, runs/<run_id>.json,
#      evidence/<run_id>.jsonl, snapshot_atual.csv e a concordância humano x
#      máquina em relatorios/. Só entram as soluções que o autor revisou como
#      e_ia = sim e brasileira ou ptbr = sim. Os três rótulos do autor saem
#      como `revisado`; tipo, área, TRL e resumo do problema saem como
#      `proposto` (decisão do autor em 2026-10-03, plano #28 §2). Nenhum texto
#      de README, model card ou resposta de API é copiado: só links, rótulos e
#      contagens. Caminhos de máquina nunca entram no manifesto público.
# (en) Writes the public v1 contract; third-party text never enters data/.

RADAR_PUBLICO_ESTADOS <- c(revisado = "revisado pelo autor", proposto = "proposta da máquina, não revisada")

radar_ler_solucoes <- function(path = "config/solucoes_piloto.yml") {
  spec <- yaml::yaml.load(readr::read_file(path, locale = readr::locale(encoding = "UTF-8")))
  ids <- purrr::map_chr(spec$solucoes, "solution_id")
  if (anyDuplicated(ids)) stop("solution_id repetido em ", path, ".", call. = FALSE)
  arts <- unlist(purrr::map(spec$solucoes, "artefatos"))
  if (anyDuplicated(arts)) stop("Um artefato aparece em mais de uma solução.", call. = FALSE)
  spec
}

# (pt) Concordância entre o gabarito do autor e a proposta da máquina, por
#      variável. A pergunta que decide a inclusão é "a máquina disse sim quando
#      o autor disse sim?": precisão, recall, F1 e kappa tratam `incerto` da
#      máquina como "não sim". Falhas da máquina (NA) ficam fora e são contadas.
# (en) Binary inclusion metrics per flag; machine failures are excluded.
radar_concordancia <- function(gold, maquina, variaveis = RADAR_MARCACOES) {
  x <- dplyr::inner_join(gold, maquina, by = "id", suffix = c("_h", "_m"))
  purrr::map_dfr(variaveis, function(v) {
    hv <- tolower(trimws(x[[paste0(v, "_h")]])); mv <- tolower(trimws(x[[paste0(v, "_m")]]))
    ok <- !is.na(hv) & nzchar(hv) & !is.na(mv) & nzchar(mv)
    hv <- hv[ok]; mv <- mv[ok]; n <- length(hv)
    tp <- sum(mv == "sim" & hv == "sim"); fp <- sum(mv == "sim" & hv != "sim")
    fn <- sum(mv != "sim" & hv == "sim"); tn <- n - tp - fp - fn
    safe <- function(a, b) if (b == 0) NA_real_ else a / b
    p <- safe(tp, tp + fp); r <- safe(tp, tp + fn)
    pe <- ((tp + fp) * (tp + fn) + (fn + tn) * (fp + tn)) / n^2
    decididos <- mv != "incerto"
    tibble::tibble(
      variavel = v, n = n, falhas_maquina = sum(!ok),
      verdadeiro_positivo = tp, falso_positivo = fp, falso_negativo = fn, verdadeiro_negativo = tn,
      precisao = p, recall = r, f1 = if (is.na(p) || is.na(r) || p + r == 0) NA_real_ else 2 * p * r / (p + r),
      kappa = safe((tp + tn) / n - pe, 1 - pe),
      maquina_incerto = sum(mv == "incerto"),
      acordo_quando_decide = safe(sum(hv[decididos] == mv[decididos]), sum(decididos))
    )
  })
}

radar_publicar_piloto <- function(gold, maquina, candidatos, corpus, solucoes, manifesto, decifra,
                                  out_dir = "data", referencia = Sys.Date()) {
  run_id <- solucoes$rodada
  norm <- function(v) tolower(trimws(v))
  gold <- dplyr::mutate(gold, dplyr::across(dplyr::all_of(RADAR_MARCACOES), norm))
  inclui <- gold$id[gold$e_ia == "sim" & (gold$brasileira == "sim" | gold$ptbr == "sim")]
  vinculos <- purrr::map_dfr(solucoes$solucoes, function(s) {
    tibble::tibble(solution_id = s$solution_id, artifact_id = unlist(s$artefatos),
                   justificativa = s$justificativa %||% NA_character_)
  })
  faltam <- setdiff(inclui, vinculos$artifact_id)
  if (length(faltam)) stop("Artefatos incluídos pelo autor sem solução curada: ", paste(faltam, collapse = ", "), call. = FALSE)
  sobram <- setdiff(vinculos$artifact_id, inclui)
  if (length(sobram)) stop("Solução curada com artefato que o autor não incluiu: ", paste(sobram, collapse = ", "), call. = FALSE)

  # One row per artifact with metadata, machine proposal and TRL.
  base <- candidatos[match(vinculos$artifact_id, candidatos$id), , drop = FALSE]
  base$readme <- radar_readme_do_documento(corpus$text[match(base$id, corpus$id)])
  trl <- radar_estimar_trl(base, referencia = referencia)
  wide <- radar_decifra_largo(maquina)
  art <- dplyr::bind_cols(vinculos, base[c("platform", "url", "owner", "license")], trl)
  art <- dplyr::left_join(art, wide[intersect(c("id", "tipo_artefato", "area_problema"), names(wide))],
                          by = c("artifact_id" = "id"))
  art <- dplyr::left_join(art, gold[c("id", RADAR_MARCACOES)], by = c("artifact_id" = "id"))

  dir.create(file.path(out_dir, "runs"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(out_dir, "evidence"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(out_dir, "relatorios"), recursive = TRUE, showWarnings = FALSE)
  obs <- as.character(as.Date(substr(manifesto$timestamp_utc, 1L, 10L)))

  sol <- purrr::map_dfr(solucoes$solucoes, function(s) {
    tibble::tibble(solution_id = s$solution_id, nome = s$nome,
                   problema_resumo = trimws(s$problema_resumo),
                   problema_resumo_estado = "proposto", nota = trimws(s$nota %||% ""),
                   primeira_observacao = obs, ultima_observacao = obs)
  })
  readr::write_csv(sol, file.path(out_dir, "solutions.csv"), na = "")
  readr::write_csv(dplyr::transmute(art, solution_id, artifact_id, plataforma = platform, url,
                                    data_inicio = obs, justificativa),
                   file.path(out_dir, "solution_artifacts.csv"), na = "")

  # Evidence: one fact per line; author labels are `revisado`, the rest `proposto`.
  fato <- function(row, campo, valor, estado, revisor, trecho) {
    list(run_id = run_id, solution_id = row$solution_id, artifact_id = row$artifact_id, campo = campo,
         # A label read off public documentation is an inference whoever makes it;
         # `revisao` says whether the author reviewed it.
         valor = valor, estado = "inferido",
         revisao = estado, revisor = revisor, fonte_url = row$url, trecho_ou_campo = trecho,
         observado_em = obs, versao_codebook = manifesto$codebook_version %||% NA_character_)
  }
  linhas <- unlist(lapply(seq_len(nrow(art)), function(i) {
    r <- art[i, ]
    c(lapply(RADAR_MARCACOES, function(v) fato(r, v, r[[v]], "revisado", "autor", "revisão humana do documento")),
      list(fato(r, "tipo_artefato", r$tipo_artefato, "proposto", "decifra", "decifra:tipo_artefato"),
           fato(r, "area_problema", r$area_problema, "proposto", "decifra", "decifra:area_problema"),
           fato(r, "trl_provavel", r$trl_provavel, "proposto", "radar", r$trl_sinais)))
  }), recursive = FALSE)
  writeLines(vapply(linhas, function(l) jsonlite::toJSON(l, auto_unbox = TRUE, na = "null"), character(1)),
             file.path(out_dir, "evidence", paste0(run_id, ".jsonl")), useBytes = TRUE)

  # Run manifest: parameters, counts and versions only; no machine paths.
  publico <- list(
    run_id = run_id, timestamp_utc = manifesto$timestamp_utc, consultas = manifesto$consultas,
    totais = manifesto$totais, tentativas_usadas = manifesto$tentativas_usadas,
    documentos_selecionados = manifesto$documentos_selecionados, status_http = manifesto$status_http,
    contas_hf = manifesto$contas_hf, collector_commit = manifesto$collector_commit,
    codebook_version = decifra$codebook_version, decifra_commit = decifra$commit, decifra_modelo = decifra$modelo,
    decifra_extracoes = decifra$extracoes, decifra_falhas = decifra$falhas,
    revisao_humana = list(revisor = "autor", documentos = nrow(gold), adjudicacoes = sum(nzchar(gold$adjudicacao %||% ""))),
    cache_ref = "bbsia-radar/api"
  )
  writeLines(jsonlite::toJSON(publico, auto_unbox = TRUE, pretty = TRUE, na = "null"),
             file.path(out_dir, "runs", paste0(run_id, ".json")), useBytes = TRUE)

  conc <- radar_concordancia(gold, wide)
  readr::write_csv(conc, file.path(out_dir, "relatorios", paste0(run_id, "-concordancia.csv")), na = "")

  # Derived snapshot for the site; the first artifact listed is the primary one.
  snap <- art |>
    dplyr::group_by(solution_id) |>
    dplyr::summarise(
      artefatos = paste(url, collapse = " | "), plataformas = paste(unique(platform), collapse = ", "),
      responsavel = paste(unique(stats::na.omit(owner)), collapse = ", "),
      e_ia = if (any(e_ia == "sim")) "sim" else dplyr::first(e_ia),
      brasileira = if (any(brasileira == "sim")) "sim" else dplyr::first(brasileira),
      ptbr = if (any(ptbr == "sim")) "sim" else dplyr::first(ptbr),
      tipo_artefato = dplyr::first(tipo_artefato), area_problema = dplyr::first(area_problema),
      trl_provavel = dplyr::first(trl_provavel), ativo = dplyr::first(ativo), licenca = dplyr::first(license),
      .groups = "drop") |>
    dplyr::right_join(sol[c("solution_id", "nome", "problema_resumo", "nota")], by = "solution_id")
  snap <- snap[match(sol$solution_id, snap$solution_id), c("solution_id", "nome", "problema_resumo",
    "e_ia", "brasileira", "ptbr", "tipo_artefato", "area_problema", "trl_provavel", "ativo", "licenca",
    "plataformas", "responsavel", "artefatos", "nota")]
  snap$estado_rotulos <- RADAR_PUBLICO_ESTADOS[["revisado"]]
  snap$estado_demais <- RADAR_PUBLICO_ESTADOS[["proposto"]]
  readr::write_csv(snap, file.path(out_dir, "snapshot_atual.csv"), na = "")
  invisible(list(solucoes = sol, artefatos = art, concordancia = conc, snapshot = snap))
}

# (pt) Markdown gerado para o site a partir do conjunto público. O CI do site
#      não tem R: o script de publicação grava report/_piloto.md e o relatório
#      o inclui. Arquivo derivado; nunca editar à mão.
# (en) Generated include for the Quarto report; never edit by hand.
RADAR_ROTULOS <- c(
  aplicacao = "Aplicação", biblioteca = "Biblioteca", modelo = "Modelo", dataset = "Base de dados",
  benchmark = "Benchmark", demo = "Demonstração", api = "API", servidor_mcp = "Servidor MCP",
  agente_ia = "Agente de IA", pipeline = "Pipeline", guia_metodologia = "Guia ou metodologia", outro = "Outro",
  saude = "Saúde", educacao = "Educação", justica_e_direito = "Justiça e direito",
  seguranca_publica = "Segurança pública", gestao_publica = "Gestão pública",
  atendimento_ao_cidadao = "Atendimento ao cidadão", transparencia_e_controle = "Transparência e controle",
  financas_e_tributos = "Finanças e tributos", trabalho_e_assistencia_social = "Trabalho e assistência social",
  meio_ambiente_e_agro = "Meio ambiente e agro", infraestrutura_e_mobilidade = "Infraestrutura e mobilidade",
  ciencia_e_pesquisa = "Ciência e pesquisa", cultura_e_linguagem = "Cultura e linguagem",
  transversal = "Transversal", sim = "sim", nao = "não", incerto = "incerto"
)

radar_rotulo_legivel <- function(x) {
  vapply(x, function(v) {
    if (is.na(v) || !nzchar(v)) return("—")
    partes <- trimws(strsplit(v, ";", fixed = TRUE)[[1]])
    paste(ifelse(partes %in% names(RADAR_ROTULOS), RADAR_ROTULOS[partes], partes), collapse = "; ")
  }, character(1), USE.NAMES = FALSE)
}

radar_licenca_legivel <- function(x) {
  ifelse(is.na(x) | !nzchar(x), "—", ifelse(toupper(x) == "NOASSERTION", "não declarada", x))
}

radar_relatorio_piloto_md <- function(res, manifesto, decifra) {
  num <- function(x) format(x, big.mark = ".", decimal.mark = ",")
  pct <- function(x) ifelse(is.na(x), "—", formatC(x, format = "f", digits = 2, decimal.mark = ","))
  t <- manifesto$totais
  conc <- res$concordancia
  snap <- res$snapshot
  perguntas <- c(e_ia = "É IA?", brasileira = "É brasileira?", ptbr = "É adaptada ao português do Brasil?")
  linhas_conc <- sprintf("| %s | %d | %s | %s | %s | %s | %d |", perguntas[conc$variavel], conc$n,
                         pct(conc$precisao), pct(conc$recall), pct(conc$f1), pct(conc$kappa), conc$maquina_incerto)
  primeiro_link <- sub(" \\|.*$", "", snap$artefatos)
  extras <- lengths(strsplit(snap$artefatos, " | ", fixed = TRUE)) - 1L
  linhas_sol <- sprintf("| [%s](%s)%s | %s | %s | %s | %s | %s | %s | %s |",
                        snap$nome, primeiro_link, ifelse(extras > 0, sprintf(" (+%d)", extras), ""),
                        snap$problema_resumo, radar_rotulo_legivel(snap$brasileira), radar_rotulo_legivel(snap$ptbr),
                        radar_rotulo_legivel(snap$tipo_artefato), radar_rotulo_legivel(snap$area_problema),
                        snap$trl_provavel, radar_licenca_legivel(snap$licenca))
  notas <- snap$nota[!is.na(snap$nota) & nzchar(snap$nota)]
  nomes_notas <- snap$nome[!is.na(snap$nota) & nzchar(snap$nota)]
  c(
    "<!-- Gerado por scripts/03_publicar.R a partir de data/. Não editar à mão. -->",
    "",
    sprintf("Rodada `%s`, coletada em %s. Classificação no Decifra (`%s`, modelo `%s`, codebook v%s) e revisão humana do autor.",
            manifesto$run_id, substr(manifesto$timestamp_utc, 1, 10), decifra$commit, decifra$modelo, decifra$codebook_version),
    "",
    "## Do que foi encontrado ao que entrou",
    "",
    "| Etapa | Quantidade |",
    "|---|---|",
    sprintf("| Projetos encontrados nas buscas (GitHub, Hugging Face, GitLab) | %s |", num(t$github + t$huggingface + t$gitlab)),
    sprintf("| Documentos lidos e classificados | %s |", num(t$corpus)),
    sprintf("| Artefatos que o autor confirmou como IA brasileira ou em português do Brasil | %s |", num(nrow(res$artefatos))),
    sprintf("| Soluções, depois de agrupar as variantes da mesma família | %s |", num(nrow(res$solucoes))),
    "",
    "A busca foi pequena de propósito: poucas contas e temas conhecidos, uma página por consulta. Os números mostram como o método se comporta, não o tamanho do universo.",
    "",
    "## As soluções do piloto",
    "",
    "As colunas **brasileira** e **pt-BR** foram revisadas pelo autor. Tipo, área, TRL e o resumo do problema são **proposta da máquina, ainda não revisada**. O TRL é uma estimativa do radar a partir de sinais públicos; nunca chega a 7–9 sem uso institucional declarado.",
    "",
    "| Solução | Problema que resolve (proposta) | Brasileira | pt-BR | Tipo (proposta) | Área (proposta) | TRL provável | Licença |",
    "|---|---|---|---|---|---|---|---|",
    linhas_sol,
    "",
    if (length(notas)) c("**Observações**", "", sprintf("- **%s.** %s", nomes_notas, notas), "") else character(),
    "## Quanto a classificação automática acertou",
    "",
    "Comparamos a resposta da máquina com a revisão do autor em cada documento. A pergunta que decide a inclusão é: quando o autor disse *sim*, a máquina também disse? Quando a máquina não tem evidência suficiente, ela responde *incerto*, e isso conta como \"não disse sim\".",
    "",
    "| Pergunta | Documentos | Precisão | Recall | F1 | kappa | Respostas *incerto* |",
    "|---|---|---|---|---|---|---|",
    linhas_conc,
    "",
    sprintf("A máquina nunca disse *sim* quando o autor disse *não* (precisão 1,00). Ela é conservadora: prefere *incerto* quando a documentação não basta, e por isso deixou passar algumas soluções brasileiras. %d das %s extrações falharam por tempo esgotado e ficaram fora da conta.",
            decifra$falhas, num(decifra$extracoes)),
    ""
  )
}
