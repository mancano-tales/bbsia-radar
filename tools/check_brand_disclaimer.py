"""Check that the BBSIA logo only appears inside the independence disclaimer.

(pt) A marca do BBSIA pode aparecer no site só dentro do quadro que avisa que
     o site não é do BBSIA (decisão do autor em 2026-09-29, plano #28 §2.3).
     Este verificador lê o HTML gerado pelo Quarto e falha se: (1) um <img>
     com "bbsia-logo" no src estiver fora de um elemento com a classe
     "disclaimer-panel"; (2) esse quadro não contiver o texto do aviso; ou
     (3) a página inicial não tiver o logo dentro de um quadro válido.
(en) Parses the rendered HTML with the standard library only, so the CI needs
     no extra dependency. Relationship checks replace the old independent
     greps, which passed if logo and disclaimer merely coexisted on a page.

Usage: python tools/check_brand_disclaimer.py report/_site
"""

import sys
from html.parser import HTMLParser
from pathlib import Path

DISCLAIMER_CLASS = "disclaimer-panel"
DISCLAIMER_TEXT = "Este site não é do BBSIA"
LOGO_MARKER = "bbsia-logo"
VOID_TAGS = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "source", "track", "wbr"}


class BrandParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack: list[bool] = []  # True when the open element is a disclaimer panel
        self.panels: list[dict] = []  # one per panel: text and logo count
        self.open_panels: list[dict] = []
        self.logos_outside = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "img" and LOGO_MARKER in (attrs.get("src") or ""):
            if self.open_panels:
                self.open_panels[-1]["logos"] += 1
            else:
                self.logos_outside += 1
        if tag in VOID_TAGS:
            return
        is_panel = DISCLAIMER_CLASS in (attrs.get("class") or "").split()
        self.stack.append(is_panel)
        if is_panel:
            panel = {"text": "", "logos": 0}
            self.panels.append(panel)
            self.open_panels.append(panel)

    def handle_endtag(self, tag):
        if tag in VOID_TAGS or not self.stack:
            return
        if self.stack.pop() and self.open_panels:
            self.open_panels.pop()

    def handle_data(self, data):
        for panel in self.open_panels:
            panel["text"] += data


def check_page(path: Path) -> list[str]:
    parser = BrandParser()
    parser.feed(path.read_text(encoding="utf-8"))
    problems = []
    if parser.logos_outside:
        problems.append(f"{path.name}: logotipo do BBSIA fora do quadro de aviso")
    for panel in parser.panels:
        if panel["logos"] and DISCLAIMER_TEXT not in " ".join(panel["text"].split()):
            problems.append(f"{path.name}: quadro com logotipo sem o texto '{DISCLAIMER_TEXT}'")
    return problems


def main(site_dir: str) -> int:
    site = Path(site_dir)
    problems = []
    for page in sorted(site.glob("*.html")):
        problems += check_page(page)
    index = BrandParser()
    index.feed((site / "index.html").read_text(encoding="utf-8"))
    valid = [p for p in index.panels if p["logos"] and DISCLAIMER_TEXT in " ".join(p["text"].split())]
    if not valid:
        problems.append("index.html: falta o quadro de aviso com o logotipo")
    for problem in problems:
        print(f"::error::{problem}")
    if not problems:
        print("OK: a marca do BBSIA só aparece dentro do quadro de aviso.")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "report/_site"))
