# UmbraCore Build Error Checklist

## Target 1: //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests (693 errors)

The errors in this target can be grouped into the following categories:

### 1. Visibility Issues (Internal vs Public)
- [x] Fix methods in `SecurityCoreAdapters` module that are declared public but use internal types
- [x] Fix `AnyCryptoService.swift` - methods with internal return types declared as public
- [x] Fix `CryptoServiceTypeAdapter.swift` - public methods returning internal types
- [x] Fix `SecurityImplementation` module - methods with internal return types

### 2. Missing Error Case Members
- [x] Add/fix error cases in `UmbraErrors.Security.Protocols`:
  - [x] `.invalidInput` 
  - [x] `.storageOperationFailed`
  - [x] `.notImplemented`
  - [x] `.encryptionFailed`
  - [x] `.decryptionFailed`
  - [x] `.randomGenerationFailed`
  - [x] `.serviceError`

### 3. Missing Types/References
- [x] Fix references to `CryptoWrapper` which cannot be found
- [x] Fix missing `isEmpty` reference
- [x] Resolve ambiguous `ErrorSeverity` references
- [x] Fix missing `LogDestination` type
- [x] Fix missing `ErrorLoggingService` type

### 4. Protocol Conformance Issues
- [x] Fix `CryptoServiceImpl` to conform to `CryptoServiceProtocol`
- [x] Fix `CryptoServiceTypeAdapter` to conform to `CryptoServiceProtocol`
- [x] Fix `AnyCryptoService` to conform to `CryptoServiceProtocol`

### 5. Duplicate Declarations
- [x] Fix duplicate declaration of `mapSecurityError` in `XPCServiceAdapter`

### 6. Type Conversion Issues
- [x] Fix conversion from `Result<SecureBytes, UmbraErrors.Security.Protocols>` to `SecurityResultDTO`

## Targets with errors:
- [ ] ~~//Sources/Logging:Logging~~ (doesn't exist in codebase)
- [ ] ~~//Sources/LoggingCore:LoggingCore~~ (doesn't exist in codebase)
- [x] //Sources/Repositories:Repositories 
- [x] //Sources/ErrorHandlingCore:ErrorHandlingCore
- [x] //Sources/ErrorHandlingUtilities:ErrorHandlingUtilities
- [ ] //Tests/ErrorHandlingTests:ErrorHandlingTests (temporarily disabled - requires architectural changes)

## Targets with Warnings Only:
- [x] //Sources/Repositories:Repositories (2 warnings)
- [x] //Sources/ErrorHandlingUtilities:ErrorHandlingUtilities (2 warnings)
- [x] //Sources/UmbraBookmarkService:UmbraBookmarkService (1 warning)

## Approach
1. First, fix the error enums and ensure all required cases exist
2. Then address the type visibility issues
3. Fix protocol conformance problems
4. Address remaining reference and conversion issues

## Progress Tracking

| Category | Item | Status | Notes |
|----------|------|--------|-------|
| Error Cases | `.invalidInput` | Fixed | |
| Error Cases | `.storageOperationFailed` | Fixed | |
| Error Cases | `.notImplemented` | Fixed | |
| Error Cases | `.encryptionFailed` | Fixed | |
| Error Cases | `.decryptionFailed` | Fixed | |
| Error Cases | `.randomGenerationFailed` | Fixed | |
| Error Cases | `.serviceError` | Fixed | |
| Visibility | `SecurityCoreAdapters` methods | Fixed | |
| Visibility | `AnyCryptoService` methods | Fixed | |
| Visibility | `CryptoServiceTypeAdapter` methods | Fixed | |
| Visibility | `SecurityImplementation` methods | Fixed | |
| References | `CryptoWrapper` references | Fixed | |
| References | `isEmpty` reference | Fixed | |
| References | `ErrorSeverity` ambiguity | Fixed | |
| References | `LogDestination` type | Fixed | |
| References | `ErrorLoggingService` type | Fixed | |
| Protocol | `CryptoServiceImpl` conformance | Fixed | |
| Protocol | `CryptoServiceTypeAdapter` conformance | Fixed | |
| Protocol | `AnyCryptoService` conformance | Fixed | |
| Duplicates | `mapSecurityError` in `XPCServiceAdapter` | Fixed | |
| Conversion | `Result` to `SecurityResultDTO` | Fixed | |

## Fixed Targets
- [x] //Sources/SecurityTypeConverters:SecurityTypeConverters
- [x] //Sources/SecurityBridgeProtocolAdapters:SecurityBridgeProtocolAdapters
- [x] //Sources/CoreTypesImplementation/Tests:CoreTypesImplementationTests
- [x] //Sources/ErrorHandlingUtilities:ErrorHandlingUtilities
- [x] //Sources/ErrorHandlingCore:ErrorHandlingCore
- [x] //Sources/Repositories:Repositories
- [x] //Sources/UmbraBookmarkService:UmbraBookmarkService
