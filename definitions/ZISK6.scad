// Key length
kl=28;

// Combination cuts

// Shoulder
aspace = 4.4;

// Pin distance
pinspace = 3.7;

// Highest cut
hcut = ph - 2*tol - 4.04; // Some databases say the deepest cut is 4.14
                          // but I think given measurements on new keys
                          // the correct value is 4.04.

 // Cut spacing
cutspace = 0.215; // Actually it uses alternating 0.21/0.22 cuts
odd_cutspace_corr = -0.05; // This corrects the alternating cuts if we are on an odd cut.

lasercut_corr =  0.2; // This corrects for the fact, that in this lock system, the pin
                      // does not rest with its tip on the key, but with its shoulders.
                      // Removing the shoulders of the cut in lasercut therefore needs
                      // a small correction.

// Cut angle
cutangle = 110;

// Plateau spacing of the cut
platspace = 0.3;
