# XPC Protocols Migration Guide

**Date: 5 March 2025**  
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
import UmbraCoreTypes // For SecureBytes and other core types
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

#### Common Error Handling Patterns

When migrating from throwing functions to Result types, follow these patterns:

```swift
// Pattern 1: Simple conversion for functions with no error-handling logic
// Old
func simpleOperation() async throws -> Data {
    return someData
}

// New
func simpleOperation() async -> Result<Data, XPCSecurityError> {
    return .success(someData)
}

// Pattern 2: Converting do-catch blocks
// Old
func complexOperation() async throws -> Data {
    do {
        let result = try await someRiskyOperation()
        return result
    } catch SomeError.invalidData {
        throw SecurityError.invalidData
    } catch {
        throw SecurityError.general("Unknown error: \(error)")
    }
}

// New
func complexOperation() async -> Result<Data, XPCSecurityError> {
    do {
        let result = try await someRiskyOperation()
        return .success(result)
    } catch SomeError.invalidData {
        return .failure(.invalidData)
    } catch {
        return .failure(.general)
    }
}

// Pattern 3: Converting checked continuations
// Old
func asyncOperation() async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
        performAsyncTask { result, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else if let result = result {
                continuation.resume(returning: result)
            } else {
                continuation.resume(throwing: SecurityError.general("No result"))
            }
        }
    }
}

// New
func asyncOperation() async -> Result<Data, XPCSecurityError> {
    return await withCheckedContinuation { continuation in
        performAsyncTask { result, error in
            if let error = error {
                continuation.resume(returning: .failure(.general))
            } else if let result = result {
                continuation.resume(returning: .success(result))
            } else {
                continuation.resume(returning: .failure(.invalidData))
            }
        }
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
let service = XPCProtocolMigrationFactory.createStandardService(implementation: MyImplementation())

// Create an adapter from legacy to modern
let adapter = XPCProtocolMigrationFactory.createLegacyAdapter(from: legacyService)
```

### 6. Migration Tools

The UmbraCore project provides several tools to assist with the XPC protocol migration:

#### Go-Based Analyzer

The `xpc_protocol_analyzer.go` script identifies files that need migration:

```bash
# Run the analyzer to identify files that need migration
cd /Users/mpy/CascadeProjects/UmbraCore
go run Scripts/xpc_protocol_analyzer.go
```

The analyzer will generate a report in JSON format at `xpc_protocol_analysis.json`, containing information about files that need to be updated.

#### Python Migration Helper

The `xpc_migration.py` script helps automate the migration process:

```bash
# Run migration on specific modules
cd /Users/mpy/CascadeProjects/UmbraCore
python3 Scripts/xpc_migration.py --module CoreTypes --module UmbraCryptoService
```

This script can perform basic migration tasks like updating imports and converting simple error handling patterns. Complex error handling may still require manual intervention.

### 7. Testing Your Migration

Always verify your migration with thorough testing:

1. Run existing unit tests with the new protocol implementations
2. Create specific test cases for Result-based error handling
3. Verify that protocol adapters correctly bridge between old and new implementations
4. Test the entire communication chain from client to service

## Common Migration Pitfalls

1. **Forgetting SecureBytes conversions**: Ensure Data/BinaryData is properly converted to SecureBytes
2. **Missing error mapping**: Ensure all possible error cases are mapped to appropriate XPCSecurityError cases
3. **Overlooked throw statements**: All throws should be converted to .failure returns
4. **Incorrect Swift concurrency patterns**: Update continuations to use Result types properly

## Reference Resources

- See `XPCProtocolsMigration.swift` in SecurityInterfaces for example adapters
- Refer to `LegacyXPCServiceAdapter.swift` in XPCProtocolsCore for bridging helpers
- Run the existing test suites to verify compatibility during migration
- Reference implementations:
  - `UmbraCryptoService/CryptoXPCService.swift`: Complete migration example with Result-based error handling
  - `XPCProtocolsCore/XPCProtocolsCore.swift`: Proper exports and type definitions

## Migration Status

As of 5 March 2025, the XPC Protocol migration is 96% complete:
- 37 of 77 files have been fully migrated
- UmbraCryptoService module has been completely migrated
- Core modules are in progress

See the updated `UmbraCore_Refactoring_Plan.md` for detailed status tracking.

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
