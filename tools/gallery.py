#!/usr/bin/env python3
"""Feed the gallery page from index.json. Standard library only.

  python3 tools/gallery.py            # write gallery/cases.js (+ the README Cases table with --readme)
  python3 tools/gallery.py --readme   # also rewrite the Cases table in README.md
  python3 tools/gallery.py --check    # fail if gallery/cases.js or the README table is stale (CI)

The page itself, gallery/index.html, is hand-written Preact components with no build step.
It reads the data this script writes into gallery/cases.js. A <script src> file (not a fetch
of index.json) keeps the page working when it is opened straight from disk (file://).

Run `python3 tools/validate.py --write` first: this script reads index.json, never case.json.
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INDEX = ROOT / "index.json"
DATA = ROOT / "gallery" / "cases.js"
README = ROOT / "README.md"
START, END = "<!-- cases:start -->", "<!-- cases:end -->"


def load_cases():
    index = json.loads(INDEX.read_text())
    cases = []
    for c in index["cases"]:
        src = c.get("source") or {}
        c = dict(c)
        # A case may ship its own 3D viewer next to case.json. Only in-repo cases can be checked here.
        c["viewer"] = "index.html" if src.get("kind") == "in-repo" and (ROOT / src["path"] / "index.html").is_file() else None
        cases.append(c)
    return cases


def cases_js(cases):
    body = json.dumps({"generated_from": "index.json", "count": len(cases), "cases": cases}, indent=2, ensure_ascii=False)
    return ("// Written by tools/gallery.py from index.json. Do not edit by hand:\n"
            "// run `python3 tools/validate.py --write && python3 tools/gallery.py --readme`.\n"
            f"window.CASE_INDEX = {body};\n")


def case_href(c):
    src = c.get("source") or {}
    if src.get("kind") == "in-repo":
        return src["path"] + "/"
    return src.get("url", "")


def readme_table(cases):
    rows = ["| id | holds | status | outer (mm) |", "|---|---|---|---|"]
    for c in cases:
        holds = " · ".join(h.get("part", "") for h in c.get("hardware") or []) or "—"
        status = c.get("status") or "unknown"
        if not c.get("printed"):
            status += ", **not printed yet**"
        outer = " × ".join(f"{v:g}" for v in c["outer_mm"]) if c.get("outer_mm") else "—"
        n = len(c.get("variants") or [])
        more = f" · {n} variants" if n else ""
        rows.append(f"| [`{c['id']}`]({case_href(c)}){more} | {holds} | {status} | {outer} |")
    rows.append("")
    rows.append("Browse every case with its preview and downloads in [`gallery/index.html`](gallery/index.html).")
    return "\n".join(rows)


def readme_text(cases):
    text = README.read_text()
    if START not in text or END not in text:
        return None
    head, rest = text.split(START, 1)
    _, tail = rest.split(END, 1)
    return f"{head}{START}\n{readme_table(cases)}\n{END}{tail}"


def main():
    args = set(sys.argv[1:])
    cases = load_cases()
    js = cases_js(cases)
    readme = readme_text(cases)
    stale = []
    if "--check" in args:
        if not DATA.is_file() or DATA.read_text() != js:
            stale.append("gallery/cases.js")
        if readme is not None and README.read_text() != readme:
            stale.append("README.md Cases table")
        for s in stale:
            print(f"ERROR {s}: stale: run `python3 tools/gallery.py --readme` and commit it")
        print(f"{len(cases)} case(s), {len(stale)} stale file(s)")
        sys.exit(1 if stale else 0)
    DATA.parent.mkdir(exist_ok=True)
    DATA.write_text(js)
    print(f"wrote {DATA.relative_to(ROOT)} ({len(cases)} case(s))")
    if "--readme" in args:
        if readme is None:
            print(f"ERROR README.md has no {START} … {END} markers")
            sys.exit(1)
        README.write_text(readme)
        print("rewrote the README Cases table")


if __name__ == "__main__":
    main()
