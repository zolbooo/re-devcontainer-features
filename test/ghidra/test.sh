#!/bin/bash
set -e

source dev-container-features-test-lib

check "ghidra is on PATH" which ghidra
check "ghidra support files exist" bash -c "test -f /usr/local/lib/ghidra/current/ghidra/ghidraRun"
check "analyzeHeadless is on PATH" which analyzeHeadless
check "analyzeHeadless support file exists" bash -c "test -f /usr/local/lib/ghidra/current/ghidra/support/analyzeHeadless"

reportResults
