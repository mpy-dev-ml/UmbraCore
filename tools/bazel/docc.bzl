"""Rules for building DocC documentation."""

def _docc_archive_impl(ctx):
    """Implementation of the docc_archive rule."""
    output_dir = ctx.actions.declare_directory(ctx.attr.name)
    
    args = ctx.actions.args()
    args.add("docc")
    args.add("convert")
    args.add(ctx.file.src.path)
    args.add("--output-path")
    args.add(output_dir.path)
    args.add("--fallback-display-name")
    args.add(ctx.attr.display_name)
    args.add("--fallback-bundle-identifier")
    args.add(ctx.attr.bundle_identifier)
    args.add("--additional-symbol-graph-dir")
    args.add(ctx.file.symbol_graph.dirname)
    
    ctx.actions.run(
        executable = "/usr/bin/xcrun",
        arguments = [args],
        inputs = [ctx.file.src, ctx.file.symbol_graph],
        outputs = [output_dir],
        mnemonic = "DocC",
        progress_message = "Generating DocC documentation for %s" % ctx.attr.name,
    )
    
    return [DefaultInfo(files = depset([output_dir]))]

docc_archive = rule(
    implementation = _docc_archive_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = [".docc"],
            mandatory = True,
            doc = "The .docc package to process",
        ),
        "symbol_graph": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The symbol graph file for the target",
        ),
        "display_name": attr.string(
            mandatory = True,
            doc = "The display name for the documentation bundle",
        ),
        "bundle_identifier": attr.string(
            mandatory = True,
            doc = "The bundle identifier for the documentation bundle",
        ),
    },
)
