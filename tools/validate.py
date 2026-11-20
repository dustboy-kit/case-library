#!/usr/bin/env python3
"""Validate every case and (re)build index.json. Standard library only.

  python3 tools/validate.py            # check, exit 1 on any error
  python3 tools/validate.py --write    # also rewrite index.json
  python3 tools/validate.py --check-index   # fail if index.json is stale

Sources, like the Arduino Library Manager:
  cases/<id>/case.json      cases kept in this repo
  registry.txt              one https://github.com/<owner>/<repo> per line: a case kept in its own repo,
                            with case.json at the repo root (fetched with git, shallow)
"""
import json, re, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMA = json.loads((ROOT / "case.schema.json").read_text())
REQ = SCHEMA["required"]
PROPS = SCHEMA["properties"]
errors = []


def err(where, msg):
    errors.append(f"{where}: {msg}")


def check(meta, where, base, expect_id=None):
    for k in REQ:
        if k not in meta:
            err(where, f"missing required field `{k}`")
    if expect_id and meta.get("id") != expect_id:
        err(where, f"id `{meta.get('id')}` must equal `{expect_id}`")
    if "id" in meta and not re.fullmatch(PROPS["id"]["pattern"], meta["id"]):
        err(where, "id must be lowercase letters, digits and dashes")
    if "version" in meta and not re.fullmatch(PROPS["version"]["pattern"], meta["version"]):
        err(where, "version must be semver x.y.z")
    if meta.get("status") not in PROPS["status"]["enum"]:
        err(where, f"status must be one of {PROPS['status']['enum']}")
    for h in meta.get("hardware", []):
        if h.get("size_source") not in PROPS["hardware"]["items"]["properties"]["size_source"]["enum"]:
            err(where, f"hardware `{h.get('part')}`: bad size_source")
    if meta.get("status") != "concept" and any(h.get("size_source") == "photo-estimate" for h in meta.get("hardware", [])):
        err(where, "a case built on photo-estimated sizes must stay at status `concept`")
    if meta.get("status") in ("printed", "field-tested") and not meta.get("printed"):
        err(where, "status says printed but `printed` is false")
    files = [meta.get("entry")] + [p.get("stl") for p in meta.get("print_parts", [])] + [meta.get("preview")]
    for f in filter(None, files):
        if not (base / f).is_file():
            err(where, f"file not found: {f}")
    if meta.get("entry") and (base / meta["entry"]).is_file():
        src = (base / meta["entry"]).read_text(errors="replace")
        for p in meta.get("print_parts", []):
            if f'"{p["scene"]}"' not in src:
                err(where, f"scene `{p['scene']}` does not appear in {meta['entry']}")


def local_cases():
    out = []
    for cj in sorted((ROOT / "cases").glob("*/case.json")):
        where = str(cj.relative_to(ROOT))
        try:
            meta = json.loads(cj.read_text())
        except json.JSONDecodeError as e:
            err(where, f"invalid JSON: {e}")
            continue
        check(meta, where, cj.parent, expect_id=cj.parent.name)
        out.append({**meta, "source": {"kind": "in-repo", "path": str(cj.parent.relative_to(ROOT))}})
    return out


def registry_cases(fetch):
    out = []
    reg = ROOT / "registry.txt"
    for n, line in enumerate(reg.read_text().splitlines(), 1):
        url = line.split("#", 1)[0].strip()
        if not url:
            continue
        where = f"registry.txt:{n}"
        if not re.fullmatch(r"https://github\.com/[\w.-]+/[\w.-]+", url):
            err(where, f"`{url}` must be https://github.com/<owner>/<repo>")
            continue
        if not fetch:
            out.append({"id": url.rsplit("/", 1)[1], "source": {"kind": "registry", "url": url, "fetched": False}})
            continue
        with tempfile.TemporaryDirectory() as tmp:
            r = subprocess.run(["git", "clone", "--depth", "1", "--quiet", url, tmp], capture_output=True, text=True)
            if r.returncode:
                err(where, f"cannot clone {url}: {r.stderr.strip()[:200]}")
                continue
            cj = Path(tmp) / "case.json"
            if not cj.is_file():
                err(where, f"{url} has no case.json at the repo root")
                continue
            meta = json.loads(cj.read_text())
            check(meta, f"{where} ({url})", Path(tmp))
            sha = subprocess.run(["git", "-C", tmp, "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
            out.append({**meta, "source": {"kind": "registry", "url": url, "commit": sha}})
    return out


def main():
    args = set(sys.argv[1:])
    cases = local_cases() + registry_cases(fetch="--no-fetch" not in args)
    ids = [c.get("id") for c in cases]
    for d in {i for i in ids if ids.count(i) > 1}:
        err("index", f"duplicate id `{d}`")
    index = {
        "schema": "case.schema.json",
        "count": len(cases),
        "cases": [{k: c.get(k) for k in ("id", "name", "version", "status", "license", "authors", "summary",
                                         "kit", "outer_mm", "printed", "tags", "preview", "entry",
                                         "print_parts", "hardware", "source")} for c in cases],
    }
    text = json.dumps(index, indent=2, ensure_ascii=False) + "\n"
    if "--write" in args:
        (ROOT / "index.json").write_text(text)
    if "--check-index" in args and (ROOT / "index.json").read_text() != text:
        err("index.json", "stale: run `python3 tools/validate.py --write` and commit index.json")
    for e in errors:
        print("ERROR", e)
    print(f"{len(cases)} case(s), {len(errors)} error(s)")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
