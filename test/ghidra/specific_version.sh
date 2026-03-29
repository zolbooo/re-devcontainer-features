#!/bin/bash
set -e

source dev-container-features-test-lib

check "ghidra pinned version" bash -c "readlink -f /usr/local/lib/ghidra/current | grep -F '12.0.3'"

reportResults
