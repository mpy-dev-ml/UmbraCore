# XPC Protocols Migration Guide

**Date: 4 March 2025**  
**UmbraCore Refactoring Project**

## Overview

This guide documents the migration path from the legacy XPC service protocols in `SecurityInterfaces` and `SecurityInterfacesBase` to the new consolidated protocols in `XPCProtocolsCore`. The migration is part of the larger UmbraCore refactoring effort to reduce redundancy, break circular dependencies, and standardise error handling.

## Protocol Hierarchy

### New Protocol Hierarchy (XPCProtocolsCore)

```
XPCServiceProtocolBasic
  ↓
XPCServiceProtocolStandard
  ↓
XPCServiceProtocolComplete
```

### Legacy Protocol Hierarchy (being deprecated)

```
SecurityInterfacesBase.XPCServiceProtocolBase
  ↓
SecurityInterfaces.XPCServiceProtocol
```

## Migration Steps

### 1. Update Imports

Replace imports of legacy protocols with XPCProtocolsCore:

```swift
// Old
import SecurityInterfacesBase
import SecurityInterfaces

// New
import XPCProtocolsCore
```

### 2. Update Protocol Conformance

Update your service classes to conform to the new protocols:

```swift
// Old
class MyXPCService: SecurityInterfaces.XPCServiceProtocol {
    // Implementation
}

// New
class MyXPCService: XPCProtocolsCore.XPCServiceProtocolStandard {
    // Implementation
}
```

### 3. Error Handling Changes

The new protocols use `Result<Success, XPCSecurityError>` instead of throwing functions:

```swift
// Old
func encrypt(data: BinaryData) async throws -> BinaryData {
    // Implementation that can throw
}

// New
func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    do {
        // Implementation
        return .success(result)
    } catch {
        return .failure(.cryptoError)
    }
}
```

### 4. Using Bridge Adapters During Migration

If you need to maintain compatibility during a phased migration, use the provided adapters:

```swift
// Bridge from legacy protocol to new protocol
let legacyService: SecurityInterfaces.XPCServiceProtocol = MyLegacyService()
let adaptedService = XPCProtocolMigrationFactory.createStandardAdapter(from: legacyService)

// Bridge from new protocol to legacy protocol
let newService: XPCServiceProtocolStandard = MyNewService()
let legacyCompatAdapter = LegacyXPCServiceAdapter(service: newService)
```

### 5. Using the XPCProtocolMigrationFactory

The `XPCProtocolMigrationFactory` provides convenience methods for creating protocol adapters:

```swift
// Create a standard protocol adapter
let standardAdapter = XPCProtocolMigrationFactory.createStandardAdapter(from: legacyService)

// Create a complete protocol adapter with all functionality
let completeAdapter = XPCProtocolMigrationFactory.createCompleteAdapter(from: legacyService)

// Create a basic protocol adapter with minimal functionality
let basicAdapter = XPCProtocolMigrationFactory.createBasicAdapter(from: legacyService)

// Convert errors between legacy and new formats
let standardError = XPCProtocolMigrationFactory.convertToStandardError(legacyError)
let legacyError = XPCProtocolMigrationFactory.convertToLegacyError(standardError)
```

## Key Method Mappings

| Legacy Method (SecurityInterfaces) | New Method (XPCProtocolsCore) |
|-----------------------------------|------------------------------|
| `ping() throws -> Bool` | `pingBasic() -> Result<Bool, XPCSecurityError>` |
| `resetSecurityData() throws` | `resetSecurity() -> Result<Void, XPCSecurityError>` |
| `getVersion() throws -> String` | `getServiceVersion() -> Result<String, XPCSecurityError>` |
| `getHostIdentifier() throws -> String` | `getDeviceIdentifier() -> Result<String, XPCSecurityError>` |
| `synchroniseKeys(_:) throws` | `synchronizeKeys(_:) -> Result<Void, XPCSecurityError>` |
| `encrypt(data:) throws -> BinaryData` | `encrypt(data:) -> Result<SecureBytes, XPCSecurityError>` |
| `decrypt(data:) throws -> BinaryData` | `decrypt(data:) -> Result<SecureBytes, XPCSecurityError>` |

## Type Changes

| Legacy Type | New Type |
|------------|----------|
| `BinaryData` | `SecureBytes` |
| Various error types | `XPCSecurityError` (alias to `UmbraCoreTypes.CESecurityError`) |

## Timeline

- **Phase 1 (March 2025)**: Legacy protocols marked as deprecated
- **Phase 2 (April 2025)**: All new code must use XPCProtocolsCore
- **Phase 3 (June 2025)**: Legacy protocols fully removed

## Troubleshooting

### Circular Dependencies

If you encounter circular dependency issues:

1. Use `@_exported import` only in the top-level module files
2. Use explicit imports in individual files
3. Use adapter pattern instead of direct inheritance where needed

### Namespace Conflicts

If you encounter namespace conflicts with Security-related types:

1. Use type aliasing with clear prefixes 
2. Avoid using same-named enums as module names
3. Reference CoreErrors.SecurityError using the CESecurityError alias

## Additional Resources

- See `XPCProtocolsMigration.swift` in SecurityInterfaces for example adapters
- Refer to `LegacyXPCServiceAdapter.swift` in XPCProtocolsCore for bridging helpers
- Run the existing test suites to verify compatibility during migration
