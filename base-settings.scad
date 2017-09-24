use2DThinning = true; // Only use 2D thinning with a version > 2014.03

// Bumping defaults
bump_addaspace = 1.5; // How much additional space to shoulder
bump_addplatspace = 0.4; // How much additional plateau space
bump_addcutdepth = 0.2; // How much additional cut depth

/* 
 * The following settings are internal. Play with them at your own risk 
 */

// Key handle data
khx= thin_handle ? 2.5 : 5;
khy= thin_handle ? 25 : 20;
khz= thin_handle ? 12 : 20;

// Branding on the key
bh=0.2;

// Boundaries when cutting the key
csx=10;
csy=20;
csz=2;

// Key handle connector data
if (khcx==undef) {
  khcx=3;        // This parameter must be adjusted to barely fit all of the 
                 // key profile, or even smaller if the core requires this.
                 // It can be overridden by the profile definitions file.
}
khcy=ph+1;     // This should always fit, as we know the profile height
khcz=5;        // This is just the length of the connector
khcxoff = 0.2; // Adjustment of the key handle connector in x-direction
