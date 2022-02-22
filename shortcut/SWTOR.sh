#!/usr/bin/env arch -x86_64 bash

export PATH="/usr/local/bin:$PATH"
MACOS_CATALINA=1015
CURRENT_VERSION=$(sw_vers -productVersion | awk '{print $1}' | sed "s:.[[:digit:]]*.$::g")
export CURRENT_VERSION

if [[ $(echo "${CURRENT_VERSION}" | cut -d"." -f2 | wc -c) -eq 2 ]]; then
  CURRENT_VERSION_COMBINED=$(echo "${CURRENT_VERSION}" | cut -d"." -f1)0$(echo "${CURRENT_VERSION}" | cut -d"." -f2)
  export CURRENT_VERSION_COMBINED
else
	CURRENT_VERSION_COMBINED=$(echo "${CURRENT_VERSION}" | cut -d"." -f1)$(echo "${CURRENT_VERSION}" | cut -d"." -f2)
	export CURRENT_VERSION_COMBINED
fi

# Oddness for reassigned PATH_TO_SWTOR_LAUNCHER comes from custom/express installation
if [[ CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
	PREFIX_LOCATION=$(dirname "$(find ~/ -path \*drive_c/Program\ Files/Electronic\ Arts -print -quit 2>/dev/null| tail -1 | grep -o '.*/drive_c')")
	PATH_TO_SWTOR_LAUNCHER="/drive_c/Program Files/Electronic Arts/BioWare/Star Wars - The Old Republic/"
	cd "$PREFIX_LOCATION$PATH_TO_SWTOR_LAUNCHER" || PATH_TO_SWTOR_LAUNCHER="/drive_c/Program Files/Electronic Arts/BioWare/Star Wars-The Old Republic/"
	WINEPREFIX=$PREFIX_LOCATION wine32on64 "$PREFIX_LOCATION$PATH_TO_SWTOR_LAUNCHER/launcher.exe"
else
	PREFIX_LOCATION=$(dirname "$(find ~/ -path \*drive_c/Program\ Files\ \(x86\)/Electronic\ Arts -print -quit 2>/dev/null| tail -1 | grep -o '.*/drive_c')")
	PATH_TO_SWTOR_LAUNCHER="/drive_c/Program Files (x86)/Electronic Arts/BioWare/Star Wars - The Old Republic/"
	cd "$PREFIX_LOCATION$PATH_TO_SWTOR_LAUNCHER" || PATH_TO_SWTOR_LAUNCHER="/drive_c/Program Files (x86)/Electronic Arts/BioWare/Star Wars-The Old Republic/"
	WINEPREFIX=$PREFIX_LOCATION wine "$PREFIX_LOCATION$PATH_TO_SWTOR_LAUNCHER/launcher.exe"
fi