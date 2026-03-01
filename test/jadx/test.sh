#!/bin/bash
set -e

source dev-container-features-test-lib

check "jadx version command" bash -c "jadx --version"
check "jadx-gui help command" bash -c "jadx-gui --help"

reportResults
