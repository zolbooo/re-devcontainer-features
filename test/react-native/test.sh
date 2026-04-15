#!/bin/bash
set -e

source dev-container-features-test-lib

check "node available" bash -c "node --version"
check "uv available" bash -c "uv --version"
check "uvx available" bash -c "uvx --version"
check "hbc-file-parser available" bash -c "hbc-file-parser --help"
check "hbc-disassembler available" bash -c "hbc-disassembler --help"
check "hbc-decompiler available" bash -c "hbc-decompiler --help"

reportResults
