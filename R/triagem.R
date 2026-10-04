# Decision rule shared by e_ia, brasileira and ptbr / Regra de decisão comum.
#
# (pt) O codebook (config/codebook.yml, v0.2.3) usa a mesma regra nas duas
#      marcações de vínculo (brasileira e ptbr): `sim` com 1 sinal forte ou 2 médios; `incerto` com
#      1 médio, só fracos, nenhum sinal ou sinais conflitantes; `nao` só com
#      evidência positiva contrária. Em `e_ia`, `sim` exige evidência citável
#      de modelo aprendido. O silêncio da fonte nunca vira `nao`. Esta função
#      aplica a regra a sinais já identificados (por uma pessoa, por regra do
#      radar ou pelo Decifra) e serve de gabarito executável para os casos de
#      aceitação em tests/fixtures/codebook_aceitacao.yml. Ela não lê texto nem
#      identifica sinais: isso é trabalho do Decifra e da revisão humana.
# (en) Applies the codebook's shared decision rule to already-identified
#      signals. It never reads documents; it makes the acceptance cases
#      executable, so a change to the rule shows up as a failing test.

radar_decidir_marcacao <- function(fortes = 0L, medios = 0L, fracos = 0L,
                                   negativa = FALSE, conflito = FALSE,
                                   regra = c("vinculo", "e_ia")) {
  regra <- match.arg(regra)
  counts <- c(fortes = fortes, medios = medios, fracos = fracos)
  if (any(is.na(counts)) || any(counts < 0) || any(counts != round(counts))) {
    stop("Contagens de sinais precisam ser inteiros não negativos.", call. = FALSE)
  }
  if (!is.logical(negativa) || !is.logical(conflito) ||
      length(negativa) != 1L || length(conflito) != 1L ||
      is.na(negativa) || is.na(conflito)) {
    stop("negativa e conflito precisam ser TRUE ou FALSE.", call. = FALSE)
  }
  # (pt) `e_ia` não tem escala de sinais: `sim` exige evidência citável de
  #      modelo aprendido (contada como `fortes`); médios e fracos não bastam.
  #      Em `brasileira` e `ptbr`, vale 1 forte ou 2 médios.
  # (en) e_ia needs citable model evidence; the vinculo flags use thresholds.
  positiva <- if (regra == "e_ia") fortes >= 1L else fortes >= 1L || medios >= 2L
  # (pt) Qualquer sinal forte ou médio ao lado de evidência contrária é
  #      conflito, mesmo abaixo do limiar de `sim`. Um sinal fraco não conflita:
  #      a tag `language:pt` convive com um card que declara modelo genérico.
  # (en) A strong or medium signal plus contrary evidence is a conflict.
  if (conflito || (negativa && (fortes + medios) >= 1L)) return("incerto")
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
    args <- sinais[[marcacao]] %||% list()
    args$regra <- if (marcacao == "e_ia") "e_ia" else "vinculo"
    do.call(radar_decidir_marcacao, args)
  }, character(1)), marcacoes)
}
