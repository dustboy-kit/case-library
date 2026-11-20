#!/usr/bin/env bash
# Every pair of bodies must not overlap: intersection volume < 0.01 mm^3 (touching faces count as 0).
set -uo pipefail
cd "$(dirname "$0")"
fail=0
for p in tub_pms tub_xiao tub_oled tub_tray tub_lid tub_plug tray_pms tray_xiao tray_oled tray_plug lid_xiao lid_oled lid_pms lid_tray lid_plug; do
  out=$("${OPENSCAD:-openscad}" --backend=manifold -D "scene=\"fit_$p\"" -o /tmp/dbkc_fit.stl dbk-case.scad 2>&1)
  if echo "$out" | grep -qiE 'empty|no top level'; then v=0; else v=$(python3 tools/stlvol.py /tmp/dbkc_fit.stl); fi
  if python3 -c "import sys; sys.exit(0 if float('$v') < 0.01 else 1)"; then echo "ok   $p  overlap ${v} mm3"; else echo "HIT  $p  overlap ${v} mm3"; fail=1; fi
done
exit $fail
