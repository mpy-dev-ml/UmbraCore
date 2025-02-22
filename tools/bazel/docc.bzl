"""Rules for building DocC documentation."""

load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")

def _docc_archive_impl(ctx):
    """Implementation of the docc_archive rule."""
    output_dir = ctx.actions.declare_directory(ctx.attr.name)
    symbol_graph_dir = ctx.actions.declare_directory(ctx.attr.name + "_symbols")
    
    # Generate the symbol graph
    symbol_args = ctx.actions.args()
    symbol_args.add("swiftc")
    symbol_args.add("-emit-symbol-graph")
    symbol_args.add("-emit-module")
    symbol_args.add("-target")
    symbol_args.add("arm64-apple-macos14.0")
    symbol_args.add("-sdk")
    symbol_args.add("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
    symbol_args.add("-module-name")
    symbol_args.add(ctx.attr.module_name)
    symbol_args.add("-emit-symbol-graph-dir")
    symbol_args.add(symbol_graph_dir.path)
    
    # Add search paths for dependencies
    for dep in ctx.attr.deps:
        if SwiftInfo in dep:
            for module in dep[SwiftInfo].transitive_modules.to_list():
                symbol_args.add("-I")
                symbol_args.add(module.swift.swiftmodule.dirname)
    
    for src in ctx.files.srcs:
        symbol_args.add(src.path)
    
    ctx.actions.run(
        executable = "/usr/bin/xcrun",
        arguments = [symbol_args],
        inputs = ctx.files.srcs + [
            module.swift.swiftmodule
            for dep in ctx.attr.deps
            if SwiftInfo in dep
            for module in dep[SwiftInfo].transitive_modules.to_list()
        ],
        outputs = [symbol_graph_dir],
        mnemonic = "SwiftSymbolGraph",
        progress_message = "Generating symbol graph for %s" % ctx.attr.name,
    )
    
    # Generate the DocC archive
    args = ctx.actions.args()
    args.add("docc")
    args.add("convert")
    
    # Find the .docc directory in the bundle
    docc_dir = None
    for file in ctx.files.docc_bundle:
        if file.dirname.endswith(".docc"):
            docc_dir = file.dirname
            break
    if not docc_dir:
        fail("No .docc directory found in bundle")
    
    args.add(docc_dir)
    args.add("--output-dir")
    args.add(output_dir.path)
    args.add("--fallback-display-name")
    args.add(ctx.attr.display_name)
    args.add("--fallback-bundle-identifier")
    args.add(ctx.attr.bundle_identifier)
    args.add("--additional-symbol-graph-dir")
    args.add(symbol_graph_dir.path)
    args.add("--hosting-base-path")
    args.add(ctx.attr.name)
    args.add("--transform-for-static-hosting")
    
    # Add dependencies' symbol graphs
    for dep in ctx.attr.deps:
        if SwiftInfo in dep:
            for module in dep[SwiftInfo].transitive_modules.to_list():
                args.add("--additional-symbol-graph-dir")
                args.add(module.swift.swiftmodule.dirname)
    
    ctx.actions.run(
        executable = "/usr/bin/xcrun",
        arguments = [args],
        inputs = ctx.files.docc_bundle + [symbol_graph_dir] + ctx.files.srcs + [
            module.swift.swiftmodule
            for dep in ctx.attr.deps
            if SwiftInfo in dep
            for module in dep[SwiftInfo].transitive_modules.to_list()
        ],
        outputs = [output_dir],
        mnemonic = "DocCArchive",
        progress_message = "Generating DocC archive for %s" % ctx.attr.name,
    )
    
    return [DefaultInfo(files = depset([output_dir]))]

docc_archive = rule(
    implementation = _docc_archive_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(providers = [SwiftInfo]),
        "docc_bundle": attr.label(allow_files = True),
        "module_name": attr.string(mandatory = True),
        "display_name": attr.string(mandatory = True),
        "bundle_identifier": attr.string(mandatory = True),
    },
)
