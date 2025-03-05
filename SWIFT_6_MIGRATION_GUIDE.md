# UmbraCore Swift 6 Migration Guide

This document outlines the steps needed to migrate UmbraCore to Swift 6 compatibility mode and details the changes made to support this transition.

## Overview

Swift 6 introduces several changes to the language that require modifications to existing Swift 5 code. This guide documents the changes made to UmbraCore to ensure compatibility with Swift 6.

## Build System Updates

### Swift Compiler Options

We've centralized Swift compiler options in:
- `tools/swift/compiler_options.bzl`
- `tools/swift/build_rules.bzl`

These files define standardized compiler settings for all UmbraCore modules, ensuring consistent Swift 6 compatibility.

### Bazel Configuration

1. Updated `.bazelrc` to use Swift 6 compatibility settings by default
2. Added Swift 6 configuration in `.bazelrc.swift`:
   - `swift_6_prep`: Enables upcoming Swift 6 features
   - `swift_concurrency`: Enforces strict concurrency checking
   - `swift_6_ready`: Combined configuration for full Swift 6 readiness

3. Updated `MODULE.bazel` with Swift 6 compiler flags

### New Build Rules

Created `umbracore_swift_library` and `umbracore_swift_test_library` build rules that:
- Apply Swift 6 compiler settings consistently
- Support different build modes (debug, release, default)
- Enforce strict concurrency checking
- Enable upcoming Swift 6 features

## Key Swift 6 Compatibility Changes

### Existential Types

Swift 6 requires explicit use of `any` for existential types:

```swift
// Swift 5
let logger: LoggerProtocol = MyLogger()

// Swift 6
let logger: any LoggerProtocol = MyLogger()
```

### Module Imports

Swift 6 requires explicit module qualifiers for types with the same name across different modules:

```swift
// Swift 5 (ambiguous)
let config = SecurityConfig()

// Swift 6 (explicit)
let config = SecurityProtocolsCore.SecurityConfig()
```

### Concurrency

Swift 6 enforces stricter actor isolation and concurrency rules:

```swift
// Swift 5 (potential data race)
actor MyActor {
    var data: [String] = []
    
    func process() {
        for item in data { // Data race!
            process(item)
        }
    }
}

// Swift 6 (safe)
actor MyActor {
    var data: [String] = []
    
    func process() async {
        let localCopy = data // Make local copy
        for item in localCopy {
            await process(item)
        }
    }
}
```

## Compatibility Testing

We've created a script to check Swift 6 compatibility:
- Located at `Scripts/check_swift_6_compatibility.sh`
- Tests key modules against Swift 6 compiler flags
- Provides detailed error reports for issues

## Action Items for Complete Migration

1. Fix all warnings produced by `-warn-swift-5-to-swift-6-path`
2. Add `any` to all existential types
3. Fix actor isolation issues
4. Resolve ambiguous module references
5. Update all concurrency-related code to be safe
6. Add explicit `isolated` or `nonisolated` keywords where needed

## Affected Modules

The following modules have been updated to ensure Swift 6 compatibility:

- XPCProtocolsCore
- SecurityProtocolsCore
- SecurityInterfaces
- SecurityInterfacesBase
- UmbraCoreTypes

## Building with Swift 6 Settings

To build a module with Swift 6 compatibility settings:

```bash
bazel build //Sources/ModuleName:ModuleName --config=swift_6_ready
```

To test the entire project with Swift 6 settings:

```bash
bazel test //... --config=swift_6_ready
```

## References

- [Swift 6 Language Guide](https://www.swift.org/swift-6-evolution/)
- [SE-0362: Piecemeal adoption of strict concurrency checking](https://github.com/apple/swift-evolution/blob/main/proposals/0362-piecemeal-strict-concurrency-checking.md)
- [SE-0335: Introduce existential any](https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md)
- [SE-0306: Type-level module imports](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md)
