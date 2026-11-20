# import-codex-cases — spec

Bring the two Codex case sets (prism-100 and the pm25-openscad shell) into `cases/` so that
`index.json`, the gallery and GitHub Pages show them next to the BOSL2 case.

## Why it exists

Measured on m5, 2026-11-20:

| | where it lived | in index.json |
|---|---|---|
| BOSL2 case `dbk-pms7003-xiao-c3` | `cases/` | yes (1 of 1) |
| prism-100: 100 two-piece shells, `cases.scad` + 100 plate STLs (20 MB) + 100 views (2 MB) | a herdr worktree's `output/` (uncommitted), copied into `laris-co/dustboy-oracle` `ψ/lab` at `1a28d42` (private) | no |
| pm25-openscad: `pm25-monitor.scad`, 8 scenes, 10 renders (304 KB) | same | no |

**The gallery shows only what `index.json` lists, and `index.json` lists only `cases/*/case.json`.**
The repo was seeded with the BOSL2 case alone: its `case.json` says "Earlier photo-estimated
designs (100-variant prism gallery) are not imported", and issue #1 put the import out of scope.
Nat (2026-11-20): "only [one case] why? … bring it in".

## Non-goals

- **Not making them fit.** Both sets come from photo-estimated sizes of the photographed carrier
  PCB (Tong's "ESP32minipms7003" board), which catbutter dropped on 2026-11-19 in favour of the
  breadboard edition. They enter at `concept`; `validate.py` refuses anything higher.
- **Not redesigning the BOSL2 case.** Its height (47 mm vs ~22 mm) is a separate root cause:
  Dupont plugs stacked vertically. Tracked on its own issue.

## Library decisions

**`variants` is a new optional field in `case.schema.json`** — one case can carry many printable
variants (`id`, `name`, `preview`, `stl`, `tags`). prism-100 is one source file with a
`case_id` switch, not 100 drawings, so it is one case with 100 variants, not 100 cases.
Consequence: the gallery has 101 cards for 3 cases. The count line says both.

**The 100 plate STLs are committed** (20 MB), like every in-repo case's `stl/`. **Not** rendered
in the Pages job — that would put OpenSCAD in the deploy path for a download link.
Consequence: the clone grows from ~3 MB to ~26 MB.

**`cases.scad` gets one change: a `scene` variable** that overrides `part`, so `tools/render.sh`
(which passes `-D scene=…`) can export it like every other case. Nothing else is edited.

**IDs say which hardware they hold**: `dbk-pcb-prism-100`, `dbk-pcb-photo-shell`. The `pcb`
in the id is the whole reason they are flat (board on top of the sensor, no wires).

## Constraints

- **`validate.py` checks `"<scene>"` appears in the entry file** for each print part, so the
  scene names must be quoted strings in the source.
- **A photo-estimate case must stay `concept`**: `validate.py` errors otherwise.

---
DNA lenses: none — `/oracle-plan --quick` (root cause traced in-session via /find-root-cause) · 2026-11-20
