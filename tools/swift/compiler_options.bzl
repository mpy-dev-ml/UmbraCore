# Swift compiler options for the project
# These are centralized here for consistency across all targets

# Swift 6 preparation options
SWIFT_6_PREP_OPTIONS = [
    "-enable-upcoming-feature", "Isolated",
    "-enable-upcoming-feature", "ExistentialAny",
    "-enable-upcoming-feature", "StrictConcurrency",
    "-enable-upcoming-feature", "InternalImportsByDefault",
    "-warn-swift-5-to-swift-6-path",
]

# Concurrency safety options
CONCURRENCY_SAFETY_OPTIONS = [
    "-strict-concurrency=complete",
    "-enable-actor-data-race-checks",
    "-warn-concurrency",
]

# Target platform options
PLATFORM_OPTIONS = [
    "-target", "arm64-apple-macos14.0",
]

# Performance optimization options for release builds
OPTIMIZATION_OPTIONS = [
    "-O", 
    "-whole-module-optimization",
]

# Debug options
DEBUG_OPTIONS = [
    "-g",
    "-Onone",
]

# All swift compile options for standard builds
DEFAULT_SWIFT_COPTS = PLATFORM_OPTIONS + CONCURRENCY_SAFETY_OPTIONS + SWIFT_6_PREP_OPTIONS

# Release build options
RELEASE_SWIFT_COPTS = DEFAULT_SWIFT_COPTS + OPTIMIZATION_OPTIONS

# Debug build options
DEBUG_SWIFT_COPTS = DEFAULT_SWIFT_COPTS + DEBUG_OPTIONS

def get_swift_copts(mode = "default"):
    """Returns the appropriate Swift compiler options based on the build mode.
    
    Args:
        mode: Build mode ("default", "release", or "debug")
        
    Returns:
        List of compiler options
    """
    if mode == "release":
        return RELEASE_SWIFT_COPTS
    elif mode == "debug":
        return DEBUG_SWIFT_COPTS
    else:
        return DEFAULT_SWIFT_COPTS
