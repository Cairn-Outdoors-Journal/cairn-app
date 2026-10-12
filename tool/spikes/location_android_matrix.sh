#!/usr/bin/env bash
# Run from anywhere with the Android emulator up and the location spike installed:
#   flutter build apk --debug -t lib/spikes/location_capture/main.dart && adb install -r build/app/outputs/flutter-apk/app-debug.apk
# The tap coordinates (158 620) are where the Cairn tile sits in this emulator's quick settings.
# Stage 5b: what does an Android quick-settings tile tap get at each
# permission level, with Cairn in the background or not running at all?
ADB=${ADB:-adb}
PKG=com.cairnjournal.app
TILE=$PKG/.capture.CaptureTileService

log() { $ADB shell run-as $PKG cat files/captures.jsonl 2>/dev/null; }
clear_log() { $ADB shell run-as $PKG rm -f files/captures.jsonl; }

set_permission() {
  case $1 in
    off)
      $ADB shell pm revoke $PKG android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null
      $ADB shell pm revoke $PKG android.permission.ACCESS_FINE_LOCATION 2>/dev/null
      $ADB shell pm revoke $PKG android.permission.ACCESS_COARSE_LOCATION 2>/dev/null ;;
    whileInUse)
      $ADB shell pm grant $PKG android.permission.ACCESS_FINE_LOCATION
      $ADB shell pm grant $PKG android.permission.ACCESS_COARSE_LOCATION
      $ADB shell pm revoke $PKG android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null ;;
    always)
      $ADB shell pm grant $PKG android.permission.ACCESS_FINE_LOCATION
      $ADB shell pm grant $PKG android.permission.ACCESS_COARSE_LOCATION
      $ADB shell pm grant $PKG android.permission.ACCESS_BACKGROUND_LOCATION ;;
  esac
}

# $1 = permission, $2 = foreground | background | stopped
scenario() {
  set_permission "$1"
  if [ "$2" = foreground ]; then
    $ADB shell am start -n $PKG/.MainActivity >/dev/null
    sleep 6
  elif [ "$2" = stopped ]; then
    $ADB shell am force-stop $PKG
  else
    $ADB shell am start -n $PKG/.MainActivity >/dev/null
    sleep 6
    $ADB shell input keyevent KEYCODE_HOME
    sleep 2
  fi
  $ADB emu geo fix -119.1730 37.7225 2833 8 >/dev/null
  # Tap the tile on screen: the "cmd statusbar click-tile" shortcut does not
  # reach a tile whose service Android has not bound.
  $ADB shell cmd statusbar expand-settings >/dev/null
  sleep 2
  $ADB shell input tap 158 620
  # A real GPS keeps reporting; phones only deliver fixes that arrive after a
  # request starts. Feed one fix a second (walking slowly north) for the
  # direct attempt and the foreground-service attempt, 20 s timeout each.
  for i in $(seq 1 45); do
    $ADB emu geo fix -119.1730 $(python3 -c "print(37.7225 + $i * 0.00001)") 2833 8 >/dev/null
    sleep 1
  done
  $ADB shell cmd statusbar collapse >/dev/null
  echo "=== permission=$1 app=$2"
}

$ADB shell am force-stop $PKG
clear_log
for p in off whileInUse always; do
  for s in foreground background stopped; do
    scenario $p $s
  done
done
log
