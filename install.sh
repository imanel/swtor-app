#!/usr/bin/env arch -x86_64 bash

set -e

NONE='\033[00m'
PURPLE='\033[01;35m'
RED='\033[0;31m'
TOOLS_VERSION=$(xcode-select -p)
TOOLS_INSTALLED="/Library/Developer/CommandLineTools"
XCODE_CHECK=$(ls /Applications/Xcode.app) || : # set -e can cause the script to die here, so added || : to skip fail
XCODE_INSTALLED="Contents"
CURRENT_USER=$(whoami)
SWTOR_CUSTOM_SHORTCUT_LINK=https://github.com/AgentRG/swtor_on_mac/raw/master/SWTOR.zip
SWTOR_DOWNLOAD=http://www.swtor.com/download

create_temporary_downloads_folder() {
  echo -e "${PURPLE}\t(1/1) Creating temporary downloads folder\n${NONE}"
  mkdir /Users/"$CURRENT_USER"/swtor_tmp || :
}

install_package_wget() {
  echo -e "${PURPLE}\t(1/4) Installing wget${NONE}"
  brew install wget
}

tap_into_gcenx_brew() {
  echo -e "${PURPLE}\t(2/4) Tap into Gcenx/homebrew-wine${NONE}"
  brew tap Gcenx/homebrew-wine
}

install_package_wine_stable() {
  echo -e "${PURPLE}\t(3/4) Installing latest Wine version${NONE}"
  brew update
  brew install --cask --no-quarantine wine-crossover
}

install_package_winetricks() {
  echo -e "${PURPLE}\t(4/4) Installing Winetricks\n${NONE}"
  brew install winetricks
}

create_swtor_prefix() {
  echo -e "${PURPLE}\t(1/1) Creating "SWTOR On Mac" Wine prefix\n${NONE}"
  WINEARCH=win32 WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" wine wineboot
}

install_dll_vcrun2008() {
  echo -e "${PURPLE}\t(1/3) Installing vcrun2008${NONE}"
  env WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" sh winetricks -q vcrun2008
}

install_dll_crypt32() {
  echo -e "${PURPLE}\t(2/3) Installing crypt32${NONE}"
  env WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" sh winetricks -q crypt32
}

install_dll_d3dx9_36() {
  echo -e "${PURPLE}\t(3/3) Installing d3dx9_36\n${NONE}"
  env WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" sh winetricks -q d3dx9_36
}

set_vram() {
  echo -e "${PURPLE}\t(1/3) Setting prefix VRAM to 1024${NONE}"
  env WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" sh winetricks -q videomemorysize=1024
}

switch_windows_version() {
  echo -e "${PURPLE}\t(2/3) Switching Windows version to Windows 10${NONE}"
  env WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" sh winetricks -q win10
}

switch_all_dlls_to_builtin() {
  echo -e "${PURPLE}\t(3/3) Change all prefix DLLs to be builtin\n${NONE}"
  env WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" sh winetricks -q alldlls=builtin
}

download_swtor() {
  echo -e "${PURPLE}\t(1/2) Downloading SWTOR_setup.exe from http://www.swtor.com/download${NONE}"
  wget -O SWTOR_setup.exe $SWTOR_DOWNLOAD
}

download_swtor_shortcut_zip() {
  echo -e "${PURPLE}\t(2/2) Downloading SWTOR.zip from https://github.com/AgentRG/swtor_on_mac/${NONE}"
  wget $SWTOR_CUSTOM_SHORTCUT_LINK
}

move_swtor_setup() {
  echo -e "${PURPLE}\t(1/2) Moving SWTOR_setup.exe to prefix folder${NONE}"
  mv "/Users/$CURRENT_USER/swtor_tmp/SWTOR_setup.exe" "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/"
}

move_swtor_shortcut_zip() {
  echo -e "${PURPLE}\t(2/2) Moving SWTOR.zip to prefix folder\n${NONE}"
  mv "/Users/$CURRENT_USER/swtor_tmp/SWTOR.zip" "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/"
}

delete_temporary_downloads_folder() {
  echo -e "${PURPLE}\t(1/1) Deleting temporary downloads folder\n${NONE}"
  rm -r /Users/"$CURRENT_USER"/swtor_tmp/
}

unzip_swtor_app() {
  echo -e "${PURPLE}\t(1/2) Unzip SWTOR.zip\n${NONE}"
  unzip "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/SWTOR.zip"
}

move_swtor_app_to_desktop() {
  echo -e "${PURPLE}\t(2/2) Move SWTOR.app to Desktop\n${NONE}"
  mv "/Users/$CURRENT_USER/SWTOR.app" "/Users/$CURRENT_USER/Desktop/"
}

launch_swtor() {
  echo -e "${PURPLE}\tLaunching SWTOR_setup.exe...${NONE}"
  WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" wine "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/SWTOR_setup.exe" >/dev/null 2>&1
}

# Main function that installs Homebrew packages and SWTOR
install() {

  echo -e "${PURPLE}\tStep 1: Create temporary downloads folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  create_temporary_downloads_folder

  echo -e "${PURPLE}\tStep 2: Install Homebrew packages${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  install_package_wget
  tap_into_gcenx_brew
  install_package_wine_stable
  install_package_winetricks

  echo -e "${PURPLE}\tStep 4: Create custom Wine prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  create_swtor_prefix

  echo -e "${PURPLE}\tStep 5: Install DLLs to prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  # export WINE=wine32on64 # required to fool winetricks into using wine32on64
  install_dll_vcrun2008
  install_dll_crypt32
  install_dll_d3dx9_36

  echo -e "${PURPLE}\tStep 6: Change prefix settings${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  set_vram
  switch_windows_version
  switch_all_dlls_to_builtin

  echo -e "${PURPLE}\tStep 7: Download SWTOR executable${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  cd "/Users/$CURRENT_USER/swtor_tmp/" || exit
  download_swtor
  download_swtor_shortcut_zip
  cd "/Users/$CURRENT_USER/" || exit

  echo -e "${PURPLE}\tStep 8: Move executables and icon and move to prefix folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  move_swtor_setup
  move_swtor_shortcut_zip

  echo -e "${PURPLE}\tStep 9: Delete temporary downloads folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  delete_temporary_downloads_folder

  echo -e "${PURPLE}\tStep 10: Unzip SWTOR.zip and move application to Desktop${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  unzip_swtor_app
  move_swtor_app_to_desktop

  echo -e "${PURPLE}\tSWTOR On Mac Installation Finished Successfully!${NONE}"

  launch_swtor
}

echo -e "${PURPLE}\tAgentRG's SWTOR On Mac\n${NONE}"

# Check if Command Line Tools are installed followed by if Homebrew is installed
# If either isn't installed, the script will quit
if [ "$TOOLS_VERSION" = "$TOOLS_INSTALLED" ] || [ "$XCODE_CHECK" = "$XCODE_INSTALLED" ]; then
  if [[ $(command -v brew) == "" ]]; then
    echo -e "${RED}\tERROR: Homebrew not installed. Exiting.${NONE}"
  else
    install
  fi
else
  echo -e "${RED}\tERROR: Command Line Tools not installed. Exiting.${NONE}"
fi
