#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${1:-$SCRIPT_DIR/pm25-monitor.scad}"

find_openscad() {
  if [[ -n "${OPENSCAD:-}" && -x "${OPENSCAD}" ]]; then
    printf '%s\n' "$OPENSCAD"
    return
  fi
  if command -v openscad >/dev/null 2>&1; then
    command -v openscad
    return
  fi
  local candidate
  for candidate in \
    "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" \
    "/opt/homebrew/bin/openscad" \
    "/usr/local/bin/openscad"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  return 1
}

if [[ ! -f "$SOURCE" ]]; then
  printf 'SCAD source not found: %s\n' "$SOURCE" >&2
  exit 1
fi

if ! OPENSCAD_BIN="$(find_openscad)"; then
  printf 'OpenSCAD was not found. Set OPENSCAD=/absolute/path/to/openscad.\n' >&2
  exit 1
fi

scenes=(
  exploded layout stack fit pcb
  sensor shell closed stack stack
)
cameras=(
  "0,0,0,58,0,35,180"
  "0,0,0,62,0,32,180"
  "0,0,0,58,0,35,180"
  "0,0,0,62,0,38,180"
  "0,0,0,52,0,28,180"
  "0,0,0,60,0,32,180"
  "0,0,0,58,0,35,180"
  "0,0,0,58,0,35,180"
  "0,0,0,88,0,90,180"
  "0,0,0,0,0,0,180"
)

printf 'OpenSCAD: %s\nSource:   %s\n' "$OPENSCAD_BIN" "$SOURCE"

for index in "${!scenes[@]}"; do
  number="$(printf '%02d' "$((index + 1))")"
  scene="${scenes[$index]}"
  names=(01-exploded 02-layout 03-stack 04-fit 05-pcb 06-sensor 07-shell-inside 08-closed 09-side 10-top)
  output="$SCRIPT_DIR/renders/${names[$index]}.png"
  temporary="$SCRIPT_DIR/renders/.$number.png.tmp.png"

  printf '[%s/10] %-9s -> %s\n' "$((index + 1))" "$scene" "$(basename "$output")"
  rm -f -- "$temporary"
  "$OPENSCAD_BIN" \
    --hardwarnings \
    --backend=Manifold \
    --render=true \
    --projection=o \
    --autocenter \
    --viewall \
    --colorscheme=Tomorrow \
    --imgsize=1000,800 \
    --camera="${cameras[$index]}" \
    -D "scene=\"$scene\"" \
    -o "$temporary" \
    "$SOURCE"
  mv -f -- "$temporary" "$output"
done

printf 'Rendered 10 views in %s\n' "$SCRIPT_DIR"
