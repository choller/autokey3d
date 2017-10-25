// This is generic code for 4 axis dimple cutting

module dimplecut(
    kt, /* Key thickness */
    aspace, /* Distance of axis to stop */
    pinspace, /* Distance between pins */
    lcut, /* Depth of lowest cut */
    cutspace, /* Depth of one cut step */
    cutangle, /* Cut Angle */
    cutnum, /* Cut Number */
    cutlevel, /* Cut Level (0 no cut, 1 lowest, ...) */
    axis, /* Cut axis */
    px, /* Distance of axis to edge */
    d1, /* Lower diameter of the cutter (tip diameter) */
    d2, /* Upper diameter of the cutter */
    zcorr, /* Correction value in cut direction */
    ) {
        
    gamma = (360-2*cutangle) / 4; // Ramp angle for making the cutter
    lcutter = 10; // Length of cutter shaft
    
    h = (d2 - d1)/2 / sin(gamma) * sin(90-gamma);
    
    ocs = (axis == 1 || axis == 2) ? 0 : 1; // on center side?
    neg = (ocs == 1) ? 1 : -1;
    mx = (ocs == 1) ? 0 : 1;
    vtrans = axis > 1 ? -ph + 2*px : 0;
    passive = axis % 2 ? 1 : 0;
    
    cutdepth = cutlevel > 0 ? lcut + (cutlevel-1)*cutspace : 0;
    
    translate([ - cutdepth * neg,0,0]) // comment this out for calibration
    translate([ocs*zcorr,0,0])
    translate([0,vtrans,0])
    translate([neg*(h/2) + ocs*kt,ph-px,kl/2 - aspace - cutnum*pinspace])
    mirror([mx,0,0])
    rotate([0,90,0])
    union() {
        cylinder(h, d1/2, de/2, center=true);
        translate([0,0,lcutter/2 + h/2])
        cylinder(lcutter,de/2,de/2,center=true);
    }
}
