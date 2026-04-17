#!/bin/bash
set -e

source dev-container-features-test-lib

check "libX11 runtime available" bash -c "ldconfig -p | grep -q 'libX11.so.6'"
check "libX11-xcb runtime available" bash -c "ldconfig -p | grep -q 'libX11-xcb.so.1'"
check "libpulse runtime available" bash -c "ldconfig -p | grep -q 'libpulse.so.0'"
check "libpng runtime available" bash -c "ldconfig -p | grep -q 'libpng16.so.16'"
check "libxkbfile runtime available" bash -c "ldconfig -p | grep -q 'libxkbfile.so.1'"
check "android CLI available" bash -c "android --version"
check "emulator command available" bash -c "emulator -version"
check "emulator package installed" bash -c "android --no-metrics --sdk \"$ANDROID_HOME\" sdk list 'emulator*' | grep -F 'emulator'"
check "requested avd listed" bash -c "android --no-metrics --sdk \"$ANDROID_HOME\" emulator list --long | grep -F 'medium_phone'"
check "avd directory exists" bash -c "test -d \"$ANDROID_AVD_HOME/medium_phone.avd\""

reportResults
