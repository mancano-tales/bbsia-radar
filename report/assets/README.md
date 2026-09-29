# Ativos visuais do BBSIA Radar

`bbsia-source-icon.svg` é uma cópia do [ícone SVG publicado pelo próprio BBSIA](https://bancobrasileiro.ia.br/icon.svg), consultado em 2026-09-28. SHA-256 dos 725 bytes UTF-8 da resposta: `90ba06d6626b4b9af4719b43e7b350f94583069f9ef1755f8e4b55fc1a83c402`. O comentário do arquivo original informa que ele foi vetorizado de `bbsia.PNG` (265×184). `bbsia-logo.svg` conserva as mesmas coordenadas e cores com escala de 16 para `viewBox="0 0 512 512"`; a versão transparente retira apenas a moldura. O banner usa curvas geométricas próprias para o texto, sem carregar fontes locais ou remotas.

Os PNGs são derivados destes SVGs por `node tools/render-assets.mjs`. O script procura Edge ou Chrome local, cria um perfil temporário isolado, captura cada composição em escala 1:1 e rejeita PNGs cuja assinatura ou dimensão não corresponda à especificação. `node tools/render-assets.mjs --check` confere os arquivos versionados sem abrir navegador. O cartão OpenGraph é uma composição estática local do banner, sem dados de candidatos.

Estes arquivos identificam visualmente o BBSIA no radar; a licença do código do repositório não concede direitos sobre a marca de terceiros nem implica endosso institucional. A publicação inicial do site segue sujeita à autorização prevista no plano do Quarto.
