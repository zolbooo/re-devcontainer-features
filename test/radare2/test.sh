#!/bin/bash
set -e

source dev-container-features-test-lib

check "r2 version command" bash -c "r2 -v"
check "rabin2 version command" bash -c "rabin2 -v"

reportResults
