# System definitions

This directory contains definitions for various lock systems. A definition
file must always contain at least one property, that is the key length (`kl`).

Without this information, it would not be possible to create a blank with the
appropriate length obviously. All other properties are optional and only required
when creating regular keys or bump keys.

The following is a list of supported properties:

```
kl            - Length of the key
aspace        - Distance from shoulder to first pin
pinspace      - Distance between pins
hcut          - Highest (deepest) possible cut (*)
cutspace      - Distance between two adjacent cut depths (**)
cutangle      - Angle of the cut in degrees
platspace     - Flat space (plateau) between the cut ramps
```

`(*)` Measured from the side where the cut is made. Some databases measure this
from the opposite side. In that case, you should subtract your measurement from
the total key blank height and use the result.

`(**)` Some systems use unsupported alternating cut depths. If the alternation
isn't large though (e.g. some systems alternate by 0.05mm) then using the mean
of the two works well.
