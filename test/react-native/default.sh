#!/bin/bash
set -e

source dev-container-features-test-lib

check "default uv version" bash -c "uv --version | grep -F '0.10.9'"
check "default hermes-dec executable" bash -c "hbc-file-parser --help"

reportResults
