"""
Swift macros for UmbraCore build system.
"""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")

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
        "-enable-testing",
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

def umbra_swift_test(
        name,
        srcs,
        deps = [],
        data = [],
        copts = [],
        swiftc_inputs = [],
        env = {},
        tags = [],
        **kwargs):
    """A macro that creates a Swift test target with UmbraCore-specific configuration.

    Args:
        name: Name of the test target.
        srcs: Source files to compile.
        deps: Dependencies of the test target.
        data: Data files required by the test.
        copts: Additional compiler options.
        swiftc_inputs: Additional inputs to swiftc.
        env: Environment variables for the test.
        tags: Tags for the test target.
        **kwargs: Additional arguments to pass to swift_test.
    """
    
    # Base compiler options for Swift tests
    base_copts = [
        "-target", "arm64-apple-macos14.0",
        "-enable-testing",
        "-swift-version", "5",
        "-strict-concurrency=complete",
    ]
    
    # Base environment variables for Swift tests
    base_env = {
        "MACOS_DEPLOYMENT_TARGET": "14.0",
        "SWIFT_DETERMINISTIC_HASHING": "1",
        "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
    }
    
    # Merge the base environment with any provided environment variables
    test_env = dict(base_env)
    test_env.update(env)
    
    # Create the Swift test target
    swift_test(
        name = name,
        srcs = srcs,
        deps = deps,
        data = data,
        copts = base_copts + copts,
        swiftc_inputs = swiftc_inputs,
        env = test_env,
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:arm64",
        ],
        tags = tags,
        **kwargs
    )
