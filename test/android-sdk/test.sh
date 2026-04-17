#!/bin/bash
set -e

source dev-container-features-test-lib

check "android CLI available" bash -c "android --version"
check "adb available" bash -c "adb --version"
check "platform tools installed" bash -c "android --no-metrics --sdk \"$ANDROID_HOME\" sdk list 'platform-tools*' | grep -F 'platform-tools'"
check "build tools in PATH" bash -c "command -v aapt2"

reportResults
