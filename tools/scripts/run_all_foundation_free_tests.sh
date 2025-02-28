#!/bin/bash
# Script to build and run all the foundation-free module tests directly with xcrun

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

BAZEL_OUT_DIR="/Users/mpy/.bazel/execroot/_main/bazel-out/darwin_arm64-opt/bin"

echo "🏗️  Building all foundation-free modules and tests..."

# Build each module and its tests individually 
for MODULE in "${MODULES[@]}"; do
  echo "Building //Sources/$MODULE:$MODULE..."
  bazel build "//Sources/$MODULE:$MODULE" || echo "⚠️ Failed to build $MODULE"
  
  echo "Building //Sources/$MODULE:${MODULE}Tests..."
  bazel build "//Sources/$MODULE:${MODULE}Tests" || echo "⚠️ Failed to build ${MODULE}Tests"
done

echo "✅ Build process completed"
echo ""

# Run all tests directly with xcrun
echo "🧪 Running tests using xcrun..."
FAILED_TESTS=()
SUCCESSFUL_TESTS=()

for MODULE in "${MODULES[@]}"; do
  TEST_PATH="${BAZEL_OUT_DIR}/Sources/${MODULE}/${MODULE}Tests.xctest"
  if [ -d "$TEST_PATH" ]; then
    echo "📊 Testing $MODULE..."
    if xcrun xctest -XCTest All "$TEST_PATH"; then
      SUCCESSFUL_TESTS+=("$MODULE")
      echo "✅ $MODULE tests passed"
    else
      FAILED_TESTS+=("$MODULE")
      echo "❌ $MODULE tests failed"
    fi
  else
    echo "⚠️  Could not find test bundle for $MODULE at $TEST_PATH"
    FAILED_TESTS+=("$MODULE")
  fi
  echo ""
done

# Print summary
echo "📝 Test Summary:"
echo "----------------"
echo "Total modules tested: ${#MODULES[@]}"
echo "Successful: ${#SUCCESSFUL_TESTS[@]} (${SUCCESSFUL_TESTS[*]:-none})"
echo "Failed: ${#FAILED_TESTS[@]} (${FAILED_TESTS[*]:-none})"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  exit 1
fi
