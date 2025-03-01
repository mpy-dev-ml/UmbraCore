"""
UmbraCore module build rules.
These rules define standard ways to build different types of UmbraCore modules.
"""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

def umbracore_foundation_free_module(
        name,
        srcs = None,
        deps = None,
        copts = None,
        visibility = None,
        testonly = None,
        additional_inputs = None):
    """
    Creates a Swift module that is completely free of Foundation dependencies.
    
    Args:
        name: Name of the module
        srcs: Source files (defaults to glob Sources/**/*.swift)
        deps: Dependencies (should not include Foundation)
        copts: Compiler options
        visibility: Visibility
        testonly: Whether this is a test-only target
        additional_inputs: Additional input files to include in the module
    """
    if srcs == None:
        srcs = native.glob(["Sources/**/*.swift"])
    
    if deps == None:
        deps = []
    
    if copts == None:
        copts = [
            "-target", "arm64-apple-macos15.4",
            "-g",
            "-swift-version", "5",
        ]
    
    if additional_inputs == None:
        additional_inputs = []
    
    swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        copts = copts,
        visibility = visibility,
        testonly = testonly,
        additional_inputs = additional_inputs,
    )

def umbracore_foundation_independent_module(
        name,
        srcs = None,
        deps = None,
        copts = None,
        visibility = None,
        testonly = None):
    """
    Creates a Swift module that may use other modules but avoids Foundation dependencies.
    
    Args:
        name: Name of the module
        srcs: Source files (defaults to glob Sources/**/*.swift)
        deps: Dependencies (should not include Foundation)
        copts: Compiler options
        visibility: Visibility
        testonly: Whether this is a test-only target
    """
    if srcs == None:
        srcs = native.glob(["Sources/**/*.swift"])
    
    if deps == None:
        deps = []
    
    if copts == None:
        copts = [
            "-target", "arm64-apple-macos15.4",
            "-g",
            "-swift-version", "5",
        ]
    
    swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        copts = copts,
        visibility = visibility,
        testonly = testonly,
    )

def umbracore_test_module(
        name,
        srcs = None,
        deps = None,
        copts = None,
        visibility = None):
    """
    Creates a Swift test module.
    
    Args:
        name: Name of the test module
        srcs: Source files (defaults to glob Tests/**/*.swift)
        deps: Dependencies
        copts: Compiler options
        visibility: Visibility
    """
    if srcs == None:
        srcs = native.glob(["Tests/**/*.swift"])
    
    if deps == None:
        deps = []
    
    if copts == None:
        copts = []
    
    swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        copts = copts,
        testonly = True,
        visibility = visibility,
    )
