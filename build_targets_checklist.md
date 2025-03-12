# UmbraCore Build Targets Checklist

This document tracks the build status of all UmbraCore targets. We'll build each target sequentially and verify its success before moving to the next one.

## Foundation-Free Core Modules

- [x] //Sources/SecureBytes:SecureBytes
- [x] //Sources/SecureBytes:SecureBytesTests
- [x] //Sources/CoreTypesInterfaces:CoreTypesInterfaces
- [x] //Sources/CoreTypesInterfaces:CoreTypesInterfacesTests
- [x] //Sources/CoreErrors:CoreErrors
- [x] //Sources/CoreErrors:CoreErrorsSources
- [x] //Sources/UmbraCoreTypes:UmbraCoreTypes
- [x] //Sources/UmbraCoreTypes/CoreErrors:UmbraCoreTypesCoreErrors
- [x] //Sources/XPCProtocolsCore:XPCProtocolsCore
- [ ] //Sources/XPCProtocolsCore:XPCProtocolsCoreTests (Temporarily disabled due to complex dependency issues)
- [x] //Sources/SecurityProtocolsCore:SecurityProtocolsCore
- [x] //Sources/SecurityProtocolsCore:SecurityProtocolsCoreTests

## Security and Cryptography Modules

- [x] //Sources/SecurityBridge:SecurityBridge
- [x] //Sources/SecurityBridge:SecurityBridgeTests
- [x] //Sources/SecurityBridge:SecurityBridgeMigrationTests
- [x] //Sources/SecurityBridge:SecurityBridgeSanityTests
- [x] //Sources/SecurityBridge:SecurityProviderAdapterTests
- [x] //Sources/SecurityBridge:CryptoServiceAdapterTests
- [x] //Sources/SecurityBridge:RandomDataTests
- [x] //Sources/SecurityBridge:SanityTests
- [x] //Sources/SecurityBridge:TemporaryTests
- [x] //Sources/SecurityBridge/Sources/XPCBridge:XPCBridge
- [x] //Sources/SecurityBridgeProtocolAdapters:SecurityBridgeProtocolAdapters
- [x] //Sources/SecurityCoreAdapters:SecurityCoreAdapters
- [x] //Sources/SecurityImplementation:SecurityImplementation
- [x] //Sources/SecurityImplementation:SecurityImplementationTests
- [x] //Sources/SecurityImplementation:SecurityImplementationTests_runner
- [x] //Sources/SecurityInterfaces:SecurityInterfaces
- [x] //Sources/SecurityInterfaces:SecurityInterfacesForTesting
- [x] //Sources/SecurityInterfaces:SecurityInterfacesTests
- [x] //Sources/SecurityInterfaces:SecurityInterfacesTests_empty_src
- [ ] //Sources/SecurityInterfaces/Tests:SecurityProviderTests (build issues - module resolution)
- [x] //Sources/SecurityInterfacesBase:SecurityInterfacesBase
- [x] //Sources/SecurityInterfacesBase:SecurityInterfacesBaseForTesting
- [x] //Sources/SecurityInterfacesFoundation:SecurityInterfacesFoundation
- [x] //Sources/SecurityInterfacesFoundation:SecurityInterfacesFoundationForTesting
- [x] //Sources/SecurityInterfacesProtocols:SecurityInterfacesProtocols
- [x] //Sources/SecurityInterfacesProtocols:SecurityInterfacesProtocolsForTesting
- [x] //Sources/SecurityInterfacesXPC:SecurityInterfacesXPC
- [x] //Sources/SecurityInterfacesXPC:SecurityInterfacesXPCForTesting
- [x] //Sources/SecurityTypeConverters:SecurityTypeConverters
- [x] //Sources/SecurityTypes:SecurityTypes
- [x] //Sources/SecurityTypes/Protocols:SecurityTypesProtocols
- [x] //Sources/SecurityTypes/Types:SecurityTypesTypes
- [ ] //Sources/SecurityUtils:SecurityUtils (build issues - module resolution)
- [ ] //Sources/SecurityUtils/Protocols:SecurityUtilsProtocols (build issues - revisit later)
- [ ] //Sources/UmbraSecurity:UmbraSecurity (build issues - revisit later)
- [ ] //Sources/UmbraSecurity/Extensions:UmbraSecurityExtensions (build issues - revisit later)
- [ ] //Sources/UmbraSecurity/Services:UmbraSecurityServicesCore (build issues - revisit later)
- [x] //Sources/UmbraSecurityCore:UmbraSecurityCore
- [x] //Sources/UmbraSecurityCore:UmbraSecurityCoreTests
- [x] //Sources/UmbraCrypto:UmbraCrypto
- [ ] //Sources/UmbraCryptoService:UmbraCryptoService (build issues - revisit later)
- [x] //Sources/UmbraCryptoService/Resources:UmbraCryptoServiceResources
- [ ] //Sources/UmbraKeychainService:UmbraKeychainService (build issues - revisit later)
- [x] //Sources/CryptoServiceProtocol:CryptoServiceProtocol
- [x] //Sources/CryptoTypes:CryptoTypes
- [x] //Sources/CryptoTypes/Protocols:CryptoTypesProtocols
- [ ] //Sources/CryptoTypes/Services:CryptoTypesServices (build issues - missing dependencies)
- [x] //Sources/CryptoTypes/Types:CryptoTypesTypes
- [x] //Sources/CryptoSwiftFoundationIndependent:CryptoSwiftFoundationIndependent

## Core and Service Modules

- [x] //Sources/Core:Core
- [ ] //Sources/Core/Services:CoreServices (build issues - namespace resolution)
- [x] //Sources/Core/Services/TypeAliases:CoreServicesTypeAliases
- [ ] //Sources/Core/Services/TypeAliases:CoreServicesSecurityTypeAliases (build issues - revisit later)
- [ ] //Sources/Core/Services/Types:CoreServicesTypes (build issues - revisit later)
- [x] //Sources/Core/UmbraCore:CoreUmbraCore
- [x] //Sources/CoreServicesTypesNoFoundation:CoreServicesTypesNoFoundation
- [x] //Sources/CoreTypesImplementation:CoreTypesImplementation
- [x] //Sources/FoundationBridgeTypes:FoundationBridgeTypes
- [x] //Sources/FoundationBridgeTypes:FoundationBridgeTypesForTesting
- [x] //Sources/Services:Services
- [x] //Sources/Services/CredentialManager:CredentialManager
- [x] //Sources/Services/CryptoService:CryptoService
- [ ] //Sources/Services/SecurityUtils:SecurityUtils (build issues - revisit later)
- [ ] //Sources/Services/SecurityUtils/Protocols:SecurityUtilsProtocols (build issues - revisit later)
- [ ] //Sources/Services/SecurityUtils/Services:SecurityUtilsServices (build issues - revisit later)
- [x] //Sources/ServiceTypes:ServiceTypes
- [x] //Sources/UmbraCore:UmbraCore
- [x] //Sources/UmbraBookmarkService:UmbraBookmarkService

## Error Handling and Logging Modules

- [x] //Sources/ErrorHandling:ErrorHandling
- [x] //Sources/ErrorHandling/Common:ErrorHandlingCommon
- [x] //Sources/ErrorHandling/Core:ErrorHandlingCore
- [x] //Sources/ErrorHandling/Domains:ErrorHandlingDomains
- [ ] //Sources/ErrorHandling/Examples:ErrorHandlingExamples (build issues - LoggingWrapper dependency)
- [x] //Sources/ErrorHandling/Interfaces:ErrorHandlingInterfaces
- [x] //Sources/ErrorHandling/Logging:ErrorHandlingLogging
- [x] //Sources/ErrorHandling/Mapping:ErrorHandlingMapping
- [x] //Sources/ErrorHandling/Models:ErrorHandlingModels
- [x] //Sources/ErrorHandling/ModuleInfo:ErrorHandlingModuleInfo
- [x] //Sources/ErrorHandling/Notification:ErrorHandlingNotification
- [x] //Sources/ErrorHandling/Protocols:ErrorHandlingProtocols
- [x] //Sources/ErrorHandling/Recovery:ErrorHandlingRecovery
- [x] //Sources/ErrorHandling/Types:ErrorHandlingTypes
- [x] //Sources/ErrorHandling/Utilities:ErrorHandlingUtilities
- [x] //Sources/Features/Logging/Errors:FeaturesLoggingErrors
- [x] //Sources/Features/Logging/Models:FeaturesLoggingModels
- [x] //Sources/Features/Logging/Protocols:FeaturesLoggingProtocols
- [ ] //Sources/Features/Logging/Services:FeaturesLoggingServices (build issues - import syntax errors)
- [x] //Sources/LoggingWrapper:LoggingWrapper
- [x] //Sources/LoggingWrapperInterfaces:LoggingWrapperInterfaces
- [x] //Sources/UmbraLogging:UmbraLogging
- [x] //Sources/UmbraLoggingAdapters:UmbraLoggingAdapters

## Feature and API Modules

- [ ] //Sources/API:API
- [ ] //Sources/Features:Features
- [x] //Sources/Features/Crypto/Models:FeaturesCryptoModels
- [x] //Sources/Features/Crypto/Protocols:FeaturesCryptoProtocols
- [x] //Sources/Repositories:Repositories
- [x] //Sources/Repositories/Protocols:RepositoriesProtocols
- [x] //Sources/Repositories/Types:RepositoriesTypes
- [x] //Sources/Resources:Resources
- [x] //Sources/Resources/Protocols:ResourcesProtocols
- [x] //Sources/Resources/Types:ResourcesTypes

## Testing and Utility Modules

- [x] //Sources/Autocomplete:Autocomplete
- [x] //Sources/Autocomplete/Protocols:Protocols
- [x] //Sources/KeyManagementTypes:KeyManagementTypes
- [x] //Sources/KeyManagementTypes/Tests:KeyManagementTypesTests
- [x] //Sources/ObjCBridgingTypes:ObjCBridgingTypes
- [x] //Sources/ObjCBridgingTypes:ObjCBridgingTypesForTesting
- [x] //Sources/ObjCBridgingTypesFoundation:ObjCBridgingTypesFoundation
- [x] //Sources/ObjCBridgingTypesFoundation:ObjCBridgingTypesFoundationForTesting
- [x] //Sources/ResticCLIHelper:ResticCLIHelper
- [x] //Sources/ResticCLIHelper/Commands:ResticCLIHelperCommands
- [x] //Sources/ResticCLIHelper/Models:ResticCLIHelperModels
- [x] //Sources/ResticCLIHelper/Protocols:ResticCLIHelperProtocols
- [x] //Sources/ResticCLIHelper/Types:ResticCLIHelperTypes
- [x] //Sources/ResticTypes:ResticTypes
- [x] //Sources/SecureString:SecureString
- [x] //Sources/SecureString:SecureStringTests
- [x] //Sources/Snapshots:Snapshots
- [x] //Sources/Snapshots/Protocols:SnapshotsProtocols
- [x] //Sources/TestUtils:TestUtils
- [x] //Sources/Testing:Testing
- [x] //Sources/TestingMacros:TestingMacros
- [x] //Sources/UmbraMocks:UmbraMocks
- [x] //Sources/UmbraXPC:UmbraXPC
- [x] //Sources/XPC:XPC
- [x] //Sources/XPC/Core:XPCCore
