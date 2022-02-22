#!/usr/bin/env arch -x86_64 bash

set -e

NONE='\033[00m'
PURPLE='\033[01;35m'
RED='\033[0;31m'
MACOS_HIGH_SIERRA=1013
MACOS_CATALINA=1015
CURRENT_VERSION=$(sw_vers -productVersion | awk '{print $1}' | sed "s:.[[:digit:]]*.$::g")
TOOLS_VERSION=$(xcode-select -p)
TOOLS_INSTALLED="/Library/Developer/CommandLineTools"
XCODE_CHECK=$(ls /Applications/Xcode.app) || : # set -e can cause the script to die here, so added || : to skip fail
XCODE_INSTALLED="Contents"
CURRENT_USER=$(whoami)
CROSSOVER_TAR=src-crossover-wine-clang-0.0.3.tar.bz2
CROSSOVER_LINK=https://github.com/AgentRG/swtor_on_mac/releases/download/6.0-wine-crossover/$CROSSOVER_TAR
SWTOR_CUSTOM_SHORTCUT_LINK=https://github.com/AgentRG/swtor_on_mac/raw/master/SWTOR.zip
SWTOR_DOWNLOAD=http://www.swtor.com/download
CPU_ARCHITECTURE=$(sysctl -n machdep.cpu.brand_string)

if [[ $(echo "${CURRENT_VERSION}" | cut -d"." -f2 | wc -c) -eq 2 ]]; then
  CURRENT_VERSION_COMBINED=$(echo "${CURRENT_VERSION}" | cut -d"." -f1)0$(echo "${CURRENT_VERSION}" | cut -d"." -f2)
  export CURRENT_VERSION_COMBINED
else
	CURRENT_VERSION_COMBINED=$(echo "${CURRENT_VERSION}" | cut -d"." -f1)$(echo "${CURRENT_VERSION}" | cut -d"." -f2)
	export CURRENT_VERSION_COMBINED
fi

create_temporary_downloads_folder() {
  echo -e "${PURPLE}\t(1/1) Creating temporary downloads folder\n${NONE}"
  mkdir /Users/"$CURRENT_USER"/swtor_tmp || :
}

# Pre-Catalina Package Management

install_package_wget() {
  echo -e "${PURPLE}\t(1/4) Installing wget${NONE}"
  brew install wget
}

tap_into_agentrg_brew() {
  echo -e "${PURPLE}\t(2/4) Tap into AgentRG/homebrew-wine${NONE}"
  brew tap agentrg/homebrew-wine
}

install_package_wine_stable() {
  echo -e "${PURPLE}\t(3/4) Installing latest Wine version${NONE}"
  brew update
  brew install --cask --no-quarantine agentrg-wine-stable
}

install_package_winetricks() {
  echo -e "${PURPLE}\t(4/4) Installing Winetricks\n${NONE}"
  brew install winetricks
}

# ---

# Post-Catalina Package Management

install_package_wget_catalina() {
  echo -e "${PURPLE}\t(1/11) Installing wget${NONE}"
  brew install wget
}

install_package_winetricks_catalina() {
  echo -e "${PURPLE}\t(2/11) Installing Winetricks\n${NONE}"
  brew install winetricks
}

install_package_cmake() {
  echo -e "${PURPLE}\t(3/11) Installing CMake\n${NONE}"
  brew install cmake
}

install_package_gcc() {
  echo -e "${PURPLE}\t(4/11) Installing GCC\n${NONE}"
  brew install gcc
}

install_package_bison() {
  echo -e "${PURPLE}\t(5/11) Installing Bison\n${NONE}"
  brew install bison
  # Homebrew packages in Apple Silicon are installed under /opt/homebrew/opt/
  if [[ $CPU_ARCHITECTURE == *"M1"* ]]; then
    PATH="/opt/homebrew/opt/bison/bin:$PATH"
  else
    PATH="$(brew --prefix bison)/bin:$PATH"
  fi
  export PATH
}

install_package_xquartz() {
  echo -e "${PURPLE}\t(6/11) Installing XQuartz\n${NONE}"
  brew install --cask xquartz
}

install_package_flex() {
  echo -e "${PURPLE}\t(7/11) Installing Flex\n${NONE}"
  brew install flex
}

install_package_mingw_w64() {
  echo -e "${PURPLE}\t(8/11) Installing Mingw-w64\n${NONE}"
  brew install mingw-w64
}

install_package_pkg_config() {
  echo -e "${PURPLE}\t(9/11) Installing pkg-config\n${NONE}"
  brew install pkg-config
}

install_package_freetype() {
  echo -e "${PURPLE}\t(10/11) Installing FreeType\n${NONE}"
  brew install freetype
}

install_package_gnutls() {
  echo -e "${PURPLE}\t(11/11) Installing GnuTLS\n${NONE}"
  brew install gnutls
}

# ---

download_crossover_21_patched() {
  echo -e "${PURPLE}\t(1/5) Downloading patched CrossOver 21.1.0 from https://github.com/AgentRG/swtor_on_mac${NONE}"
  wget $CROSSOVER_LINK
}

unpack_crossover_21_tar() {
  echo -e "${PURPLE}\t(2/5) Unpacking and deleting $CROSSOVER_TAR${NONE}"
  tar -jxvf $CROSSOVER_TAR
  rm -f $CROSSOVER_TAR
  cd "/Users/$CURRENT_USER/swtor_tmp/sources/" || exit
}

compile_llvm() {
  echo -e "${PURPLE}\t(3/5) Compile LLVM ${NONE}"
  DIR=$(pwd)
  export DIR
  cd clang/llvm
  mkdir build || (rm -r build && mkdir build)
  cd build
  cmake ../
  make
  cd bin
  PATH="$(pwd):$PATH"
  export PATH
  cd "$DIR"
}

compile_clang() {
  echo -e "${PURPLE}\t(4/5) Compile Clang${NONE}"
  DIR=$(pwd)
  export DIR
  cd clang/clang
  mkdir build || (rm -r build && mkdir build)
  cd build
  cmake ../
  make
  cd bin
  PATH="$(pwd):$PATH"
  export PATH
  cd "$DIR"
}

compile_wine() {
  echo -e "${PURPLE}\t(5/5) Compile and install Wine${NONE}"
  DIR=$(pwd)
  export DIR
  cd wine
  PATH="$(pwd):$PATH"
  export PATH
  export MACOSX_DEPLOYMENT_TARGET=10.14
  CC="clang" CXX="clang++" MACOSX_DEPLOYMENT_TARGET=10.14 ./configure --enable-win32on64 -disable-winedbg --without-x \
  --disable-tests --disable-mscms --without-sane --without-alsa --without-capi --without-dbus --without-inotify \
  --without-oss --without-pulse --without-udev --without-v4l2 --without-cms --without-gstreamer --without-gsm \
  --without-gphoto --with-mingw --without-krb5 --without-vkd3d --without-vulkan --disable-vulkan_1 --disable-winevulkan
  make
  echo -e "${PURPLE}\tMoving Wine binaries to /usr/local/bin/ (password may be required)${NONE}"
  sudo make install-lib
  cd "$DIR"
}

check_if_wine_installed() {
  if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
    if [[ $(wine32on64 --version) != "wine-6.0" ]]; then
      echo -e "${RED}\tERROR: Crossover Wine didn't get installed. Please check for errors in the output. Exiting.${NONE}"
      exit
    fi
  fi
}

create_swtor_prefix() {
  echo -e "${PURPLE}\t(1/1) Creating "SWTOR On Mac" Wine prefix\n${NONE}"
  if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
    WINEARCH=win32 WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" wine32on64 wineboot
  else
    WINEARCH=win64 WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" wine wineboot
  fi
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
  if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
    mv "/Users/$CURRENT_USER/swtor_tmp/SWTOR_setup.exe" "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/"
  else
    mv "/Users/$CURRENT_USER/swtor_tmp/SWTOR_setup.exe" "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files (x86)/"
  fi
}

move_swtor_shortcut_zip() {
  echo -e "${PURPLE}\t(2/2) Moving SWTOR.zip to prefix folder\n${NONE}"
  if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
    mv "/Users/$CURRENT_USER/swtor_tmp/SWTOR.zip" "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/"
  else
    mv "/Users/$CURRENT_USER/swtor_tmp/SWTOR.zip" "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files (x86)/"
  fi
}

delete_temporary_downloads_folder() {
  echo -e "${PURPLE}\t(1/1) Deleting temporary downloads folder\n${NONE}"
  rm -r /Users/"$CURRENT_USER"/swtor_tmp/
}

unzip_swtor_app() {
  echo -e "${PURPLE}\t(1/2) Unzip SWTOR.zip\n${NONE}"
  if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
      unzip "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/SWTOR.zip"
  else
      unzip "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files (x86)/SWTOR.zip"
  fi
}

move_swtor_app_to_desktop() {
  echo -e "${PURPLE}\t(2/2) Move SWTOR.app to Desktop\n${NONE}"
  mv "/Users/$CURRENT_USER/SWTOR.app" "/Users/$CURRENT_USER/Desktop/"
}

launch_swtor() {
  echo -e "${PURPLE}\tLaunching SWTOR_setup.exe...${NONE}"
  if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
    WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" wine32on64 "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files/SWTOR_setup.exe" >/dev/null 2>&1
  else
    WINEPREFIX="/Users/$CURRENT_USER/SWTOR On Mac" wine "/Users/$CURRENT_USER/SWTOR On Mac/drive_c/Program Files (x86)/SWTOR_setup.exe" >/dev/null 2>&1
    fi
}

# Main function that installs Homebrew packages and SWTOR for macOS's before Catalina
install_pre_catalina() {

  echo -e "${PURPLE}\tStep 1: Create temporary downloads folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  create_temporary_downloads_folder

  echo -e "${PURPLE}\tStep 2: Install Homebrew packages${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  install_package_wget
  tap_into_agentrg_brew
  install_package_wine_stable
  check_if_wine_installed
  install_package_winetricks

  echo -e "${PURPLE}\tStep 3: Create custom Wine prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  create_swtor_prefix

  echo -e "${PURPLE}\tStep 4: Install DLLs to prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  install_dll_vcrun2008
  install_dll_crypt32
  install_dll_d3dx9_36

  echo -e "${PURPLE}\tStep 5: Change prefix settings${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  set_vram
  switch_windows_version
  switch_all_dlls_to_builtin

  echo -e "${PURPLE}\tStep 6: Download SWTOR executable${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  cd "/Users/$CURRENT_USER/swtor_tmp/" || exit
  download_swtor
  download_swtor_shortcut_zip
  cd "/Users/$CURRENT_USER/" || exit

  echo -e "${PURPLE}\tStep 7: Move executables and icon and move to prefix folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  move_swtor_setup
  move_swtor_shortcut_zip

  echo -e "${PURPLE}\tStep 8: Delete temporary downloads folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  delete_temporary_downloads_folder

  echo -e "${PURPLE}\tStep 9: Unzip SWTOR.zip and move application to Desktop${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  unzip_swtor_app
  move_swtor_app_to_desktop

  echo -e "${PURPLE}\tSWTOR On Mac Installation Finished Successfully!${NONE}"

  launch_swtor
}

# Main function that installs Homebrew packages and SWTOR for macOS's after Catalina
install_post_catalina() {

  echo -e "${PURPLE}\tStep 1: Create temporary downloads folder${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾${NONE}"

  create_temporary_downloads_folder

  echo -e "${PURPLE}\tStep 2: Install Homebrew packages${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  install_package_wget_catalina
  install_package_winetricks_catalina
  install_package_cmake
  install_package_gcc
  install_package_bison
  install_package_xquartz
  install_package_flex
  install_package_mingw_w64
  install_package_pkg_config
  install_package_freetype
  install_package_gnutls

  echo -e "${PURPLE}\tStep 3: Download and compile patched Wine CrossOver 21${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  cd "/Users/$CURRENT_USER/swtor_tmp/" || exit
  download_crossover_21_patched
  unpack_crossover_21_tar
  compile_llvm
  compile_clang
  compile_wine
  check_if_wine_installed

  echo -e "${PURPLE}\tStep 4: Create custom Wine prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  create_swtor_prefix

  echo -e "${PURPLE}\tStep 5: Install DLLs to prefix${NONE}"
  echo -e "${PURPLE}\t‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ${NONE}"

  export WINE=wine32on64 # required to fool winetricks into using wine32on64
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

check_if_not_high_sierra_or_earlier() {
    if [[ $CURRENT_VERSION_COMBINED -lt $MACOS_HIGH_SIERRA ]]; then
      echo -e "${RED}\tERROR: SWTOR will only work on machines with macOS High Sierra (10.13) or later. The macOS of this machine is $CURRENT_VERSION. Exiting${NONE}"
      exit
    fi
}

echo -e "${PURPLE}\tAgentRG's SWTOR On Mac\n${NONE}"

check_if_not_high_sierra_or_earlier

# Check if Command Line Tools are installed followed by if Homebrew is installed
# If either isn't installed, the script will quit
if [ "$TOOLS_VERSION" = "$TOOLS_INSTALLED" ] || [ "$XCODE_CHECK" = "$XCODE_INSTALLED" ]; then
  if [[ $(command -v brew) == "" ]]; then
    echo -e "${RED}\tERROR: Homebrew not installed. Exiting.${NONE}"
  else
    if [[ $CURRENT_VERSION_COMBINED -ge $MACOS_CATALINA ]]; then
      install_post_catalina
    else
      install_pre_catalina
    fi
  fi
else
  echo -e "${RED}\tERROR: Command Line Tools not installed. Exiting.${NONE}"
fi