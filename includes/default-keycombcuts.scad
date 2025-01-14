include <regularcut.scad>;

module keycombcuts(laser=false, realdim=false) {
   for (i = [0:len(keycomb)-1]) {
     keycombcut(i, keycomb[i], aspace, laser, realdim=realdim);
   }
   if (laser) {
     keycombcuts_laser(realdim=realdim);
   }
}

module keycombcuts_laser(realdim=false) {
   for (i = [0:len(keycomb)-1]) {
     if (i < len(keycomb)-1) {
       hull() {
         keycombcut(i, keycomb[i], aspace, true, false, true, realdim=realdim);
         keycombcut(i+1, keycomb[i+1], aspace, true, true, false, realdim=realdim);
       }
     }
   }
   hull() {
     keycombcut(len(keycomb)-1, keycomb[len(keycomb)-1], aspace, true, false, true, realdim=realdim);
     translate([0,0,-kl])
       keycombcut(len(keycomb)-1, keycomb[len(keycomb)-1], aspace, true, false, true, realdim=realdim);
   }
}
