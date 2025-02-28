#!/bin/bash
# Script to build and run all the foundation-free module tests

set -e  # Exit on error

MODULES=(
  "BinaryData"
  "BinaryStream"
  "ConcurrencyPrimitives"
  "FilePath"
  "Serialization"
  "StringConversion"
  "URLPath"
)

echo "🏗 Building foundation-free module tests..."
for MODULE in "${MODULES[@]}"; do
  echo "Building $MODULE..."
  bazel build "//Sources/$MODULE:${MODULE}Tests"
done

echo "🧪 Running tests for foundation-free modules..."
for MODULE in "${MODULES[@]}"; do
  TEST_PATH=$(find "$(bazel info bazel-out)" -name "${MODULE}Tests.xctest" -type d)
  if [ -n "$TEST_PATH" ]; then
    echo "Running tests for $MODULE..."
    xcrun xctest -XCTest All "$TEST_PATH"
  else
    echo "⚠️ Could not find test bundle for $MODULE"
  fi
done

echo "✅ Foundation-free module tests completed"
