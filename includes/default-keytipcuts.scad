module keytipcut_old(gamma, negrot, yfactor) {
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

module keytipcuts() {
        /* Make the upper cut in the key tip */
        keytipcut_old(40,false,2.1);

        /* Make the lower cut in the key tip */
        keytipcut_old(45,true,0);
}

