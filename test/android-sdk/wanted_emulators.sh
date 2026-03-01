#!/bin/bash
set -e

source dev-container-features-test-lib

check "libX11 runtime available" bash -c "ldconfig -p | grep -q 'libX11.so.6'"
check "libpulse runtime available" bash -c "ldconfig -p | grep -q 'libpulse.so.0'"
check "libpng runtime available" bash -c "ldconfig -p | grep -q 'libpng16.so.16'"
check "libxkbfile runtime available" bash -c "ldconfig -p | grep -q 'libxkbfile.so.1'"
check "emulator command available" bash -c "emulator -version"
check "emulator package installed" bash -c "sdkmanager --list_installed | grep -F \"emulator\""
check "system image package installed" bash -c "sdkmanager --list_installed | grep -F \"system-images;android-34;google_apis;x86_64\""
check "avd directory exists" bash -c "test -d \"$ANDROID_AVD_HOME/pixel34.avd\""

reportResults
