# macOS Target Settings Guide

## Overview

This document outlines the macOS minimum version settings for the UmbraCore project. As of March 2025, the minimum supported macOS version is **14.7.4**.

## Key Configuration Files

The macOS target version is defined in these central locations:

1. **compiler_options.bzl** - Defines Swift compiler flags for all targets
   ```python
   PLATFORM_OPTIONS = [
       "-target", "arm64-apple-macos14.7.4",
   ]
   ```

2. **.bazelrc** - Sets global build settings
   ```
   build --macos_minimum_os=14.7.4
   ```

3. **bazel/macros/swift.bzl** - Configures test environment variables
   ```python
   base_env = {
       "MACOS_DEPLOYMENT_TARGET": "14.7.4",
       # ...
   }
   ```

4. **Package.swift** - Sets Swift Package Manager configuration
   ```swift
   platforms: [
       .macOS(.v14_7),
   ],
   ```

## Third-Party Dependencies

Our third-party dependencies have the following macOS compatibility:

1. **SwiftyBeaver (2.1.1)** - Compatible with macOS 10.10+
2. **CryptoSwift (1.8.4)** - Compatible with macOS 10.13+

Both dependencies are built with our project settings through Swift Package Manager and Bazel, ensuring they use the correct macOS target.

## Validation

To validate that all targets are using the correct macOS version:

```bash
./tools/validate_macos_target.sh
```

## Troubleshooting

If you encounter build errors related to macOS version incompatibilities:

1. Ensure you're using the latest project configuration by pulling recent changes
2. Run `./tools/enforce_macos_target.sh` to enforce consistent settings
3. Clear the Bazel cache with `bazelisk clean --expunge`
4. If problems persist with third-party dependencies, check their compatibility with macOS 14.7.4

## Adding New Targets

When adding new targets to the project:

1. Use our standard macros from `bazel/macros/swift.bzl` (e.g., `umbra_swift_library`)
2. Avoid hardcoding platform/target flags in individual BUILD files
3. If custom flags are needed, extend the central compiler options rather than overriding

## Updating the Minimum macOS Version

When updating the minimum macOS version in the future:

1. Update `tools/swift/compiler_options.bzl`
2. Update `.bazelrc`
3. Update `bazel/macros/swift.bzl`
4. Update `Package.swift`
5. Run `./tools/enforce_macos_target.sh`
6. Validate with `./tools/validate_macos_target.sh`
