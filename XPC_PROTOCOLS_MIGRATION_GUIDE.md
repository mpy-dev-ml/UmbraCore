# XPC Protocols Migration Guide

## Overview

This guide outlines the process for migrating from legacy XPC protocols in the SecurityInterfaces modules to the new consolidated XPC protocols in XPCProtocolsCore. The migration is part of the UmbraCore refactoring plan to reduce module fragmentation and establish a clearer, more maintainable architecture.

## Motivation

The legacy XPC protocol system had several limitations:

1. **Redundant protocol definitions** across multiple modules
2. **Inconsistent error handling** with different error types
3. **Lack of protocol hierarchy** for different service capabilities
4. **Tight coupling** with specific module implementations
5. **Foundation dependencies** in core protocol definitions

The new XPC protocol system addresses these issues with:

1. A **single, foundation-free core module** (XPCProtocolsCore)
2. A **clear protocol hierarchy** with BasicProtocol, StandardProtocol, and CompleteProtocol
3. **Standardized error handling** using UmbraCoreTypes.CoreErrors
4. **Migration adapters** for backward compatibility
5. **Comprehensive testing** of all protocol implementations

## Deprecation Timeline

| Date | Phase | Action |
|------|-------|--------|
| March 2025 | Phase 1 | Mark legacy protocols as deprecated |
| April 2025 | Phase 2 | Client code migration |
| May 2025 | Phase 3 | Legacy protocol removal |

## Migration Steps

### Step 1: Identify modules that need refactoring

Use the XPC Protocol Analyzer tool to scan the codebase and identify files that need refactoring:

```bash
cd /Users/mpy/CascadeProjects/UmbraCore
./Scripts/run_xpc_analyzer.sh
```

This will generate a detailed report at `xpc_protocol_migration_report.md` showing which modules and files need to be updated.

### Step 2: Update imports

Replace:
```swift
import SecurityInterfaces
import SecurityInterfacesBase
import SecurityInterfacesProtocols
```

With:
```swift
import XPCProtocolsCore
import UmbraCoreTypes
```

### Step 3: Update protocol conformances

#### Before:
```swift
public class MyService: XPCServiceProtocol {
    public func encrypt(data: BinaryData) async throws -> BinaryData {
        // Implementation
    }
    
    public func decrypt(data: BinaryData) async throws -> BinaryData {
        // Implementation
    }
}
```

#### After:
```swift
public class MyService: XPCServiceProtocolStandard {
    public func encryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Implementation
    }
    
    public func decryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityError> {
        // Implementation
    }
    
    // Additional required methods...
}
```

### Step 4: Update data types

#### Before:
```swift
let data = BinaryData([1, 2, 3, 4, 5])
```

#### After:
```swift
let data = SecureBytes(bytes: [1, 2, 3, 4, 5])
```

### Step 5: Update error handling

#### Before:
```swift
throw SecurityProtocolError.implementationMissing("Not implemented")
```

#### After:
```swift
return .failure(.implementationMissing)
```

### Step 6: Track migration progress

Run the analyzer tool regularly to track migration progress:

```bash
./Scripts/run_xpc_analyzer.sh
```

Review the updated report to see which modules still need to be migrated.

## Protocol Hierarchy

### XPCServiceProtocolBasic
Minimal interface for basic service operations:
- ping
- synchroniseKeys

### XPCServiceProtocolStandard
Extended interface for standard cryptographic operations:
- Everything from XPCServiceProtocolBasic
- generateRandomData
- encryptData/decryptData
- hashData
- signData/verifySignature

### XPCServiceProtocolComplete
Comprehensive interface with Result-based error handling:
- Everything from XPCServiceProtocolStandard
- Result-based versions of all methods
- Additional methods for advanced use cases

## Using Migration Adapters

If you need to maintain compatibility with legacy code during migration, you can use the provided adapters:

### For adapting new protocols to legacy code:
```swift
// Create your service using the new protocols
let myNewService = MyNewXPCService()

// Adapt it for use with legacy code
let legacyAdapter = LegacyXPCServiceAdapter(service: myNewService)

// Now legacyAdapter can be used with code expecting the old XPCServiceProtocol
```

### For adapting legacy services to new protocols:
```swift
// Your existing legacy service
let legacyService = LegacyXPCService()

// Adapt it for use with new protocol code
let modernAdapter = CryptoXPCServiceAdapter(service: legacyService)

// Now modernAdapter can be used with code expecting the new XPCServiceProtocolComplete
```

## Example Implementation: SecurityProvider

The `SecurityProvider` class in `SecurityInterfaces` has been refactored to serve as an example of the migration pattern:

```swift
// Create a service using the new XPC protocols
let xpcService = MyXPCService() // Conforms to XPCServiceProtocolStandard
let securityBridge = SecurityProviderImplementation()

// Create the adapter that uses the new protocols
let securityProvider = SecurityProviderAdapter(
  bridge: securityBridge,
  xpcService: xpcService
)

// Use the provider with the new interface
let result = try await securityProvider.performSecurityOperation(
  operation: .encrypt,
  parameters: ["key": "encryption-key", "data": someData]
)
```

## Testing Guidance

All services implementing the new XPC protocols should include comprehensive tests:

1. Test **basic functionality** (ping, synchronizeKeys)
2. Test **standard operations** (encryption, decryption, hash, etc.)
3. Test **error conditions** (invalid data, missing keys, etc.)
4. Test **protocol negotiation** when applicable

Example test code is available in `XPCProtocolsCoreTests.swift`.

## Automated Analysis Tool

To track migration progress and identify areas that need refactoring, use the XPC Protocol Analyzer tool:

```bash
cd /Users/mpy/CascadeProjects/UmbraCore
./Scripts/run_xpc_analyzer.sh
```

The analyzer produces two reports:
1. `xpc_protocol_analysis.json`: Detailed JSON report with all analysis data
2. `xpc_protocol_migration_report.md`: Human-readable Markdown report with prioritised modules

### Customising the Analysis

The analyzer can be customised by editing the configuration file:

```bash
vim /Users/mpy/CascadeProjects/UmbraCore/Scripts/xpc_analyzer_config.json
```

This allows you to:
- Add additional legacy imports/protocols to search for
- Exclude specific directories from analysis
- Adjust verbosity settings
- Set output locations

## Common Migration Issues

### 1. Method signature mismatches

The new protocols use slightly different method signatures. Pay close attention to parameter names and types.

### 2. Error type differences

The new protocols standardize on XPCSecurityError, which may require mapping from your custom error types.

### 3. Thread safety considerations

All new protocol implementations should be Sendable-compliant. Check for any thread safety issues in your implementations.

## Best Practices

1. **Start with protocol selection**: Choose the appropriate protocol level (Basic, Standard, Complete) based on your service's needs.
2. **Implement incrementally**: Begin with the Basic protocol, then add Standard functionality, and finally Complete if needed.
3. **Use the adapters during migration**: This allows gradual migration without breaking existing code.
4. **Add comprehensive tests**: Ensure your implementation meets the protocol requirements.
5. **Consider error handling carefully**: The new protocols provide standardized error types that should be used consistently.

## Support

If you encounter issues during migration, please file a ticket in the issue tracker with the tag "xpc-migration".

## References

1. UmbraCore Refactoring Plan
2. XPCProtocolsCore Documentation
3. UmbraCoreTypes Documentation
