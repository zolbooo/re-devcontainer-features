#!/bin/bash
set -e

source dev-container-features-test-lib

check "android CLI available" bash -c "android --version"
check "android-32 platform installed" bash -c "test -d \"$ANDROID_HOME/platforms/android-32\""
check "android-32 sources installed" bash -c "test -d \"$ANDROID_HOME/sources/android-32\""
check "specific ndk installed" bash -c "test -d \"$ANDROID_HOME/ndk/25.2.9519653\""
check "build tools in PATH" bash -c "command -v aapt2"

reportResults
