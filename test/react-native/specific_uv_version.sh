#!/bin/bash
set -e

source dev-container-features-test-lib

check "uv pinned version" bash -c "uv --version | grep -F '0.11.6'"
check "hermes-dec still available" bash -c "hbc-file-parser --help"

reportResults
