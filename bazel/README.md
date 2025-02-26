# UmbraCore Bazel Build System

## Overview

This directory contains configuration and extensions for the UmbraCore Bazel build system. The build system is designed to be efficient, maintainable, and consistent across the codebase.

## Key Components

### Macros

Located in `bazel/macros/`:

- `swift.bzl`: Standardised Swift library macros for consistent build configuration
  - `umbra_swift_library`: Standard library with proper target triple and concurrency settings
  - `umbra_test_library`: Test-specific library with appropriate settings

## Build Configuration

The build system uses several configuration files:

- `.bazelrc`: Main Bazel configuration
- `user.bazelrc`: User-specific settings (not checked into version control)
- `MODULE.bazel`: Bzlmod dependency configuration
- `BUILD.bazel`: Root build file

## Build Optimizations

The build system includes several optimizations:

1. **Worker Process Optimization**: Uses persistent worker processes for Swift compilation
2. **Local Caching**: Optimized disk and repository caching
3. **Memory Usage Optimizations**: JVM memory settings and sandbox reuse
4. **Build Stamping**: Version and build information embedded in releases

## Analysis Tools

The repository includes tools for analyzing and visualizing the build:

1. `analyze_build.sh`: Profiles and analyzes build performance
2. `visualize_deps.sh`: Generates dependency graphs for modules

## Usage Examples

### Standard Build Commands

```bash
# Full build
bazel build //...

# Debug build
bazel build --config=debug //...

# Release build
bazel build --config=release //...

# Test
bazel test //...
```

### Analysis Commands

```bash
# Profile entire build
./analyze_build.sh

# Analyze specific target
./analyze_build.sh //Sources/UmbraCore

# Visualize dependencies
./visualize_deps.sh
```

### Using Build Macros

In your BUILD.bazel files:

```python
load("//bazel/macros:swift.bzl", "umbra_swift_library")

umbra_swift_library(
    name = "MyModule",
    srcs = glob(["*.swift"]),
    deps = [
        "//Sources/DependencyModule",
        "@external_dependency//:Lib",
    ],
)
```

## Best Practices

1. Always use the standard macros for consistency
2. Set user-specific settings in user.bazelrc
3. Run dependency visualization for major changes
4. Profile builds regularly to spot performance regressions
