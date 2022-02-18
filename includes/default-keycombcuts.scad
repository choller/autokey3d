include <regularcut.scad>;

module keycombcuts(laser=false) {
   for (i = [0:len(keycomb)-1]) { 
     keycombcut(i, keycomb[i], aspace, laser);
   }
   if (laser) {
     keycombcuts_laser();
   }
}

module keycombcuts_laser() {
   for (i = [0:len(keycomb)-1]) {
     if (i < len(keycomb)-1) {
       hull() {
         keycombcut(i, keycomb[i], aspace, true, false, true);
         keycombcut(i+1, keycomb[i+1], aspace, true, true, false);
       }
     }
   }
   hull() {
     keycombcut(len(keycomb)-1, keycomb[len(keycomb)-1], aspace, true, false, true);
     translate([0,0,-kl])
       keycombcut(len(keycomb)-1, keycomb[len(keycomb)-1], aspace, true, false, true);
   }
}
