#!/bin/bash
set -e

source dev-container-features-test-lib

check "apktool pinned version" bash -c "apktool --version | grep -F '2.12.1'"

reportResults
