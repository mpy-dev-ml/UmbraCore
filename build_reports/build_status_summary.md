# UmbraCore Build Status Summary

*Generated on: March 6, 2025*

## Build Overview

- **Total Targets**: 161
- **Built Successfully**: 155
- **Failed Targets**: 6
- **Success Rate**: 96.3%

## Failed Targets

### Toolchain Configuration Issues

```
ERROR: /Users/mpy/CascadeProjects/UmbraCore/bazel/toolchains/BUILD.bazel:30:29: in macos_arm64_toolchain_config rule //bazel/toolchains:macos_arm64_toolchain_config
```

**Root Cause**: The `cc_common.create_cc_toolchain_config_info()` function is being called with unexpected keyword arguments: `cxx_flags` and `link_flags`. This suggests a mismatch between the Bazel version and the toolchain configuration.

**Affected Targets**:
- `//bazel/toolchains:macos_arm64_toolchain_config`
- `//bazel/toolchains:macos_arm64_test_toolchain` (dependent)

### Code Generation Module Issues

```
ERROR: /Users/mpy/CascadeProjects/UmbraCore/tools/BUILD.bazel:[LINE]: in umbracore_gen_module rule //tools:[TARGET]
Error in format: Missing argument 'path'
```

**Root Cause**: The `umbracore_gen_module.bzl` file has a formatting error where a `path` argument is expected but not provided in a string format operation.

**Affected Targets**:
- `//tools:gen_secure_string`
- `//tools:gen_url_path`
- `//tools:gen_time_types`

### Test Configuration Issues

```
ERROR: /Users/mpy/CascadeProjects/UmbraCore/Sources/SecurityInterfaces/BUILD.bazel:37:29: in srcs attribute of swift_library rule //Sources/SecurityInterfaces:SecurityInterfacesTests: attribute must be non empty.
```

**Root Cause**: The `SecurityInterfacesTests` target has an empty `srcs` attribute, which is not allowed for Swift library rules. This might be related to the macro implementation of `umbracore_swift_test_library`.

**Affected Targets**:
- `//Sources/SecurityInterfaces:SecurityInterfacesTests`

## Warnings

### Swift 6 Compatibility

```
Sources/UmbraCoreTypes/CoreErrors/Sources/ErrorMapping.swift:83:5: warning: switch covers known cases, but 'SecurityError' may have additional unknown values; this is an error in the Swift 6 language mode
```

**Root Cause**: The `switch` statement in `ErrorMapping.swift` doesn't handle unknown cases for `SecurityError`, which will become an error in Swift 6. This should be addressed by adding an `@unknown default` case.

## Next Steps

1. **Toolchain Configuration**:
   - Update the toolchain configuration in `bazel/toolchains/macos_arm64_toolchain_config.bzl` to remove or properly handle `cxx_flags` and `link_flags`.

2. **Code Generation Modules**:
   - Fix the format string in `tools/build_defs/umbracore_gen_module.bzl` to properly include the missing `path` argument.

3. **Test Configuration**:
   - Add source files to the `SecurityInterfacesTests` target or update the macro to handle empty source lists.

4. **Swift 6 Compatibility**:
   - Update `ErrorMapping.swift` to include `@unknown default` handling for enum switch statements.

## Recently Completed Work

- Successfully refactored the CoreTypes module with improved architecture and error handling
- Split the functionality between CoreTypesInterfaces and CoreTypesImplementation
- Implemented robust error mapping between different error domains
- Added comprehensive test coverage for all new components
- Applied SwiftLint and SwiftFormat to ensure consistent code style
