# Crypto XPC Protocol Migration Guide

## Overview

As part of the UmbraCore XPC protocol consolidation effort, we're standardising all XPC service protocols under the `XPCProtocolsCore` module. This guide explains how to migrate your crypto service implementations from the legacy `CryptoXPCServiceProtocol` to the new `XPCServiceProtocolStandard`.

## Why Migrate?

- **Standardisation**: All XPC services will use a consistent protocol hierarchy
- **Improved Type Safety**: The new protocols use `SecureBytes` instead of `Data` for better safety
- **Foundation-Free Core**: The core protocols don't depend on Foundation
- **Future-Proof**: The new protocols are designed to support Swift concurrency and Sendable requirements

## Migration Steps

### 1. Add XPCProtocolsCore Dependency

Update your BUILD.bazel file to include the XPCProtocolsCore dependency:

```python
deps = [
    # existing dependencies...
    "//Sources/UmbraCoreTypes",
    "//Sources/XPCProtocolsCore",
]
```

### 2. Use the Adapter During Migration

For existing services implementing `CryptoXPCServiceProtocol`, use the provided adapter to bridge to the new protocol:

```swift
import CryptoTypes.Adapters
import XPCProtocolsCore

// Get your existing crypto service
let legacyCryptoService: CryptoXPCServiceProtocol = /* your existing service */

// Convert to the new protocol
let standardService: XPCServiceProtocolStandard = legacyCryptoService.asXPCServiceProtocolStandard()

// Now you can use standardService with code expecting XPCServiceProtocolStandard
```

### 3. Direct Implementation

For new services, implement `XPCServiceProtocolStandard` directly instead of `CryptoXPCServiceProtocol`:

```swift
import XPCProtocolsCore
import UmbraCoreTypes

class MyCryptoService: XPCServiceProtocolStandard {
    // Implement required methods
    static var protocolIdentifier: String { return "com.mycompany.crypto" }
    
    func ping() async throws -> Bool {
        // Implementation
        return true
    }
    
    func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // Implementation
    }
    
    func generateRandomData(length: Int) async throws -> SecureBytes {
        // Implementation
    }
    
    func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        // Implementation
    }
    
    // Implement remaining methods...
}
```

### 4. Method Mapping

The following table shows how methods map between the old and new protocols:

| CryptoXPCServiceProtocol | XPCServiceProtocolStandard |
|--------------------------|----------------------------|
| `generateKey(bits:)` | `generateRandomData(length:)` |
| `generateSalt(length:)` | `generateRandomData(length:)` |
| `encrypt(_:key:)` | `encryptData(_:keyIdentifier:)` |
| `decrypt(_:key:)` | `decryptData(_:keyIdentifier:)` |
| `storeCredential(_:forIdentifier:)` | *Use secure storage service* |
| `retrieveCredential(forIdentifier:)` | *Use secure storage service* |
| `deleteCredential(forIdentifier:)` | *Use secure storage service* |

## Type Conversions

### From `Data` to `SecureBytes`

```swift
// Convert Data to SecureBytes
let secureBytes = SecureBytes(bytes: [UInt8](data))

// Convert SecureBytes to Data
let data = Data(secureBytes.withUnsafeBytes { Array($0) })
```

## Timeline

- **Current**: Both protocols available, legacy protocol deprecated
- **6 months**: Legacy protocol marked for removal
- **12 months**: Legacy protocol removed

## Need Help?

If you have questions about the migration process, please contact the UmbraCore team.

---

This guide is part of the UmbraCore XPC Protocol Consolidation project.
