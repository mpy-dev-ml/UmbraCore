"""Rules for overriding Swift package dependencies build settings."""

def override_build_settings(name, copts=None, target_compatible_with=None, **kwargs):
    """Overrides for specific Swift packages to add custom build settings."""
    
    # Add library evolution support for CryptoSwift
    if name == "CryptoSwift":
        if copts == None:
            copts = []
        
        # Enable library evolution support for binary compatibility
        copts.extend([
            "-Xfrontend",
            "-enable-library-evolution",
            "-target",
            "arm64-apple-macos15.4",
        ])
    
    return {
        "copts": copts,
        "target_compatible_with": target_compatible_with,
        **kwargs
    }
