#!/usr/bin/env bash
# Export every print part of one case (or all cases) from its .scad, and run its fit check.
#   tools/render.sh cases/dbk-pms7003-xiao-c3      # one case
#   tools/render.sh                                # every case under cases/
# Needs: openscad (2026 dev build for --backend=manifold) and the case's libraries in
# OpenSCADPATH or ~/Documents/OpenSCAD/libraries. Output goes to $OUT (default build/).
set -euo pipefail
cd "$(dirname "$0")/.."
OPENSCAD=${OPENSCAD:-openscad}
OUT=${OUT:-build}
dirs=("$@"); [ ${#dirs[@]} -eq 0 ] && dirs=(cases/*/)
fail=0
for d in "${dirs[@]}"; do
  d=${d%/}; id=$(basename "$d")
  entry=$(python3 -c "import json,sys;print(json.load(open('$d/case.json'))['entry'])")
  backend=$(python3 -c "import json;print(json.load(open('$d/case.json'))['openscad'].get('backend','manifold'))")
  mkdir -p "$OUT/$id"
  for scene in $(python3 -c "import json;[print(p['scene']) for p in json.load(open('$d/case.json'))['print_parts']]"); do
    log=$("$OPENSCAD" --backend="$backend" -D "scene=\"$scene\"" -o "$OUT/$id/$scene.stl" "$d/$entry" 2>&1) || { echo "FAIL $id/$scene"; echo "$log" | tail -5; fail=1; continue; }
    if echo "$log" | grep -qiE '^(ERROR|WARNING)'; then echo "WARN $id/$scene"; echo "$log" | grep -iE '^(ERROR|WARNING)' | head -5; fi
    [ -s "$OUT/$id/$scene.stl" ] && echo "ok   $id/$scene  $(wc -c < "$OUT/$id/$scene.stl") bytes" || { echo "EMPTY $id/$scene"; fail=1; }
  done
  fc=$(python3 -c "import json;print(json.load(open('$d/case.json')).get('checks',{}).get('fitcheck',''))")
  if [ -n "$fc" ]; then
    ( cd "$d" && OPENSCAD="$OPENSCAD" bash "$fc" ) || { echo "FAIL $id fitcheck"; fail=1; }
  fi
done
exit $fail
