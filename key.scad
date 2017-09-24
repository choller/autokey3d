include <settings.scad>;

$fn = 100;

// For debugging purposes only, you can override particular
// profile or system definitions directly in the program, e.g.:
//
//cutangle = 100;
//platspace = 0.0;
//bump_addcutdepth = 0.0;

// Do not change anything below unless you know what you are doing

addaspace = bumpkey ? bump_addaspace : 0.0;
addplatspace = bumpkey ? bump_addplatspace : 0.0;
addcutdepth = bumpkey ? bump_addcutdepth : 0.0;

keycomb = bumpkey ? [0,0,0,0,0,0] : combination;

module keycombcuts() {
   for (i = [0:len(keycomb)-1]) { 
     keycombcut(i, keycomb[i]);
   }
}

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

module branding(h) {
  linear_extrude(height=h,center=true)
  import("branding/branding.dxf");
}

module rawprofile(h) {
  if (h > 0) {
    linear_extrude(height=h,center=true)
    import("profile.dxf");
  } else {
    import("profile.dxf");
  }
}

module profile() {
   /*
		We first create the difference between our extruded profile
		and a bounding box (called the "negative"), and then we use
		that negative to cut our blank out of another bounding box.
		It's necessary to take this detour because we cannot
		thin using minkowski, but we can thicken the negative
		which means thinning the key blank of course.
   */
   if (tol > 0) {
       if (use2DThinning) {
         linear_extrude(height=csz+1,center=true)
         difference() {
		translate([-csx/4,-csy/4])
		  square([csx,csy]);
		minkowski() {
			difference() {
				translate([-csx/4,-csy/4])
				square([csx,csy]);
				resize([0,ph,0],auto=[true,true,false],center=true)
					rawprofile(0);
			}
			circle(r=tol);
		}
	 }
       } else {
	difference() {
		translate([-csx/4,-csy/4,-csz/4])
		  cube([csx,csy,1]);
		minkowski() {
			difference() {
				translate([-csx/4,-csy/4,-csz/4])
				cube([csx,csy,csz]);
				resize([0,ph,0],auto=[true,true,false],center=true)
					rawprofile(csz+1);
			}
			cylinder(r=tol, h=0.1);
		}
	}
       }
   } else {
      resize([0,ph,0],auto=[true,true,false],center=true)
          rawprofile(csz+1);
   }
}

module keytipcut(gamma, negrot, yfactor) {
	// Dimensions of the box we use for cutting
	bsx=10;
	bs=20;

	// Calculate y and z offsets of the right lower corner of our cut box
	rsq = sqrt(2*(bs/2)*(bs/2)); // Length from box center to corner
	hyp = sqrt(2*rsq*rsq *(1-cos(gamma))); // Distance between old corner and new corner
	alpha = 180-45-90+gamma/2; // Angle across the z-movement vector
	beta = 90-alpha; // Angle across the y-movement vector
	a = hyp * sin(alpha); // Length of the z-movement
	b = (negrot ? -1 : 1) * hyp * sin(beta); // Length of the y-movement

	translate([-bsx/4 + bsx/2,-bs/4 + bs/2 * yfactor + b,-kl/2 - bs + bs/2 + a])
		rotate([negrot ? 360-gamma : gamma,0,0])
			cube([bsx,bs,bs], center=true);
}

rotate([270,180,0])
union() {
	difference() {
		/* Create the uncut blank */
		resize([0,0,kl]) profile();

		/* Make the upper cut in the key tip */
		keytipcut(40,false,2.1);

		/* Make the lower cut in the key tip */
		keytipcut(45,true,0);

        if (!blank) {
            keycombcuts();
        }
	}

	// Key handle connector
	translate([khcxoff,-(khcy-ph)/2,kl/2]) //Add +0.1 to z here to check that handle is exact
	cube([khcx,khcy,khcz]);

   
	// Key handle
	translate([0,-khy/4,kl/2+khcz]) //Add +0.1 to z here to check that handle is exact
	cube([khx,khy,khz]);

	// Branding
	translate([khx+0.1,-khy/4 + 0.1*khy,kl/2+khcz+0.4*khz])
	resize([0,0.8*khy,0],auto=[false,true,true],center=true)
	rotate([90,0,90])
	branding(bh);
}
