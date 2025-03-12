"""
MacOS ARM64 toolchain configuration for UmbraCore tests
"""

load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "tool_path")

def _impl(ctx):
    # Define the toolchain with explicit architecture and SDK settings
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/bin/clang",
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/ar",
        ),
        tool_path(
            name = "cpp",
            path = "/usr/bin/cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/usr/bin/gcov",
        ),
        tool_path(
            name = "nm",
            path = "/usr/bin/nm",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/bin/objdump",
        ),
        tool_path(
            name = "strip",
            path = "/usr/bin/strip",
        ),
    ]

    # Compiler flags specifically for ARM64 architecture
    cxx_builtin_include_directories = [
        "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/include",
        "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks",
    ]

    # Return the toolchain configuration with only supported parameters
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "macos-arm64-toolchain",
        host_system_name = "x86_64-apple-macos",
        target_system_name = "arm64-apple-macos",
        target_cpu = "darwin_arm64",
        target_libc = "macos",
        compiler = "clang",
        abi_version = "darwin_arm64",
        abi_libc_version = "darwin_arm64",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        # NOTE: Removed cxx_flags and link_flags which are not supported in this Bazel version
    )

macos_arm64_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
