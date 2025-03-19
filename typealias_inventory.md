# Typealias Inventory
Generated on 2025-03-19 19:02:21

## All Typealiases

| Module | File | Line | Typealias | Original Type | Category | Recommendation |
| ------ | ---- | ---- | --------- | ------------- | -------- | -------------- |
| Core | Sources/Core/Services/Types/KeyMetadata.swift | 23 | AccessControls | KeyManagementTypes.KeyMetadata.AccessControls | Service | Refactor |
| Core | Sources/Core/Services/CryptoService.swift | 21 | CryptoConfig | CryptoTypes.CryptoConfig | Service | Refactor |
| Core | Sources/Core/Core_Aliases.swift | 8 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| Core | Sources/Core/Services/CryptoError.swift | 15 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| Core | Sources/Core/Services/KeyManager.swift | 493 | KeyManagerError | CoreErrors.KeyManagerError | Error Type | Keep |
| Core | Sources/Core/Core_Aliases.swift | 11 | KeyManagerError | CoreErrors.KeyManagerError | Error Type | Keep |
| Core | Sources/Core/Services/Types/DeprecatedTypeAliases.swift | 12 | KeyMetadataLegacy | KeyMetadata | Legacy/Deprecated | Deprecate |
| Core | Sources/Core/Services/Types/KeyStatus.swift | 11 | KeyStatus | KeyManagementTypes.KeyStatus | Service | Refactor |
| Core | Sources/Core/Services/Types/DeprecatedTypeAliases.swift | 18 | KeyStatusLegacy | KeyStatus | Legacy/Deprecated | Deprecate |
| Core | Sources/Core/Services/TypeAliases/XPCServiceProtocolAlias.swift | 41 | LegacyXPCServiceProtocol | XPCServiceProtocol | Protocol | Refactor |
| Core | Sources/Core/Services/SecurityService.swift | 16 | SPCSecurityError | UmbraErrors.Security.Protocols | Error Type | Keep |
| Core | Sources/Core/Core_Aliases.swift | 5 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| Core | Sources/Core/Services/UmbraService.swift | 40 | ServiceError | CoreErrors.ServiceError | Error Type | Keep |
| Core | Sources/Core/Core_Aliases.swift | 14 | ServiceError | CoreErrors.ServiceError | Error Type | Keep |
| Core | Sources/Core/Services/Types/ServiceState.swift | 12 | ServiceState | CoreServicesTypes.ServiceState | Service | Refactor |
| Core | Sources/Core/Services/Types/KeyStatus.swift | 36 | StatusType | KeyManagementTypes.KeyStatus.StatusType | Service | Refactor |
| Core | Sources/Core/Services/Types/DeprecatedTypeAliases.swift | 24 | StorageLocationLegacy | StorageLocation | Legacy/Deprecated | Deprecate |
| Core | Sources/Core/Services/TypeAliases/XPCServiceProtocolAlias.swift | 26 | XPCServiceProtocol | XPCServiceProtocolStandard | Protocol | Refactor |
| Core | Sources/Core/Services/Types/XPCServiceProtocol.swift | 5 | XPCServiceProtocol | XPCProtocolsCore.ServiceProtocolStandard | Protocol | Refactor |
| Core | Sources/Core/Services/TypeAliases/XPCServiceProtocolAlias.swift | 29 | XPCServiceProtocolBase | XPCServiceProtocolBasic | Protocol | Refactor |
| Core | Sources/Core/Services/TypeAliases/XPCServiceProtocolAlias.swift | 33 | XPCServiceProtocolComplete | XPCServiceProtocolStandard | Protocol | Refactor |
| CoreErrors | Sources/CoreErrors/CoreErrors_Extensions.swift | 16 | CE | ErrorHandlingDomains.SecurityError | Error Type | Keep |
| CoreErrors | Sources/CoreErrors/CoreErrors_Extensions.swift | 29 | CE | ErrorHandlingDomains.RepositoryErrorType | Error Type | Keep |
| CoreErrors | Sources/CoreErrors/CoreErrors_Extensions.swift | 35 | CE | ErrorHandlingDomains.ApplicationError | Error Type | Keep |
| CoreErrors | Sources/CoreErrors/XPCErrors_Extensions.swift | 110 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| CoreErrors | Sources/CoreErrors/XPCErrors_Extensions.swift | 106 | ServiceError | CoreErrors.ServiceError | Error Type | Keep |
| CoreServicesTypes | Sources/CoreServicesTypes/KeyMetadata.swift | 17 | AccessControls | KeyManagementTypes.KeyMetadata.AccessControls | Service | Refactor |
| CoreServicesTypes | Sources/CoreServicesTypes/KeyStatus.swift | 12 | KeyStatus | KeyManagementTypes.KeyStatus | Service | Refactor |
| CoreServicesTypesNoFoundation | Sources/CoreServicesTypesNoFoundation/KeyMetadata.swift | 16 | AccessControls | KeyManagementTypes.KeyMetadata.AccessControls | Service | Refactor |
| CoreServicesTypesNoFoundation | Sources/CoreServicesTypesNoFoundation/KeyStatus.swift | 15 | KeyStatus | KeyManagementTypes.KeyStatus | Service | Refactor |
| CoreTypesImplementation | Sources/CoreTypesImplementation/Sources/ErrorAdapters.swift | 10 | CESecurityError | UmbraErrors.Security.Core | Error Type | Keep |
| CoreTypesInterfaces | Sources/CoreTypesInterfaces/Sources/CoreTypesInterfaces.swift | 5 | BinaryData | SecureData | Binary Data | Keep |
| CoreTypesInterfaces | Sources/CoreTypesInterfaces/Sources/Extensions.swift | 15 | CT | CoreTypesExtensions | Convenience | Refactor |
| CoreTypesInterfaces | Sources/CoreTypesInterfaces/Sources/ErrorTypes.swift | 45 | CoreSecurityError | CoreErrors.SecurityError | Error Type | Keep |
| CoreTypesInterfaces | Sources/CoreTypesInterfaces/Sources/CoreTypesInterfaces.swift | 15 | SecurityErrorBase | CoreSecurityError | Error Type | Refactor |
| CryptoTypes | Sources/CryptoTypes/CryptoTypes_Aliases.swift | 4 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| CryptoTypes | Sources/CryptoTypes/Services/CryptoTypes_Services.swift | 6 | DefaultCryptoService | DefaultCryptoServiceImpl | Service | Keep |
| ErrorHandling | Sources/ErrorHandling/Protocols/ErrorHandlingProtocol.swift | 101 | ErrorSeverity | ErrorHandlingCommon.ErrorSeverity | Error Type | Keep |
| ErrorHandling | Sources/ErrorHandling/Mapping/SecurityErrorMapper.swift | 32 | SourceType | UmbraErrors.GeneralSecurity.Core | Error Type | Keep |
| ErrorHandling | Sources/ErrorHandling/Mapping/ApplicationErrorMapper.swift | 9 | SourceType | UmbraErrors.Application.Core | Error Type | Keep |
| ErrorHandling | Sources/ErrorHandling/Mapping/ErrorRegistry.swift | 108 | SourceType | M.ErrorTypeB | Error Type | Keep |
| ErrorHandling | Sources/ErrorHandling/Mapping/SecurityErrorMapper.swift | 35 | TargetType | ErrorHandlingTypes.SecurityError | Error Type | Keep |
| ErrorHandling | Sources/ErrorHandling/Mapping/ErrorRegistry.swift | 109 | TargetType | M.ErrorTypeA | Error Type | Keep |
| ErrorHandling | Sources/ErrorHandling/Mapping/ApplicationErrorMapper.swift | 12 | TargetType | ApplicationError | Error Type | Refactor |
| Features | Sources/Features/Features_Aliases.swift | 4 | LoggingError | CoreErrors.LoggingError | Error Type | Keep |
| KeyManagementTypes | Sources/KeyManagementTypes/Sources/TypeConverters.swift | 275 | RawLocations | TypeConverters.RawLocations | Convenience | Refactor |
| KeyManagementTypes | Sources/KeyManagementTypes/Sources/TypeConverters.swift | 285 | RawMetadata | TypeConverters.RawMetadata | Convenience | Refactor |
| KeyManagementTypes | Sources/KeyManagementTypes/Sources/TypeConverters.swift | 280 | RawStatus | TypeConverters.RawStatus | Convenience | Refactor |
| LoggingWrapper | Sources/LoggingWrapper/LogLevel.swift | 31 | LogLevel | LoggingWrapperInterfaces.LogLevel | Convenience | Refactor |
| Repositories | Sources/Repositories/Types/RepositoryProtocols.swift | 92 | CompleteRepository | RepositoryCore & RepositoryLocking & RepositoryMaintenance & | Protocol | Refactor |
| Repositories | Sources/Repositories/Repositories_Aliases.swift | 10 | LegacyRepositoryError | CoreErrors.RepositoryError | Error Type | Keep |
| Repositories | Sources/Repositories/Types/Repository.swift | 7 | Repository | RepositoryCore & RepositoryLocking & RepositoryMaintenance & | Convenience | Keep |
| Repositories | Sources/Repositories/Repositories_Aliases.swift | 6 | RepositoryError | ErrorHandlingDomains.RepositoryError | Error Type | Keep |
| Resources | Sources/Resources/Resources_Aliases.swift | 4 | ResourceError | CoreErrors.ResourceError | Error Type | Keep |
| SecureBytes | Sources/SecureBytes/Sources/SecureBytes.swift | 174 | ArrayLiteralElement | UInt8 | Convenience | Refactor |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/XPCSecurityDTOAdapter.swift | 12 | ConfigDTO | CoreDTOs.SecurityConfigDTO | Data Transfer Object | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityProtocolDTOAdapter.swift | 12 | ConfigDTO | CoreDTOs.SecurityConfigDTO | Data Transfer Object | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityDTOAdapter.swift | 12 | ConfigDTO | CoreDTOs.SecurityConfigDTO | Data Transfer Object | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/SecurityBridge.swift | 28 | ConfigDTO | CoreDTOs.SecurityConfigDTO | Data Transfer Object | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityDTOAdapter.swift | 13 | ErrorDTO | CoreDTOs.SecurityErrorDTO | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityProtocolDTOAdapter.swift | 13 | ErrorDTO | CoreDTOs.SecurityErrorDTO | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/SecurityBridge.swift | 31 | ErrorDTO | CoreDTOs.SecurityErrorDTO | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/XPCSecurityDTOAdapter.swift | 13 | ErrorDTO | CoreDTOs.SecurityErrorDTO | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/XPCBridge/ComprehensiveSecurityXPCAdapter.swift | 216 | GetStatusCallback | @convention(c) ( | Convenience | Refactor |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityProtocolDTOAdapter.swift | 14 | ProtocolConfigDTO | SecurityProtocolsCore.SecurityConfigDTO | Data Transfer Object | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/XPCBridge/XPCServiceAdapter.swift | 12 | ProtocolErrorType | UmbraErrors.Security.Protocols | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/ProtocolAdapters/KeyManagementAdapter.swift | 8 | SPCSecurityError | UmbraErrors.Security.Protocols | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityProtocolDTOAdapter.swift | 15 | SecurityCoreError | UmbraErrors.Security.Core | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/SecurityBridge.swift | 37 | SecurityError | UmbraErrors.Security.Core | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityDTOAdapter.swift | 14 | SecurityError | UmbraErrors.Security.Core | Error Type | Keep |
| SecurityBridge | Sources/SecurityBridge/Sources/DTOAdapters/SecurityProtocolDTOAdapter.swift | 16 | SecurityProtocolError | UmbraErrors.Security.Protocols | Error Type | Keep |
| SecurityBridgeProtocolAdapters | Sources/SecurityBridgeProtocolAdapters/Sources/SecurityProviderProtocolAdapter.swift | 12 | SPCSecurityError | UmbraErrors.Security.Protocols | Error Type | Keep |
| SecurityCoreAdapters | Sources/SecurityCoreAdapters/Sources/Adapters/AnyCryptoService.swift | 6 | SecurityError | UmbraErrors.Security.Protocols | Error Type | Keep |
| SecurityImplementation | Sources/SecurityImplementation/Sources/CryptoServices/Core/CryptoError.swift | 25 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| SecurityInterfacesBase | Sources/SecurityInterfacesBase/SecurityInterfacesBase_Aliases.swift | 6 | CoreSecurityError | CoreErrors.SecurityError | Error Type | Keep |
| SecurityProtocolsCore | Sources/SecurityProtocolsCore/Sources/Types/BinaryDataTypealias.swift | 6 | BinaryData | SecureBytes | Binary Data | Keep |
| SecurityProtocolsCore | Sources/SecurityProtocolsCore/Sources/SecurityProtocolsCore.swift | 21 | SecurityConfig | SecurityConfigDTO | Data Transfer Object | Keep |
| SecurityProtocolsCore | Sources/SecurityProtocolsCore/Sources/SecurityProtocolsCore.swift | 20 | SecurityResult | SecurityResultDTO | Data Transfer Object | Keep |
| SecurityTypeConverters | Sources/SecurityTypeConverters/Sources/DTOExtensions.swift | 10 | SPCSecurityError | UmbraErrors.Security.Protocols | Error Type | Keep |
| SecurityTypes | Sources/SecurityTypes/SecurityTypes_Aliases.swift | 6 | CoreSecurityError | UmbraErrors.Security.Core | Error Type | Keep |
| Services | Sources/Services/CryptoService/CryptoService.swift | 66 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| Services | Sources/Services/Services_Aliases.swift | 8 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| Services | Sources/Services/Services_Aliases.swift | 11 | KeyManagerError | CoreErrors.KeyManagerError | Error Type | Keep |
| Services | Sources/Services/Services_Aliases.swift | 5 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| Services | Sources/Services/Services_Aliases.swift | 14 | ServiceError | CoreErrors.ServiceError | Error Type | Keep |
| UmbraCoreTypes | Sources/UmbraCoreTypes/CoreErrors/Sources/CEPackage.swift | 7 | CEResourceError | CoreErrors.ResourceError | Error Type | Keep |
| UmbraCoreTypes | Sources/UmbraCoreTypes/CoreErrors/Sources/CEPackage.swift | 10 | CESecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraCoreTypes | Sources/UmbraCoreTypes/Sources/SecureBytes+Sequence.swift | 5 | Element | UInt8 | Convenience | Refactor |
| UmbraCoreTypes | Sources/UmbraCoreTypes/Sources/SecureBytes+Sequence.swift | 15 | Element | UInt8 | Convenience | Refactor |
| UmbraCoreTypes | Sources/UmbraCoreTypes/Sources/SecureBytes+Sequence.swift | 6 | Iterator | SecureBytesIterator | Binary Data | Keep |
| UmbraCryptoService | Sources/UmbraCryptoService/UmbraCryptoService_Aliases.swift | 4 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraErrors | Sources/UmbraErrors/Mapping/ErrorMapper.swift | 39 | SourceError | Error | Error Type | Refactor |
| UmbraErrors | Sources/UmbraErrors/Mapping/SecurityErrorMapper.swift | 42 | SourceError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraErrors | Sources/UmbraErrors/Mapping/SecurityErrorMapper.swift | 7 | SourceError | SecurityError | Error Type | Refactor |
| UmbraErrors | Sources/UmbraErrors/Mapping/SecurityErrorMapper.swift | 43 | TargetError | SecurityError | Error Type | Refactor |
| UmbraErrors | Sources/UmbraErrors/Mapping/ErrorMapper.swift | 42 | TargetError | Target | Error Type | Refactor |
| UmbraErrors | Sources/UmbraErrors/Mapping/SecurityErrorMapper.swift | 8 | TargetError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Types_Aliases.swift | 14 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Services_Aliases.swift | 14 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/UmbraCryptoService_Aliases.swift | 4 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Core_Aliases.swift | 14 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/CryptoService_Aliases.swift | 4 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/CryptoTypes_Aliases.swift | 4 | CryptoError | CoreErrors.CryptoError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Core_Aliases.swift | 5 | KeyManagerError | CoreErrors.KeyManagerError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Services_Aliases.swift | 5 | KeyManagerError | CoreErrors.KeyManagerError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Errors_Aliases.swift | 4 | LoggingError | CoreErrors.LoggingError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Protocols_Aliases.swift | 7 | LoggingError | CoreErrors.LoggingError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Features_Aliases.swift | 4 | LoggingError | CoreErrors.LoggingError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/UmbraLogging_Aliases.swift | 4 | LoggingError | CoreErrors.LoggingError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Repositories_Aliases.swift | 4 | RepositoryError | CoreErrors.RepositoryError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Types_Aliases.swift | 8 | RepositoryError | CoreErrors.RepositoryError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Types_Aliases.swift | 5 | ResourceError | CoreErrors.ResourceError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Resources_Aliases.swift | 4 | ResourceError | CoreErrors.ResourceError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Protocols_Aliases.swift | 4 | ResourceError | CoreErrors.ResourceError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/SecurityTypes_Aliases.swift | 5 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Services_Aliases.swift | 11 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/SecurityProtocolsCore_Aliases.swift | 5 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/SecurityInterfacesBase_Aliases.swift | 5 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Types_Aliases.swift | 11 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Core_Aliases.swift | 11 | SecurityError | CoreErrors.SecurityError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Services_Aliases.swift | 8 | ServiceError | CoreErrors.ServiceError | Error Type | Keep |
| UmbraLogging | Sources/UmbraLogging/Core_Aliases.swift | 8 | ServiceError | CoreErrors.ServiceError | Error Type | Keep |
| XPCProtocolsCore | Sources/XPCProtocolsCore/Sources/XPCProtocolMigrationFactory.swift | 9 | SPCSecurityError | UmbraErrors.Security.Protocols | Error Type | Keep |
| XPCProtocolsCore | Sources/XPCProtocolsCore/Sources/XPCProtocolsCore.swift | 114 | XPCSecurityError | SecurityError | Error Type | Refactor |

## Cross-Module References

| Module | Typealias | Original Type |
| ------ | --------- | ------------- |
| Core | AccessControls | KeyManagementTypes.KeyMetadata.AccessControls |
| Core | CryptoConfig | CryptoTypes.CryptoConfig |
| Core | CryptoError | CoreErrors.CryptoError |
| Core | CryptoError | CoreErrors.CryptoError |
| Core | KeyManagerError | CoreErrors.KeyManagerError |
| Core | KeyManagerError | CoreErrors.KeyManagerError |
| Core | KeyStatus | KeyManagementTypes.KeyStatus |
| Core | SPCSecurityError | UmbraErrors.Security.Protocols |
| Core | SecurityError | CoreErrors.SecurityError |
| Core | ServiceError | CoreErrors.ServiceError |
| Core | ServiceError | CoreErrors.ServiceError |
| Core | ServiceState | CoreServicesTypes.ServiceState |
| Core | StatusType | KeyManagementTypes.KeyStatus.StatusType |
| Core | XPCServiceProtocol | XPCProtocolsCore.ServiceProtocolStandard |
| CoreErrors | CE | ErrorHandlingDomains.SecurityError |
| CoreErrors | CE | ErrorHandlingDomains.RepositoryErrorType |
| CoreErrors | CE | ErrorHandlingDomains.ApplicationError |
| CoreErrors | CryptoError | CoreErrors.CryptoError |
| CoreErrors | ServiceError | CoreErrors.ServiceError |
| CoreServicesTypes | AccessControls | KeyManagementTypes.KeyMetadata.AccessControls |
| CoreServicesTypes | KeyStatus | KeyManagementTypes.KeyStatus |
| CoreServicesTypesNoFoundation | AccessControls | KeyManagementTypes.KeyMetadata.AccessControls |
| CoreServicesTypesNoFoundation | KeyStatus | KeyManagementTypes.KeyStatus |
| CoreTypesImplementation | CESecurityError | UmbraErrors.Security.Core |
| CoreTypesInterfaces | CoreSecurityError | CoreErrors.SecurityError |
| CryptoTypes | CryptoError | CoreErrors.CryptoError |
| ErrorHandling | ErrorSeverity | ErrorHandlingCommon.ErrorSeverity |
| ErrorHandling | SourceType | UmbraErrors.GeneralSecurity.Core |
| ErrorHandling | SourceType | UmbraErrors.Application.Core |
| ErrorHandling | SourceType | M.ErrorTypeB |
| ErrorHandling | TargetType | ErrorHandlingTypes.SecurityError |
| ErrorHandling | TargetType | M.ErrorTypeA |
| Features | LoggingError | CoreErrors.LoggingError |
| KeyManagementTypes | RawLocations | TypeConverters.RawLocations |
| KeyManagementTypes | RawMetadata | TypeConverters.RawMetadata |
| KeyManagementTypes | RawStatus | TypeConverters.RawStatus |
| LoggingWrapper | LogLevel | LoggingWrapperInterfaces.LogLevel |
| Repositories | LegacyRepositoryError | CoreErrors.RepositoryError |
| Repositories | RepositoryError | ErrorHandlingDomains.RepositoryError |
| Resources | ResourceError | CoreErrors.ResourceError |
| SecurityBridge | ConfigDTO | CoreDTOs.SecurityConfigDTO |
| SecurityBridge | ConfigDTO | CoreDTOs.SecurityConfigDTO |
| SecurityBridge | ConfigDTO | CoreDTOs.SecurityConfigDTO |
| SecurityBridge | ConfigDTO | CoreDTOs.SecurityConfigDTO |
| SecurityBridge | ErrorDTO | CoreDTOs.SecurityErrorDTO |
| SecurityBridge | ErrorDTO | CoreDTOs.SecurityErrorDTO |
| SecurityBridge | ErrorDTO | CoreDTOs.SecurityErrorDTO |
| SecurityBridge | ErrorDTO | CoreDTOs.SecurityErrorDTO |
| SecurityBridge | ProtocolConfigDTO | SecurityProtocolsCore.SecurityConfigDTO |
| SecurityBridge | ProtocolErrorType | UmbraErrors.Security.Protocols |
| SecurityBridge | SPCSecurityError | UmbraErrors.Security.Protocols |
| SecurityBridge | SecurityCoreError | UmbraErrors.Security.Core |
| SecurityBridge | SecurityError | UmbraErrors.Security.Core |
| SecurityBridge | SecurityError | UmbraErrors.Security.Core |
| SecurityBridge | SecurityProtocolError | UmbraErrors.Security.Protocols |
| SecurityBridgeProtocolAdapters | SPCSecurityError | UmbraErrors.Security.Protocols |
| SecurityCoreAdapters | SecurityError | UmbraErrors.Security.Protocols |
| SecurityImplementation | CryptoError | CoreErrors.CryptoError |
| SecurityInterfacesBase | CoreSecurityError | CoreErrors.SecurityError |
| SecurityTypeConverters | SPCSecurityError | UmbraErrors.Security.Protocols |
| SecurityTypes | CoreSecurityError | UmbraErrors.Security.Core |
| Services | CryptoError | CoreErrors.CryptoError |
| Services | CryptoError | CoreErrors.CryptoError |
| Services | KeyManagerError | CoreErrors.KeyManagerError |
| Services | SecurityError | CoreErrors.SecurityError |
| Services | ServiceError | CoreErrors.ServiceError |
| UmbraCoreTypes | CEResourceError | CoreErrors.ResourceError |
| UmbraCoreTypes | CESecurityError | CoreErrors.SecurityError |
| UmbraCryptoService | CryptoError | CoreErrors.CryptoError |
| UmbraErrors | SourceError | CoreErrors.SecurityError |
| UmbraErrors | TargetError | CoreErrors.SecurityError |
| UmbraLogging | CryptoError | CoreErrors.CryptoError |
| UmbraLogging | CryptoError | CoreErrors.CryptoError |
| UmbraLogging | CryptoError | CoreErrors.CryptoError |
| UmbraLogging | CryptoError | CoreErrors.CryptoError |
| UmbraLogging | CryptoError | CoreErrors.CryptoError |
| UmbraLogging | CryptoError | CoreErrors.CryptoError |
| UmbraLogging | KeyManagerError | CoreErrors.KeyManagerError |
| UmbraLogging | KeyManagerError | CoreErrors.KeyManagerError |
| UmbraLogging | LoggingError | CoreErrors.LoggingError |
| UmbraLogging | LoggingError | CoreErrors.LoggingError |
| UmbraLogging | LoggingError | CoreErrors.LoggingError |
| UmbraLogging | LoggingError | CoreErrors.LoggingError |
| UmbraLogging | RepositoryError | CoreErrors.RepositoryError |
| UmbraLogging | RepositoryError | CoreErrors.RepositoryError |
| UmbraLogging | ResourceError | CoreErrors.ResourceError |
| UmbraLogging | ResourceError | CoreErrors.ResourceError |
| UmbraLogging | ResourceError | CoreErrors.ResourceError |
| UmbraLogging | SecurityError | CoreErrors.SecurityError |
| UmbraLogging | SecurityError | CoreErrors.SecurityError |
| UmbraLogging | SecurityError | CoreErrors.SecurityError |
| UmbraLogging | SecurityError | CoreErrors.SecurityError |
| UmbraLogging | SecurityError | CoreErrors.SecurityError |
| UmbraLogging | SecurityError | CoreErrors.SecurityError |
| UmbraLogging | ServiceError | CoreErrors.ServiceError |
| UmbraLogging | ServiceError | CoreErrors.ServiceError |
| XPCProtocolsCore | SPCSecurityError | UmbraErrors.Security.Protocols |

## Category Breakdown

| Category | Count | Percentage |
| -------- | ----- | ---------- |
| Binary Data | 3 | 2.4% |
| Convenience | 10 | 8.1% |
| Data Transfer Object | 7 | 5.6% |
| Service | 10 | 8.1% |
| Error Type | 85 | 68.5% |
| Legacy/Deprecated | 3 | 2.4% |
| Protocol | 6 | 4.8% |

## Recommendation Breakdown

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Refactor | 31 | 25.0% |
| Keep | 90 | 72.6% |
| Deprecate | 3 | 2.4% |

## Common Justifications

| Justification | Examples |
| ------------- | -------- |
| Consider direct service type reference | Core.AccessControls, Core.CryptoConfig, Core.KeyStatus |
| Cross-module error type reference | Core.CryptoError, Core.CryptoError, Core.KeyManagerError |
| Plan to remove after transition period | Core.KeyMetadataLegacy, Core.KeyStatusLegacy, Core.StorageLocationLegacy |
| Binary data type abstraction | CoreTypesInterfaces.BinaryData, SecurityProtocolsCore.BinaryData, UmbraCoreTypes.Iterator |
| Same-module alias adds indirection | CoreTypesInterfaces.CT, SecureBytes.ArrayLiteralElement, SecurityBridge.GetStatusCallback |
| Service implementation reference | CryptoTypes.DefaultCryptoService |
| Consider direct type import | KeyManagementTypes.RawLocations, KeyManagementTypes.RawMetadata, KeyManagementTypes.RawStatus |
| Direct protocol usage preferred for clarity | Core.LegacyXPCServiceProtocol, Core.XPCServiceProtocol, Core.XPCServiceProtocol |
| Consider direct error type usage | CoreTypesInterfaces.SecurityErrorBase, ErrorHandling.TargetType, UmbraErrors.SourceError |
| Simplifies complex type composition | Repositories.Repository |
| Data transfer object for API boundaries | SecurityBridge.ConfigDTO, SecurityBridge.ConfigDTO, SecurityBridge.ConfigDTO |

### Potential Recommendations
Based on the typealias policy, here are some initial recommendations:

1. Evaluate all typealiases against the acceptance criteria:
   - Is it required for external API compatibility?
   - Is it needed for transition/backward compatibility?
   - Does it simplify an extremely complex type signature?
2. For typealiases that don't meet these criteria, plan replacement with direct types
3. For typealiases that must be maintained, add documentation explaining why

## UmbraLogging Module Analysis

The UmbraLogging module contains 25 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 25 | 100.0% |

## KeyManagementTypes Module Analysis

The KeyManagementTypes module contains 3 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Refactor | 3 | 100.0% |

## SecurityProtocolsCore Module Analysis

The SecurityProtocolsCore module contains 3 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 3 | 100.0% |

## Services Module Analysis

The Services module contains 5 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 5 | 100.0% |

## CoreErrors Module Analysis

The CoreErrors module contains 5 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 5 | 100.0% |

## CoreTypesInterfaces Module Analysis

The CoreTypesInterfaces module contains 4 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 2 | 50.0% |
| Refactor | 2 | 50.0% |

## Repositories Module Analysis

The Repositories module contains 4 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 3 | 75.0% |
| Refactor | 1 | 25.0% |

## UmbraCoreTypes Module Analysis

The UmbraCoreTypes module contains 5 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 3 | 60.0% |
| Refactor | 2 | 40.0% |

## Core Module Analysis

The Core module contains 21 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 8 | 38.1% |
| Refactor | 10 | 47.6% |
| Deprecate | 3 | 14.3% |

## SecurityBridge Module Analysis

The SecurityBridge module contains 16 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 15 | 93.8% |
| Refactor | 1 | 6.2% |

## UmbraErrors Module Analysis

The UmbraErrors module contains 6 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 2 | 33.3% |
| Refactor | 4 | 66.7% |

## ErrorHandling Module Analysis

The ErrorHandling module contains 7 typealiases.

| Recommendation | Count | Percentage |
| -------------- | ----- | ---------- |
| Keep | 6 | 85.7% |
| Refactor | 1 | 14.3% |
