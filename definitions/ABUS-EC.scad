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

// Plateau spacing of the cut (tip diameter of cutter, W105)
platspace = 0.7;

module dimplecut(cutnum, cutlevel, axis) {
    gamma = (360-2*cutangle) / 4; // Ramp angle for making the cutter
    lcutter = 10; // Length of cutter shaft
    kt = 2.88; // Key thickness :/ ?
    
    px = 1.73; // Distance pin cut to edge of blank
    de = 6; // Cutter diameter, W105
    
    h = (de - platspace)/2 / sin(gamma) * sin(90-gamma);
    
    aspace = aspaces[axis];
    
    ocs = (axis == 1 || axis == 2) ? 0 : 1; // on center side?
    neg = (ocs == 1) ? 1 : -1;
    mx = (ocs == 1) ? 0 : 1;
    vtrans = axis > 1 ? -ph + 2*px : 0;
    passive = axis % 2 ? 1 : 0;
    
    zcorr = 0.1; // Compensate dimensional errors in x/y
                 // This value must be chosen such that the cutters touch
                 // the blank without any cut depth.

    cutdepth = passive ? cutlevel * pcutspace : lcut + (cutlevel-1)*cutspace;
    
    translate([ - cutdepth * neg,0,0]) // comment this out for calibration
    translate([ocs*zcorr,0,0])
    translate([0,vtrans,0])
    translate([neg*(h/2) + ocs*kt,ph-px,kl/2 - aspace - cutnum*pinspace])
    mirror([mx,0,0])
    rotate([0,90,0])
    union() {
        cylinder(h, platspace/2, de/2, center=true);
        translate([0,0,lcutter/2 + h/2])
        cylinder(lcutter,de/2,de/2,center=true);
    }
}

module keycombcuts() {
   for (i = [0:5]) { 
     dimplecut(i, keycomb[i], 0);
   }
   
   for (i = [6:12]) { 
     dimplecut(i-6, keycomb[i], 1);
   }

   for (i = [13:18]) { 
     dimplecut(i-13, keycomb[i], 2);
   }

   for (i = [19:25]) { 
     dimplecut(i-19, keycomb[i], 3);
   }
}

module keytipthin() {
    thinl = 3.5; // Length of key tip to be thinned
    thinw = 0.9; // How much material to remove at the tip
    gamma = 45;
    
    bs = 10;
    
    translate([0,-bs/2 + thinw,-bs/2 - kl/2 + thinl])
    cube([bs,bs,bs], center=true);
    
    translate([0,bs/2 - thinw + ph,-bs/2 - kl/2 + thinl])
    cube([bs,bs,bs], center=true);
    
    translate([0,-bs/2-ph/2+thinw,-bs/2 - kl/2 + thinl])
    translate([0,-bs/2,bs/2])
    rotate([gamma,0,0])
    translate([0,bs/2,-bs/2])
    cube([bs,bs,bs], center=true);
    
    translate([0,-bs/2+sqrt(bs*bs)+ph-thinw,-bs/2 - kl/2 + thinl])
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
    
        translate([-bs/2,ph-w,ly])
        translate([bs+pth,0,0])
        translate([0,bs/2,-kl/2 -bs/2])
        translate([-bs/2,0,bs/2])
        rotate([0,gamma,0])
        translate([bs/2,0,-bs/2])
        cube([bs,bs,bs], center=true);

        keytipthin();
}
