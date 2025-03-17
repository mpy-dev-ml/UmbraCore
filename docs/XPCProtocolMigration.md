# XPC Protocol Migration Guide

## Overview

This guide provides a comprehensive overview of the migration path from legacy XPC service protocols to the modern XPCProtocolsCore implementations. The modernisation effort brings several significant improvements:

- Type-safe APIs with `SecureBytes` instead of raw `Data` or `NSData`
- Modern async/await patterns replacing completion handlers
- Structured error handling using `Result` types
- Consistent protocol hierarchy with composition
- Better memory management and security practices

## Migration Timeline

| Phase | Timeline | Description |
|-------|----------|-------------|
| Phase 1 | Current | Legacy protocols marked as deprecated, adapter pattern available |
| Phase 2 | +3 months | Client code migration, dual support with adapters |
| Phase 3 | +6 months | Service implementations migration to modern protocols |
| Phase 4 | +9 months | Legacy protocols removed, all code migrated to modern equivalents |

## Protocol Mappings

| Legacy Protocol | Modern Replacement | Notes |
|-----------------|-------------------|-------|
| `XPCServiceProtocol` | `XPCServiceProtocolBasic` | Basic connectivity and synchronisation |
| `ModernCryptoXPCServiceProtocol` | `XPCServiceProtocolStandard` | Standard crypto operations |
| `SecurityXPCServiceProtocol` | `XPCServiceProtocolComplete` | Complete security operations including bookmarks |
| `XPCServiceProtocolBaseFoundation` | `XPCServiceProtocolBasic` | Foundation-based adaptations |
| `XPCServiceProtocolFoundationBridge` | `XPCServiceProtocolComplete` | Full bridge to modern protocols |
| `FoundationXPCSecurityService` | `XPCServiceProtocolComplete` | Foundation security adaptations |

## Migration Steps - Client Code

### Step 1: Import the Modern Module

```swift
// Before
import SecurityInterfaces
import SecurityBridge

// After
import XPCProtocolsCore
```

### Step 2: Service Creation

```swift
// Before - Legacy service creation
let legacyService = obtainLegacyXPCService()

// After - Option 1: Create a new modern service directly
let modernService = ModernXPCService()

// After - Option 2: Migrate an existing legacy service using the factory
let modernService = XPCProtocolMigrationFactory.createCompleteAdapter(service: legacyService)
```

### Step 3: Replace Callback Patterns with Async/Await

```swift
// Before - Nested callbacks
legacyService.validateConnection { isValid, error in
    guard isValid, error == nil else {
        handleError(error)
        return
    }
    
    legacyService.encryptData(sensitiveData) { encryptedData, encryptError in
        // More nested callbacks...
    }
}

// After - Structured async code
Task {
    let pingResult = await modernService.ping()
    
    guard case .success(true) = pingResult else {
        // Error handling...
        return
    }
    
    let encryptResult = await modernService.encrypt(data: sensitiveData)
    
    switch encryptResult {
    case .success(let encryptedData):
        // Success handling
    case .failure(let error):
        // Error handling
    }
}
```

### Step 4: Update Error Handling

```swift
// Before - Manual error checking
if let error = error {
    // Error handling
} else {
    // Success path
}

// After - Result type switching
switch result {
case .success(let value):
    // Success path
case .failure(let error):
    // Typed error handling
    switch error {
    case .encryptionError(let reason):
        // Handle encryption error
    case .storageError(let reason):
        // Handle storage error
    default:
        // Handle other errors
    }
}
```

### Step 5: Data Type Migration

```swift
// Before - Using NSData or Data
let data: Data = getDataSomehow()
legacyService.encryptData(data, withReply: completion)

// After - Using SecureBytes
let secureData = SecureBytes(data: data)
let result = await modernService.encrypt(data: secureData)
```

## Migration Steps - Service Implementation

### Step 1: Protocol Conformance Update

```swift
// Before
class LegacyService: NSObject, XPCServiceProtocol {
    // implementation
}

// After
class ModernService: XPCServiceProtocolComplete {
    // implementation
}
```

### Step 2: Method Signature Updates

```swift
// Before
func encryptData(_ data: Data, withReply reply: @escaping (Data?, Error?) -> Void) {
    // implementation with callback
}

// After
func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    // implementation with result
}
```

### Step 3: Error Handling Improvements

```swift
// Before
do {
    let result = try performOperation()
    reply(result, nil)
} catch {
    reply(nil, error)
}

// After
do {
    let result = try performOperation()
    return .success(result)
} catch {
    return .failure(.operationError(reason: error.localizedDescription))
}
```

## Gradual Migration Strategy

For larger codebases, a gradual migration approach is recommended:

1. **Adapter Phase**: Use the migration factory to wrap legacy services with modern interfaces
   ```swift
   let modernWrapper = XPCProtocolMigrationFactory.createCompleteAdapter(service: legacyService)
   ```

2. **Dual Implementation**: Maintain both legacy and modern APIs during transition
   ```swift
   // Support both callback and async patterns
   func processData(_ data: Data, completion: ((Data?, Error?) -> Void)?) {
       if let completion = completion {
           // Legacy path with callback
           legacyProcess(data, completion: completion)
       } else {
           // Modern path with async
           Task {
               let result = await modernProcess(data)
               // Handle result
           }
       }
   }
   
   // New async API
   func processDataAsync(_ data: Data) async -> Result<Data, Error> {
       // Implementation using modern patterns
   }
   ```

3. **Progressive Replacement**: Replace uses of legacy APIs one at a time, starting with leaf nodes
   in your dependency graph and working inward

4. **Testing Strategy**: When updating each component, ensure comprehensive tests are in place to
   verify that both legacy and modern paths behave identically

## Examples

For concrete code examples demonstrating these migration patterns, refer to the `XPCMigrationExamples.swift` file in the XPCProtocolsCore module.

## Common Issues and Solutions

### Issue: Handling data conversion during transition

**Solution**: Use the helper extension methods provided in `XPCProtocolMigrationFactory`

```swift
// Convert from NSData to SecureBytes
let secureBytes = SecureBytes(data: nsData as Data)

// Convert from SecureBytes to Data
let data = secureBytes.data
```

### Issue: Managing service lifetime with different concurrency models

**Solution**: Use Task and structured concurrency when bridging between completion handlers and async/await

```swift
// Bridge from completion handler to async
func legacyMethodWithCompletion(completion: @escaping (Result<Data, Error>) -> Void) {
    Task {
        let result = await modernAsyncMethod()
        completion(result)
    }
}

// Bridge from async to completion handler
func modernMethodThatUsesAsync() async -> Result<Data, Error> {
    await withCheckedContinuation { continuation in
        legacyMethodWithCompletion { result in
            continuation.resume(returning: result)
        }
    }
}
```

## Further Resources

- [Swift Concurrency Guide](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Apple Structured Concurrency Documentation](https://developer.apple.com/documentation/swift/calling_objective-c_apis_asynchronously)
- [XPC Service Programming Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html)

## Support

For questions or support during migration, please contact the UmbraCore development team.
