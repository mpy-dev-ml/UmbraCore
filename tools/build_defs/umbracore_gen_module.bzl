"""
UmbraCore module generator rule with enhanced type safety.

This rule provides a way to generate new Foundation-free modules with the standard directory structure
in accordance with the UmbraCore refactoring plan.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

# Define a provider to enforce structure of module data
ModuleInfo = provider(
    doc = "Information about an UmbraCore module",
    fields = {
        "name": "The module name (string)",
        "path": "The module path (string)",
    },
)

def _validate_string(value, param_name):
    """Validates that a value is a string.
    
    Args:
        value: The value to validate
        param_name: Name of the parameter for error reporting
        
    Returns:
        The validated string
        
    Fails:
        If value is not a string
    """
    if not value or type(value) != "string":
        fail("%s must be a non-empty string, got %s" % (param_name, type(value)))
    return value

def _generate_build_file(module_name):
    """Generates content for BUILD.bazel file.
    
    Args:
        module_name: Name of the module (string)
        
    Returns:
        Content for BUILD.bazel file (string)
    """
    _validate_string(module_name, "module_name")
    
    return """load("//tools/build_defs:umbracore_module.bzl", "umbracore_foundation_free_module", "umbracore_test_module")

umbracore_foundation_free_module(
    name = "%s",
    visibility = ["//visibility:public"],
    deps = [
        # Add foundation-free dependencies here
    ],
)

umbracore_test_module(
    name = "%sTests",
    deps = [
        ":%s",
        # Add test dependencies here
    ],
)
""" % (module_name, module_name, module_name)

def _generate_source_file(module_name):
    """Generates content for main source file.
    
    Args:
        module_name: Name of the module (string)
        
    Returns:
        Content for source file (string)
    """
    _validate_string(module_name, "module_name")
    
    return """// %s.swift
// %s
//
// Created as part of the UmbraCore Foundation Decoupling project
//

/// Primary entry point for the %s module.
/// This module is designed to be fully Foundation-free.
public enum %s {
    /// Module version
    public static let version = "1.0.0"
}
""" % (module_name, module_name, module_name, module_name)

def _generate_test_file(module_name):
    """Generates content for test file.
    
    Args:
        module_name: Name of the module (string)
        
    Returns:
        Content for test file (string)
    """
    _validate_string(module_name, "module_name")
    
    return """// %sTests.swift
// %s
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import XCTest
@testable import %s

class %sTests: XCTestCase {
    
    func testVersion() {
        XCTAssertFalse(%s.version.isEmpty)
    }
}
""" % (module_name, module_name, module_name, module_name, module_name)

def _umbracore_gen_module_impl(ctx):
    """Implementation of the umbracore_gen_module rule.
    
    Args:
        ctx: Rule context
        
    Returns:
        Default provider with created files
    """
    module_name = _validate_string(ctx.attr.module_name, "module_name")
    module_path = "Sources/%s" % module_name
    
    # Generate file contents for the module
    build_content = _generate_build_file(module_name)
    source_content = _generate_source_file(module_name) 
    test_content = _generate_test_file(module_name)
    
    # Create a shell script that will create the module in the source tree
    script_content = """#!/bin/bash
# Get the absolute path to the workspace root
WORKSPACE_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
echo "Workspace root: $WORKSPACE_ROOT"

echo "Creating %s module in $WORKSPACE_ROOT/%s..."

# Create the directory structure
mkdir -p "$WORKSPACE_ROOT/%s/Sources" "$WORKSPACE_ROOT/%s/Tests"

# Create the BUILD.bazel file
cat > "$WORKSPACE_ROOT/%s/BUILD.bazel" << 'EOF'
%s
EOF

# Create the source file
cat > "$WORKSPACE_ROOT/%s/Sources/%s.swift" << 'EOF'
%s
EOF

# Create the test file
cat > "$WORKSPACE_ROOT/%s/Tests/%sTests.swift" << 'EOF'
%s
EOF

echo "✓ Created %s module in $WORKSPACE_ROOT/%s"
echo "• Module structure:"
echo "  - $WORKSPACE_ROOT/%s/BUILD.bazel"
echo "  - $WORKSPACE_ROOT/%s/Sources/%s.swift"
echo "  - $WORKSPACE_ROOT/%s/Tests/%sTests.swift"
echo ""
echo "Next steps:"
echo "1. Add your core types to $WORKSPACE_ROOT/%s/Sources/"
echo "2. Add tests to $WORKSPACE_ROOT/%s/Tests/"
echo "3. Update dependencies in $WORKSPACE_ROOT/%s/BUILD.bazel if needed"
""" % (
        module_name, 
        module_path,
        module_path, 
        module_path,
        module_path, 
        build_content,
        module_path, 
        module_name, 
        source_content,
        module_path, 
        module_name, 
        test_content,
        module_name, 
        module_path,
        module_path, 
        module_path, 
        module_name, 
        module_path, 
        module_name,
        module_path,
        module_path,
        module_path
    )
    
    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(executable, script_content, is_executable = True)
    
    return [
        DefaultInfo(
            executable = executable,
        ),
    ]

# Rule definition
umbracore_gen_module = rule(
    implementation = _umbracore_gen_module_impl,
    attrs = {
        "module_name": attr.string(
            doc = "Name of the module to generate",
            mandatory = True,
        ),
    },
    executable = True,
)
