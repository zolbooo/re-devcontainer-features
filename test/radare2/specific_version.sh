#!/bin/bash
set -e

source dev-container-features-test-lib

check "radare2 pinned version" bash -c "r2 -v | grep -F '6.0.8'"
check "rabin2 version command" bash -c "rabin2 -v"

reportResults
