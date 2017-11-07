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

__version__ = 1.1

BASE_DIR = os.path.dirname(os.path.realpath(__file__))
BRAND_DIR = os.path.join(BASE_DIR, "branding")

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

    # Settings
    parser.add_argument("--definition", dest="definition", required=True, help="Path to the definition file to use", metavar="FILE")
    parser.add_argument("--profile", dest="profile", required=True, help="Path to the profile file to use", metavar="FILE")
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
    actions = [ "bumpkey", "blank", "key" ]

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
