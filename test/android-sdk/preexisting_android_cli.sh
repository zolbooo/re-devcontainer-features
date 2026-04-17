#!/bin/bash
set -e

source dev-container-features-test-lib

check "android CLI replaced stub" bash -c "android --version | grep -Eq '^[0-9]+\\.[0-9]+'"
check "android CLI is not stub" bash -c "! android --version | grep -F 'preseed'"
check "adb available" bash -c "adb --version"
check "build tools in PATH" bash -c "command -v aapt2"

reportResults
