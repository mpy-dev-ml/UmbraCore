"""
Swift macros for UmbraCore build system.
"""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

def umbra_swift_library(
        name,
        srcs,
        deps = [],
        testonly = False,
        additional_copts = [],
        **kwargs):
    """Standard Swift library configuration for UmbraCore.

    Args:
        name: Target name
        srcs: Source files
        deps: Dependencies
        testonly: Whether this is a test-only library
        additional_copts: Additional compiler options
        **kwargs: Additional arguments to pass to swift_library
    """
    copts = [
        "-target",
        "arm64-apple-macos14.0",
        "-strict-concurrency=complete",
        "-enable-actor-data-race-checks",
        "-warn-concurrency",
    ] + additional_copts

    swift_library(
        name = name,
        srcs = srcs,
        copts = copts,
        module_name = name,
        testonly = testonly,
        visibility = ["//visibility:public"],
        deps = deps,
        **kwargs
    )

def umbra_test_library(
        name,
        srcs,
        deps = [],
        additional_copts = [],
        **kwargs):
    """Standard Swift test library configuration for UmbraCore.

    Args:
        name: Target name
        srcs: Source files
        deps: Dependencies
        additional_copts: Additional compiler options
        **kwargs: Additional arguments to pass to swift_library
    """
    umbra_swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        testonly = True,
        additional_copts = additional_copts,
        **kwargs
    )
