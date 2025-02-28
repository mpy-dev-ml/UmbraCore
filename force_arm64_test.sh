#!/bin/bash
# Script to force arm64 architecture for tests

# Set environment variables
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export MACOS_DEPLOYMENT_TARGET=14.0
export ARCHFLAGS="-arch arm64"
export ARCH=arm64
export ARCHS=arm64
export DYLD_ARCH_OVERRIDE=arm64

# Clean any previous builds
bazel clean

# Build the test binary
bazel build \
  --cpu=darwin_arm64 \
  --apple_platform_type=macos \
  --macos_minimum_os=14.0 \
  "$@"

# Get the path to the test binary
TEST_BINARY=$(bazel info bazel-bin)/Tests/UmbraTestKitTests/UmbraTestKitTests.xctest/Contents/MacOS/UmbraTestKitTests

# Check if the binary exists
if [ ! -f "$TEST_BINARY" ]; then
  echo "Test binary not found at $TEST_BINARY"
  exit 1
fi

# Print architecture information
echo "Test binary architecture:"
file "$TEST_BINARY"

# Run the test binary directly with xctest
xcrun xctest "$TEST_BINARY"
