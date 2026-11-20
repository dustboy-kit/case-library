# Prism / PM2.5 case library
100 two-piece OpenSCAD enclosure concepts for the photographed PMS7003 and the narrow display PCB. Browse index.html offline. Each plate STL has a complete matching base and lid, in mm, laid apart with their flat exterior faces on the bed. Use your slicer's **split to objects** feature for separate prints. The preview shows the assembled shell; the electronics are not included in the STL.

## Edit one design
Open cases.scad, set case_id (1–100), then set part to assembled, exploded, plate, base or lid. The separate lid export is oriented for the print bed. The tens group picks the body; the position in that group picks the grille. For example: **001** Datum / Parallel, **041** Loop / Parallel, **054** Bracket / Honeycomb, **098** Keystone / Wave.

    openscad -D 'case_id=54' -D 'part="plate"' --export-format binstl -o bracket-honeycomb.stl cases.scad

Run python3 build.py in this folder to regenerate the gallery, all meshes and the ZIP (tested with OpenSCAD 2026.10.11). No Python package dependencies. To keep only a favorite, download its STL rather than the collection.

## Before printing or powering hardware
- The estimated sensor envelope is 50 × 38 × 12 mm, carried over from the photo-based model. The nominal OLED aperture is 29 × 8.5 mm, centered 8.8 mm off the midline. Measure the real hardware; these are not supplier tolerances.
- The base has a locating tongue and the lid a slip fit. The halves are **not positively latched**. There are no PCB bosses or assumed screw holes. Plan retention and strain relief for real use.
- Verify the USB mating plug at full insertion, board height, sensor connector/cable space and display alignment. Check sensor inlet and outlet locations and isolate their air paths where required; grille area and side windows do not validate sensor operation.
- Start by printing **one** base and lid or a section coupon. Check material, shrinkage, clearances and cooling before choosing a family for production. Mounting ears and the cord eye are concepts, not load-rated features.
- Source photos establish external form. The project schematic identifies the PMS7003, XIAO ESP32C3 and SSD1306 but is not a mechanical drawing. New shell silhouettes and vent patterns are intentional design alternatives.
