#!/bin/bash
set -e

source dev-container-features-test-lib

check "frida version command" bash -c "frida --version"
check "frida-ps help command" bash -c "frida-ps --help"
check "default server artifact exists" bash -c "test -f /usr/local/lib/frida/current/android/arm64/frida-server"
check "default server artifact executable" bash -c "test -x /usr/local/lib/frida/current/android/arm64/frida-server"

reportResults
