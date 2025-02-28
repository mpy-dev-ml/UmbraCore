"""
UmbraCore module build rules to ensure consistent module structure.

These rules automate the creation of UmbraCore modules with the proper 
structure and dependencies according to our refactoring plan.
"""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")

def umbracore_foundation_free_module(name, **kwargs):
    """Creates a Foundation-free Swift module.
    
    Args:
        name: Name of the target.
        **kwargs: Additional arguments to pass to swift_library.
    """
    
    # Make sure visibility is set if not provided
    visibility = kwargs.pop("visibility", None)
    
    deps = kwargs.pop("deps", [])
    
    swift_library(
        name = name,
        srcs = native.glob(["Sources/**/*.swift"]),
        module_name = name,
        deps = deps,
        visibility = visibility,
        testonly = False,
        generates_header = False,
        # Enable testability
        copts = [
            "-strict-concurrency=complete",
            "-warn-concurrency",
            "-enable-actor-data-race-checks",
            "-enable-testing",
        ],
        **kwargs
    )

def umbracore_test_module(name, **kwargs):
    """Creates a Swift test module.
    
    Args:
        name: Name of the target.
        **kwargs: Additional arguments to pass to swift_test.
    """
    
    # Make sure visibility is set if not provided
    visibility = kwargs.pop("visibility", None)
    
    # Make sure deps is set
    deps = kwargs.pop("deps", [])
    
    swift_test(
        name = name,
        srcs = native.glob(["Tests/**/*.swift"]),
        module_name = name,
        deps = deps,
        visibility = visibility,
        # Apply strict concurrency checking
        copts = [
            "-strict-concurrency=complete",
            "-warn-concurrency",
            "-enable-actor-data-race-checks",
            "-enable-testing",
        ],
        **kwargs
    )

def umbracore_quick_module_creator(name, module_name):
    """Creates a simple script that directly creates a module in the source tree.
    
    This rule is a workaround for creating files in the source tree from a Bazel rule.
    It outputs a shell script that, when run, will create the module files.
    
    Args:
        name: Name of the target.
        module_name: Name of the module to create.
    """
    
    native.genrule(
        name = name,
        srcs = [],
        outs = [name + ".sh"],
        cmd = """cat > $@ << 'EOF'
#!/bin/bash
MODULE_NAME="%s"
MODULE_PATH="Sources/$$MODULE_NAME"

echo "Creating $$MODULE_NAME module in $$MODULE_PATH..."

# Create the directory structure
mkdir -p "$$MODULE_PATH/Sources" "$$MODULE_PATH/Tests"

# Create the BUILD.bazel file
cat > "$$MODULE_PATH/BUILD.bazel" << 'INNER_EOF'
load("//tools/build_defs:umbracore_module.bzl", "umbracore_foundation_free_module", "umbracore_test_module")

umbracore_foundation_free_module(
    name = "$$MODULE_NAME",
    visibility = ["//visibility:public"],
    deps = [
        # Add foundation-free dependencies here
    ],
)

umbracore_test_module(
    name = "$${MODULE_NAME}Tests",
    deps = [
        ":$$MODULE_NAME",
        # Add test dependencies here
    ],
)
INNER_EOF

# Create the source file
cat > "$$MODULE_PATH/Sources/$$MODULE_NAME.swift" << 'INNER_EOF'
// $$MODULE_NAME.swift
// $$MODULE_NAME
//
// Created as part of the UmbraCore Foundation Decoupling project
//

/// Primary entry point for the $$MODULE_NAME module.
/// This module is designed to be fully Foundation-free.
public enum $$MODULE_NAME {
    /// Module version
    public static let version = "1.0.0"
}
INNER_EOF

# Create the test file
cat > "$$MODULE_PATH/Tests/$${MODULE_NAME}Tests.swift" << 'INNER_EOF'
// $${MODULE_NAME}Tests.swift
// $$MODULE_NAME
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
@testable import $$MODULE_NAME

class $${MODULE_NAME}Tests: XCTestCase {
    
    func testVersion() {
        XCTAssertFalse($$MODULE_NAME.version.isEmpty)
    }
}
INNER_EOF

echo "✓ Created $$MODULE_NAME module in $$MODULE_PATH"
echo "• Module structure:"
echo "  - $$MODULE_PATH/BUILD.bazel"
echo "  - $$MODULE_PATH/Sources/$$MODULE_NAME.swift"
echo "  - $$MODULE_PATH/Tests/$${MODULE_NAME}Tests.swift"
echo ""
echo "Next steps:"
echo "1. Add your core types to $$MODULE_PATH/Sources/"
echo "2. Add tests to $$MODULE_PATH/Tests/"
echo "3. Update dependencies in $$MODULE_PATH/BUILD.bazel if needed"
EOF
chmod +x $@
""" % module_name,
        executable = True,
    )

def umbracore_foundation_free_module_creator(name, module_name):
    """Creates a simple script that directly creates a foundation-free module in the source tree.
    
    This rule generates a shell script that, when run, will create all the necessary
    files for a new Foundation-free module with proper structure.
    
    Args:
        name: Name of the target.
        module_name: Name of the module to create.
    """
    
    native.genrule(
        name = name,
        srcs = [],
        outs = [name + ".sh"],
        cmd = """cat > $@ << 'EOF'
#!/bin/bash
MODULE_NAME="%s"
MODULE_DIR="Sources/$$MODULE_NAME"

echo "Creating $$MODULE_NAME module in $$MODULE_DIR..."

# Create the directory structure
mkdir -p "$$MODULE_DIR/Sources" "$$MODULE_DIR/Tests"

# Create the BUILD.bazel file
cat > "$$MODULE_DIR/BUILD.bazel" << 'INNER_EOF'
load("//tools/build_defs:umbracore_module.bzl", "umbracore_foundation_free_module")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_test")

umbracore_foundation_free_module(
    name = "%s",
    visibility = ["//visibility:public"],
)

swift_test(
    name = "%sTests",
    srcs = glob(["Tests/*.swift"]),
    deps = [":%s"],
    tags = ["manual"],
)
INNER_EOF

# Create the source file
cat > "$$MODULE_DIR/Sources/$$MODULE_NAME.swift" << 'INNER_EOF'
// %s.swift - Foundation-free implementation
// Part of UmbraCore project
// Created on %s

@frozen
public struct %s {
    // MARK: - Properties
    
    // MARK: - Initialisation
    
    /// Creates a new instance of %s.
    public init() {
        // Implementation
    }
    
    // MARK: - Methods
    
    /// Example method demonstrating Foundation-free implementation
    public func exampleMethod() -> Bool {
        return true
    }
}
INNER_EOF

# Create the test file
cat > "$$MODULE_DIR/Tests/$${MODULE_NAME}Tests.swift" << 'INNER_EOF'
// %sTests.swift - Tests for Foundation-free implementation
// Part of UmbraCore project
// Created on %s

import XCTest
@testable import %s

final class %sTests: XCTestCase {
    // MARK: - Properties
    
    private var sut: %s!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        sut = %s()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialisation() {
        XCTAssertNotNil(sut)
    }
    
    func testExampleMethod() {
        XCTAssertTrue(sut.exampleMethod())
    }
}
INNER_EOF

echo "✓ Created $$MODULE_NAME module in $$MODULE_DIR"
echo "• Module structure:"
echo "  - $$MODULE_DIR/BUILD.bazel"
echo "  - $$MODULE_DIR/Sources/$$MODULE_NAME.swift"
echo "  - $$MODULE_DIR/Tests/$${MODULE_NAME}Tests.swift"
echo ""
echo "Next steps:"
echo "1. Add your core types to $$MODULE_DIR/Sources/"
echo "2. Add tests to $$MODULE_DIR/Tests/"
echo "3. Build with: bazel build //Sources/$$MODULE_NAME:$$MODULE_NAME"
echo "4. Test with:  bazel test //Sources/$$MODULE_NAME:$${MODULE_NAME}Tests"
EOF
chmod +x $@
""" % (
    module_name,              # MODULE_NAME variable
    module_name,              # BUILD.bazel: library name
    module_name,              # BUILD.bazel: test name
    module_name,              # BUILD.bazel: test deps
    module_name,              # Source file name in header
    "2025-02-28",             # Creation date
    module_name,              # Struct name
    module_name,              # Init comment
    module_name,              # Test file header
    "2025-02-28",             # Creation date
    module_name,              # Import statement
    module_name,              # Test class name
    module_name,              # SUT type
    module_name,              # SUT initialization
),
        executable = True,
    )

def umbracore_bridge_module(
        name,
        srcs = None,
        foundation_free_deps = None,
        foundation_deps = None,
        visibility = None):
    """Creates a bridge module that connects Foundation-free and Foundation-dependent code.
    
    This macro creates a module that follows the bridge pattern established in our
    refactoring plan, ensuring proper separation of concerns.
    
    Args:
        name: Name of the bridge module.
        srcs: Source files for the module. Defaults to all Swift files in Sources/.
        foundation_free_deps: Dependencies that do not import Foundation.
        foundation_deps: Dependencies that may import Foundation.
        visibility: Visibility of the module. Defaults to public.
    """
    if srcs == None:
        srcs = native.glob(["Sources/**/*.swift"])
    
    if foundation_free_deps == None:
        foundation_free_deps = []
    
    if foundation_deps == None:
        foundation_deps = []
    
    if visibility == None:
        visibility = ["//visibility:public"]
    
    swift_library(
        name = name,
        srcs = srcs,
        module_name = name,
        visibility = visibility,
        deps = foundation_free_deps + foundation_deps,
    )
