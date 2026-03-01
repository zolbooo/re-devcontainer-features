#!/bin/bash
set -e

source dev-container-features-test-lib

check "frida pinned core version" bash -c "frida --version | grep -Fx '17.7.2'"
check "frida server artifact for x86_64 exists" bash -c "test -f /usr/local/lib/frida/current/android/x86_64/frida-server"
check "frida server artifact for x86_64 executable" bash -c "test -x /usr/local/lib/frida/current/android/x86_64/frida-server"

reportResults
