#!/bin/bash
set -e

source dev-container-features-test-lib

check "jadx pinned version" bash -c "jadx --version | grep -F '1.5.4'"
check "jadx-gui help command" bash -c "jadx-gui --help"

reportResults
