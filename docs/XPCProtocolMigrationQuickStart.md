# XPC Protocol Migration - QuickStart Guide

## Overview

This quick-start guide covers the most common migration scenarios when updating from legacy XPC service protocols to the modern XPCProtocolsCore implementations.

## 🔄 Migration Map - One-Minute Guide

1. **Replace Legacy Protocol with Modern Equivalent**:
   ```swift
   // Before
   import SecurityInterfaces
   let service: XPCServiceProtocol = getLegacyService()
   
   // After
   import XPCProtocolsCore
   let service: XPCServiceProtocolBasic = ModernXPCService()
   ```

2. **Migrate an Existing Service Instance**:
   ```swift
   // Before: Using legacy service
   let legacyService = getLegacyService()
   
   // After: Convert to modern equivalent
   let modernService = XPCProtocolMigrationFactory.createCompleteAdapter(service: legacyService)
   ```

3. **Update Method Calls**:
   ```swift
   // Before: Completion handler pattern
   service.doSomething(withData: data) { result, error in
       // handle result
   }
   
   // After: Async/await pattern
   Task {
       let result = await service.doSomething(data: data)
       // handle result
   }
   ```

## 🛠️ Most Common Migration Scenarios

### From Legacy XPCServiceProtocol to XPCServiceProtocolBasic

```swift
// Before - Legacy code with completion handlers
legacyService.validateConnection { valid, error in
    print("Connection valid: \(valid)")
}

// After - Modern code with async/await
Task {
    let result = await modernService.ping()
    switch result {
    case .success(let isValid):
        print("Connection valid: \(isValid)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### From ModernCryptoXPCServiceProtocol to XPCServiceProtocolComplete

```swift
// Before - Legacy crypto operations
legacyService.encrypt(sensitiveData, key: encryptionKey) { encryptedData, error in
    if let error = error {
        handleError(error)
    } else if let data = encryptedData {
        processCiphertext(data)
    }
}

// After - Modern crypto operations
Task {
    let result = await modernService.encrypt(
        data: SecureBytes(data: sensitiveData),
        keyIdentifier: "main-encryption-key"
    )
    
    switch result {
    case .success(let ciphertext):
        processCiphertext(ciphertext)
    case .failure(let error):
        handleError(error)
    }
}
```

### From SecurityXPCServiceProtocol to XPCServiceProtocolComplete

```swift
// Before - Legacy bookmark handling
legacyService.createBookmark(forPath: filePath) { bookmarkData, error in
    if let error = error {
        handleError(error)
    } else if let data = bookmarkData {
        saveBookmark(data)
    }
}

// After - Modern bookmark handling
Task {
    let result = await modernService.createSecurityBookmark(forPath: filePath)
    
    switch result {
    case .success(let bookmark):
        saveBookmark(bookmark)
    case .failure(let error):
        handleError(error)
    }
}
```

## 📋 Quick Reference - Protocol & Type Mappings

| Legacy | Modern | Notes |
|--------|--------|-------|
| `XPCServiceProtocol` | `XPCServiceProtocolBasic` | Basic connection and version methods |
| `ModernCryptoXPCServiceProtocol` | `XPCServiceProtocolStandard` | Standard crypto operations |
| `SecurityXPCServiceProtocol` | `XPCServiceProtocolComplete` | Complete security operations |
| `NSData` | `SecureBytes` | Secure data container |
| `Error?` | `Result<T, XPCSecurityError>` | Modern error handling |
| `completion: (T?, Error?) -> Void` | `async -> Result<T, Error>` | Async pattern |

## 🔍 Key Features of Modern Protocols

- **Type Safety**: Uses `SecureBytes` instead of raw `Data` for better security
- **Structured Concurrency**: Uses Swift's modern async/await pattern
- **Error Handling**: Uses `Result` type with specific error enums
- **Protocol Composition**: Follows a logical hierarchy of protocols

## 📈 Next Steps

- See the comprehensive [XPCProtocolMigration.md](XPCProtocolMigration.md) guide for detailed examples
- Check the `XPCMigrationExamples.swift` file in the XPCProtocolsCore module for code examples
- Use the migration factory methods in `XPCProtocolMigrationFactory` for adapting existing services

## 🆘 Common Pitfalls

- **Memory Management**: Ensure that service objects remain referenced during async operations
- **Task Cancellation**: Be aware of potential task cancellation in async contexts
- **Data Conversion**: Be careful when converting between different data types
- **Error Mapping**: Pay attention to how errors are mapped between systems
