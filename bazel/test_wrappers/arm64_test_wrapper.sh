#!/bin/bash
# Custom test wrapper for running arm64 XCTest binaries
set -eux

# Print environment for debugging
echo "Running test with environment:"
env | sort

# Use the actual installed Xcode version
XCODE_PATH="/Applications/Xcode.app/Contents/Developer"
export DEVELOPER_DIR="${XCODE_PATH}"

# Print architecture of the test binary
echo "Test binary architecture:"
file "$TEST_BINARY"

# Force architecture to arm64 for the test runner
export ARCH=arm64

# Use arch command to ensure arm64 execution
arch -arm64 "$TEST_BINARY" "$@"

# Exit with the return code of the test
exit $?
