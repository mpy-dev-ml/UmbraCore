"""
UmbraCore module build rules to ensure consistent module structure.

These rules automate the creation of UmbraCore modules with the proper 
structure and dependencies according to our refactoring plan.
"""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")

def umbracore_foundation_free_module(
        name,
        srcs = None,
        deps = None,
        testonly = False,
        visibility = None):
    """Creates a Foundation-free UmbraCore module with standard structure.
    
    This macro generates a Swift library target that explicitly has no 
    Foundation dependencies and follows the architecture defined in our 
    refactoring plan.
    
    Args:
        name: Name of the module to create.
        srcs: Source files for the module. Defaults to all Swift files in Sources/.
        deps: Additional dependencies. Must be Foundation-free.
        testonly: Whether this module is only used for testing.
        visibility: Visibility of the module. Defaults to public.
    """
    if srcs == None:
        srcs = native.glob(["Sources/**/*.swift"])
    
    if deps == None:
        deps = []
    
    if visibility == None:
        visibility = ["//visibility:public"]
    
    swift_library(
        name = name,
        srcs = srcs,
        module_name = name,
        visibility = visibility,
        deps = deps,
        testonly = testonly,
    )

def umbracore_test_module(
        name,
        srcs = None,
        deps = None):
    """Creates a test target for a UmbraCore module.
    
    Args:
        name: Name of the test target.
        srcs: Test source files. Defaults to all Swift files in Tests/.
        deps: Dependencies needed for tests.
    """
    if srcs == None:
        srcs = native.glob(["Tests/**/*.swift"])
    
    if deps == None:
        deps = []
    
    module_name = name.replace("Tests", "")
    
    # Create a testable version of the module
    swift_library(
        name = module_name + "TestLib",
        srcs = native.glob(["Sources/**/*.swift"]),
        module_name = module_name,
        visibility = ["//visibility:private"],
        deps = deps,
        testonly = True,
        copts = ["-enable-testing"],
    )
    
    # Create the test target
    swift_test(
        name = name,
        srcs = srcs,
        deps = deps + [":" + module_name + "TestLib"],
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
