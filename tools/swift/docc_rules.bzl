"""
Rules for building DocC documentation within Bazel.
"""

def _docc_archive_impl(ctx):
    """Implementation for the docc_archive rule."""
    
    output_dir = ctx.actions.declare_directory(ctx.attr.name + ".doccarchive")
    
    # Symbol graph generation args
    symbol_graph_args = []
    if ctx.attr.sdk:
        symbol_graph_args.append("--sdk " + ctx.attr.sdk)
    if ctx.attr.target:
        symbol_graph_args.append("--target " + ctx.attr.target)
    if ctx.attr.product_name:
        symbol_graph_args.append("--product-name " + ctx.attr.product_name)
    
    # Build a command that runs our Go tool
    command = """
        set -e
        
        # Build the DocC tool
        cd {workspace}/tools/go
        go build -o bin/docc cmd/docc/main.go
        
        # Run the DocC tool
        ./bin/docc \
            --module {module} \
            --output {output} \
            {symbol_graph_args} \
            --verbose
    """.format(
        workspace = ctx.workspace_name,
        module = ctx.attr.module_name,
        output = output_dir.path,
        symbol_graph_args = " ".join(symbol_graph_args),
    )
    
    # Execute the command
    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = [output_dir],
        command = command,
        mnemonic = "DoCCGenerate",
        progress_message = "Generating DocC documentation for %s" % ctx.attr.module_name,
    )
    
    return [DefaultInfo(files = depset([output_dir]))]

docc_archive = rule(
    implementation = _docc_archive_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            doc = "Source files for the module",
        ),
        "module_name": attr.string(
            mandatory = True,
            doc = "Name of the Swift module to document",
        ),
        "sdk": attr.string(
            default = "macosx",
            doc = "SDK to use for symbol graph generation",
        ),
        "target": attr.string(
            doc = "Target to use for symbol graph generation",
        ),
        "product_name": attr.string(
            doc = "Product name to use for documentation",
        ),
    },
)

def docc_documentation(name, module_name, srcs, **kwargs):
    """
    Generate DocC documentation for a Swift module.
    
    Args:
        name: Name of the rule
        module_name: Name of the Swift module to document
        srcs: Source files for the module
        **kwargs: Additional arguments
    """
    
    docc_archive(
        name = name,
        module_name = module_name,
        srcs = srcs,
        **kwargs
    )
    
    # Rule to host the documentation for local preview
    native.sh_binary(
        name = name + "_preview",
        srcs = ["preview_docc.sh"],
        data = [":" + name],
    )

def docc_serve(name, docc_archive):
    """
    Create a rule to serve a DocC archive.
    
    Args:
        name: Name of the rule
        docc_archive: DocC archive to serve
    """
    
    native.sh_binary(
        name = name,
        srcs = ["serve_docc.sh"],
        data = [docc_archive],
    )
