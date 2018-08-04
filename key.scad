include <settings.scad>;

$fn = 100;

// For debugging purposes only, you can override particular
// profile or system definitions directly in the program, e.g.:
//
//cutangle = 100;
//bumpkey = 1;
//platspace = 0.0;
//bump_addcutdepth = 0.0;
//bump_addaspace = 0.0;

// Do not change anything below unless you know what you are doing

addaspace = bumpkey ? bump_addaspace : 0.0;
addplatspace = bumpkey ? bump_addplatspace : 0.0;
addcutdepth = bumpkey ? bump_addcutdepth : 0.0;

keycomb = bumpkey ? [0,0,0,0,0,0] : combination;

nohandle = false;
lasercut = false;
mark = false;

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

rotate([270,180,0])
union() {
	difference() {
        /* Create the uncut blank and make sure it is zero-aligned with y-axis */
        translate([-tol,0,0])
        resize([0,0,kl]) profile();

		/* Cut the key tip */
		keytipcuts();

        if (!blank) {
            keycombcuts(lasercut);
		}
	}
	khcyo = -(khcy-ph)/2;
	khyo = khcyo - (khy-khcy)/2;

	// Key handle connector
	translate([khcxoff,khcyo,kl/2]) //Add +0.1 to z here to check that handle is exact
	cube([khcx,khcy,khcz]);
    
    if (mark) {
      translate([khcxoff,khcyo,kl/2])
      translate([khcx,khcy/2,khcz/2])
      sphere(r=khcx/4);
    }

    if (!nohandle) {
	  // Key handle
	  translate([khcxoff,khyo,kl/2+khcz]) //Add +0.1 to z here to check that handle is exact
	  cube([khx,khy,khz]);

	  // Branding
	  khzb = thin_handle ? khz*0.1 : khz*0.5 - 1;
	  translate([khcxoff+khx+0.1,khyo + 0.1*khy,kl/2+khcz+khzb])
	  resize([0,0.8*khy,0],auto=[false,true,true],center=true)
	  rotate([90,0,90])
	  branding(bh);
    }
}
