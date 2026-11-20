# Contributing

## A new case in this repo
1. Fork the repo, then add `cases/<id>/`. The `<id>` must be lowercase letters, digits and dashes.
2. Write `case.json` (see `case.schema.json`):
   - **`print_parts`**: each entry names a `scene` value that your `.scad` exports, for example `-D 'scene="lid"'`.
   - **`hardware`**: every part the case holds, with its size and where that size came from.
   - **`status`**: `concept` unless a fit check against part models passes.
3. Commit the `.scad`, the exported `stl/`, and one preview PNG.
4. Run `python3 tools/validate.py --write`, then commit `index.json`.
5. Open a PR. CI must pass: the metadata check, and the render of every part plus the fit check.

## A case kept in your own repo
1. Put `case.json` at your repo root. Its paths are relative to the root.
2. Add your repo URL to `registry.txt` in a PR, or open an **Add a case** issue.
3. CI clones your repo on each PR and once a week. If your repo stops passing, the weekly run fails and a maintainer will open an issue.

## Moving a case up the status ladder
- Open a **Fit report** issue: printer, material, result, and caliper sizes.
- One positive fit report lets the case author (or a maintainer) set `printed: true` and `status: printed` in a PR that links the report.

## Review
A maintainer checks four things:
- CI is green.
- Every size source is honest.
- The license is stated.
- No private data is in any file.

Merging is a human's call. Bots and AI agents may open PRs, but they never merge them.
