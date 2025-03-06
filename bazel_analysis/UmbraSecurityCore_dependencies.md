# Bazel Dependency Analysis: UmbraSecurityCore

Generated: 2025-03-06 16:06:09

## Direct Dependencies

- SecureBytes
- SecurityProtocolsCore
- Sources/Adapters/AnyCryptoService.swift
- Sources/Adapters/CryptoServiceTypeAdapter.swift
- Sources/Adapters/FoundationTypeBridge.swift
- Sources/Implementations/DefaultCryptoService.swift
- Sources/UmbraSecurityCore.swift
- UmbraSecurityCore
- @platforms//os:macos
- @build_bazel_rules_swift//swift:emit_private_swiftinterface
- @build_bazel_rules_swift//swift:emit_swiftinterface
- @build_bazel_rules_swift//swift:per_module_swiftcopt
- @build_bazel_rules_swift//toolchains:toolchain_type
- @@rules_swift++non_module_deps+build_bazel_rules_swift_local_config//:toolchain

## Modules That Depend On This Module

- UmbraSecurityCore
- UmbraSecurityCoreTests

## ⚠️ Circular Dependencies Detected

- //Sources/UmbraSecurityCore:UmbraSecurityCore

## Dependency Analysis

| Module | # of Dependencies | # of Dependents |
|--------|-------------------|----------------|

## Refactoring Recommendations

- **High Priority**: Resolve circular dependencies
- **Medium Priority**: Consider breaking down module with many direct dependencies
