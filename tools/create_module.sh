#!/bin/bash
# create_module.sh - FoundationIndependent module generator
# Part of UmbraCore Foundation Decoupling project

set -e # Exit on error

# Check if module name is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <ModuleName>"
  echo "Example: $0 SecureString"
  exit 1
fi

MODULE_NAME="$1"
MODULE_PATH="Sources/$MODULE_NAME"

echo "Creating $MODULE_NAME module in $MODULE_PATH..."

# Create the directory structure
mkdir -p "$MODULE_PATH/Sources" "$MODULE_PATH/Tests"

# Create the BUILD.bazel file
cat > "$MODULE_PATH/BUILD.bazel" << EOF
load("//tools/build_defs:umbracore_module.bzl", "umbracore_foundation_free_module", "umbracore_test_module")

umbracore_foundation_free_module(
    name = "$MODULE_NAME",
    visibility = ["//visibility:public"],
    deps = [
        # Add foundation-free dependencies here
    ],
)

umbracore_test_module(
    name = "${MODULE_NAME}Tests",
    deps = [
        ":$MODULE_NAME",
        # Add test dependencies here
    ],
)
EOF

# Create the source file
cat > "$MODULE_PATH/Sources/$MODULE_NAME.swift" << EOF
// $MODULE_NAME.swift
// $MODULE_NAME
//
// Created as part of the UmbraCore Foundation Decoupling project
//

/// Primary entry point for the $MODULE_NAME module.
/// This module is designed to be fully Foundation-free.
public enum $MODULE_NAME {
    /// Module version
    public static let version = "1.0.0"
}
EOF

# Create the test file
cat > "$MODULE_PATH/Tests/${MODULE_NAME}Tests.swift" << EOF
// ${MODULE_NAME}Tests.swift
// $MODULE_NAME
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
@testable import $MODULE_NAME

class ${MODULE_NAME}Tests: XCTestCase {
    
    func testVersion() {
        XCTAssertFalse($MODULE_NAME.version.isEmpty)
    }
}
EOF

echo "✓ Created $MODULE_NAME module in $MODULE_PATH"
echo "• Module structure:"
echo "  - $MODULE_PATH/BUILD.bazel"
echo "  - $MODULE_PATH/Sources/$MODULE_NAME.swift"
echo "  - $MODULE_PATH/Tests/${MODULE_NAME}Tests.swift"
echo ""
echo "Next steps:"
echo "1. Add your core types to $MODULE_PATH/Sources/"
echo "2. Add tests to $MODULE_PATH/Tests/"
echo "3. Update dependencies in $MODULE_PATH/BUILD.bazel if needed"
