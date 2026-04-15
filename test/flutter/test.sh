#!/bin/bash
set -e

source dev-container-features-test-lib

check "blutter wrapper exists" bash -c "command -v blutter"
check "blutter.py exists" bash -c "test -f /usr/local/lib/blutter/current/blutter.py"
check "current symlink exists" bash -c "test -L /usr/local/lib/blutter/current"
check "python3 available" bash -c "command -v python3"
check "pyelftools installed" bash -c "python3 -c 'import elftools'"
check "cmake available" bash -c "command -v cmake"

reportResults
