#!/bin/bash
set -e

source dev-container-features-test-lib

check "frida version command" bash -c "frida --version"
check "gadget artifact exists" bash -c "test -f /usr/local/lib/frida/current/android/arm64/frida-gadget.so"
check "server artifact not present for gadget scenario" bash -c "test ! -f /usr/local/lib/frida/current/android/arm64/frida-server"

reportResults
