# Oracle Prism · design preset
One inline design review of the same assembly, using five lenses in sequence.

## 👤 Lens 1: User — what will someone notice or use?
Cases 001–010 preserve the rectangular silhouette closest to the photographed yellow cover. The Loop series (041–050) adds a cord eye; Bracket (051–060) adds two mounting ears. The OLED stays in the same place. The gallery lets you hold the body constant while comparing all ten grilles.

## 🔧 Lens 2: Maintainer — what can change without editing 100 files?
In cases.scad, profile(f) defines the perimeter; motif(m) defines the face cuts. The common lid(f,m) owns the display and USB openings, and base(f) owns the mating rim. Variant 054 is Bracket × Honeycomb, not a separately maintained drawing.

## 🐛 Lens 3: Breaker — what can fail despite a clean render?
build.py checks every STL for collapsed triangles, edges not paired in opposite directions, wrong component counts, overlapping plate Y extents, and bodies not resting at Z=0. These catch digital defects. They cannot catch recirculated air, a USB plug fouling the rim, an over-tight print, or an enclosure coming apart.

## ✂️ Lens 4: Simplifier — what can be left out?
The same slip joint and two printed pieces serve all versions. No invented PCB hole pattern, fastener set, or 100 hand-edited models. Datum / Parallel is the reference option before choosing a more elaborate face. Trade-off: the simple joint locates the halves but does not lock them.

## 🔌 Lens 5: Integrator — what needs the actual hardware?
The preceding pm25-monitor.scad model supplies the sensor-envelope and display offsets. The source electrical schematic identifies parts but gives no enclosure tolerances. The two side vent banks, roof perforations and USB opening in cases.scad are provisional until a physical trial verifies inlet/exhaust separation, clearance and access.

**Cross-lens summary:** Hold the electrical layout fixed; vary how the case is held, mounted, and ventilated. Use manifest.json and mesh checks to compare the 100 digital designs, then measure the hardware and test one preferred design before printing more.
