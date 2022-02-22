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

  cp -v "$TEMPLATE_DIR/Info.plist" "$APP_DIR/Contents/"
  cp -v "$TEMPLATE_DIR/SWTOR.icns" "$APP_DIR/Contents/Resources/"
  cp -v "$TEMPLATE_DIR/SWTOR.sh" "$APP_DIR/Contents/MacOS/SWTOR"
}

move_prefix_to_app() {
  log "->\tMoving prefix to SWTOR.app"
  mv -v "$PREFIX_DIR" "$APP_DIR/Contents/Resources/"
}

compress_app() {
  local file_name="$1.tar.gz"
  log "->\Compressing SWTOR.app as $file_name"
  tar -cvzf "$DIST_DIR/$file_name" -C "$DIST_DIR" --gid 0 --uid 0 "SWTOR.app"
}


move_back_prefix_dir() {
  log "->\tMoving prefix dir back to original place"
  mv -v "$APP_DIR/Contents/Resources/prefix" "$PREFIX_DIR"
}

remove_skeleton_app() {
  log "->\tRemoving skeleton SWTOR.app"
  rm -rf "$APP_DIR"
}

package() {

  log "_ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 1: Create dist dir"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  create_dist_dir

  log "_ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 2: Create SWTOR.app"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  create_skeleton_app
  move_prefix_to_app

  log "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  log "Step 3: Prepare SWTOR-light package"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  compress_app "SWTOR-light"

  log "_ _ _ _ _ _ _ _"
  log "Step 9: Cleanup"
  log "‾ ‾ ‾ ‾ ‾ ‾ ‾ ‾"

  move_back_prefix_dir
  remove_skeleton_app

}

if [[ -d "$PREFIX_DIR" ]]; then
  package
else
  log "ERROR: Prefix dir is not generated, please run build.sh first."
fi
