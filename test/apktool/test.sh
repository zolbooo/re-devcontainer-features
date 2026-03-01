#!/bin/bash
set -e

source dev-container-features-test-lib

check "apktool version command" bash -c "apktool --version"

reportResults
