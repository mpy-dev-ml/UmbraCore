# UmbraCore Build Status

## Build Status as of 2025-02-26

| Target | Build Status |
|--------|-------------|
| UmbraLogging | ✅ SUCCESS |
| ErrorHandlingModels | ✅ SUCCESS |
| ErrorHandlingCommon | ✅ SUCCESS |
| ErrorHandlingProtocols | ✅ SUCCESS |
| ErrorHandling | ✅ SUCCESS |
| SecurityTypesTypes | ✅ SUCCESS |
| SecurityTypesProtocols | ✅ SUCCESS |
| SecurityTypes | ✅ SUCCESS |
| CryptoTypesTypes | ✅ SUCCESS |
| CryptoTypesProtocols | ✅ SUCCESS |
| CryptoTypesServices | ✅ SUCCESS |
| CryptoTypes | ✅ SUCCESS |
| SecurityUtilsProtocols | ✅ SUCCESS |
| SecurityUtils | ✅ SUCCESS |
| XPCCore | ✅ SUCCESS |
| XPC | ✅ SUCCESS |
| UmbraXPC | ✅ SUCCESS |
| UmbraKeychainService | ✅ SUCCESS |
| UmbraCryptoService | ✅ SUCCESS |
| UmbraCrypto | ✅ SUCCESS |
| UmbraBookmarkService | ✅ SUCCESS |
| UmbraSecurityExtensions | ✅ SUCCESS |
| UmbraSecurityServices | ❌ FAILED (circular dependency between Foundation and CoreServicesTypes) |
| UmbraSecurity | ❌ FAILED (depends on UmbraSecurityServices) |
| ResticTypes | ✅ SUCCESS |
| ResticCLIHelperTypes | ✅ SUCCESS |
| ResticCLIHelperModels | ✅ SUCCESS |
| ResticCLIHelperProtocols | ✅ SUCCESS |
| ResticCLIHelperCommands | ✅ SUCCESS |
| ResticCLIHelper | ✅ SUCCESS |
| CryptoServiceProtocol | ✅ SUCCESS |
| ServiceTypes | ✅ SUCCESS |
| CryptoService | ✅ SUCCESS |
| CredentialManager | ✅ SUCCESS |
| Services_SecurityUtilsProtocols | ✅ SUCCESS |
| Services_SecurityUtilsServices | ✅ SUCCESS |
| Services_SecurityUtils | ✅ SUCCESS |
| Services | ✅ SUCCESS |
| ResourcesTypes | ✅ SUCCESS |
| ResourcesProtocols | ✅ SUCCESS |
| Resources | ✅ SUCCESS |
| RepositoriesTypes | ✅ SUCCESS |
| RepositoriesProtocols | ✅ SUCCESS |
| Repositories | ❌ FAILED (RepositoryStatistics does not conform to RepositoryStats) |
| SnapshotsProtocols | ✅ SUCCESS |
| Snapshots | ✅ SUCCESS |
| FeaturesLoggingModels | ✅ SUCCESS |
| FeaturesLoggingErrors | ✅ SUCCESS |
| FeaturesLoggingProtocols | ✅ SUCCESS |
| FeaturesLoggingServices | ✅ SUCCESS |
| FeaturesCryptoModels | ✅ SUCCESS |
| FeaturesCryptoProtocols | ✅ SUCCESS |
| Features | ✅ SUCCESS |
| CoreServicesTypes | ✅ SUCCESS |

## Summary
- 49 targets built successfully
- 3 targets failed to build

## Identified Issues
1. **UmbraSecurityServices**: Circular dependency between Foundation and CoreServicesTypes
2. **UmbraSecurity**: Fails because it depends on UmbraSecurityServices
3. **Repositories**: Type mismatch - RepositoryStatistics does not conform to RepositoryStats

## Next Steps
- Continue building remaining targets
- Investigate and resolve the circular dependency in UmbraSecurityServices
- Fix the type conformance issue in Repositories
- Update this document with final build status
