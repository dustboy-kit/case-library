## What this PR adds or changes

- Case id:
- New case / new version / registry line / tooling:

## Checklist

- [ ] `case.json` follows `case.schema.json`; `id` matches the folder name
- [ ] `python3 tools/validate.py --write` run, and `index.json` committed
- [ ] Every `print_parts` scene exports (`tools/render.sh cases/<id>`)
- [ ] Part sizes say where they came from (`size_source`); photo-estimate cases stay `concept`
- [ ] `version` bumped if the geometry changed
- [ ] No costs, prices, private hostnames or credentials in any file
