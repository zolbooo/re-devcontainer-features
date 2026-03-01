#!/bin/bash
set -e

source dev-container-features-test-lib

check "emulator command available" bash -c "emulator -version"
check "emulator package installed" bash -c "sdkmanager --list_installed | grep -F \"emulator\""
check "system image package installed" bash -c "sdkmanager --list_installed | grep -F \"system-images;android-34;google_apis;x86_64\""
check "avd directory exists" bash -c "test -d \"$HOME/.android/avd/pixel34.avd\""

reportResults
