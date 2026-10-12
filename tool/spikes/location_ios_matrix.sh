#!/usr/bin/env bash
# Run with the iPhone 18 Pro simulator booted and the location spike installed:
#   flutter build ios --simulator --debug -t lib/spikes/location_capture/main.dart
# The capture fires inside Cairn's process via the --spike-capture-after launch hook.
# Stage 5b on iOS: a capture fired from inside Cairn's process, with Cairn on
# screen or in the background, at each permission level. (Widget, Control
# Center and Action button taps need a person; see the manual checklist.)
SIM=${SIM:-booted}
APP=com.cairnjournal.app
GROUP=$(xcrun simctl get_app_container $SIM $APP groups | awk '/group.com.cairnjournal.app/ {print $2}')
LOG="$GROUP/captures.jsonl"

set_permission() {
  xcrun simctl privacy $SIM revoke location $APP 2>/dev/null
  xcrun simctl privacy $SIM revoke location-always $APP 2>/dev/null
  case $1 in
    whileInUse) xcrun simctl privacy $SIM grant location $APP ;;
    always) xcrun simctl privacy $SIM grant location-always $APP ;;
  esac
}

scenario() {
  xcrun simctl terminate $SIM $APP 2>/dev/null
  set_permission "$1"
  xcrun simctl location $SIM set 37.7225,-119.1730
  xcrun simctl launch $SIM $APP --spike-capture-after 4 >/dev/null
  if [ "$2" = background ]; then
    sleep 1.5
    xcrun simctl launch $SIM com.apple.Preferences >/dev/null
  fi
  sleep 28
  echo "=== permission=$1 app=$2"
}

rm -f "$LOG"
for p in off whileInUse always; do
  for s in foreground background; do
    scenario $p $s
  done
done
cat "$LOG"
