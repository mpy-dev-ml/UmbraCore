# UmbraCore Adapter Module Refactoring Plan

**Date:** 6 March 2025  
**Author:** MPY & Cascade  
**Status:** Draft

## 1. Executive Summary

UmbraCore's architecture currently relies on several isolation pattern anti-patterns, specifically in the form of:

1. **Isolation files** - Files with explicit "Isolation" naming that contain bridging code
2. **Type aliases** - Type aliases used to redirect types between modules
3. **Error mapping functions** - Functions that map between error types across module boundaries
4. **Circular dependencies** - Modules depending on each other directly or indirectly

This document outlines a systematic approach to refactor these isolation patterns into a more maintainable adapter module architecture, which will prepare the codebase for Swift 6's enhanced module system. We will begin with the UmbraSecurityCore module as a proof of concept, as it presents typical adapter patterns but with fewer dependencies than more critical modules.

## 2. Problem Analysis

### 2.1 Current Isolation Patterns

Our codebase analysis revealed several pervasive isolation patterns:

| Pattern | Description | Impact |
|---------|-------------|--------|
| Isolation Files | Files with "Isolation" in the name that contain bridging code | Creates implicit dependencies; makes refactoring difficult |
| Type Aliases | Declaring type aliases to redirect types between modules | Creates hidden dependencies; reduces code clarity |
| Error Mapping | Functions that convert between error types | Adds complexity; creates tight coupling |
| Circular Dependencies | Modules depending on each other | Makes the architecture fragile; complicates testing |

### 2.2 UmbraSecurityCore Analysis

UmbraSecurityCore exhibits similar adapter patterns and a circular dependency, making it an ideal candidate for our initial refactoring effort:

- **Adapter Files:**
  - `AnyCryptoService.swift` - Type-erased wrapper for CryptoServiceProtocol
  - `CryptoServiceTypeAdapter.swift` - Adapter between crypto service implementations
  - `FoundationTypeBridge.swift` - Protocol for bridging Foundation-free/dependent types

- **Current Dependencies:**
  - SecurityProtocolsCore
  - UmbraCoreTypes

- **Existing Issues:**
  - Circular dependency on itself
  - Sendable concurrency warnings in AnyCryptoService.swift
  - Unreachable catch blocks in DefaultCryptoService.swift

## 3. Refactoring Approach

### 3.1 Core Principles

1. **Separation of Concerns** - Clearly separate adapter code from business logic
2. **Uni-directional Dependencies** - Ensure dependencies flow in one direction
3. **Interface Stability** - Maintain public interfaces to minimise breaking changes
4. **Compatibility** - Ensure backward compatibility during the transition

### 3.2 Module Structure Pattern

For each module with isolation patterns, we will extract adapter functionality into a dedicated module:

```
Original Module
  │
  ├── Core Logic
  │     └── Implementation files
  │
  └── Isolation/Adapter Code
        └── Adapter files, type aliases, etc.
```

Will be refactored to:

```
Original Module               New Adapter Module
  │                               │
  ├── Core Logic     ┌─────────── ├── Public Interfaces
  │     │            │            │
  │     └────────────┘            └── Adapter Implementations
  │
  └── Implementation-only files
```

### 3.3 Step-by-Step Refactoring Process for UmbraSecurityCore

#### Step 1: Create New Adapter Module Structure

1. Create a new module directory `SecurityCoreAdapters`
2. Create a BUILD.bazel file for the new module
3. Create a module structure:
   - `Sources/`
   - `Sources/Adapters/`
   - `Sources/Protocols/`

#### Step 2: Move Adapter Code to New Module

1. Move these files to the new module:
   - `AnyCryptoService.swift` → `SecurityCoreAdapters/Sources/Adapters/`
   - `CryptoServiceTypeAdapter.swift` → `SecurityCoreAdapters/Sources/Adapters/`
   - `FoundationTypeBridge.swift` → `SecurityCoreAdapters/Sources/Protocols/`

2. Update imports in these files to reflect new module locations

#### Step 3: Update the Original Module

1. Update imports in the UmbraSecurityCore module to reference the new adapter module
2. Update the UmbraSecurityCore.swift factory methods to reference adapters from the new module
3. Update the BUILD.bazel file to depend on the new adapter module

#### Step 4: Fix Specific Issues

1. Address Sendable concurrency warnings in AnyCryptoService.swift
2. Fix unreachable catch blocks in DefaultCryptoService.swift
3. Ensure proper handling of Swift 6 enum case handling with @unknown default

### 3.4 Testing Strategy

1. **Build Verification:**
   - Ensure both modules build individually: `bazelisk build //Sources/UmbraSecurityCore:UmbraSecurityCore`
   - Ensure both modules build together: `bazelisk build //Sources/SecurityCoreAdapters:SecurityCoreAdapters`

2. **Unit Tests:**
   - Run existing tests to verify functionality is preserved: `bazelisk test //Sources/UmbraSecurityCore:UmbraSecurityCoreTests`
   - Create new tests for the adapter module if needed

3. **Integration Tests:**
   - Verify that dependent modules still work correctly

## 4. Implementation Details

### 4.1 New Module BUILD.bazel

```python
load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)

swift_library(
    name = "SecurityCoreAdapters",
    srcs = glob(["Sources/**/*.swift"]),
    module_name = "SecurityCoreAdapters",
    target_compatible_with = ["@platforms//os:macos"],
    copts = [
        "-target", "arm64-apple-macos15.4",
        "-Xfrontend", "-enable-library-evolution",
        "-g",
        "-swift-version", "5",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/SecurityProtocolsCore",
        "//Sources/UmbraCoreTypes",
    ],
)
```

### 4.2 Updated UmbraSecurityCore BUILD.bazel

```python
load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
    "swift_test",
)

swift_library(
    name = "UmbraSecurityCore",
    srcs = glob([
        "Sources/**/*.swift",
        # Exclude moved adapter files
        "!Sources/Adapters/*.swift",
    ]),
    module_name = "UmbraSecurityCore",
    target_compatible_with = ["@platforms//os:macos"],
    copts = [
        "-target", "arm64-apple-macos15.4",
        "-Xfrontend", "-enable-library-evolution",
        "-g",
        "-swift-version", "5",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/SecureBytes",
        "//Sources/SecurityProtocolsCore",
        "//Sources/SecurityCoreAdapters",
    ],
)

swift_test(
    name = "UmbraSecurityCoreTests",
    srcs = glob(["Tests/**/*.swift"]),
    target_compatible_with = ["@platforms//os:macos"],
    copts = [
        "-target", "arm64-apple-macos15.4",
        "-g",
        "-swift-version", "5",
    ],
    deps = [
        ":UmbraSecurityCore",
        "//Sources/SecureBytes",
        "//Sources/SecurityProtocolsCore",
        "//Sources/SecurityCoreAdapters",
    ],
)
```

## 5. Validation Criteria

The refactoring will be considered successful if:

1. All builds pass without errors
2. All tests pass without regressions
3. Circular dependencies are resolved
4. The module structure follows the defined pattern
5. Swift 6 compatibility warnings are addressed
6. No changes to public interfaces that would break client code

## 6. Rollout Plan

1. **Phase 1:** UmbraSecurityCore refactoring (proof of concept)
2. **Phase 2:** Apply same pattern to 2-3 non-critical modules
3. **Phase 3:** Apply to CoreTypes and other central modules
4. **Phase 4:** Address any remaining module isolation issues

## 7. Appendix

### 7.1 Module Analysis Tools

We have two primary analysis tools:

1. **bazel_analyze.go** - Analyzes Bazel dependencies
   ```
   go run bazel_analyze.go -module=ModuleName
   ```

2. **swift_code_analyzer.go** - Analyzes Swift code structure and patterns
   ```
   go run swift_code_analyzer.go --modules=ModuleName --verbose
   ```

### 7.2 Reference Documents

- [Swift 6 Module System Documentation](https://www.swift.org/documentation/)
- [UmbraCore Refactoring Plan](UmbraCore_Refactoring_Plan.md)

---

This document will be updated as we progress through the refactoring process.
