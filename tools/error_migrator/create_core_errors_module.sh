#!/bin/bash

set -e

# Default values
TARGET_DIR="/Users/mpy/CascadeProjects/UmbraCore/Sources/CoreErrors"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --dir PATH      Path where CoreErrors module will be created (default: /Users/mpy/CascadeProjects/UmbraCore/Sources/CoreErrors)"
      echo "  --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

echo "Creating CoreErrors module structure at $TARGET_DIR"

# Create directory structure
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/Sources"
mkdir -p "$TARGET_DIR/Tests"

# Create BUILD.bazel file
cat > "$TARGET_DIR/BUILD.bazel" << 'EOF'
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "CoreErrors",
    srcs = glob(["Sources/**/*.swift"]),
    module_name = "CoreErrors",
    visibility = ["//visibility:public"],
    deps = [
        "@SwiftFoundation//:Foundation",
    ],
)

swift_library(
    name = "CoreErrorsTests",
    testonly = True,
    srcs = glob(["Tests/**/*.swift"]),
    module_name = "CoreErrorsTests",
    visibility = ["//visibility:public"],
    deps = [
        ":CoreErrors",
        "@SwiftFoundation//:Foundation",
        "@SwiftFoundation//:XCTest",
    ],
)
EOF

# Create placeholder Swift file
cat > "$TARGET_DIR/Sources/CoreErrors.swift" << 'EOF'
// CoreErrors.swift
// This file will be populated by the error_migrator tool

import Foundation

// Placeholder for generated error types
// Run the error_migrator tool to populate this module with consolidated error types
EOF

# Create test placeholder
cat > "$TARGET_DIR/Tests/CoreErrorsTests.swift" << 'EOF'
// CoreErrorsTests.swift

import XCTest
@testable import CoreErrors

class CoreErrorsTests: XCTestCase {
    func testErrorsExist() {
        // Placeholder test - will be expanded after error migration
        XCTAssertTrue(true, "This test will be expanded after error migration")
    }
}
EOF

echo "CoreErrors module structure created successfully."
echo ""
echo "Next steps:"
echo "1. Run the error_migrator tool to populate the module"
echo "2. Add the module to the UmbraCore project"
echo "3. Update imports in files that reference the migrated errors"
