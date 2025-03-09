# UmbraCore Project Analysis Report

*Generated on 9 March 2025 at 00:47:15*

## Colour Legend

| Colour | Meaning |
|--------|--------|
| <span style="color:#FFA500">Amber</span> | File exceeds 500 lines of code - consider refactoring |
| <span style="color:#FF0000">Red</span> | File exceeds 750 lines of code - high priority for refactoring |

## Summary

| Metric | Value |
|--------|-------|
| Total Targets with Code | 31 |
| Total Files | 213 |
| Total Lines of Code | 26372 |

## Targets by Lines of Code

| Rank | Target | Type | Files | Lines of Code |
|------|--------|------|-------|---------------|
| 1 | `//Sources/ErrorHandling:ErrorHandling` | swift_library | 49 | 8151 |
| 2 | `//Sources/SecurityImplementation:SecurityImplementation` | swift_library | 6 | 2483 |
| 3 | `//Sources/ResticCLIHelper:ResticCLIHelper` | swift_library | 25 | 2121 |
| 4 | `//Sources/SecurityBridge:SecurityBridge` | swift_library | 10 | 1994 |
| 5 | `//Sources/Core:Core` | swift_library | 10 | 1659 |
| 6 | `//Sources/XPCProtocolsCore:XPCProtocolsCore` | swift_library | 9 | 1553 |
| 7 | `//Sources/UmbraCoreTypes:UmbraCoreTypes` | swift_library | 7 | 1171 |
| 8 | `//Sources/UmbraSecurity:UmbraSecurity` | swift_library | 11 | 1107 |
| 9 | `//Sources/XPC:XPC` | swift_library | 3 | 576 |
| 10 | `//Sources/UmbraSecurityCore:UmbraSecurityCore` | swift_library | 3 | 573 |
| 11 | `//Sources/CoreTypesImplementation:CoreTypesImplementation` | swift_library | 7 | 569 |
| 12 | `//Sources/Repositories:Repositories` | swift_library | 7 | 529 |
| 13 | `//Sources/CryptoTypes:CryptoTypes` | swift_library | 10 | 517 |
| 14 | `//Sources/CoreTypesInterfaces:CoreTypesInterfaces` | swift_library | 8 | 421 |
| 15 | `//Sources/SecureBytes:SecureBytes` | swift_library | 2 | 362 |
| 16 | `//Sources/Services/SecurityUtils:SecurityUtils` | swift_library | 4 | 353 |
| 17 | `//Sources/SecureString:SecureString` | swift_library | 2 | 267 |
| 18 | `//Sources/Core/Services:CoreServices` | swift_library | 9 | 267 |
| 19 | `//Sources/Resources:Resources` | swift_library | 4 | 260 |
| 20 | `//Sources/SecurityInterfaces:SecurityInterfaces` | swift_library | 2 | 226 |

## Top 20 Files by Lines of Code

| Rank | File | Lines of Code |
|------|------|---------------|
| 1 | `Sources/SecurityImplementation/Sources/CryptoService.swift` | <span style="color:#FF0000">1068</span> |
| 2 | `Sources/SecurityBridge/Tests/CryptoServiceAdapterTests.swift` | <span style="color:#FFA500">721</span> |
| 3 | `Sources/SecurityImplementation/Tests/SecurityImplementationTests.swift` | <span style="color:#FFA500">721</span> |
| 4 | `Sources/ErrorHandling/Mapping/UmbraErrorMapper.swift` | <span style="color:#FFA500">504</span> |
| 5 | `Sources/Core/Services/KeyManager.swift` | 424 |
| 6 | `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift` | 416 |
| 7 | `Sources/UmbraSecurityCore/Tests/CryptoServiceAdaptersTests.swift` | 402 |
| 8 | `Sources/SecurityBridge/Tests/XPCServiceAdapterTests.swift` | 400 |
| 9 | `Sources/XPCProtocolsCore/Tests/XPCProtocolsTests.swift` | 386 |
| 10 | `Sources/ErrorHandling/Utilities/ComprehensiveErrorHandlingExample.swift` | 364 |
| 11 | `Sources/ErrorHandling/Extensions/SecurityErrors+UmbraError.swift` | 364 |
| 12 | `Sources/UmbraCoreTypes/Sources/SecureBytes.swift` | 362 |
| 13 | `Sources/ErrorHandling/Domains/ApplicationError.swift` | 358 |
| 14 | `Sources/ErrorHandling/Logging/ErrorLogger.swift` | 356 |
| 15 | `Sources/XPC/Core/XPCServiceProtocols.swift` | 353 |
| 16 | `Sources/SecurityImplementation/Sources/SecurityProvider.swift` | 348 |
| 17 | `Sources/UmbraSecurity/Services/SecurityService.swift` | 341 |
| 18 | `Sources/XPCProtocolsCore/Tests/CryptoXPCServiceAdapterTests.swift` | 330 |
| 19 | `Sources/ErrorHandling/Models/ErrorContext.swift` | 322 |
| 20 | `Sources/ErrorHandling/Domains/SecurityError.swift` | 315 |

## Detailed Breakdown: All Targets and Files

| Target | Target Type | Total LOC | File | File LOC |
|--------|------------|-----------|------|----------|
| `//Sources/ErrorHandling:ErrorHandling` | swift_library | 8151 | `Sources/ErrorHandling/Mapping/UmbraErrorMapper.swift` | <span style="color:#FFA500">504</span> |
| | | | `Sources/ErrorHandling/Utilities/SecurityErrorHandler.swift` | 416 |
| | | | `Sources/ErrorHandling/Utilities/ComprehensiveErrorHandlingExample.swift` | 364 |
| | | | `Sources/ErrorHandling/Extensions/SecurityErrors+UmbraError.swift` | 364 |
| | | | `Sources/ErrorHandling/Domains/ApplicationError.swift` | 358 |
| | | | `Sources/ErrorHandling/Logging/ErrorLogger.swift` | 356 |
| | | | `Sources/ErrorHandling/Models/ErrorContext.swift` | 322 |
| | | | `Sources/ErrorHandling/Domains/SecurityError.swift` | 315 |
| | | | `Sources/ErrorHandling/Recovery/SecurityErrorRecoveryService.swift` | 247 |
| | | | `Sources/ErrorHandling/Domains/RepositoryError.swift` | 232 |
| | | | `Sources/ErrorHandling/Notification/ErrorNotifier.swift` | 225 |
| | | | `Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift` | 218 |
| | | | `Sources/ErrorHandling/Utilities/ErrorHandlingExample.swift` | 210 |
| | | | `Sources/ErrorHandling/Notification/ErrorNotification.swift` | 205 |
| | | | `Sources/ErrorHandling/Domains/SecurityErrorDomain.swift` | 202 |
| | | | `Sources/ErrorHandling/Notification/MacErrorNotificationService.swift` | 187 |
| | | | `Sources/ErrorHandling/Mapping/ApplicationErrorMapper.swift` | 187 |
| | | | `Sources/ErrorHandling/Models/GenericUmbraError.swift` | 175 |
| | | | `Sources/ErrorHandling/Mapping/SecurityErrorMapper.swift` | 173 |
| | | | `Sources/ErrorHandling/Recovery/ErrorRecovery.swift` | 169 |
| | | | `Sources/ErrorHandling/Extensions/ApplicationErrors+UmbraError.swift` | 167 |
| | | | `Sources/ErrorHandling/Domains/NetworkErrors.swift` | 165 |
| | | | `Sources/ErrorHandling/Utilities/ErrorHandlingExamples.swift` | 160 |
| | | | `Sources/ErrorHandling/ModuleInfo/ModuleInfo.swift` | 154 |
| | | | `Sources/ErrorHandling/Interfaces/ErrorInterfaces.swift` | 152 |
| | | | `Sources/ErrorHandling/Logging/UmbraErrorLoggingExtensions.swift` | 143 |
| | | | `Sources/ErrorHandling/Domains/ApplicationErrors.swift` | 134 |
| | | | `Sources/ErrorHandling/Core/ErrorFactory.swift` | 132 |
| | | | `Sources/ErrorHandling/Logging/ErrorLoggingSetup.swift` | 128 |
| | | | `Sources/ErrorHandling/Core/ErrorHandler.swift` | 124 |
| | | | `Sources/ErrorHandling/Mapping/ErrorRegistry.swift` | 120 |
| | | | `Sources/ErrorHandling/Recovery/RecoveryAction.swift` | 118 |
| | | | `Sources/ErrorHandling/Domains/SecurityErrors.swift` | 111 |
| | | | `Sources/ErrorHandling/Domains/StorageErrors.swift` | 111 |
| | | | `Sources/ErrorHandling/Recovery/RecoveryOptions.swift` | 109 |
| | | | `Sources/ErrorHandling/Mapping/ErrorMapper.swift` | 86 |
| | | | `Sources/ErrorHandling/Models/ServiceErrorTypes.swift` | 74 |
| | | | `Sources/ErrorHandling/Common/ErrorContext.swift` | 72 |
| | | | `Sources/ErrorHandling/Extensions/Error+Context.swift` | 65 |
| | | | `Sources/ErrorHandling/Domains/RepositoryErrorDomain.swift` | 62 |
| | | | `Sources/ErrorHandling/ModuleInfo/ModuleInfoTemplate.swift` | 53 |
| | | | `Sources/ErrorHandling/Common/BaseErrorTypes.swift` | 50 |
| | | | `Sources/ErrorHandling/Common/Common.swift` | 50 |
| | | | `Sources/ErrorHandling/Protocols/ServiceErrorProtocol.swift` | 45 |
| | | | `Sources/ErrorHandling/Models/CommonError.swift` | 39 |
| | | | `Sources/ErrorHandling/Interfaces/LoggingInterfaces.swift` | 36 |
| | | | `Sources/ErrorHandling/Models/CoreError.swift` | 29 |
| | | | `Sources/ErrorHandling/Protocols/ErrorReporting.swift` | 27 |
| | | | `Sources/ErrorHandling/Domains/UmbraErrors.swift` | 6 |
| | | | | |
| `//Sources/SecurityImplementation:SecurityImplementation` | swift_library | 2483 | `Sources/SecurityImplementation/Sources/CryptoService.swift` | <span style="color:#FF0000">1068</span> |
| | | | `Sources/SecurityImplementation/Tests/SecurityImplementationTests.swift` | <span style="color:#FFA500">721</span> |
| | | | `Sources/SecurityImplementation/Sources/SecurityProvider.swift` | 348 |
| | | | `Sources/SecurityImplementation/Sources/KeyManager.swift` | 269 |
| | | | `Sources/SecurityImplementation/Sources/Types.swift` | 46 |
| | | | `Sources/SecurityImplementation/Sources/SecurityImplementation.swift` | 31 |
| | | | | |
| `//Sources/ResticCLIHelper:ResticCLIHelper` | swift_library | 2121 | `Sources/ResticCLIHelper/Models/SnapshotInfo.swift` | 244 |
| | | | `Sources/ResticCLIHelper/Commands/BackupCommand.swift` | 232 |
| | | | `Sources/ResticCLIHelper/Commands/SnapshotCommand.swift` | 228 |
| | | | `Sources/ResticCLIHelper/Commands/ListCommand.swift` | 204 |
| | | | `Sources/ResticCLIHelper/Commands/CopyCommand.swift` | 150 |
| | | | `Sources/ResticCLIHelper/Commands/StatsCommand.swift` | 127 |
| | | | `Sources/ResticCLIHelper/Commands/ForgetCommand.swift` | 109 |
| | | | `Sources/ResticCLIHelper/Commands/RestoreCommand.swift` | 90 |
| | | | `Sources/ResticCLIHelper/Commands/FindCommand.swift` | 73 |
| | | | `Sources/ResticCLIHelper/Commands/LsCommand.swift` | 72 |
| | | | `Sources/ResticCLIHelper/Commands/DiffCommand.swift` | 72 |
| | | | `Sources/ResticCLIHelper/Models/FileMetadata.swift` | 71 |
| | | | `Sources/ResticCLIHelper/Protocols/ResticCLIHelperProtocol.swift` | 68 |
| | | | `Sources/ResticCLIHelper/Commands/CheckCommand.swift` | 54 |
| | | | `Sources/ResticCLIHelper/Types/CommandResult.swift` | 48 |
| | | | `Sources/ResticCLIHelper/Models/RepositoryStats.swift` | 40 |
| | | | `Sources/ResticCLIHelper/Models/RepositoryObject.swift` | 37 |
| | | | `Sources/ResticCLIHelper/Commands/InitCommand.swift` | 34 |
| | | | `Sources/ResticCLIHelper/Commands/RepairCommand.swift` | 34 |
| | | | `Sources/ResticCLIHelper/Commands/RebuildIndexCommand.swift` | 34 |
| | | | `Sources/ResticCLIHelper/Commands/PruneCommand.swift` | 34 |
| | | | `Sources/ResticCLIHelper/Types/ResticTypes.swift` | 34 |
| | | | `Sources/ResticCLIHelper/Protocols/ResticCommand.swift` | 12 |
| | | | `Sources/ResticCLIHelper/Types/ResticError.swift` | 11 |
| | | | `Sources/ResticCLIHelper/Types/MaintenanceType.swift` | 9 |
| | | | | |
| `//Sources/SecurityBridge:SecurityBridge` | swift_library | 1994 | `Sources/SecurityBridge/Tests/CryptoServiceAdapterTests.swift` | <span style="color:#FFA500">721</span> |
| | | | `Sources/SecurityBridge/Tests/XPCServiceAdapterTests.swift` | 400 |
| | | | `Sources/SecurityBridge/Tests/SecurityBridgeMigrationTests.swift` | 224 |
| | | | `Sources/SecurityBridge/Tests/SecurityBridgeTests.swift` | 151 |
| | | | `Sources/SecurityBridge/Tests/SecurityProviderAdapterTests.swift` | 148 |
| | | | `Sources/SecurityBridge/Tests/SanityTests.swift` | 105 |
| | | | `Sources/SecurityBridge/Sources/SecurityBridgeError.swift` | 92 |
| | | | `Sources/SecurityBridge/Tests/RandomDataTests.swift` | 71 |
| | | | `Sources/SecurityBridge/Tests/TemporaryTests.swift` | 61 |
| | | | `Sources/SecurityBridge/Sources/SecurityBridge.swift` | 21 |
| | | | | |
| `//Sources/Core:Core` | swift_library | 1659 | `Sources/Core/Services/KeyManager.swift` | 424 |
| | | | `Sources/Core/Services/SecurityService.swift` | 289 |
| | | | `Sources/Core/Services/CryptoService.swift` | 288 |
| | | | `Sources/Core/Services/ServiceContainer.swift` | 274 |
| | | | `Sources/Core/Services/SecurityError.swift` | 94 |
| | | | `Sources/Core/Services/UmbraService.swift` | 83 |
| | | | `Sources/Core/Services/CryptoError.swift` | 70 |
| | | | `Sources/Core/UmbraCore/UmbraCore.swift` | 65 |
| | | | `Sources/Core/Services/CoreService.swift` | 48 |
| | | | `Sources/Core/Extensions/TimeInterval+Extensions.swift` | 24 |
| | | | | |
| `//Sources/XPCProtocolsCore:XPCProtocolsCore` | swift_library | 1553 | `Sources/XPCProtocolsCore/Tests/XPCProtocolsTests.swift` | 386 |
| | | | `Sources/XPCProtocolsCore/Tests/CryptoXPCServiceAdapterTests.swift` | 330 |
| | | | `Sources/XPCProtocolsCore/Tests/DeprecationWarningTests.swift` | 212 |
| | | | `Sources/XPCProtocolsCore/Tests/LegacyXPCAdapterTests.swift` | 200 |
| | | | `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolStandard.swift` | 157 |
| | | | `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolComplete.swift` | 128 |
| | | | `Sources/XPCProtocolsCore/Sources/XPCProtocolMigrationFactory.swift` | 69 |
| | | | `Sources/XPCProtocolsCore/Sources/XPCProtocolsCore.swift` | 36 |
| | | | `Sources/XPCProtocolsCore/Sources/XPCServiceProtocolBasic.swift` | 35 |
| | | | | |
| `//Sources/UmbraCoreTypes:UmbraCoreTypes` | swift_library | 1171 | `Sources/UmbraCoreTypes/Sources/SecureBytes.swift` | 362 |
| | | | `Sources/UmbraCoreTypes/Tests/ResourceLocatorTests.swift` | 241 |
| | | | `Sources/UmbraCoreTypes/Tests/SecureBytesTests.swift` | 184 |
| | | | `Sources/UmbraCoreTypes/Sources/ResourceLocator.swift` | 135 |
| | | | `Sources/UmbraCoreTypes/Tests/CoreErrorsMappingTests.swift` | 117 |
| | | | `Sources/UmbraCoreTypes/Sources/SecureBytes+Extensions.swift` | 68 |
| | | | `Sources/UmbraCoreTypes/Sources/TimePoint.swift` | 64 |
| | | | | |
| `//Sources/UmbraSecurity:UmbraSecurity` | swift_library | 1107 | `Sources/UmbraSecurity/Services/SecurityService.swift` | 341 |
| | | | `Sources/UmbraSecurity/Services/SecurityProviderFoundationImpl.swift` | 207 |
| | | | `Sources/UmbraSecurity/Services/SecurityServiceNoCrypto.swift` | 116 |
| | | | `Sources/UmbraSecurity/Services/SecurityProviderFactory.swift` | 90 |
| | | | `Sources/UmbraSecurity/Services/SecurityServiceBridge.swift` | 89 |
| | | | `Sources/UmbraSecurity/Extensions/URL+SecurityScoped.swift` | 75 |
| | | | `Sources/UmbraSecurity/Services/SecurityCryptoService.swift` | 68 |
| | | | `Sources/UmbraSecurity/Services/SecurityServiceFactory.swift` | 51 |
| | | | `Sources/UmbraSecurity/Services/SecurityServiceUltraMinimal.swift` | 33 |
| | | | `Sources/UmbraSecurity/Services/SecurityServiceFactoryMinimal.swift` | 19 |
| | | | `Sources/UmbraSecurity/Services/UmbraSecurityServicesModule.swift` | 18 |
| | | | | |
| `//Sources/XPC:XPC` | swift_library | 576 | `Sources/XPC/Core/XPCServiceProtocols.swift` | 353 |
| | | | `Sources/XPC/Core/XPCConnectionManager.swift` | 147 |
| | | | `Sources/XPC/Core/XPCError.swift` | 76 |
| | | | | |
| `//Sources/UmbraSecurityCore:UmbraSecurityCore` | swift_library | 573 | `Sources/UmbraSecurityCore/Tests/CryptoServiceAdaptersTests.swift` | 402 |
| | | | `Sources/UmbraSecurityCore/Tests/DefaultCryptoServiceTests.swift` | 124 |
| | | | `Sources/UmbraSecurityCore/Sources/UmbraSecurityCore.swift` | 47 |
| | | | | |
| `//Sources/CoreTypesImplementation:CoreTypesImplementation` | swift_library | 569 | `Sources/CoreTypesImplementation/Tests/ErrorAdaptersTests.swift` | 130 |
| | | | `Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift` | 103 |
| | | | `Sources/CoreTypesImplementation/Sources/DefaultCoreProvider.swift` | 91 |
| | | | `Sources/CoreTypesImplementation/Tests/SecureDataAdaptersTests.swift` | 72 |
| | | | `Sources/CoreTypesImplementation/Sources/SecureDataAdapters.swift` | 60 |
| | | | `Sources/CoreTypesImplementation/Sources/CoreTypesImplementation.swift` | 58 |
| | | | `Sources/CoreTypesImplementation/Tests/CoreProviderTests.swift` | 55 |
| | | | | |
| `//Sources/Repositories:Repositories` | swift_library | 529 | `Sources/Repositories/Types/RepositoryError.swift` | 180 |
| | | | `Sources/Repositories/Types/Repository.swift` | 95 |
| | | | `Sources/Repositories/Types/RepositoryProtocols.swift` | 93 |
| | | | `Sources/Repositories/Types/RepositoryState.swift` | 79 |
| | | | `Sources/Repositories/Types/LogMetadataBuilder.swift` | 49 |
| | | | `Sources/Repositories/Types/RepositoryStats.swift` | 28 |
| | | | `Sources/Repositories/Protocols/RepositoryProtocol.swift` | 5 |
| | | | | |
| `//Sources/CryptoTypes:CryptoTypes` | swift_library | 517 | `Sources/CryptoTypes/Services/CredentialManager.swift` | 183 |
| | | | `Sources/CryptoTypes/Services/DefaultCryptoService.swift` | 84 |
| | | | `Sources/CryptoTypes/Types/CredentialManager.swift` | 80 |
| | | | `Sources/CryptoTypes/Protocols/CryptoServiceProtocol.swift` | 42 |
| | | | `Sources/CryptoTypes/Protocols/CryptoService.swift` | 34 |
| | | | `Sources/CryptoTypes/Types/CryptoConfiguration.swift` | 29 |
| | | | `Sources/CryptoTypes/Types/CryptoConfig.swift` | 21 |
| | | | `Sources/CryptoTypes/Protocols/CredentialManagerProtocol.swift` | 20 |
| | | | `Sources/CryptoTypes/Types/SecureStorageData.swift` | 18 |
| | | | `Sources/CryptoTypes/Services/CryptoTypes_Services.swift` | 6 |
| | | | | |
| `//Sources/CoreTypesInterfaces:CoreTypesInterfaces` | swift_library | 421 | `Sources/CoreTypesInterfaces/Tests/SecureDataTests.swift` | 81 |
| | | | `Sources/CoreTypesInterfaces/Sources/ErrorTypes.swift` | 74 |
| | | | `Sources/CoreTypesInterfaces/Sources/SecureData.swift` | 66 |
| | | | `Sources/CoreTypesInterfaces/Tests/ByteArrayTests.swift` | 64 |
| | | | `Sources/CoreTypesInterfaces/Sources/ByteArray.swift` | 53 |
| | | | `Sources/CoreTypesInterfaces/Sources/CoreProvider.swift` | 53 |
| | | | `Sources/CoreTypesInterfaces/Sources/CoreTypesInterfaces.swift` | 15 |
| | | | `Sources/CoreTypesInterfaces/Sources/Extensions.swift` | 15 |
| | | | | |
| `//Sources/SecureBytes:SecureBytes` | swift_library | 362 | `Sources/SecureBytes/Sources/SecureBytes.swift` | 196 |
| | | | `Sources/SecureBytes/Tests/SecureBytesTests.swift` | 166 |
| | | | | |
| `//Sources/Services/SecurityUtils:SecurityUtils` | swift_library | 353 | `Sources/Services/SecurityUtils/Services/SecurityBookmarkService.swift` | 106 |
| | | | `Sources/Services/SecurityUtils/Protocols/URLProvider.swift` | 98 |
| | | | `Sources/Services/SecurityUtils/Services/EncryptedBookmarkService.swift` | 97 |
| | | | `Sources/Services/SecurityUtils/Services/PathURLProvider.swift` | 52 |
| | | | | |
| `//Sources/SecureString:SecureString` | swift_library | 267 | `Sources/SecureString/Sources/SecureString.swift` | 179 |
| | | | `Sources/SecureString/Tests/SecureStringTests.swift` | 88 |
| | | | | |
| `//Sources/Core/Services:CoreServices` | swift_library | 267 | `Sources/Core/Services/Types/KeyStatus.swift` | 77 |
| | | | `Sources/Core/Services/Types/KeyMetadata.swift` | 64 |
| | | | `Sources/Core/Services/Types/SecurityPolicy.swift` | 50 |
| | | | `Sources/Core/Services/TypeAliases/XPCServiceProtocolAlias.swift` | 23 |
| | | | `Sources/Core/Services/Types/ServiceState.swift` | 22 |
| | | | `Sources/Core/Services/Types/ValidationResult.swift` | 13 |
| | | | `Sources/Core/Services/Types/StorageLocation.swift` | 11 |
| | | | `Sources/Core/Services/Types/XPCServiceProtocol.swift` | 5 |
| | | | `Sources/Core/Services/TypeAliases/CoreTypes.swift` | 2 |
| | | | | |
| `//Sources/Resources:Resources` | swift_library | 260 | `Sources/Resources/Protocols/ResourceProtocol.swift` | 172 |
| | | | `Sources/Resources/Types/ResourceError.swift` | 34 |
| | | | `Sources/Resources/Protocols/ManagedResource.swift` | 29 |
| | | | `Sources/Resources/Types/ResourceState.swift` | 25 |
| | | | | |
| `//Sources/SecurityInterfaces:SecurityInterfaces` | swift_library | 226 | `Sources/SecurityInterfaces/Tests/SecurityProviderTests.swift` | 152 |
| | | | `Sources/SecurityInterfaces/Models/SecurityModels.swift` | 74 |
| | | | | |
| `//Sources/UmbraCoreTypes/CoreErrors:UmbraCoreTypesCoreErrors` | swift_library | 216 | `Sources/UmbraCoreTypes/CoreErrors/Sources/ErrorMapping.swift` | 121 |
| | | | `Sources/UmbraCoreTypes/CoreErrors/Sources/ResourceLocatorError.swift` | 70 |
| | | | `Sources/UmbraCoreTypes/CoreErrors/Sources/CEPackage.swift` | 25 |
| | | | | |
| `//Sources/SecurityTypeConverters:SecurityTypeConverters` | swift_library | 201 | `Sources/SecurityTypeConverters/Sources/DTOExtensions.swift` | 89 |
| | | | `Sources/SecurityTypeConverters/Sources/BinaryDataConverters.swift` | 81 |
| | | | `Sources/SecurityTypeConverters/Sources/ErrorMappers.swift` | 31 |
| | | | | |
| `//Sources/SecurityBridgeProtocolAdapters:SecurityBridgeProtocolAdapters` | swift_library | 180 | `Sources/SecurityBridgeProtocolAdapters/Sources/SecurityProviderProtocolAdapter.swift` | 146 |
| | | | `Sources/SecurityBridgeProtocolAdapters/Sources/SecurityBridgeErrorMapper.swift` | 34 |
| | | | | |
| `//Sources/SecurityTypes:SecurityTypes` | swift_library | 178 | `Sources/SecurityTypes/Protocols/SecurityProvider.swift` | 49 |
| | | | `Sources/SecurityTypes/Protocols/SecureStorageProvider.swift` | 37 |
| | | | `Sources/SecurityTypes/Types/SecurityError.swift` | 34 |
| | | | `Sources/SecurityTypes/Types/HashAlgorithm.swift` | 30 |
| | | | `Sources/SecurityTypes/Types/SecurityError+Extended.swift` | 28 |
| | | | | |
| `//Sources/Services:Services` | swift_library | 176 | `Sources/Services/CredentialManager/CredentialManager.swift` | 98 |
| | | | `Sources/Services/CryptoService/CryptoService.swift` | 72 |
| | | | `Sources/Services/SecurityUtils/SecurityUtils.swift` | 6 |
| | | | | |
| `//Sources/SecurityProtocolsCore:SecurityProtocolsCore` | swift_library | 116 | `Sources/SecurityProtocolsCore/Tests/SecurityProtocolsCoreTests.swift` | 95 |
| | | | `Sources/SecurityProtocolsCore/Sources/SecurityProtocolsCore.swift` | 21 |
| | | | | |
| `//Sources/SecurityUtils:SecurityUtils` | swift_library | 79 | `Sources/SecurityUtils/Protocols/URLProvider.swift` | 33 |
| | | | `Sources/SecurityUtils/Protocols/SecurityBookmarkServiceProtocol.swift` | 24 |
| | | | `Sources/SecurityUtils/Protocols/CredentialManager.swift` | 22 |
| | | | | |
| `//Sources/UmbraLoggingAdapters:UmbraLoggingAdapters` | swift_library | 30 | `Sources/UmbraLoggingAdapters/Sources/UmbraLoggingAdapters.swift` | 30 |
| | | | | |
| `//Sources/SecurityCoreAdapters:SecurityCoreAdapters` | swift_library | 27 | `Sources/SecurityCoreAdapters/Sources/SecurityCoreAdapters.swift` | 27 |
| | | | | |
| `//Sources/Snapshots:Snapshots` | swift_library | 5 | `Sources/Snapshots/Protocols/SnapshotProtocol.swift` | 5 |
| | | | | |
| `//Sources/Autocomplete:Autocomplete` | swift_library | 5 | `Sources/Autocomplete/Protocols/AutocompleteProtocol.swift` | 5 |
| | | | | |
