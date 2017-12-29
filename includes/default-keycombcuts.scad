module keycombcut(cutnum, cutlevel, lcut1=false, lcut2=false) {
   lcut = lcut1 || lcut2;
   cutdim = 10;
   d = cutdim / sqrt(2); // Diagonal of the cutting rect

   // Allow correcting on odd cutlevels for alternating cuts
   cutcorr = cutlevel % 2 > 0 ? odd_cutspace_corr : 0;

   rotangle1 = cutangle / 2;
   rotangle2 = -rotangle1; // Correction calculations are for clockwise rotation

   // Rotational correction factors:
   // The edge of the rotating cube touching the key will stick in place
   // no matter what rotations are applied. This ensures the correct plateau
   // spacing and the correct cutting position, independent of the cut angle.
   ycorrect = d * sin(rotangle2) / cos(rotangle2/2) * sin(45+rotangle2/2);
   zcorrect = d * sin(-rotangle2) / cos(-rotangle2/2) * sin(45-rotangle2/2);

   translate([0, addcutdepth + hcut-(cutlevel*cutspace + cutcorr), 0])
   translate([0,0,(aspace + addaspace + cutnum*pinspace)*-1])  // Pin position
   translate([0,-cutdim/2 + tol, -cutdim/2 + kl/2]) // Center the cutter at 0. We need to add the tolerance to reach the lower end of the thinned key.
   
   translate([0,0,platspace/2]) // Center the original plateau over the pin
   hull() {
   if (!lcut || lcut1) {
     // Towards handle
     translate([0, ycorrect, zcorrect])
       rotate([-rotangle1,0,0])
	   cube([cutdim,cutdim,cutdim], center=true);
   }

   if (!lcut || lcut2) {
     // Towards tip of key
     translate([0, ycorrect, -zcorrect+cutdim])
       translate([0,0,-platspace-addplatspace])
         rotate([rotangle1,0,0])
	     cube([cutdim,cutdim,cutdim], center=true);
     }
   }
}

module keycombcuts() {
   for (i = [0:len(keycomb)-1]) { 
     keycombcut(i, keycomb[i]);
   }
}

module keycombcuts_laser() {
   for (i = [0:len(keycomb)-1]) {
     if (i < len(keycomb)-1) {
       hull() {
         keycombcut(i, keycomb[i], false, true);
         keycombcut(i+1, keycomb[i+1], true, false);
       }
     }
   }
   hull() {
     keycombcut(len(keycomb)-1, keycomb[len(keycomb)-1], false, true);
     translate([0,0,-kl])
       keycombcut(len(keycomb)-1, keycomb[len(keycomb)-1], false, true);
   }
}
