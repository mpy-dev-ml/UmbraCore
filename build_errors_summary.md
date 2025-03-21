# UmbraCore Build Errors Summary

## Overview
A full build of the UmbraCore project was run using `bazelisk build //... -k --verbose_failures` to identify all current errors. The errors have been categorized to help prioritize fixes.

## Key Findings

### 1. XPC Protocol Consolidation Issues
Most errors relate to the ongoing XPC Protocol Consolidation work and fall into these categories:

- **Missing XPCSecurityError Type (20 occurrences)**
  - ✅ **RESOLVED**: The `XPCSecurityError` type has been identified as a deprecated typealias 
  - It should be replaced with `ErrorHandlingDomains.UmbraErrors.Security.Protocols`
  - This is part of the XPC Protocol Consolidation effort where type aliases are being replaced with fully qualified types
  - An automated migration script has been created: `xpc_security_error_migration.py`
  - A comprehensive migration guide has been added: `XPC_PROTOCOLS_MIGRATION_GUIDE.md`

- **Missing CryptoError Members (30+ occurrences)**
  - Various members of `CryptoError` are referenced but not found
  - This includes `asymmetricEncryptionError`, `decryptionError`, `keyGenerationError`, etc.

- **Missing Foundation Adapter Types (40+ occurrences)**
  - Types like `FoundationSecurityResult`, `FoundationCryptoServiceImpl`, etc. are not in scope

- **Syntax and Type Definition Issues**
  - ✅ **RESOLVED**: Fixed syntax errors in SecurityBridgeTypes.swift:
    - Corrected typealias declaration syntax
    - Renamed `ErrorHandlingDomains.UmbraErrors.Security.ProtocolsDTO` to `SecurityProtocolsErrorDTO`
  - ✅ **RESOLVED**: Added missing `CoreServicesTypes.ServiceState` enum
  - ✅ **RESOLVED**: Fixed access control issue with `StatusType` in KeyStatus.swift
  - ✅ **RESOLVED**: Removed type aliases in favor of fully qualified types:
    - Removed `SecurityProtocolsError` type alias in SecurityBridgeTypes.swift
    - Removed `ServiceState` type alias in ServiceState.swift
    - Removed `KeyStatus`, `StorageLocation` and other type aliases in Core/Services/Types
    - Updated references to use fully qualified types like `KeyManagementTypes.KeyStatus`

### 2. Most Affected Modules

1. **UmbraSecurity (30 errors)**
   - Primary issues in `SecurityService.swift`
   - Missing Security Provider adapters and Foundation implementations

2. **SecurityImplementation (22+ errors)**
   - Issues with CryptoErrorMapper
   - Missing member access in various crypto services

3. **Features/Logging (10 errors)**
   - Service state and logging-related errors

4. **CryptoTypes (5 errors)**
   - Issues with CredentialManager and error mapping

### 3. Error Categories

1. **Missing Member Access (36%)** - Type members that don't exist
2. **Type Scope Issues (34%)** - Types not in scope or missing from modules 
3. **Missing Type/Module References (21%)** - Types not found in specified modules
4. **Other Error Types (9%)** - Build system, Objective-C compatibility, access control, type conversion

## Recommendations

1. **First Priority: Fix XPCSecurityError**
   - Ensure `XPCSecurityError` is properly exported from `XPCProtocolsCore`
   - Update modules to import it correctly

2. **Second Priority: Address CryptoError Members**
   - Add missing members to `CryptoError` type or
   - Update code to use the new error hierarchy (UmbraErrors.Crypto.Core)

3. **Third Priority: Foundation Adapters**
   - Implement missing Foundation adapter types or
   - Update code to use the new Foundation-independent DTOs

4. **High-Impact Files to Fix First**
   - `Sources/UmbraSecurity/Services/SecurityService.swift`
   - `Sources/SecurityImplementation/Sources/CryptoServices/Core/CryptoErrorMapper.swift`
   - `Sources/CryptoTypes/Types/CredentialManager.swift`

This analysis aligns with the ongoing XPC Protocol Consolidation and Foundation-independent DTO work referenced in the project memories. The errors reflect a project in transition between legacy and new API designs.
