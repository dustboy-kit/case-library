/* Prism / 100 enclosures for the photographed PMS7003 monitor.
   Millimetres. Photo-based concept dimensions, NOT measured tolerances.
   Set case_id and part in Customizer, F6, then export STL.
   Assembly coordinates: display faces +Z, USB exits +X. */
case_id = 1; // [1:100]
part = "assembled"; // [assembled,exploded,plate,lid,base]
scene = ""; // case-library: tools/render.sh sets scene="plate"; empty = use part
part_ = scene == "" ? part : scene;
sensor_xy = [50,38];
sensor_height = 12;
display_xy = [0,-8.8];
display_opening = [29,8.5];
usb_y = -12.1;
lip_clearance = 0.32; // per side; a starting value, not a verified printer tolerance

/* [Hidden] */
$fn=36;
eps=0.06;
split_z=4.8;
bed=2.2;
roof=2.2;
top=bed+sensor_height+1.6+0.92+2.2+0.65+roof;
inside=sensor_xy+[4.6,4.6];
core=inside+[4.4,4.4];
family=floor((case_id-1)/10);
face=(case_id-1)%10;
palette=["#e0ad32","#b1bf9b","#c5835b","#94b9b7","#cca164","#a8b7c6","#d7b773","#a7b69c","#b3a4ba","#ccad96"];

module rr(w,h,r) {
    offset(r=r) square([w-2*r,h-2*r],center=true);
}
module pill(a,b,r) {
    hull(){translate(a) circle(r=r);translate(b) circle(r=r);}
}
module profile(f) {
    w=core.x; h=core.y;
    if(f==0) rr(w,h,2.6);                                // datum shell
    if(f==1) hull(){                                      // soft capsule
        for(x=[-1,1]) translate([x*w*0.30,0]) scale([0.78,1]) circle(d=h+7);
    }
    if(f==2) union(){                                     // four bumpers
        rr(w,h,3); for(x=[-1,1],y=[-1,1]) translate([x*(w/2-2),y*(h/2-2)]) circle(r=5.5);
    }
    if(f==3) hull(){                                      // asymmetric thumb ledge
        rr(w,h,3); translate([-w/2-3,h*0.14]) circle(r=10);
    }
    if(f==4) union(){                                     // lanyard eye
        rr(w,h,4); hull(){translate([-w/2+2,0]) circle(r=7);translate([-w/2-8,0]) circle(r=5.5);}
    }
    if(f==5) union(){                                     // mounting ears
        rr(w,h,3); for(s=[-1,1]) hull(){
            translate([s*(w/2-2),0]) circle(r=8);translate([s*(w/2+6),0]) circle(r=5.4);
        }
    }
    if(f==6) union(){                                     // external grip ribs
        rr(w,h,4); for(x=[-20:8:20],s=[-1,1])
            translate([x,s*(h/2-0.8)]) rr(3.6,8,1.5);
    }
    if(f==7) {                                            // faceted drum
        a=w/2+3;b=h/2+3;c=7;
        polygon([[-a+c,-b],[a-c,-b],[a,-b+c],[a,b-c],[a-c,b],[-a+c,b],[-a,b-c],[-a,-b+c]]);
    }
    if(f==8) union(){                                     // scalloped hand grip
        rr(w,h,4);for(x=[-18,-6,6,18],s=[-1,1])
            translate([x,s*(h/2-2)]) scale([1.25,1]) circle(r=5);
    }
    if(f==9) hull(){                                      // tapered keystone
        for(s=[-1,1]) {
          translate([s*(w/2+4),h/2-2]) circle(r=4.5);
          translate([s*(w/2-3),-h/2+1]) circle(r=3.5);
        }
    }
}
module holes(f) {
    if(f==4) translate([-core.x/2-8,0]) circle(r=2.8);
    if(f==5) for(s=[-1,1]) translate([s*(core.x/2+6),0]) circle(r=2.3);
}
// Rounded grooves/slots drawn in the free face area above the display.
// Each motif consists of separated paths: no floating islands in the grille.
module arc(cx,cy,r,a,b,pen) {
    n=ceil((b-a)/12);
    for(i=[0:n-1]) let(u=a+(b-a)*i/n,v=a+(b-a)*(i+1)/n)
        pill([cx+r*cos(u),cy+r*sin(u)],[cx+r*cos(v),cy+r*sin(v)],pen);
}
module motif(m) {
    if(m==0) for(i=[-2:2]) translate([0,i*2.9]) rr(31-abs(i)*3,1.35,.62);
    if(m==1) for(i=[-3:3],j=[-1:1]) translate([i*4.5+j*0.8,j*4.4]) circle(r=1.15+0.18*(3-abs(i)));
    if(m==2) for(i=[0:11]) let(a=i*30) pill([5.5*cos(a),3.1*sin(a)],[16*cos(a),7.5*sin(a)],.75);
    if(m==3) for(j=[-1:1],i=[-2:2]) translate([i*5.8+(abs(j)%2)*2.9,j*4.95]) circle(r=2.6,$fn=6);
    if(m==4) for(i=[-2:2]) translate([i*6.8,0]) union(){pill([-2.2,-5.3],[1.8,0],.8);pill([1.8,0],[-2.2,5.3],.8);}
    if(m==5) for(s=[-1,1]) scale([s,1]) for(r=[4,7.7,11.4]) arc(4,0,r,-54,54,.78);
    if(m==6) for(i=[-2:2],j=[-1:1]) translate([i*6.9+abs(j)*1.6,j*4.8]) rotate(25+i*1.7+j*2.1) rr(4.8,2.1,.8);
    if(m==7) for(j=[-1:1],i=[0:11]) let(x=-16+i*2.65,y=4.7*j)
         pill([x,y+1.4*sin(x*14)],[x+2.65,y+1.4*sin((x+2.65)*14)],.68);
    if(m==8) for(i=[-2:2]) translate([i*6.8,0]) {
         t=2-abs(i); for(j=[-t:t]) translate([0,j*2.9]) square([4.15,1.6],center=true);
    }
    if(m==9) for(s=[-1,1]) scale([s,s]) for(i=[0:2]) translate([0,2.25*i]) {
        pill([-16,-4.3],[-6+i*2,-4.3],.60);
        pill([-6+i*2,-4.3],[-3+i*2,-1.0],.60);
    }
}
module slice(z,h) {translate([0,0,z]) linear_extrude(height=h) children();}
module body(z,h,f) {slice(z,h) difference(){profile(f);holes(f);}}
module base(f) {
    union(){
        difference(){
            body(0,split_z,f);
            slice(bed,split_z-bed+eps) rr(inside.x,inside.y,2.4);
            // Under-body air paths. Do not rely on these to separate inlet and exhaust.
            for(x=[-17,-10,10,17]) translate([x,0,-eps]) linear_extrude(bed+2*eps) rr(2.4,18,1);
        }
        // Registration tongue inside the lid. Open-center rim rather than a second floor.
        slice(split_z-eps,1.65+eps) difference(){
            rr(inside.x-2*lip_clearance,inside.y-2*lip_clearance,2.8);
            rr(inside.x-2*lip_clearance-2.5,inside.y-2*lip_clearance-2.5,1.65);
        }
        // Ledge joins the narrower tongue to the lower case across the seam.
        slice(split_z-1.0,1.0) difference(){rr(inside.x+1,inside.y+1,3);rr(inside.x-2*lip_clearance-2.5,inside.y-2*lip_clearance-2.5,1.65);}
    }
}
module lid(f,m) {
    difference(){
        body(split_z,top-split_z,f);
        slice(split_z-eps,top-roof-split_z+eps) rr(inside.x,inside.y,2.4);
        slice(top-roof-eps,roof+2*eps) translate(display_xy) rr(display_opening.x,display_opening.y,0.95);
        slice(top-roof-eps,roof+2*eps) translate([0,8.6]) motif(m);
        // USB and two side vent banks in assembled coordinates. Nominal positions only.
        translate([inside.x/2-1,usb_y-5.8,bed+sensor_height+0.15]) cube([24,11.6,5]);
        for(s=[-1,1],x=[-15,-9,-3,3,9,15])
            translate([x-1.5,s*core.y/2-11,split_z+2.25]) cube([3,22,4.2]);
    }
}
module plate(f,m) {
    // Independent bed-flat parts, spaced along Y. Exterior face of lid is on the bed.
    translate([0,-(core.y/2+9),0]) base(f);
    translate([0,core.y/2+9,top]) rotate([180,0,0]) lid(f,m);
}
assert(case_id>=1 && case_id<=100 && floor(case_id)==case_id,"case_id must be an integer 1-100");
assert(lip_clearance>0 && lip_clearance<0.8,"Use a practical positive clearance");
if(part_=="base") base(family);
else if(part_=="lid") translate([0,0,top]) rotate([180,0,0]) lid(family,face);
else if(part_=="plate") plate(family,face);
else if(part_=="assembled" || part_=="exploded") {
    color("#495255") base(family);
    color(palette[family]) translate([0,0,part_=="exploded"?15:0]) lid(family,face);
} else assert(false,"Unknown part");
