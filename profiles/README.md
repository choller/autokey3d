# Profile data

This directory contains profile data in SVG format.

For each SVG profile, a profile definitions file must be added to specify the
profile height (`ph`) and the material strength that should be removed (`tol`) 
when transforming the SVG into a key.

The tolerance depends on the process of the profile extraction. If the profile
has been extracted from a keyway picture, then a tolerance of 0.2 (rarely 0.15 
or 0.25) is good. If the profile has been extracted from a key or a profile
trace representing the key, then a 0.0 tolerance (default) should be used.

The profile height is assumed to be measured on the lock, not on the key. If
you have key measures instead, you should add `2*tol` to your measurement to
compensate.

The format of the files should be:

`X-Y.svg` for the profile and `X-Y.def` for the respective definition file.

`X` is the brand name (e.g. ABUS)
`Y` is the profile name (e.g. AB1) if known, or the lock type if unknown.

## Extracting your own profile

Right now, the extraction process (from picture to profile trace), is still
manual. In some cases, an automated thresholding can work but I had many cases
where this did not work and created artifacts or other inaccuracy in the
resulting profile. Therefore, I recommend to do a little manual work in your
favorite image editing software. You can see an brief example of the process 
as part of my talk, using GIMP and Inkscape:

https://www.youtube.com/watch?v=3pSa0pslxpU#t=10m40s

## List of supported profiles

```
ABUS        - AB1     - ABUS default profile (e.g. C83)
ABUS        - AB95    - Default profile for the ABUS E20
ABUS        - TS5000  - Profile for the ABUS TS5000 and XP1 locks
ABUS        - V14     - Example profile taken from an ABUS V14
BKS         - BK1     - BKS default profile (e.g. PZ88)
CES         - CE41    - Newer CES default profile (e.g. CES 810)
IKON        - RZL3    - Example profile taken from an IKON SK6
```
