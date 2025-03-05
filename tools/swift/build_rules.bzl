"""Swift build rules for UmbraCore project."""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("//tools/swift:compiler_options.bzl", "get_swift_copts")

def umbracore_swift_library(
        name,
        srcs = [],
        deps = [],
        data = [],
        copts = [],
        defines = [],
        module_name = None,
        alwayslink = False,
        generated_header_name = None,
        generates_header = False,
        swift_mode = "default",
        testonly = False,
        visibility = None,
        **kwargs):
    """A wrapper around swift_library with UmbraCore project defaults.
    
    Args:
        name: Name of the target
        srcs: Swift source files
        deps: Dependencies
        data: Additional data files
        copts: Additional compiler options
        defines: Preprocessor definitions
        module_name: Override the module name
        alwayslink: Whether to always link this library
        generated_header_name: Name for the generated Objective-C header
        generates_header: Whether to generate an Objective-C header
        swift_mode: Swift compilation mode ("default", "release", or "debug")
        testonly: Whether this target is for tests only
        visibility: Visibility specifier
        **kwargs: Additional arguments to pass to swift_library
    """
    swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        data = data,
        copts = copts + get_swift_copts(swift_mode),
        defines = defines,
        module_name = module_name,
        alwayslink = alwayslink,
        generated_header_name = generated_header_name,
        generates_header = generates_header,
        testonly = testonly,
        visibility = visibility,
        **kwargs
    )

def umbracore_swift_test_library(
        name,
        srcs = [],
        deps = [],
        data = [],
        copts = [],
        defines = [],
        module_name = None,
        visibility = None,
        **kwargs):
    """A wrapper around swift_library specifically for test libraries.
    
    Args:
        name: Name of the target
        srcs: Swift source files
        deps: Dependencies
        data: Additional data files
        copts: Additional compiler options
        defines: Preprocessor definitions
        module_name: Override the module name
        visibility: Visibility specifier
        **kwargs: Additional arguments to pass to swift_library
    """
    umbracore_swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        data = data,
        copts = copts,
        defines = defines + ["UMBRACORE_TESTING=1"],
        module_name = module_name,
        swift_mode = "debug",
        testonly = True,
        visibility = visibility,
        **kwargs
    )
