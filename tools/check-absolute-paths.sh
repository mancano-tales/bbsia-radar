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
    function delimitador_autoridade(c) {
      return c == "" || c ~ /[[:space:]]/ || c == "\"" ||
             c == sprintf("%c", 39) || c == "<" || c == ">" ||
             c == "," || c == "(" || c == ")" || c == "#" || c == "?"
    }
    function prefixo_uri_file(indice, inferior, superior, meio) {
      inferior = 1
      superior = quantidade_uri_file
      while (inferior <= superior) {
        meio = int((inferior + superior) / 2)
        if (indice < uri_file_inicio[meio]) {
          superior = meio - 1
        } else if (indice > uri_file_fim_maximo[meio]) {
          inferior = meio + 1
        } else {
          return 1
        }
      }
      return 0
    }
    function fronteira_windows(texto, indice, anterior) {
      anterior = indice == 1 ? "" : substr(texto, indice - 1, 1)
      return indice == 1 || delimitador(anterior) || anterior == "<" ||
             anterior == ">" ||
             (anterior == "/" && prefixo_uri_file(indice))
    }
    function raiz_local(texto, raiz, inicio, posicao, anterior) {
      inicio = 1
      while ((posicao = index(substr(texto, inicio), raiz)) > 0) {
        posicao += inicio - 1
        anterior = posicao == 1 ? "" : substr(texto, posicao - 1, 1)
        if (delimitador(anterior) || prefixo_uri_file(posicao)) return 1
        # Keep the search in the original line so a later match keeps its true
        # preceding character. This avoids treating a URL path as a local root.
        inicio = posicao + 1
      }
      return 0
    }
    function caminho_windows(texto, indice, caractere, barra) {
      barra = sprintf("%c", 92)
      for (indice = 1; indice <= length(texto) - 2; indice++) {
        caractere = substr(texto, indice, 1)
        if (caractere ~ /^[[:alpha:]]$/ &&
            substr(texto, indice + 1, 1) == ":" &&
            (substr(texto, indice + 2, 1) == "/" ||
             substr(texto, indice + 2, 1) == barra) &&
            fronteira_windows(texto, indice)) return 1
      }
      return 0
    }
    function caminho_unc(texto, indice, cursor, inicio_servidor, separador,
                         caractere, barra, anterior, inicio_compartilhamento) {
      barra = sprintf("%c", 92)
      for (indice = 1; indice <= length(texto) - 3; indice++) {
        separador = substr(texto, indice, 1)
        if ((separador != barra && separador != "/") ||
            substr(texto, indice + 1, 1) != separador) continue
        anterior = indice == 1 ? "" : substr(texto, indice - 1, 1)
        if (separador == barra) {
          if (indice > 1 && !delimitador(anterior)) continue
        } else if (!prefixo_uri_file(indice)) {
          # Do not treat protocol-relative web URLs as UNC paths.
          continue
        }

        cursor = indice
        while (cursor <= length(texto) &&
               substr(texto, cursor, 1) == separador) cursor++
        inicio_servidor = cursor
        while (cursor <= length(texto)) {
          caractere = substr(texto, cursor, 1)
          if (caractere == barra || caractere == "/") break
          if (delimitador_autoridade(caractere)) break
          cursor++
        }
        if (cursor <= inicio_servidor ||
            cursor > length(texto) ||
            (substr(texto, cursor, 1) != barra &&
             substr(texto, cursor, 1) != "/")) continue

        while (cursor <= length(texto) &&
               (substr(texto, cursor, 1) == barra ||
                substr(texto, cursor, 1) == "/")) cursor++
        inicio_compartilhamento = cursor
        if (inicio_compartilhamento <= length(texto) &&
            substr(texto, inicio_compartilhamento, 1) !~ /[[:space:]]/ &&
            substr(texto, inicio_compartilhamento, 1) != "\"") return 1
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
    function caminho_absoluto(texto, indice, anterior, inicio, cursor, fim,
                              barras, limite, host_inicio, maximo) {
      texto_minusculo = tolower(texto)
      quantidade_uri_file = 0
      limite = length(texto)
      for (indice = 1; indice <= limite - 4; indice++) {
        if (substr(texto_minusculo, indice, 1) != "f" ||
            substr(texto_minusculo, indice + 1, 1) != "i" ||
            substr(texto_minusculo, indice + 2, 1) != "l" ||
            substr(texto_minusculo, indice + 3, 1) != "e" ||
            substr(texto_minusculo, indice + 4, 1) != ":") continue
        anterior = indice == 1 ? "" : substr(texto, indice - 1, 1)
        if (indice != 1 && !delimitador(anterior) &&
            anterior != "<" && anterior != ">") continue

        inicio = indice + 5
        cursor = inicio
        while (cursor <= limite && substr(texto, cursor, 1) == "/") cursor++
        barras = cursor - inicio
        if (barras == 0) continue
        fim = cursor
        if (barras == 2 && cursor <= limite &&
            substr(texto, cursor, 1) !~ /[[:space:]]/ &&
            substr(texto, cursor, 1) != "/") {
          host_inicio = cursor
          while (cursor <= limite && substr(texto, cursor, 1) != "/" &&
                 !delimitador_autoridade(substr(texto, cursor, 1))) cursor++
          if (cursor > host_inicio) {
            fim = cursor
            if (substr(texto, cursor, 1) == "/") fim = cursor + 1
          }
        }

        quantidade_uri_file++
        uri_file_inicio[quantidade_uri_file] = inicio
        if (quantidade_uri_file == 1 || fim > maximo) maximo = fim
        uri_file_fim_maximo[quantidade_uri_file] = maximo
      }
      return caminho_windows(texto) || caminho_unc(texto) || caminho_unix(texto)
    }
    /^commit / { dentro = 0; caminho = ""; next }
    /^diff --git / { dentro = 0; caminho = ""; next }
    !dentro && /^\+\+\+ / {
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
      texto = substr($0, 2)
      if (caminho_absoluto(texto)) {
        print caminho ":" linha
        encontrou = 1
      }
      linha++
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
