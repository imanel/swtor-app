#!/usr/bin/env arch -x86_64 bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PREFIX_DIR="$SCRIPT_DIR/../Resources/prefix"
SWTOR_LAUNCHER_DIR="$PREFIX_DIR/drive_c/Program Files/Electronic Arts/BioWare/Star Wars - The Old Republic/"

WINEPREFIX=$PREFIX_DIR /opt/homebrew/bin/wine "$SWTOR_LAUNCHER_DIR/launcher.exe" > ~/Library/Logs/SWTOR.log 2>&1
