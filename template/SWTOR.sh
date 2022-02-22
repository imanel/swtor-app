#!/usr/bin/env arch -x86_64 bash

export PATH="/usr/local/bin:$PATH"

# Oddness for reassigned PATH_TO_SWTOR_LAUNCHER comes from custom/express installation
PREFIX_LOCATION=$(dirname "$(find ~/ -path \*drive_c/Program\ Files/Electronic\ Arts -print -quit 2>/dev/null| tail -1 | grep -o '.*/drive_c')")
PATH_TO_SWTOR_LAUNCHER="/drive_c/Program Files/Electronic Arts/BioWare/Star Wars - The Old Republic/"
cd "$PREFIX_LOCATION$PATH_TO_SWTOR_LAUNCHER" || PATH_TO_SWTOR_LAUNCHER="/drive_c/Program Files/Electronic Arts/BioWare/Star Wars-The Old Republic/"
WINEPREFIX=$PREFIX_LOCATION wine "$PREFIX_LOCATION$PATH_TO_SWTOR_LAUNCHER/launcher.exe"
