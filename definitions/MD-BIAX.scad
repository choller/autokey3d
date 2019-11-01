// NOTE: This definition expects two combination values per pin, one is the depth,
// the other one is the rotation. Valid rotation values are (in L, C, R order):
//
//   * K,B or Q for FORE pins
//   * M,D or S for AFT pins
//
// Example combination with 6 pins: 3,S,5,K,4,Q,2,K,2,Q,0,D
//   (first and last pin are AFT pins, the rest is FORE)

// Key length
kl=33.2;

// Shoulder(s) for FORE and AFT
aspaces = [5.41, 6.99];

// Pin distance
pinspace = 4.32;

// Highest cut
hcut = ph - 2*tol - 3.73;

 // Cut spacing
cutspace = 0.635; // Actually alternating between 0.63/0.64

// Cut angle
cutangle = 86;

// Plateau spacing of the cut
platspace = 0.38;

kt = 2.3; // Key thickness

add_angle = 0; // Additional rotation angle

include <includes/regularcut.scad>;

module keycombcuts() {
   for (i = [0:2:len(keycomb)-1]) {
     rotval = keycomb[i+1];

     if (rotval == "K") {
       keycombcut(i/2, keycomb[i], aspaces[0], false, false, false, -20 - add_angle, kt/2);
     } else if (rotval == "B") {
       keycombcut(i/2, keycomb[i], aspaces[0], false, false, false, 0, kt/2);
     } else if (rotval == "Q") {
       keycombcut(i/2, keycomb[i], aspaces[0], false, false, false, 20 + add_angle, kt/2);
     } else if (rotval == "M") {
       keycombcut(i/2, keycomb[i], aspaces[1], false, false, false, -20 - add_angle, kt/2);
     } else if (rotval == "D") {
       keycombcut(i/2, keycomb[i], aspaces[1], false, false, false, 0, kt/2);
     } else if (rotval == "S") {
       keycombcut(i/2, keycomb[i], aspaces[1], false, false, false, 20 + add_angle, kt/2);
     } else {
       assert(false, "Unsupported rotation value");
     }

   }
}
