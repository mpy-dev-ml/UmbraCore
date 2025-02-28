#!/bin/bash
# Script to run tests with arm64 architecture

# Set environment variables
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
# Removed SDKROOT to avoid conflicts
export MACOS_DEPLOYMENT_TARGET=14.0

# Run tests with explicit architecture settings
bazel test \
  --cpu=darwin_arm64 \
  --apple_platform_type=macos \
  --macos_minimum_os=14.0 \
  --test_output=errors \
  "$@"
