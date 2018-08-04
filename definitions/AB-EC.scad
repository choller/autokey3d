// NOTE: This definition does *not* yet support --bumpkey. Also, it's
// combination coding is different to regular keys. The combination
// is a vector of length 26 with the following composition:
//
// 0,0,0,0,0,0, 0,0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0,0
// ^            ^              ^            ^
// |            |              |            |_ second side passive pins
// |            |              |_ second side combination
// |            |_ first side passive pins
// |_ first side combination
//
// For combination, 1 is the shallowest cut and 6 the deepest.
// For passive pins, only 0 or 1 is allowed as values.
//
// A nice side effect of having this longer combination vector is that
// you can put the combinations for two locks on one key.

// Key length
kl=27;

// Combination cuts

// Shoulders
aspaces = [4.6, 3.05, 4.6, 3.05];

// Pin distance
pinspace = 3.1;

// Distance pin cut to edge of blank
px = 1.73;

// Lowest cut
lcut = 0.2;

bump_addcutdepth = 0.2;
bump_addplatspace = 0.6;

// Cut spacing
cutspace = 0.4;

// Cut spacing for passive cuts
pcutspace = 0.95;

// Cut angle (angle of cutter, W105)
cutangle = 90;

// Cutter diameter, W105
de = 6;

// Plateau spacing of the cut (tip diameter of cutter, W105)
platspace = 0.7;

kt = 2.88; // Key thickness

zcorr = 0.1; // Compensate dimensional errors in x/y
             // This value must be chosen such that the cutters touch
             // the blank without any cut depth when cutdepth is 0.

phk = ph - 2*tol;

include <includes/dimplecut.scad>;

module dimplecut_ec(cutnum, cutlevel, axis, passive=false) {
     loc_lcut = passive ? pcutspace : lcut;
     loc_cutspace = passive ? 0 : cutspace;
     loc_addaspace = passive ? 0 : addaspace;
     dimplecut(kt, aspaces[axis] + loc_addaspace, pinspace, loc_lcut, loc_cutspace, cutangle,
                cutnum, cutlevel, axis, px, platspace, de, zcorr);
}

module keycombcuts() {
   for (i = [0:5]) { 
     dimplecut_ec(i, keycomb[i], 0);
   }
   
   for (i = [6:12]) { 
     dimplecut_ec(i-6, keycomb[i], 1, true);
   }

   for (i = [13:18]) { 
     dimplecut_ec(i-13, keycomb[i], 2);
   }

   for (i = [19:25]) { 
     dimplecut_ec(i-19, keycomb[i], 3, true);
   }
}

module keytipthin() {
    thinl = 3.5; // Length of key tip to be thinned
    thinw = 0.9; // How much material to remove at the tip
    gamma = 45;
    
    bs = 10;
    
    translate([0,-bs/2 + thinw,-bs/2 - kl/2 + thinl])
    cube([bs,bs,bs], center=true);
    
    translate([0,bs/2 - thinw + phk,-bs/2 - kl/2 + thinl])
    cube([bs,bs,bs], center=true);
    
    translate([0,-bs/2-phk/2+thinw,-bs/2 - kl/2 + thinl])
    translate([0,-bs/2,bs/2])
    rotate([gamma,0,0])
    translate([0,bs/2,-bs/2])
    cube([bs,bs,bs], center=true);
    
    translate([0,-bs/2+sqrt(bs*bs)+phk-thinw,-bs/2 - kl/2 + thinl])
    translate([0,-bs/2,bs/2])
    rotate([gamma,0,0])
    translate([0,bs/2,-bs/2])
    cube([bs,bs,bs], center=true);
}

module keytipcuts() {
        ly = 3.5; // Length of ramp on y-axis
        pth = 2.85; // Profile thickness
        w = 3.2; // Width of ramp
        bs=10; // Cutting box dimensions
        gamma=27.86; // Angle of the ramp

        translate([-bs/2,-bs+w,ly])
        translate([0,bs/2,-kl/2 -bs/2])
        translate([bs/2,0,bs/2])
        rotate([0,-gamma,0])
        translate([-bs/2,0,-bs/2])
        cube([bs,bs,bs], center=true);
    
        translate([-bs/2,phk-w,ly])
        translate([bs+pth,0,0])
        translate([0,bs/2,-kl/2 -bs/2])
        translate([-bs/2,0,bs/2])
        rotate([0,gamma,0])
        translate([bs/2,0,-bs/2])
        cube([bs,bs,bs], center=true);

        keytipthin();
}
