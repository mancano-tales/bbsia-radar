#!/usr/bin/env bash
# Recebe um diff unificado e verifica apenas as linhas de texto adicionadas.
# Nunca imprime o conteúdo detectado; mostra somente arquivo relativo e linha.
set -u

achados=$(
  awk '
    function delimitador(c) {
      return c == "" || c ~ /[[:space:]]/ || c == "\"" ||
             c == sprintf("%c", 39) || c == "=" || c == "(" ||
             c == "[" || c == "{" || c == "," || c == ":" ||
             c == sprintf("%c", 96)
    }
    function raiz_local(texto, raiz, restante, posicao, anterior) {
      restante = texto
      while ((posicao = index(restante, raiz)) > 0) {
        anterior = posicao == 1 ? "" : substr(restante, posicao - 1, 1)
        if (delimitador(anterior)) return 1
        restante = substr(restante, posicao + length(raiz))
      }
      return 0
    }
    function caminho_windows(texto, indice, caractere, barra) {
      barra = sprintf("%c", 92)
      for (indice = 1; indice <= length(texto) - 2; indice++) {
        caractere = substr(texto, indice, 1)
        if (caractere ~ /^[[:alpha:]]$/ &&
            (indice == 1 || delimitador(substr(texto, indice - 1, 1))) &&
            substr(texto, indice + 1, 1) == ":" &&
            (substr(texto, indice + 2, 1) == "/" ||
             substr(texto, indice + 2, 1) == barra) &&
            substr(texto, indice + 3, 1) != substr(texto, indice + 2, 1)) return 1
      }
      return 0
    }
    function caminho_unc(texto, indice, cursor, caractere, barra) {
      barra = sprintf("%c", 92)
      for (indice = 1; indice <= length(texto) - 4; indice++) {
        if (substr(texto, indice, 1) != barra ||
            substr(texto, indice + 1, 1) != barra ||
            (indice > 1 && !delimitador(substr(texto, indice - 1, 1)))) continue
        cursor = indice + 2
        while (cursor <= length(texto)) {
          caractere = substr(texto, cursor, 1)
          if (caractere == barra || caractere == "/") break
          if (caractere ~ /[[:space:]]/ || caractere == "\"") break
          cursor++
        }
        if (cursor > indice + 2 && cursor < length(texto) &&
            (substr(texto, cursor, 1) == barra ||
             substr(texto, cursor, 1) == "/") &&
            substr(texto, cursor + 1, 1) !~ /[[:space:]]/) return 1
      }
      return 0
    }
    function caminho_unix(texto, nomes, total, indice, raiz) {
      total = split("Users home root tmp workspace workspaces mnt media", nomes, " ")
      for (indice = 1; indice <= total; indice++) {
        raiz = "/" nomes[indice] "/"
        if (raiz_local(texto, raiz)) return 1
      }
      raiz = "/" "private" "/" "tmp" "/"
      if (raiz_local(texto, raiz)) return 1
      raiz = "/" "var" "/" "folders" "/"
      if (raiz_local(texto, raiz)) return 1
      raiz = "/" "var" "/" "tmp" "/"
      if (raiz_local(texto, raiz)) return 1
      raiz = "/" "run" "/" "user" "/"
      if (raiz_local(texto, raiz)) return 1
      return 0
    }
    function caminho_absoluto(texto) {
      return caminho_windows(texto) || caminho_unc(texto) || caminho_unix(texto)
    }
    /^commit / { dentro = 0; next }
    /^diff --git / { dentro = 0; caminho = ""; next }
    /^\+\+\+ / {
      caminho = substr($0, 5)
      if (substr(caminho, 1, 2) == "b/") caminho = substr(caminho, 3)
      if (caminho == "/dev/null") caminho = ""
      next
    }
    /^@@ / {
      split($3, cabecalho, ",")
      sub(/^\+/, "", cabecalho[1])
      linha = cabecalho[1] + 0
      dentro = 1
      next
    }
    dentro && /^\+/ {
      if ($0 !~ /^\+\+\+/) {
        texto = substr($0, 2)
        if (caminho_absoluto(texto)) {
          print caminho ":" linha
          encontrou = 1
        }
        linha++
      }
      next
    }
    dentro && /^-/ { next }
    dentro && /^ / { linha++; next }
    END { if (encontrou) exit 1 }
  '
)
codigo=$?
if [ "$codigo" -eq 0 ]; then
  exit 0
fi
if [ -n "$achados" ]; then
  printf 'Caminhos absolutos detectados (arquivo relativo:linha):\n%s\n' "$achados" >&2
fi
printf '%s\n' 'Revise o diff localmente e substitua cada caminho por um caminho relativo ou configuração local. O conteúdo detectado não foi exibido.' >&2
exit 1
