// DustBoy Kit case, BOSL2. Holds the real parts:
//   Plantower PMS7003 (48 x 37 x 12, datasheet size), Seeed XIAO ESP32C3 with
//   pre-soldered headers (21 x 17.5 PCB), 0.91" SSD1306 128x32 OLED module (38 x 12).
// Four printed parts: tub, tray (XIAO shelf), lid, and nothing else; no screws.
//
// Axes: X = length (PMS air face at +X), Y = depth, Z = up. z = 0 is the inner floor.
// Values marked MEASURE are typical module sizes, not a datasheet; check them with
// calipers on the real kit before printing.
//
//   openscad -D 'scene="assembled"' -o assembled.png dbk-case.scad
//   scenes: assembled exploded section lid_under print tub tray lid
//           fit_<a>_<b> (intersection of two bodies; must be empty)

include <BOSL2/std.scad>

scene = "assembled";
$fn = 48;

// ---------------- parts (real sizes) ----------------
PMS      = [48, 37, 12];          // Plantower PMS7003, datasheet 48 x 37 x 12
PMS_CONN = [-17, -11];            // 2x5 1.27 mm socket on the label face, from PMS centre
XIAO     = [21, 17.5, 1.2];       // Seeed XIAO ESP32C3 PCB (21 x 17.5); thickness MEASURE
HDR_H    = 2.5;                   // header plastic under the PCB
HDR_PIN  = 6;                     // pin length below the plastic
USBC     = [7.4, 8.94, 3.26];     // USB-C receptacle (len, width, height); overhang 1.0 MEASURE
SHIELD   = [12.5, 10.5, 2.4];     // RF shield on the XIAO; MEASURE
OLED_PCB = [12.2, 38, 1.2];       // 0.91" module PCB, long side along Y; MEASURE
OLED_GL  = [11.5, 30, 1.5];       // glass; sits 6.5 mm from the pin end; MEASURE
OLED_AA  = [5.58, 22.38];         // SSD1306 128x32 active area (Waveshare spec)

// ---------------- case ----------------
WALL = 2.0;  FLOOR = 2.0;  LID = 2.0;
CLR  = 0.4;                       // part clearance
FIT  = 0.25;                      // lid lip clearance
IN   = [52, 42, 43];              // inner size of the tub
R_OUT = 4;                        // outer corner radius

OUT = [IN.x + 2*WALL, IN.y + 2*WALL];

// positions
pms_x  = IN.x/2 - 0.3 - PMS.x/2;               // air face 0.3 mm from the +X wall
tray_z = 27;                                   // tray bottom; 15 mm over the PMS for Dupont plugs
TRAY_T = 2;
xiao_x = -IN.x/2 + 1.2 + XIAO.x/2;             // PCB end 1.2 mm from the -X wall (USB-C side)
xiao_z = tray_z + TRAY_T + HDR_H;              // PCB underside
oled_x = 12;                                   // OLED in the +X half, long side along Y
oled_y = 0;
lid_z  = IN.z;                                 // lid underside

usb_z  = xiao_z + XIAO.z + USBC.z/2;           // USB-C centre height

// ---------------- the real parts ----------------
module pms() {
    color("#3d8f99") translate([pms_x, 0, 0]) cuboid(PMS, rounding=0.8, anchor=BOTTOM);
    color("black") translate([pms_x + PMS_CONN.x, PMS_CONN.y, PMS.z]) cuboid([5.2, 8.6, 1], anchor=BOTTOM);
    color("#0b0f12") translate([pms_x + PMS.x/2, 0, 0]) {   // inlet / outlet on the +X face
        translate([0, -9, 6])  cuboid([0.4, 12, 3.5]);
        translate([0, 10, 6])  cuboid([0.4, 8, 5]);
    }
}

module xiao() {
    translate([xiao_x, 0, xiao_z]) {
        color("#1f1f1f") cuboid(XIAO, rounding=1, edges="Z", anchor=BOTTOM);
        color("#c8ccd2") translate([-XIAO.x/2 - 1 + USBC.x/2, 0, XIAO.z]) cuboid(USBC, rounding=1, edges="X", anchor=BOTTOM);
        color("#c8ccd2") translate([3, 0, XIAO.z]) cuboid(SHIELD, anchor=BOTTOM);
        for (s = [-1, 1]) {                                     // 2 x 7 header rows
            color("#202020") translate([0, s*(XIAO.y/2 - 1.27), -HDR_H]) cuboid([XIAO.x - 2.5, 2.54, HDR_H], anchor=BOTTOM);
            color("#d4a640") for (i = [0:6]) translate([-7.62 + i*2.54, s*(XIAO.y/2 - 1.27), -HDR_H - HDR_PIN])
                cuboid([0.64, 0.64, HDR_PIN + HDR_H], anchor=BOTTOM);
        }
    }
}

module oled() {
    gl_y = OLED_PCB.y/2 - 1.5 - OLED_GL.y/2;                    // glass toward the far end
    translate([oled_x, oled_y, lid_z - OLED_GL.z - OLED_PCB.z]) {
        color("#2a62b8") cuboid(OLED_PCB, anchor=BOTTOM);
        color("#05070a") translate([0, gl_y, OLED_PCB.z]) cuboid(OLED_GL, anchor=BOTTOM);
        color("#7ff0ff") translate([0, gl_y, OLED_PCB.z + OLED_GL.z - 0.05]) cuboid([OLED_AA.x, OLED_AA.y, 0.1], anchor=BOTTOM);
        color("#d4a640") for (i = [0:3]) translate([0, -OLED_PCB.y/2 + 2 , 0])
            translate([-3.81 + i*2.54, 0, -6]) cuboid([0.64, 0.64, 6], anchor=BOTTOM);
    }
}
function oled_glass_y() = oled_y + OLED_PCB.y/2 - 1.5 - OLED_GL.y/2;

// a USB-C plug pushed fully home (overmold 12.4 x 6.6; MEASURE your cable)
module usb_plug() {
    face = xiao_x - XIAO.x/2 - 1;                               // receptacle mouth
    color("#15181c") translate([face - 0.6, 0, usb_z]) cuboid([22, 12.4, 6.6], rounding=1.5, edges="X", anchor=RIGHT);
}

// ---------------- printed parts ----------------
module tub() {
    color("#e9c21a") difference() {
        translate([0, 0, -FLOOR]) cuboid([OUT.x, OUT.y, IN.z + FLOOR], rounding=R_OUT, edges="Z", anchor=BOTTOM)
            ;
        // inside
        cuboid([IN.x, IN.y, IN.z + 1], rounding=R_OUT - WALL, edges="Z", anchor=BOTTOM);
        // air windows on the +X wall, each larger than the sensor port (Plantower guidance)
        translate([IN.x/2, -9, 6])  cuboid([WALL*3, 14, 6], rounding=1.5, edges="X");
        translate([IN.x/2, 10, 6])  cuboid([WALL*3, 10, 7], rounding=1.5, edges="X");
        // USB-C plug opening on the -X wall
        translate([-IN.x/2, 0, usb_z]) cuboid([WALL*3, 13.4, 7.6], rounding=2.5, edges="X");
        // engraved name on the front (-Y) wall
        translate([0, -OUT.y/2 + 0.6, 20]) rotate([90, 0, 0])
            linear_extrude(1) text("DustBoy", size=6, halign="center", valign="center", font="Helvetica:style=Bold");
    }
    color("#e9c21a") {
        // fin between outlet and inlet, outside, so warm outlet air is not drawn back in
        translate([IN.x/2 + WALL, 0.5, 0]) cuboid([5, 2, 12], rounding=1, edges=[RIGHT+FRONT, RIGHT+BACK], anchor=LEFT+BOTTOM);
        // PMS stops: back end and both sides
        for (s = [-1, 1]) translate([pms_x - PMS.x/2 - CLR, s*12, 0]) cuboid([2, 4, 6], anchor=RIGHT+BOTTOM);
        for (s = [-1, 1]) translate([pms_x, s*(PMS.y/2 + CLR), 0]) cuboid([30, (IN.y - PMS.y)/2 - CLR, 4], anchor=(s > 0 ? FRONT : BACK) + BOTTOM);
        // tray ledges on the Y walls (tray drops in after the PMS)
        for (s = [-1, 1]) translate([-IN.x/2, s*IN.y/2, tray_z]) cuboid([24, 2, 2], anchor=LEFT+TOP+(s > 0 ? BACK : FRONT));
        // feet
        for (x = [-1, 1], y = [-1, 1]) translate([x*(OUT.x/2 - 7), y*(OUT.y/2 - 7), -FLOOR]) cyl(d=7, h=1.2, anchor=TOP);
    }
}

TRAY = [24, IN.y - 2*CLR];
module tray() {
    // clipped to the tub's inside, less the clearance, so it drops in past the rounded corners
    intersection() {
        cuboid([IN.x - 2*CLR, IN.y - 2*CLR, 100], rounding=R_OUT - WALL - CLR, edges="Z", anchor=BOTTOM);
        tray_raw();
    }
}
module tray_raw() {
    color("#f0f0f0") difference() {
        translate([-IN.x/2 + CLR, 0, tray_z]) cuboid([TRAY.x - CLR, TRAY.y, TRAY_T], rounding=1, edges="Z", anchor=LEFT+BOTTOM);
        // slots for the two header rows; Dupont plugs go on from below
        for (s = [-1, 1]) translate([xiao_x, s*(XIAO.y/2 - 1.27), tray_z]) cuboid([19.5, 3.2, 10]);
        // wire pass for the PMS cable
        translate([-IN.x/2 + TRAY.x - 3, 0, tray_z]) cuboid([6, 16, 10], rounding=2, edges="Z");
    }
    // locating rim around the header plastic, open at the USB-C end
    color("#f0f0f0") translate([xiao_x, 0, tray_z + TRAY_T]) difference() {
        cuboid([XIAO.x + 2*CLR + 2.4, XIAO.y + 2*CLR + 2.4, 1.6], anchor=BOTTOM);
        cuboid([XIAO.x + 2*CLR, XIAO.y + 2*CLR, 5]);
        translate([-XIAO.x/2, 0, 0]) cuboid([6, XIAO.y - 4, 5]);
    }
}

module lid() {
    gl_y = oled_glass_y();
    color("#e9c21a") difference() {
        union() {
            translate([0, 0, lid_z]) cuboid([OUT.x, OUT.y, LID], rounding=R_OUT, edges="Z", anchor=BOTTOM)
                ;
            // lip that drops into the tub
            translate([0, 0, lid_z - 1.6]) rect_tube(size=[IN.x - 2*FIT, IN.y - 2*FIT], wall=1.2, h=1.6, rounding=R_OUT - WALL - FIT);
            // OLED pocket walls around the module PCB
            translate([oled_x, oled_y, lid_z]) rect_tube(size=[OLED_PCB.x + 2*CLR + 2.4, OLED_PCB.y + 2*CLR + 2.4],
                                                          wall=1.2, h=OLED_GL.z + OLED_PCB.z + 0.6, anchor=TOP);
            // hold-down post onto the XIAO RF shield
            translate([xiao_x + 3, 0, lid_z]) cuboid([6, 6, lid_z - (xiao_z + XIAO.z + SHIELD.z) - 0.2], anchor=TOP);
        }
        // OLED window: active area + 1 mm, chamfered outward
        translate([oled_x, gl_y, lid_z - 0.01])
            prismoid(size1=[OLED_AA.x + 1, OLED_AA.y + 1], size2=[OLED_AA.x + 1 + 2*LID, OLED_AA.y + 1 + 2*LID], h=LID + 0.02);
        // pin-end cut-out in the pocket so the header and Dupont plug clear it
        translate([oled_x, oled_y - OLED_PCB.y/2, lid_z]) cuboid([8, 6, 10], anchor=TOP);
        // vent slots over the XIAO
        for (i = [-2:2]) translate([xiao_x - 4, i*4.5, lid_z + LID/2]) cuboid([12, 1.6, LID + 1], rounding=0.8, edges="Z");
    }
}

// ---------------- scenes ----------------
module parts() { pms(); xiao(); oled(); }

module body(n) {
    if (n == "tub") tub();
    else if (n == "tray") tray();
    else if (n == "lid") lid();
    else if (n == "pms") pms();
    else if (n == "xiao") xiao();
    else if (n == "oled") oled();
    else if (n == "plug") usb_plug();
}

if (scene == "assembled") { tub(); tray(); lid(); parts(); usb_plug(); }
else if (scene == "inside") { tub(); tray(); parts(); usb_plug(); }
else if (scene == "exploded") {
    tub();
    up(48) pms();
    up(68) { tray(); xiao(); }
    up(100) { lid(); oled(); }
}
else if (scene == "section") difference() { union() { tub(); tray(); lid(); parts(); usb_plug(); } translate([-60, -60, -10]) cube([120, 60 + PMS_CONN.y, 80]); }
else if (scene == "section_x") difference() { union() { tub(); tray(); lid(); parts(); } translate([-100, -50, -10]) cube([100 + xiao_x, 100, 80]); }
else if (scene == "lid_under") { yrot(180) { lid(); oled(); } }
else if (scene == "tub") tub();
else if (scene == "ref_pms") pms();
else if (scene == "ref_xiao") xiao();
else if (scene == "ref_oled") oled();
else if (scene == "ref_tray") tray();
else if (scene == "ref_lid") lid();
else if (scene == "ref_plug") usb_plug();
else if (scene == "tray") tray();
else if (scene == "lid") up(lid_z + LID) xrot(180) lid();     // printed top-face down
else if (scene == "print") { tub(); right(OUT.x + 8) up(-tray_z) tray(); back(OUT.y + 8) up(lid_z + LID) xrot(180) lid(); }
else if (str_find(scene, "fit_") == 0) {
    p = str_split(substr(scene, 4), "_");
    intersection() { body(p[0]); body(p[1]); }
}
