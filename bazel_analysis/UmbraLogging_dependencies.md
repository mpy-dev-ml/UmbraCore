# Bazel Dependency Analysis: UmbraLogging

Generated: 2025-03-06 16:05:28

## Direct Dependencies

- LogEntry.swift
- LogLevel.swift
- LogMetadata.swift
- Logger.swift
- LoggingProtocol.swift
- UmbraLogging
- UmbraLogging.swift
- @build_bazel_rules_swift//swift:emit_private_swiftinterface
- @build_bazel_rules_swift//swift:emit_swiftinterface
- @build_bazel_rules_swift//swift:per_module_swiftcopt
- @build_bazel_rules_swift//toolchains:toolchain_type
- @@rules_swift++non_module_deps+build_bazel_rules_swift_local_config//:toolchain
- @swiftpkg_swiftybeaver//:SwiftyBeaver

## Modules That Depend On This Module

- API
- Autocomplete
- Protocols
- Core
- CoreServices
- CoreServicesSecurityTypeAliases
- CoreServicesTypes
- CoreUmbraCore
- CryptoServiceProtocol
- CryptoTypes
- CryptoTypesProtocols
- CryptoTypesServices
- CryptoTypesTypes
- ErrorHandling
- ErrorHandlingProtocols
- Features
- FeaturesCryptoModels
- FeaturesCryptoProtocols
- FeaturesLoggingErrors
- FeaturesLoggingModels
- FeaturesLoggingProtocols
- FeaturesLoggingServices
- Repositories
- RepositoriesProtocols
- RepositoriesTypes
- Resources
- ResourcesProtocols
- ResticCLIHelper
- ResticCLIHelperCommands
- ResticCLIHelperModels
- ResticCLIHelperProtocols
- ResticCLIHelperTypes
- ResticTypes
- SecurityBridgeTests
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
- SecurityTypes
- SecurityTypesProtocols
- SecurityTypesTypes
- SecurityUtils
- SecurityUtilsProtocols
- Services
- CredentialManager
- CryptoService
- SecurityUtilsServices
- Snapshots
- SnapshotsProtocols
- TestUtils
- Testing
- UmbraBookmarkService
- UmbraCore
- UmbraCrypto
- UmbraCryptoService
- UmbraKeychainService
- UmbraLogging
- UmbraMocks
- UmbraSecurity
- UmbraSecurityExtensions
- UmbraSecurityServicesCore
- UmbraXPC
- XPC
- XPCCore
- XPCProtocolsCoreTests
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
- //Tests/ResticTypesTests:ResticTypesTests
- //Tests/SecurityInterfacesTest:SecurityInterfacesTest
- //Tests/UmbraSecurityTests:UmbraSecurityTests
- //Tests/UmbraTestKit:UmbraTestKit
- //Tests/UmbraTestKit/TestKit:TestKit
- //Tests/UmbraTestKit/Tests:UmbraTestKitTests
- //Tests/UmbraXPCTests:UmbraXPCTests
- //Tests/XPCTests:XPCTests

## ⚠️ Circular Dependencies Detected

- //Sources/UmbraLogging:UmbraLogging

## Dependency Analysis

| Module | # of Dependencies | # of Dependents |
|--------|-------------------|----------------|

## Refactoring Recommendations

- **High Priority**: Resolve circular dependencies
- **Medium Priority**: Consider breaking down module with many direct dependencies
- **High Priority**: This module is heavily depended upon - changes should be made carefully
