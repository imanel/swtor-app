#!/usr/bin/env arch -x86_64 bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
RESOURCES_DIR="$(dirname "$SCRIPT_DIR")/Resources"

PREFIX_DIR="$RESOURCES_DIR/prefix"
SWTOR_LAUNCHER_DIR="$PREFIX_DIR/drive_c/Program Files/Electronic Arts/BioWare/Star Wars - The Old Republic/"

STANDALONE_WINE="$RESOURCES_DIR/wine/bin/wine"
M1_HOMEBREW_WINE="/opt/homebrew/bin/wine"
INTEL_HOMEBREW_WINE="/usr/local/bin/wine"

if [[ -f "$STANDALONE_WINE" ]]; then
  WINE="$STANDALONE_WINE"
elif [[ -f "$M1_HOMEBREW_WINE" ]]; then
  WINE="$M1_HOMEBREW_WINE"
else
  WINE="$INTEL_HOMEBREW_WINE"
fi

WINEPREFIX=$PREFIX_DIR $WINE "$SWTOR_LAUNCHER_DIR/launcher.exe" > ~/Library/Logs/SWTOR.log 2>&1
