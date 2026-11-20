// Written by tools/gallery.py from index.json. Do not edit by hand:
// run `python3 tools/validate.py --write && python3 tools/gallery.py --readme`.
window.CASE_INDEX = {
  "generated_from": "index.json",
  "count": 1,
  "cases": [
    {
      "id": "dbk-pms7003-xiao-c3",
      "name": "DustBoy Kit case: PMS7003 + XIAO ESP32C3 + 0.91\" OLED",
      "version": "0.1.0",
      "status": "cad-fit-checked",
      "license": "MIT",
      "authors": [
        "DustBoy Kit",
        "DustBoy Oracle (AI)"
      ],
      "summary": "Three printed parts, no screws: a tub holds the PMS7003 on its floor, a tray holds the XIAO above it with room for Dupont plugs, and the lid holds the OLED behind a bevelled window.",
      "kit": "DustBoy Kit (DBK) breadboard edition",
      "outer_mm": [
        56,
        46,
        47
      ],
      "printed": false,
      "tags": [
        "pm25",
        "air-quality",
        "esp32c3",
        "xiao",
        "pms7003",
        "ssd1306",
        "no-screws",
        "kit4kids"
      ],
      "preview": "renders/01-assembled.png",
      "entry": "dbk-case.scad",
      "print_parts": [
        {
          "scene": "tub",
          "stl": "stl/dbk-case-tub.stl"
        },
        {
          "scene": "tray",
          "stl": "stl/dbk-case-tray.stl"
        },
        {
          "scene": "lid",
          "stl": "stl/dbk-case-lid.stl"
        }
      ],
      "hardware": [
        {
          "part": "Plantower PMS7003",
          "size_mm": [
            48,
            37,
            12
          ],
          "size_source": "datasheet"
        },
        {
          "part": "Seeed XIAO ESP32C3, pre-soldered headers",
          "size_mm": [
            21,
            17.5,
            1.2
          ],
          "size_source": "datasheet",
          "note": "PCB thickness, shield and USB-C overhang are typical values marked MEASURE"
        },
        {
          "part": "SSD1306 128x32 0.91in OLED module",
          "size_mm": [
            12.2,
            38,
            1.2
          ],
          "size_source": "typical",
          "note": "module PCB and glass marked MEASURE; active area from the Waveshare spec"
        }
      ],
      "source": {
        "kind": "in-repo",
        "path": "cases/dbk-pms7003-xiao-c3"
      },
      "viewer": "index.html"
    }
  ]
};
