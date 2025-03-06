# Bazel Dependency Analysis: CoreTypes

Generated: 2025-03-06 15:42:44

## Direct Dependencies

- CoreErrors
- BinaryData.swift
- ByteArray.swift
- CoreTypes
- SecurityErrorBase.swift
- SecurityProtocolsCoreIsolation.swift
- SecurityProtocolsCoreTypes.swift
- SecurityProviderBase.swift
- XPCProtocolsCoreIsolation.swift
- XPCProtocolsCoreTypes.swift
- XPCServiceAdapter.swift
- SecureBytes
- SecurityProtocolsCore
- UmbraCoreTypes
- XPCProtocolsCore
- @build_bazel_rules_swift//swift:emit_private_swiftinterface
- @build_bazel_rules_swift//swift:emit_swiftinterface
- @build_bazel_rules_swift//swift:per_module_swiftcopt
- @build_bazel_rules_swift//toolchains:toolchain_type
- @@rules_swift++non_module_deps+build_bazel_rules_swift_local_config//:toolchain

## Modules That Depend On This Module

- API
- Core
- CoreServices
- CoreServicesSecurityTypeAliases
- CoreTypes
- CryptoTypes
- CryptoTypesProtocols
- CryptoTypesServices
- CryptoTypesTypes
- Features
- FeaturesLoggingServices
- FoundationBridgeTypes
- FoundationBridgeTypesForTesting
- ObjCBridgingTypes
- ObjCBridgingTypesForTesting
- ObjCBridgingTypesFoundation
- ObjCBridgingTypesFoundationForTesting
- CryptoServiceAdapterTests
- RandomDataTests
- SanityTests
- SecurityBridge
- SecurityBridgeMigrationTests
- SecurityBridgeSanityTests
- SecurityBridgeTests
- SecurityProviderAdapterTests
- TemporaryTests
- SecurityBridgeProtocolAdapters
- SecurityInterfaces
- SecurityInterfacesForTesting
- SecurityInterfacesTests
- SecurityProviderTests
- SecurityInterfacesBase
- SecurityInterfacesBaseForTesting
- SecurityInterfacesFoundation
- SecurityInterfacesFoundationForTesting
- SecurityInterfacesProtocols
- SecurityInterfacesProtocolsForTesting
- SecurityInterfacesXPC
- SecurityInterfacesXPCForTesting
- SecurityUtils
- Services
- CredentialManager
- CryptoService
- SecurityUtilsProtocols
- SecurityUtilsServices
- UmbraCore
- UmbraCrypto
- UmbraCryptoService
- UmbraKeychainService
- UmbraSecurity
- UmbraSecurityExtensions
- UmbraSecurityServicesCore
- XPCProtocolsCoreTests
- //TestSupport/Common:CommonTestSupport
- //TestSupport/Core:CoreTestSupport
- //TestSupport/Security:SecurityTestSupport
- //TestSupport/Security/SecurityInterfacesForTesting:SecurityInterfacesForTesting
- //TestSupport/UmbraTestKit:UmbraTestKit
- //Tests/BookmarkTests:BookmarkTests
- //Tests/CoreTests:CoreTests
- //Tests/CryptoTests:CryptoTests
- //Tests/ErrorHandlingTests:ErrorHandlingTests
- //Tests/KeychainTests:KeychainTests
- //Tests/LoggingTests:LoggingTests
- //Tests/ResourcesTests:ResourcesTests
- //Tests/ResticCLIHelperTests:ResticCLIHelperTests
- //Tests/SecurityInterfacesTest:SecurityInterfacesTest
- //Tests/UmbraSecurityTests:UmbraSecurityTests
- //Tests/UmbraTestKit:UmbraTestKit
- //Tests/UmbraTestKit/TestKit:TestKit
- //Tests/UmbraTestKit/Tests:UmbraTestKitTests
- //Tests/XPCTests:XPCTests

## ⚠️ Circular Dependencies Detected

- //Sources/CoreTypes:CoreTypes

## Dependency Analysis

| Module | # of Dependencies | # of Dependents |
|--------|-------------------|----------------|

## Refactoring Recommendations

- **High Priority**: Resolve circular dependencies
- **Medium Priority**: Consider breaking down module with many direct dependencies
- **High Priority**: This module is heavily depended upon - changes should be made carefully
