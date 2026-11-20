/*
  PM2.5 monitor concept model, units: millimetres.

  IMPORTANT: All dimensions below are estimates inferred from the supplied
  photographs. They are NOT measured, fit-checked, or production-ready.
  The schematic is used only for part identity; visible geometry follows photos.

  CLI example:
    openscad -D 'scene="exploded"' -o preview.png pm25-monitor.scad

  Scenes: exploded, layout, stack, fit, pcb, sensor, shell, closed
*/

scene = "exploded";

// ---- Adjustable estimated dimensions (mm) ----
sensor_size = [50, 38, 12];
sensor_corner_r = 1.2;
sensor_end_trim = 1.6;

pcb_size = [48, 20, 1.6];
pcb_corner_r = 0.9;
pcb_side_offset = -7.5;          // board lies along one side of sensor
oled_size = [34, 10.5, 2.2];
oled_offset = [-1.0, -1.3];
usb_size = [5.5, 9.0, 3.2];

shell_outer = [56, 44, 10];
shell_corner_r = 2.0;
shell_wall = 2.0;
shell_floor = 2.0;
window_size = [29, 8.5];
// The X-axis turnover reverses Y; center the aperture on the OLED glass.
window_offset = [oled_offset[0]+1, -(pcb_side_offset+oled_offset[1])];
closed_top = sensor_size[2]+pcb_size[2]+0.92+oled_size[2]+0.5+shell_floor;

$fn = 36;

// ---- Palette ----
teal = [0.10, 0.43, 0.47];
trim_black = [0.025, 0.035, 0.04];
pcb_green = [0.02, 0.43, 0.18];
oled_blue = [0.02, 0.16, 0.25];
glass_black = [0.01, 0.015, 0.02];
ivory = [0.86, 0.82, 0.67];
metal = [0.65, 0.68, 0.69];
solder = [0.72, 0.72, 0.68];
yellow = [1.0, 0.83, 0.035];
paper = [0.93, 0.93, 0.88];
ink = [0.08, 0.10, 0.10];

// Rounded prism centered in XY and based at Z=0.
module rounded_prism(size, r=1) {
    linear_extrude(height=size[2])
        offset(r=r)
            square([size[0]-2*r, size[1]-2*r], center=true);
}

module barcode_label(z=0) {
    color(paper)
        translate([7, 2.2, z])
            cube([24, 14, 0.35], center=true);
    // Abstract bars only; no fabricated serial text.
    for (i=[-9.5:1.45:9.5])
        color(ink)
            translate([7+i, 3.2, z+0.20])
                cube([(i%3==0)?0.55:0.30, 8.5, 0.10], center=true);
}

module socket_detail(z=0) {
    color(trim_black)
        translate([-17.5, 7.8, z])
            rounded_prism([10.5, 7.0, 0.55], 0.6);
    for (x=[-20.5:2.0:-14.5])
        for (y=[6.4, 8.4])
            color([0.55,0.40,0.15])
                translate([x,y,z+0.56]) cylinder(h=0.22, d=0.65);
}

module sensor(label_face="up") {
    // Folded teal can.
    color(teal) rounded_prism(sensor_size, sensor_corner_r);

    // Thin black end trims visible in the photographs.
    // Set just outside the can to avoid coplanar overlap/z-fighting.
    for (x=[-sensor_size[0]/2-0.16,
             sensor_size[0]/2+0.16])
        color(trim_black)
            translate([x,0,0.6])
                rounded_prism([0.55, sensor_size[1]+0.3,
                               sensor_size[2]-1.2], 0.2);

    if (label_face == "up") {
        barcode_label(sensor_size[2]+0.01);
        socket_detail(sensor_size[2]+0.01);
    } else if (label_face == "down") {
        // Decoration is genuinely placed on the lower face; top remains plain.
        mirror([0,0,1]) {
            barcode_label(0.01);
            socket_detail(0.01);
        }
    }
}

module plated_hole(x,y,z) {
    color(solder) translate([x,y,z]) cylinder(h=0.22, d=2.3);
    color(pcb_green) translate([x,y,z+0.01]) cylinder(h=0.24, d=1.15);
}

module usb_port(z=0) {
    // Short-end metal connector with a dark mouth.
    color(metal)
        translate([pcb_size[0]/2-usb_size[0]/2+0.8, -4.6, z])
            rounded_prism(usb_size, 0.8);
    color(glass_black)
        translate([pcb_size[0]/2+0.85, -4.6, z+0.7])
            rounded_prism([0.4, 5.7, 1.8], 0.12);
}

module display_pcb() {
    // Carrier PCB.
    color(pcb_green) rounded_prism(pcb_size, pcb_corner_r);

    // Four header pads at the opposite short end.
    for (y=[-6,-2,2,6])
        plated_hole(-20.2,y,pcb_size[2]+0.01);

    // Side solder rows visible beside the OLED.
    for (x=[-14:3.5:14])
        for (y=[-8.35,8.35])
            color(solder)
                translate([x,y,pcb_size[2]+0.02])
                    cylinder(h=0.35, d=1.25);

    // Blue OLED carrier and tall dark display glass along PCB.
    color(oled_blue)
        translate([oled_offset[0],oled_offset[1],pcb_size[2]])
            rounded_prism([oled_size[0]+3.0,oled_size[1]+2.2,0.9],0.6);
    color(glass_black)
        translate([oled_offset[0]+1.0,oled_offset[1],pcb_size[2]+0.92])
            rounded_prism(oled_size,0.65);

    // Ivory side connector.
    color(ivory)
        translate([1.5,8.0,pcb_size[2]])
            rounded_prism([12.5,4.2,3.2],0.5);
    for (x=[-3.5:2:6.5])
        color([0.64,0.58,0.42])
            translate([x,10.15,pcb_size[2]+1.0])
                cube([0.55,0.35,1.0], center=true);

    usb_port(pcb_size[2]);
}

module retaining_tabs() {
    // Small visible retention lips along one inside edge.
    for (x=[-16,0,16])
        color(yellow)
            translate([x, shell_outer[1]/2-shell_wall-1.25, shell_floor])
                rounded_prism([6.0,2.5,4.5],0.55);
}

module enclosure() {
    // Shallow tray, open upward; window is a real through-cut in its floor.
    color(yellow)
        difference() {
            rounded_prism(shell_outer, shell_corner_r);
            translate([0,0,shell_floor])
                rounded_prism([
                    shell_outer[0]-2*shell_wall,
                    shell_outer[1]-2*shell_wall,
                    shell_outer[2]-shell_floor+0.2
                ], max(shell_corner_r-shell_wall/2,0.7));
            translate([window_offset[0],window_offset[1],-0.1])
                rounded_prism([window_size[0],window_size[1],
                               shell_floor+0.3],0.8);
        }
    retaining_tabs();
}

module board_on_sensor(label_face="down") {
    sensor(label_face);
    translate([0,pcb_side_offset,sensor_size[2]])
        display_pcb();
}

// Cover open downward, exterior face at z=top_z.
module cover_down(top_z) {
    translate([0,0,top_z])
        rotate([180,0,0])
            enclosure();
}

module scene_exploded() {
    sensor("down");
    translate([0,pcb_side_offset,sensor_size[2]+8])
        display_pcb();
    cover_down(sensor_size[2]+pcb_size[2]+oled_size[2]+42);
}

module scene_layout() {
    translate([-62,0,0]) sensor("up");
    translate([0,0,0]) display_pcb();
    translate([62,0,0]) enclosure();
}

module scene_stack() {
    board_on_sensor("down");
}

module scene_fit() {
    board_on_sensor("down");
    // Semi-transparent, close to the stack for fit/alignment inspection.
    color([1.0,0.83,0.035,0.28])
        cover_down(closed_top+2);
}

module scene_closed() {
    board_on_sensor("down");
    // Down-facing tray encloses the board; exterior floor/window remain visible.
    cover_down(closed_top);
}

// ---- Scene dispatcher ----
if (scene == "exploded") scene_exploded();
else if (scene == "layout") scene_layout();
else if (scene == "stack") scene_stack();
else if (scene == "fit") scene_fit();
else if (scene == "pcb") display_pcb();
else if (scene == "sensor") sensor("up");
else if (scene == "shell") enclosure();
else if (scene == "closed") scene_closed();
else {
    echo(str("Unknown scene: ", scene, "; showing exploded."));
    scene_exploded();
}
