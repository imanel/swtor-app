#!/usr/bin/env arch -x86_64 bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PREFIX_DIR="$SCRIPT_DIR/prefix"

SWTOR_DOWNLOAD=http://www.swtor.com/download

log() {
  echo -e "\033[01;35m\t$1\033[00m"
}

install_package_wget() {
  log "(1/4) Installing wget"
  brew install wget
}

tap_into_gcenx_brew() {
  log "(2/4) Tap into Gcenx/homebrew-wine"
  brew tap Gcenx/homebrew-wine
}

install_package_wine_stable() {
  log "(3/4) Installing latest Wine version"
  brew update
  brew install --cask --no-quarantine wine-crossover
}

install_package_winetricks() {
  log "(4/4) Installing Winetricks"
  brew install winetricks
}

create_swtor_prefix() {
  log "(1/1) Creating Wine prefix"
  rm -rf "$PREFIX_DIR"
  WINEARCH=win32 WINEPREFIX="$PREFIX_DIR" wine wineboot
}

install_dll_vcrun2008() {
  log "(1/3) Installing vcrun2008"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q vcrun2008
}

install_dll_crypt32() {
  log "(2/3) Installing crypt32"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q crypt32
}

install_dll_d3dx9_36() {
  log "(3/3) Installing d3dx9_36"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q d3dx9_36
}

set_vram() {
  log "(1/3) Setting prefix VRAM to 1024"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q videomemorysize=1024
}

switch_windows_version() {
  log "(2/3) Switching Windows version to Windows 10"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q win10
}

switch_all_dlls_to_builtin() {
  log "(3/3) Change all prefix DLLs to be builtin"
  env WINEPREFIX="$PREFIX_DIR" sh winetricks -q alldlls=builtin
}

download_swtor() {
  log "(1/1) Downloading SWTOR_setup.exe from http://www.swtor.com/download"
  wget -O "$PREFIX_DIR/drive_c/Program Files/SWTOR_setup.exe" $SWTOR_DOWNLOAD
}

launch_swtor() {
  log "Launching SWTOR_setup.exe..."
  WINEPREFIX="$PREFIX_DIR" wine "$PREFIX_DIR/drive_c/Program Files/SWTOR_setup.exe" >/dev/null 2>&1
}

build() {

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 1: Install Homebrew packages"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  install_package_wget
  tap_into_gcenx_brew
  install_package_wine_stable
  install_package_winetricks

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 2: Create custom Wine prefix"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  create_swtor_prefix

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 3: Install DLLs to prefix"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  # export WINE=wine32on64 # required to fool winetricks into using wine32on64
  install_dll_vcrun2008
  install_dll_crypt32
  install_dll_d3dx9_36

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 4: Change prefix settings"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  set_vram
  switch_windows_version
  switch_all_dlls_to_builtin

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 5: Download SWTOR executable"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  download_swtor

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 6: Launch SWTOR installer"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  launch_swtor
}

# Check if Homebrew is installed
if [[ $(command -v brew) == "" ]]; then
  log "ERROR: Homebrew not installed. Exiting."
else
  build
fi
