# Decision rule shared by e_ia, brasileira and ptbr / Regra de decisão comum.
#
# (pt) O codebook (config/codebook.yml, v0.2.1) usa a mesma regra nas três
#      marcações: `sim` com 1 sinal forte ou 2 médios; `incerto` com 1 médio,
#      só fracos, nenhum sinal ou sinais conflitantes; `nao` só com evidência
#      positiva contrária. O silêncio da fonte nunca vira `nao`. Esta função
#      aplica a regra a sinais já identificados (por uma pessoa, por regra do
#      radar ou pelo Decifra) e serve de gabarito executável para os casos de
#      aceitação em tests/fixtures/codebook_aceitacao.yml. Ela não lê texto nem
#      identifica sinais: isso é trabalho do Decifra e da revisão humana.
# (en) Applies the codebook's shared decision rule to already-identified
#      signals. It never reads documents; it makes the acceptance cases
#      executable, so a change to the rule shows up as a failing test.

radar_decidir_marcacao <- function(fortes = 0L, medios = 0L, fracos = 0L,
                                   negativa = FALSE, conflito = FALSE) {
  counts <- c(fortes = fortes, medios = medios, fracos = fracos)
  if (any(is.na(counts)) || any(counts < 0) || any(counts != round(counts))) {
    stop("Contagens de sinais precisam ser inteiros não negativos.", call. = FALSE)
  }
  if (!is.logical(negativa) || !is.logical(conflito) ||
      length(negativa) != 1L || length(conflito) != 1L ||
      is.na(negativa) || is.na(conflito)) {
    stop("negativa e conflito precisam ser TRUE ou FALSE.", call. = FALSE)
  }
  positiva <- fortes >= 1L || medios >= 2L
  # Positive and contrary evidence together is a conflict, not a vote.
  if (conflito || (positiva && negativa)) return("incerto")
  if (positiva) return("sim")
  if (negativa) return("nao")
  "incerto"
}

# (pt) Aplica a regra a um caso de aceitação: `sinais` é uma lista por
#      marcação, cada uma com os argumentos de radar_decidir_marcacao().
#      Marcação sem sinais declarados equivale a silêncio da fonte.
# (en) One call per flag; a flag with no declared signals is source silence.
radar_decidir_caso <- function(sinais, marcacoes = c("e_ia", "brasileira", "ptbr")) {
  stats::setNames(vapply(marcacoes, function(marcacao) {
    do.call(radar_decidir_marcacao, sinais[[marcacao]] %||% list())
  }, character(1)), marcacoes)
}
