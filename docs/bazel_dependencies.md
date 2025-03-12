# UmbraCore Bazel Dependencies Guide

## Overview

This document explains how dependencies are managed in the UmbraCore project using Bazel, with a focus on Swift module dependencies and their impact on namespace resolution.

## Bazel Dependency Management

UmbraCore uses Bazel as its primary build system, which provides precise control over dependencies through explicit declaration in BUILD files.

### Key Concepts

- **Visibility**: Controls which targets can depend on each other
- **deps**: Explicit dependencies required for compilation
- **Module imports**: How Swift modules are imported and referenced
- **Toolchains**: Configure compiler flags and build environments

## Swift Module Dependencies

Swift modules in UmbraCore follow specific dependency patterns to avoid circular dependencies and namespace conflicts:

### Foundation-Free Module Dependencies

Foundation-free modules (`umbracore_foundation_free_module`) have the following dependency constraints:

- No dependencies on Foundation or other Apple frameworks
- May only depend on other foundation-free modules
- Must use primitive Swift types for interfaces

Example:
```bazel
umbracore_foundation_free_module(
    name = "SecureBytes",
    srcs = glob(["Sources/**/*.swift"]),
    visibility = ["//visibility:public"],
)
```

### Foundation-Independent Module Dependencies

Foundation-independent modules (`umbracore_foundation_independent_module`) have these constraints:

- No direct imports of Foundation
- May depend on bridge modules that provide Foundation-compatible interfaces
- May use type-erased wrappers for Foundation types

Example:
```bazel
umbracore_foundation_independent_module(
    name = "SecurityImplementation",
    srcs = glob(["Sources/**/*.swift"]),
    deps = [
        "//Sources/SecurityProtocolsCore",
        "//Sources/SecurityBridge",
    ],
    visibility = ["//visibility:public"],
)
```

### Foundation-Dependent Module Dependencies

Foundation-dependent modules (`umbracore_module`) have these constraints:

- May directly import Foundation and other Apple frameworks
- Should isolate Foundation dependencies behind clear interfaces
- Must follow specific import ordering

Example:
```bazel
umbracore_module(
    name = "UmbraKeychainService",
    srcs = glob(["Sources/**/*.swift"]),
    deps = [
        "//Sources/SecurityBridge",
        "//Sources/UmbraSecurity",
    ],
    visibility = ["//visibility:public"],
)
```

## Managing Namespace Conflicts

Bazel configuration can help manage namespace conflicts through:

1. **Import qualification**: Using the `-enable-implicit-module-import-name-qualification` flag
2. **Module mapping**: Creating explicit module maps for dependencies
3. **Visibility control**: Preventing inappropriate dependencies

Example BUILD file with namespace conflict prevention:
```bazel
swift_library(
    name = "SecurityBridgeProtocolAdapters",
    srcs = glob(["Sources/**/*.swift"]),
    copts = [
        "-enable-implicit-module-import-name-qualification",
    ],
    deps = [
        "//Sources/SecurityProtocolsCore",
        "//Sources/XPCProtocolsCore",
    ],
    visibility = ["//visibility:public"],
)
```

## Dependency Graph Tools

Bazel provides several tools to help visualize and analyze dependencies:

- `bazelisk query --output=graph "deps(//Sources/TARGET:TARGET)"` - Generate a dependency graph
- `bazelisk query --output=build "deps(//Sources/TARGET:TARGET)"` - List all dependencies
- `bazelisk query --output=xml "deps(//Sources/TARGET:TARGET, 1)"` - Direct dependencies only

These tools are invaluable for identifying and resolving dependency issues, especially when dealing with namespace conflicts.
