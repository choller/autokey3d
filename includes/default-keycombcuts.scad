module keycombcut(cutnum, cutlevel) {
   cutdim = 10;
   d = cutdim / sqrt(2); // Diagonal of the cutting rect

   rotangle1 = cutangle / 2;
   rotangle2 = -rotangle1; // Correction calculations are for clockwise rotation

   // Rotational correction factors:
   // The edge of the rotating cube touching the key will stick in place
   // no matter what rotations are applied. This ensures the correct plateau
   // spacing and the correct cutting position, independent of the cut angle.
   ycorrect = d * sin(rotangle2) / cos(rotangle2/2) * sin(45+rotangle2/2);
   zcorrect = d * sin(-rotangle2) / cos(-rotangle2/2) * sin(45-rotangle2/2);

   translate([0, addcutdepth + hcut-(cutlevel*cutspace), 0])
   translate([0,0,(aspace + addaspace + cutnum*pinspace)*-1])  // Pin position
   translate([0,-cutdim/2 + tol, -cutdim/2 + kl/2]) // Center the cutter at 0. We need to add the tolerance to reach the lower end of the thinned key.
   
   translate([0,0,platspace/2]) // Center the original plateau over the pin
   hull() {
   translate([0, ycorrect, zcorrect])
     rotate([-rotangle1,0,0])
	   cube([cutdim,cutdim,cutdim], center=true);

   translate([0, ycorrect, -zcorrect+cutdim])
     translate([0,0,-platspace-addplatspace])
       rotate([rotangle1,0,0])
	     cube([cutdim,cutdim,cutdim], center=true);
   }
}

module keycombcuts() {
   for (i = [0:len(keycomb)-1]) { 
     keycombcut(i, keycomb[i]);
   }
}
