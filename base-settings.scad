use2DThinning = true; // Only use 2D thinning with a version > 2014.03

/* 
 * The following settings are internal. Play with them at your own risk 
 */

// Key handle connector data
khcx=3; // This parameter must be adjusted to barely fit all of the key profile,
        // or even smaller if the core requires this
khcy=ph+1; // This should always fit, as we know the profile height
khcz=5; // This is just the length of the connector
khcxoff = 0.2; // Adjustment of the key handle connector in x-direction

// Key handle data
khx=5;
khy=20;
khz=20;

// Branding on the key
bh=0.2;

// Boundaries when cutting the key
csx=10;
csy=20;
csz=2;
