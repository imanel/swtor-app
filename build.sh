#!/usr/bin/env arch -x86_64 bash

set -e

NONE='\033[00m'
PURPLE='\033[01;35m'
RED='\033[0;31m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PREFIX_DIR="$SCRIPT_DIR/prefix"

SWTOR_DOWNLOAD=http://www.swtor.com/download

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
  echo -e "${PURPLE}\t(1/1) Creating Wine prefix\n${NONE}"
  rm -rf "$PREFIX_DIR"
  WINEARCH=win32 WINEPREFIX="$PREFIX_DIR" wine wineboot
}

install_dll_vcrun2008() {
  echo -e "${PURPLE}\t(1/3) Installing vcrun2008${NONE}"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q vcrun2008
}

install_dll_crypt32() {
  echo -e "${PURPLE}\t(2/3) Installing crypt32${NONE}"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q crypt32
}

install_dll_d3dx9_36() {
  echo -e "${PURPLE}\t(3/3) Installing d3dx9_36\n${NONE}"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q d3dx9_36
}

set_vram() {
  echo -e "${PURPLE}\t(1/3) Setting prefix VRAM to 1024${NONE}"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q videomemorysize=1024
}

switch_windows_version() {
  echo -e "${PURPLE}\t(2/3) Switching Windows version to Windows 10${NONE}"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q win10
}

switch_all_dlls_to_builtin() {
  echo -e "${PURPLE}\t(3/3) Change all prefix DLLs to be builtin\n${NONE}"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q alldlls=builtin
}

download_swtor() {
  echo -e "${PURPLE}\t(1/1) Downloading SWTOR_setup.exe from http://www.swtor.com/download${NONE}"
  wget -O "$PREFIX_DIR/drive_c/Program Files/SWTOR_setup.exe" $SWTOR_DOWNLOAD
}

launch_swtor() {
  echo -e "${PURPLE}\tLaunching SWTOR_setup.exe...${NONE}"
  WINEPREFIX="$PREFIX_DIR" wine "$PREFIX_DIR/drive_c/Program Files/SWTOR_setup.exe" >/dev/null 2>&1
}

build() {

  echo -e "${PURPLE}\tStep 1: Install Homebrew packages${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  install_package_wget
  tap_into_gcenx_brew
  install_package_wine_stable
  install_package_winetricks

  echo -e "${PURPLE}\tStep 2: Create custom Wine prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  create_swtor_prefix

  echo -e "${PURPLE}\tStep 3: Install DLLs to prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  # export WINE=wine32on64 # required to fool winetricks into using wine32on64
  install_dll_vcrun2008
  install_dll_crypt32
  install_dll_d3dx9_36

  echo -e "${PURPLE}\tStep 4: Change prefix settings${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  set_vram
  switch_windows_version
  switch_all_dlls_to_builtin

  echo -e "${PURPLE}\tStep 5: Download SWTOR executable${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  download_swtor

  echo -e "${PURPLE}\tStep 6: Launch SWTOR installer${NONE}"

  launch_swtor
}

# Check if Homebrew is installed
if [[ $(command -v brew) == "" ]]; then
  echo -e "${RED}\tERROR: Homebrew not installed. Exiting.${NONE}"
else
  build
fi
