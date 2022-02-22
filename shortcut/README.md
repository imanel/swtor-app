This directory contains information used in creating the shortcut used in for SWTOR On Mac

CLI command to create shortcut:

`sh appify.sh --script SWTOR.sh --icons MyIcon.icns --name "SWTOR"`

* appify.sh - Script that bundles `MyIcon.icns` + `SWTOR.sh` into an Application.
* SWTOR.sh - Script that tries to find where `launcher.exe` from SWTOR is located using `find` and commands `wine`/`wine32on64` to execute it. 
* MyIcon.icns - Icon set used for the shortcut