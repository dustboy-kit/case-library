# case-library

3D-printable cases for small electronics kits, written in OpenSCAD. Anyone can add a case through an issue or a pull request, the way the Arduino Library Manager takes new libraries.

- Every case has a `case.json` that says what it holds and how sure it is. The fields are defined in [`case.schema.json`](case.schema.json).
- CI checks every case on each PR, exports every printable part, and runs the case's fit check.
- [`index.json`](index.json) lists every case. Tools and galleries read that file.

## Cases

| id | holds | status | outer (mm) |
|---|---|---|---|
| [`dbk-pms7003-xiao-c3`](cases/dbk-pms7003-xiao-c3/) | PMS7003, XIAO ESP32C3, 0.91" OLED | cad-fit-checked, **not printed yet** | 56 × 46 × 47 |

![dbk-pms7003-xiao-c3](cases/dbk-pms7003-xiao-c3/renders/01-assembled.png)

## Status ladder

```
concept  ──►  cad-fit-checked  ──►  printed  ──►  field-tested
drawn          fit check passes     a fit report     used for real
               against part models  issue says it    (e.g. a classroom)
                                    fitted
```

- **Part sizes from photos alone keep a case at `concept`.** CI enforces this.
- **A case moves up only with evidence**: a passing fit check, or a fit report issue from someone who printed it.

## Print a case

1. Open the case folder.
2. The ready STLs are in `stl/`. They are also attached to every CI run as the `stl` artifact.
3. To change a size, edit the `.scad` file and re-export:

```
tools/render.sh cases/<id>
```

This needs OpenSCAD 2026 (a dev snapshot, for `--backend=manifold`) and the libraries listed in the case's `case.json`, such as BOSL2.

## Add a case

There are two ways, as with Arduino libraries.

| You keep the case… | Do this |
|---|---|
| **in this repo** | Open a PR that adds `cases/<id>/` with `case.json`, the `.scad`, `stl/` and one preview PNG. |
| **in your own repo** | Put `case.json` at your repo root. Then open a PR that adds one line to [`registry.txt`](registry.txt), or use the **Add a case** issue form. CI clones your repo and validates it again every week. |

Before you open a PR, run:

```
python3 tools/validate.py --write    # checks every case, rewrites index.json
tools/render.sh cases/<id>           # every print part exports, the fit check passes
```

Other issue forms:
- **Request a case**: you have hardware and need a case drawn.
- **Fit report**: you printed a case. Say whether it fitted. This is how a case reaches `printed`.

## Rules

- **Say where each size came from**: `datasheet`, `measured`, `typical` or `photo-estimate`.
- **Bump `version` when the geometry changes.**
- **No costs, prices, private hostnames or credentials** in any file. This repo is public.
- **Each case states its own license.** The tools in `tools/` are MIT.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the review steps.
