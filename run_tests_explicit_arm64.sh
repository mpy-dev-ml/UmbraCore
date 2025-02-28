#!/bin/bash
# Script to run tests with explicit arm64 architecture

# Set environment variables
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export MACOS_DEPLOYMENT_TARGET=14.0
export ARCHFLAGS="-arch arm64"
export ARCH=arm64
export ARCHS=arm64

# Run tests with explicit architecture settings
bazel test \
  --cpu=darwin_arm64 \
  --apple_platform_type=macos \
  --macos_minimum_os=14.0 \
  --test_output=errors \
  "$@"
