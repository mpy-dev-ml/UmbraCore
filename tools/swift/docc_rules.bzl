"""
Rules for building DocC documentation within Bazel.
"""

def _docc_archive_impl(ctx):
    """Implementation for the docc_archive rule."""
    
    output_dir = ctx.actions.declare_directory(ctx.attr.name + ".doccarchive")
    
    # Create a placeholder documentation archive
    command = """
        set -e
        
        # Create a basic documentation bundle
        mkdir -p {output}
        
        # Create Info.plist
        cat > {output}/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.umbra.{module}</string>
    <key>CFBundleName</key>
    <string>{module}</string>
    <key>CFBundleDisplayName</key>
    <string>{module} Documentation</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
</dict>
</plist>
EOF
        
        # Create index.html
        mkdir -p {output}/documentation
        cat > {output}/documentation/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>{module} Documentation</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
</head>
<body>
    <h1>{module} Documentation</h1>
    <p>This is a placeholder for the {module} documentation.</p>
    <p>Full documentation will be generated in a future update.</p>
</body>
</html>
EOF
    """.format(
        module = ctx.attr.module_name,
        output = output_dir.path,
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
