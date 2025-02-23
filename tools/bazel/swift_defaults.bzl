"""Swift build defaults for UmbraCore."""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

def swift_library_cached(name, srcs, deps = None, visibility = None, module_name = None, copts = None, **kwargs):
    """A macro that wraps swift_library with caching optimizations.

    Args:
        name: Name of the target.
        srcs: Source files.
        deps: Dependencies.
        visibility: Target visibility.
        module_name: Name of the Swift module.
        copts: Compiler options.
        **kwargs: Additional arguments to pass to swift_library.
    """
    if not copts:
        copts = []
    
    if not deps:
        deps = []

    # Always ensure target triple is set at the module level
    target_triple = ["-target", "arm64-apple-macos14.0"]
    if not any([opt.startswith("-target") for opt in copts]):
        copts = target_triple + copts

    swift_library(
        name = name,
        srcs = srcs,
        module_name = module_name or name,
        deps = deps,
        visibility = visibility,
        copts = copts,
        tags = kwargs.pop("tags", []) + [
            "swift-cache",  # Custom tag for cache management
        ],
        **kwargs
    )
