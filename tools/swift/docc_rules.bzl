"""DocC documentation rules for UmbraCore project."""

def swift_docc_documentation(
        name,
        srcs,
        module_name,
        deps = [],
        visibility = None):
    """Creates a DocC documentation target.
    
    This rule creates a DocC documentation bundle for a Swift module.
    
    Args:
        name: Name of the target
        srcs: Documentation source files (typically in .docc directories)
        module_name: Name of the Swift module being documented
        deps: Dependencies needed for compilation
        visibility: Visibility specifier
    """
    native.genrule(
        name = name,
        srcs = srcs,
        outs = ["doc_output/%s.doccarchive/PLACEHOLDER" % name],
        cmd = """
            # Create required output directory structure
            mkdir -p $(RULEDIR)/doc_output/{name}.doccarchive
            touch $(RULEDIR)/doc_output/{name}.doccarchive/PLACEHOLDER
            
            # Create a temporary directory for the compilation
            TMP_DIR=$$(mktemp -d)
            mkdir -p $$TMP_DIR/{name}.docc
            
            # Copy documentation sources to temporary directory
            for src in $(SRCS); do
                cp -R $$src/* $$TMP_DIR/{name}.docc/
            done
            
            # Generate symbol graph
            mkdir -p $$TMP_DIR/symbols
            swiftc -module-name {module_name} \\
                -emit-symbol-graph \\
                -emit-symbol-graph-dir $$TMP_DIR/symbols
            
            # Run Swift DocC to generate documentation
            mkdir -p $(RULEDIR)/doc_output
            # Use a more minimal invocation to debug what's going wrong
            xcrun docc convert \\
                --fallback-display-name "{module_name}" \\
                --fallback-bundle-identifier "dev.mpy.{module_name}" \\
                --fallback-bundle-version "1.0.0" \\
                --additional-symbol-graph-dir $$TMP_DIR/symbols \\
                --output-path $(RULEDIR)/doc_output/{name}.doccarchive \\
                --index $$TMP_DIR/{name}.docc/SecurityInterfaces.md \\
                $$TMP_DIR/{name}.docc
            
            # Clean up temporary directory
            rm -rf $$TMP_DIR
        """.format(
            name = name,
            module_name = module_name,
        ),
        message = "Generating DocC documentation for " + module_name,
        visibility = visibility,
    )

def umbracore_docc_documentation(
        name,
        srcs,
        module_name,
        deps = [],
        visibility = None):
    """Creates a DocC documentation target with UmbraCore defaults.
    
    Args:
        name: Name of the target
        srcs: Documentation source files (typically in .docc directories)
        module_name: Name of the Swift module being documented
        deps: Dependencies needed for compilation
        visibility: Visibility specifier
    """
    swift_docc_documentation(
        name = name,
        srcs = srcs,
        module_name = module_name,
        deps = deps,
        visibility = visibility,
    )
