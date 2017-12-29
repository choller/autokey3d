#!/usr/bin/env python
# encoding: utf-8
'''
AutoKey -- Tool to print 3D blanks, keys and bump-keys

@author:     Christian Holler (:decoder)

@license: Creative Commons BY-NC-SA 4.0 (see LICENSE)

http://creativecommons.org/licenses/by-nc-sa/4.0/

@contact:    decoder@own-hero.net
'''

# Ensure print() compatibility with Python 3
from __future__ import print_function

import sys
import os
import argparse
import shutil
import subprocess
import re

cv2_available = True

try:
    import numpy as np
    import cv2
except ImportError:
    cv2_available = False

inkscape_autotrace_avail = True
try:
    subprocess.check_call(["inkscape", "--version"])
    subprocess.check_call(["potrace", "--version"])
except:
    inkscape_autotrace_avail = False

__version__ = 1.1

BASE_DIR = os.path.dirname(os.path.realpath(__file__))
BRAND_DIR = os.path.join(BASE_DIR, "branding")

# Isolate globals
BLUE = [255,0,0]        # rectangle color
BLACK = [0,0,0]         # sure BG
WHITE = [255,255,255]   # sure FG
DRAW_BG = {'color' : BLACK, 'val' : 0}
DRAW_FG = {'color' : WHITE, 'val' : 1}
rect = (0,0,1,1)
drawing = False         # flag for drawing curves
rectangle = False       # flag for drawing rect
rect_over = False       # flag to check if rect drawn
rect_or_mask = 100      # flag for selecting rect or mask mode
value = DRAW_FG         # drawing initialized to FG
thickness = 3           # brush thickness
(img,img2,mask) = (None, None, None)
(at_ct, at_lt, at_cat, at_cs, at_lrt) = (100, 10, 60, 50, 1)

def isolate(filename, out_filename):
    global img,img2,drawing,value,mask,rectangle,rect,rect_or_mask,ix,iy,rect_over
    # Parts of this code are taken from OpenCV2 grabcut example,
    # licensed under BSD License.
    #
    # Original Code: https://github.com/opencv/opencv/blob/master/samples/python/grabcut.py
    # License: https://github.com/opencv/opencv/blob/master/LICENSE

    img = cv2.imread(filename)
    img2 = img.copy()                               # a copy of original image
    mask = np.zeros(img.shape[:2],dtype = np.uint8) # mask initialized to PR_BG
    output = np.zeros(img.shape,np.uint8)           # output image to be shown
    svg = np.zeros(img.shape,np.uint8)
    bwimg = np.zeros(img.shape,np.uint8)

    def onmouse(event, x, y, flags, param):
        global img,img2,drawing,value,mask,rectangle,rect,rect_or_mask,ix,iy,rect_over

        # Draw Rectangle
        if event == cv2.EVENT_RBUTTONDOWN:
            rectangle = True
            ix,iy = x,y

        elif event == cv2.EVENT_MOUSEMOVE:
            if rectangle == True:
                img = img2.copy()
                cv2.rectangle(img,(ix,iy),(x,y),BLUE,2)
                rect = (ix,iy,abs(ix-x),abs(iy-y))
                rect_or_mask = 0

        elif event == cv2.EVENT_RBUTTONUP:
            rectangle = False
            rect_over = True
            cv2.rectangle(img,(ix,iy),(x,y),BLUE,2)
            rect = (ix,iy,abs(ix-x),abs(iy-y))
            rect_or_mask = 0
            print("Now press the key 'n' a few times until no further change.")

        if event == cv2.EVENT_LBUTTONDOWN:
            if rect_over == False:
                print("Use the right mouse button to draw a rectangle first.")
            else:
                drawing = True
                cv2.circle(img,(x,y),thickness,value['color'],-1)
                cv2.circle(mask,(x,y),thickness,value['val'],-1)

        elif event == cv2.EVENT_MOUSEMOVE:
            if drawing == True:
                cv2.circle(img,(x,y),thickness,value['color'],-1)
                cv2.circle(mask,(x,y),thickness,value['val'],-1)

        elif event == cv2.EVENT_LBUTTONUP:
            if drawing == True:
                drawing = False
                cv2.circle(img,(x,y),thickness,value['color'],-1)
                cv2.circle(mask,(x,y),thickness,value['val'],-1)

    # input and output windows
    cv2.namedWindow('output')
    cv2.namedWindow('input')
    cv2.setMouseCallback('input',onmouse)
    cv2.moveWindow('input',img.shape[1]+10,90)

    def update_at_ct(val):
        global at_ct
        at_ct = val

    def update_at_lt(val):
        global at_lt
        at_lt = val

    def update_at_cat(val):
        global at_cat
        at_cat = val

    def update_at_cs(val):
        global at_cs
        at_cs = val

    def update_at_lrt(val):
        global at_lrt
        at_lrt = val

    def update_out():
        global res
        bar = np.zeros((img.shape[0],5,3),np.uint8)
        res = np.hstack((img2,bar,img,bar,output,bar,svg))
        cv2.imshow('Traced Profile', res)

    def empty():
        pass

    update_out()
    #cv2.createTrackbar( "CT", "Traced Profile", at_ct, 180, update_at_ct )
    #cv2.createTrackbar( "CAT", "Traced Profile", at_cat, 100, update_at_cat )
    #cv2.createTrackbar( "CS", "Traced Profile", at_cs, 100, update_at_cs )
    #cv2.createTrackbar( "LT", "Traced Profile", at_lt, 100, update_at_lt )
    #cv2.createTrackbar( "LRT", "Traced Profile", at_lrt, 100, update_at_lrt )


    while(1):
        update_out()
        cv2.imshow('input',img)
        k = 0xFF & cv2.waitKey(1)

        # key bindings
        if k == 27:         # esc to exit
            break
        elif k == ord('0'): # BG drawing
            print("Mark lock (non-profile) regions with left mouse button.")
            value = DRAW_BG
        elif k == ord('1'): # FG drawing
            print("Mark keyway (profile) regions with left mouse button.")
            value = DRAW_FG
        elif k == ord('s'): # save image
            cv2.imwrite('grabcut_summary.png',res)
            cv2.imwrite('grabcut_output.png',bwimg)

            subprocess.check_call(["inkscape", "--verb=FitCanvasToDrawing", "--verb=FileSave", "--verb=FileQuit", "tmp.svg"])
            shutil.copy("tmp.svg", out_filename)
            break

        elif k == ord('r'): # reset everything
            print("Reset.")
            rect = (0,0,1,1)
            drawing = False
            rectangle = False
            rect_or_mask = 100
            rect_over = False
            value = DRAW_FG
            img = img2.copy()
            mask = np.zeros(img.shape[:2],dtype = np.uint8) # mask initialized to PR_BG
            output = np.zeros(img.shape,np.uint8)           # output image to be shown
        elif k == ord('n'): # segment the image
            print("For finer touchups, mark lock and keyway after pressing keys 0 and 1, then press 'n' again.")
            if (rect_or_mask == 0):         # grabcut with rect
                bgdmodel = np.zeros((1,65),np.float64)
                fgdmodel = np.zeros((1,65),np.float64)
                cv2.grabCut(img2,mask,rect,bgdmodel,fgdmodel,1,cv2.GC_INIT_WITH_RECT)
                rect_or_mask = 1
            elif rect_or_mask == 1:         # grabcut with mask
                bgdmodel = np.zeros((1,65),np.float64)
                fgdmodel = np.zeros((1,65),np.float64)
                cv2.grabCut(img2,mask,rect,bgdmodel,fgdmodel,1,cv2.GC_INIT_WITH_MASK)
        elif k == ord('m'):
            cv2.imwrite('tmp.pbm',bwimg)
            subprocess.check_call([
                "potrace",
                "tmp.pbm",
                "--tight", "-s",
                "-o", "tmp.svg"
            ])
            subprocess.check_call(["inkscape", "-h", str(img.shape[0]), "-b", "white", "-e", "tmp.png", "tmp.svg"])
            svg = cv2.imread("tmp.png")

            mh = img.shape[0] - svg.shape[0]
            mw = img.shape[1] - svg.shape[1]

            # FIXME: This is only a temporary hack so we don't crash if the
            # rendered SVG is larger than the original picture.
            if mh <= 0:
              mh = 0
            if mw <= 0:
              mw = 0

            svg = cv2.copyMakeBorder(svg, mh/2, mh/2 + mh % 2, mw/2, mw/2 + mw % 2, cv2.BORDER_CONSTANT, value=(255, 255, 255, 255))

        mask2 = np.where((mask==1) + (mask==3),255,0).astype('uint8')
        output = cv2.bitwise_and(img2,img2,mask=mask2)

        blackMask = np.where((mask==1) + (mask==3),255,0).astype('uint8')
        whiteMask = np.where((mask==0) + (mask==2),255,0).astype('uint8')

        bwimg = np.zeros(output.shape, np.uint8)
        bwimg[blackMask == 255] = 0
        bwimg[whiteMask == 255] = 255

        output[whiteMask == 255] = (0,0,255)

    cv2.destroyAllWindows()
    return

def main(argv=None):
    '''Command line options.'''

    program_name = "AutoKey3D"
    program_version = "v%s" % __version__

    program_version_string = '%s %s' % (program_name, program_version)

    if argv is None:
        argv = sys.argv[1:]

    # setup argparser
    parser = argparse.ArgumentParser()

    parser.add_argument('--version', action='version', version=program_version_string)

    # Actions
    parser.add_argument("--bumpkey", dest="bumpkey", action='store_true', help="Create a bumpkey")
    parser.add_argument("--blank", dest="blank", action='store_true', help="Create a key blank")
    parser.add_argument("--key", dest="key", help="Create a key with specified combination (comma-separated numbers)", metavar="COMBINATION")
    parser.add_argument("--isolate", dest="isolate", help="Interactively isolate profile from raw picture (EXPERIMENTAL)", metavar="FILE")

    # Settings
    parser.add_argument("--definition", dest="definition", required=False, help="Path to the definition file to use", metavar="FILE")
    parser.add_argument("--profile", dest="profile", required=True, help="Path to the profile file to read/write", metavar="FILE")
    parser.add_argument("--tolerance", dest="tol", required=False, help="Override tolerance with specified value", metavar="TOL")
    parser.add_argument("--branding-model", dest="branding_model", required=False, help="Override model used in branding text", metavar="MODEL")
    parser.add_argument("--thin-handle", dest="thin_handle", action='store_true', required=False, help="Use a thin handle suitable for impressioning grips")

    parser.add_argument('args', nargs=argparse.REMAINDER)

    if len(argv) == 0:
        parser.print_help()
        return 2

    # process options
    opts = parser.parse_args(argv)

    # Check that one action is specified
    actions = [ "bumpkey", "blank", "key", "isolate" ]

    haveAction = False
    for action in actions:
        if getattr(opts, action):
            if haveAction:
                print("Error: Cannot specify multiple actions at the same time", file=sys.stderr)
                return 2
            haveAction = True
    if not haveAction:
        print("Error: Must specify at least one of these actions: %s" % " ".join(actions), file=sys.stderr)
        return 2

    if opts.isolate:
        if not cv2_available:
            print("Error: --isolate requires cv2 (python-opencv) and numpy (python-numpy) to be installed.", file=sys.stderr)
            return 2
        elif not inkscape_autotrace_avail:
            print("Error: --isolate requires inkscape and potrace to be installed.", file=sys.stderr)
            return 2
        if os.path.exists(opts.profile):
            print("Error: Refusing to overwrite existing --profile destination file.", file=sys.stderr)
            return 2
        return isolate(opts.isolate, opts.profile)

    if not opts.definition:
        print("Error: --definition is required for specified action.", file=sys.stderr)

    # Do the key branding
    with open(os.path.join(BRAND_DIR, "branding-template.svg"), 'r') as f:
        branding = f.read()
    model = os.path.basename(opts.definition).replace(".scad", "")
    if opts.branding_model:
      model = opts.branding_model

    # Read system definition
    with open(opts.definition, 'r') as f:
        definition = f.read()

    need_default_keycombcuts = not "module keycombcuts()" in definition
    need_default_keytipcuts = not "module keytipcuts()" in definition

    # Read profile definition
    profile_definition_file = "%s.def" % opts.profile.replace(".svg", "")
    with open(profile_definition_file, 'r') as f:
        profile_definition = f.read()

    khcx_override = "khcx" in profile_definition

    def_tol = None
    def_kl = None

    # Look for length in system definition for branding
    for line in definition.splitlines():
        m = re.match("\s*kl\s*=\s*([\d\.]+)\s*;", line)
        if m:
          def_kl = m.group(1)
          next

    # Look for tolerance in profile definition for branding
    for idx,line in enumerate(profile_definition.splitlines()):
        m = re.match("\s*tol\s*=\s*([\d\.]+)\s*;", line)
        if m:
          def_tol = m.group(1)
          def_tol_idx = idx
          next

    if def_kl is None:
      print("Error: Failed to find key length in system definition file")
      sys.exit(1)

    if def_tol is None:
      print("Error: Failed to find key length in system definition file")
      sys.exit(1)

    if opts.tol:
        lines = profile_definition.splitlines()
        lines[def_tol_idx] = "tol = %s;" % opts.tol
        profile_definition = "\n".join(lines)
        def_tol = opts.tol

    branding = branding.replace("%model%", model)
    branding = branding.replace("%length%", "%s" % def_kl)
    branding = branding.replace("%tol%", "%s" % def_tol)
    with open(os.path.join(BRAND_DIR, "branding.svg"), 'w') as f:
        f.write(branding)

    DEVNULL = open(os.devnull, 'w')

    subprocess.check_call(["inkscape", "-E", os.path.join(BRAND_DIR, "branding.eps"), os.path.join(BRAND_DIR, "branding.svg"),])
    subprocess.check_call(["pstoedit", "-dt", "-f", "dxf:-polyaslines", os.path.join(BRAND_DIR, "branding.eps"), os.path.join(BRAND_DIR, "branding.dxf")], stderr=DEVNULL)

    # Read base settings
    with open(os.path.join(BASE_DIR, "base-settings.scad"), 'r') as f:
        baseSettings = f.read()

    if khcx_override:
        baseSettings = baseSettings.replace("khcx=", "//khcx=")

    # Compose real settings
    with open(os.path.join(BASE_DIR, "settings.scad"), 'w') as f:
        f.write("/* AUTO-GENERATED FILE - DO NOT EDIT */\n\n")

        if opts.bumpkey:
            f.write("bumpkey = true;\n")
        else:
            f.write("bumpkey = false;\n")

        if opts.blank:
            f.write("blank = true;\n")
        else:
            f.write("blank = false;\n")

        if opts.key:
            f.write("combination = [%s];\n" % opts.key)
        else:
            f.write("combination = 0;\n")

        if opts.thin_handle:
            f.write("thin_handle = true;\n")
        else:
            f.write("thin_handle = false;\n")

        f.write(profile_definition)
        f.write("\n")
        f.write(definition)
        f.write("\n")

        f.write(baseSettings)
        f.write("\n")

        if need_default_keytipcuts:
            f.write("include <includes/default-keytipcuts.scad>;")
            f.write("\n")

        if need_default_keycombcuts:
            f.write("include <includes/default-keycombcuts.scad>;")
            f.write("\n")

    subprocess.check_call(["inkscape", "-E", os.path.join(BASE_DIR, "profile.eps"), opts.profile])
    subprocess.check_call(["pstoedit", "-dt", "-f", "dxf:-polyaslines", os.path.join(BASE_DIR, "profile.eps"), os.path.join(BASE_DIR, "profile.dxf")], stderr=DEVNULL)
    subprocess.check_call(["/usr/bin/openscad", os.path.join(BASE_DIR, "key.scad") ])


if __name__ == "__main__":
    sys.exit(main())
