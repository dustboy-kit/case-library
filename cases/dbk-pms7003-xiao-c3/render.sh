#!/usr/bin/env bash
# Render every view and export the three print STLs. Needs OpenSCAD (2026 dev build, Manifold)
# and BOSL2 in ~/Documents/OpenSCAD/libraries/BOSL2.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p renders stl
R() { "${OPENSCAD:-openscad}" --backend=manifold --colorscheme=Tomorrow --imgsize=1600,1200 --viewall --autocenter -D "scene=\"$1\"" --camera=$2 -o "renders/$3.png" dbk-case.scad 2>&1 | grep -iE 'warning|error' || true; }
R assembled  0,0,0,58,0,215,0   01-assembled
R assembled  0,0,0,62,0,40,0    02-assembled-back
R inside     0,0,0,50,0,215,0   03-inside-no-lid
R exploded   0,0,0,75,0,215,0   04-exploded
R section    0,0,0,80,0,20,0     05-section-front
R section_x  0,0,0,80,0,300,0   06-section-xiao
R lid_under  0,0,0,35,0,200,0   07-lid-underside
R print      0,0,0,50,0,210,0   08-print-plate
for p in tub tray lid; do "${OPENSCAD:-openscad}" --backend=manifold -D "scene=\"$p\"" -o "stl/dbk-case-$p.stl" dbk-case.scad 2>&1 | grep -iE 'warning|error' || true; done
ls -la renders stl
