#!/usr/bin/env arch -x86_64 bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
DIST_DIR="$SCRIPT_DIR/dist"
APP_DIR="$DIST_DIR/SWTOR.app"
PREFIX_DIR="$SCRIPT_DIR/prefix"
TEMPLATE_DIR="$SCRIPT_DIR/template"

log() {
  echo -e "\033[01;35m\t$1\033[00m"
}

create_dist_dir() {
  log "->\tCreating dist dir"
  rm -rf "$DIST_DIR"
  mkdir -v "$DIST_DIR"
}

create_skeleton_app() {
  log "->\tCreating skeleton SWTOR.app"
  mkdir -vp "$APP_DIR"/Contents/{MacOS,Resources}

  cp -v "$TEMPLATE_DIR/Info.plist" "$APP_DIR/"
  cp -v "$TEMPLATE_DIR/SWTOR.icns" "$APP_DIR/Contents/Resources/"
  cp -v "$TEMPLATE_DIR/SWTOR.sh" "$APP_DIR/Contents/MacOS/SWTOR"
}

package() {

  log "Step 1: Create dist dir"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  create_dist_dir

  log "Step 2: Create SWTOR.app"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  create_skeleton_app

}

if [[ -d "$PREFIX_DIR" ]]; then
  package
else
  log "ERROR: Prefix dir is not generated, please run build.sh first."
fi
