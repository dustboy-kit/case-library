# import-codex-cases — todo

Status as of 2026-11-20. `[x]` means verified by running it, not by assuming.
Tracking: TODO.md only.

## Done — verified

- [x] Schema + validator learn `variants` (`case.schema.json`, `tools/validate.py`).
      Verified: moved `plates/054.stl` away → `ERROR …: file not found: plates/054.stl`, rc=1; restored → 0 errors.
- [x] Import `dbk-pcb-prism-100`: source, 100 plates, 100 views, `case.json` with 100 variants.
      Verified: `tools/render.sh cases/dbk-pcb-prism-100` → `ok dbk-pcb-prism-100/plate`; the plate exported
      through the new `scene` switch has volume 18819.297 mm³, the same as the committed `plates/001.stl` and `manifest.json`.
      Surprise: the folder is 22 MB, mostly the 100 plate STLs (20 MB).
- [x] Import `dbk-pcb-photo-shell`: `pm25-monitor.scad`, 10 renders, print part `shell`.
      Verified: `tools/render.sh cases/dbk-pcb-photo-shell` → `ok dbk-pcb-photo-shell/shell`; shell bbox 56 × 44 × 10.
- [x] Gallery shows variants as cards, with a Case filter; README table lists 3 cases.
      Verified: browser on 127.0.0.1 → 102 `article`, 0 broken images, Case filter `dbk-pcb-prism-100` → "100 designs".

## Now — in flight

- [ ] **PR, CI green, merge, Pages live** with 3 cases.
      ตรวจสอบ: `curl -s https://dustboy-kit.github.io/case-library/gallery/cases.js | rg -c '"source"'` → 3

## Next — not started

- [ ] Slim the BOSL2 case at its root: side-by-side layout, Dupont keep-out bodies in the fit check. Own issue.
