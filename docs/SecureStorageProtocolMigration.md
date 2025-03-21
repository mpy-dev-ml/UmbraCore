# SecureStorageProtocol Migration Guide

## Overview

This guide provides a comprehensive overview of the migration path from multiple SecureStorageProtocol implementations to a unified, canonical implementation. This effort addresses ambiguity caused by multiple protocol implementations and helps streamline secure storage operations across the UmbraCore project.

## Key Benefits

- **Unified Implementation**: Eliminates ambiguity by providing a single, canonical implementation of SecureStorageProtocol
- **Type Safety**: Uses fully qualified types to avoid namespace conflicts
- **Swift 6 Compatibility**: Includes handling for future enum cases with `@unknown default`
- **Better Error Handling**: Standardized error types and detailed error messaging
- **Consistent API**: Ensures all secure storage operations follow the same patterns

## Migration Timeline

| Phase | Timeline | Description |
|-------|----------|-------------|
| Phase 1 | Completed | Adapter pattern implementation to bridge between different protocol versions |
| Phase 2 | Completed | Consolidation of multiple protocol implementations |
| Phase 3 | Completed | Error handling improvements and test fixes |
| Phase 4 | Future | Removal of deprecated protocol implementations |

## Protocol Consolidation

The canonical implementation of `SecureStorageProtocol` is now defined in the `SecurityProtocolsCore` module with the following methods:

```swift
public protocol SecureStorageProtocol: Sendable {
    func storeSecurely(data: UmbraCoreTypes.SecureBytes, identifier: String) async -> KeyStorageResult
    func retrieveSecurely(identifier: String) async -> KeyRetrievalResult
    func deleteSecurely(identifier: String) async -> KeyDeletionResult
}
```

## Adapter Pattern

An adapter has been created to bridge between different implementations of the `SecureStorageProtocol`:

```swift
public final class SecureStorageProtocolAdapter {
    private let storage: UmbraMocks.SecureStorageProtocol
    
    public init(storage: UmbraMocks.SecureStorageProtocol) {
        self.storage = storage
    }
    
    // Methods to store, retrieve, and delete data...
}
```

## Migration Steps - Client Code

### Step 1: Use the Adapter

If you're consuming an implementation of `SecureStorageProtocol` that doesn't match the expected API:

```swift
// Before
let mockStorage = MockKeychain()
let result = await mockStorage.storeData(data, identifier: "123")

// After
let adapter = SecureStorageProtocolAdapter(storage: mockStorage)
let result = await adapter.storeData(data, identifier: "123", metadata: [:])
```

### Step 2: Update Error Handling

Ensure your error handling uses the canonical error types:

```swift
// Before
if case let .failure(error) = result {
    print("Error: \(error)")
}

// After
if case let .failure(error) = result {
    switch error {
    case let ErrorHandlingDomains.UmbraErrors.Security.Protocols.storageOperationFailed(message):
        print("Storage failure: \(message)")
    default:
        print("Unknown error: \(error)")
    }
}
```

### Step 3: Prepare for Swift 6

Add handling for unknown future enum cases:

```swift
switch result {
case .success:
    // Handle success
case .failure:
    // Handle known error
@unknown default:
    // Handle future cases
}
```

## Recent Updates (21 March 2025)

### Error Handling Improvements

Recent updates have addressed several issues with error handling in the SecureStorageProtocol implementation:

1. **Updated SecureStorageProtocolAdapter**:
   - Fixed error mapping for KeyRetrievalError.keyNotFound and KeyDeletionError.keyNotFound
   - Added specific error messages to facilitate mapping to CryptoError.keyNotFound

2. **Enhanced MockKeychain**:
   - Added existence check before deletion to ensure proper error return in deleteSecurely
   - Now returns KeyDeletionResult.failure(.keyNotFound) when attempting to delete a nonexistent key

3. **Fixed CredentialManager Tests**:
   - Modified retrieve method to properly handle error cases
   - Updated delete method to correctly throw CryptoError.keyNotFound
   - Streamlined error handling patterns for better Swift 6 compatibility

### Swift 6 Compatibility Enhancements

1. **Removed Redundant Patterns**:
   - Eliminated unnecessary let bindings in pattern matching
   - Simplified case statement patterns for better code quality

2. **Consistent Error Handling**:
   - Standardized error handling approach across all storage operations
   - Ensured proper propagation of error types through the adapter layer

3. **Documentation**:
   - Added comprehensive DocC documentation for the migration
   - Updated existing documentation to reflect current implementation status

## Implementation Examples

### Using the Adapter in Tests

The adapter can be used to bridge between different implementations of SecureStorageProtocol:

```swift
public actor CredentialManager {
    private let cryptoService: CryptoTypesProtocols.CryptoServiceProtocol
    private let keychain: SecureStorageProtocolAdapter
    
    public init(cryptoService: CryptoTypesProtocols.CryptoServiceProtocol, keychain: UmbraMocks.SecureStorageProtocol) {
        self.cryptoService = cryptoService
        self.keychain = SecureStorageProtocolAdapter(storage: keychain)
    }
    
    // Implementation using the adapter...
}
```

## Future Considerations

1. **Full Migration**: The long-term goal is to have all code directly use the canonical implementation without adapters.
2. **Type Aliasing**: Consider removing type aliases for better clarity and to avoid ambiguity.
3. **Documentation**: Update API documentation to reflect the canonical implementation.
4. **Swift 6 Compatibility**: Ensure all code is compatible with Swift 6's stricter handling of enums.

## Contact

For questions or concerns about this migration, please contact the Security Team.
