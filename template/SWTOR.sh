#!/usr/bin/env arch -x86_64 bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
RESOURCES_DIR="$(dirname "$SCRIPT_DIR")/Resources"

PREFIX_DIR="$RESOURCES_DIR/prefix"
SWTOR_LAUNCHER_DIR="$PREFIX_DIR/drive_c/Program Files/Electronic Arts/BioWare/Star Wars - The Old Republic/"

WINE_BIN="$RESOURCES_DIR/wine/bin/wine64"

WINEPREFIX=$PREFIX_DIR $WINE_BIN "$SWTOR_LAUNCHER_DIR/launcher.exe" > ~/Library/Logs/SWTOR.log 2>&1
