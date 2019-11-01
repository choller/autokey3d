// NOTE: This definition expects two combination values per pin, one is the depth,
// the other one is the rotation. Valid rotation values are (in L, C, R order).
//
// Example combination with 6 pins: 1,C,2,C,4,L,1,L,3,L,5,C

// Key length
kl=33.2;

// Shoulder
aspace = 6.2;

// Pin distance
pinspace = 4.325;

// Highest cut
hcut = ph - 2*tol - 2.74;

 // Cut spacing
cutspace = 0.76;

// Cut angle
cutangle = 86;

// Plateau spacing of the cut
platspace = 0.32;

kt = 2.3; // Key thickness

add_angle = 0; // Additional rotation angle

include <includes/regularcut.scad>;

module keycombcuts() {
   for (i = [0:2:len(keycomb)-1]) {
     rotval = keycomb[i+1];

     if (rotval == "L") {
       keycombcut(i/2, keycomb[i], aspace, false, false, false, -20 - add_angle, kt/2);
     } else if (rotval == "C") {
       keycombcut(i/2, keycomb[i], aspace, false, false, false, 0, kt/2);
     } else if (rotval == "R") {
       keycombcut(i/2, keycomb[i], aspace, false, false, false, 20 + add_angle, kt/2);
     } else {
       assert(false, "Unsupported rotation value");
     }

   }
}
