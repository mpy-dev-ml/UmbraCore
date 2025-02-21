---
layout: default
title: API Reference
nav_order: 6
description: Complete API reference for UmbraCore
---

# API Reference

## Core Services

### UmbraKeychainService

Secure credential storage service for managing sensitive data:

```swift
// Initialize the service
let keychain = try UmbraKeychainService()

// Store credentials
try await keychain.store(
    password: "secret",
    forKey: "backup-repository"
)

// Retrieve credentials
let password = try await keychain.retrieve(
    forKey: "backup-repository"
)
```

### UmbraCryptoService

Cryptographic operations service for data security:

```swift
// Initialize the service
let crypto = try UmbraCryptoService()

// Encrypt data
let encrypted = try await crypto.encrypt(
    sensitiveData,
    using: .aes256GCM
)

// Decrypt data
let decrypted = try await crypto.decrypt(
    encrypted
)
```

### UmbraBookmarkService

File system bookmark management for persistent file access:

```swift
// Initialize the service
let bookmarks = try UmbraBookmarkService()

// Create bookmark
let bookmark = try await bookmarks.create(
    for: fileURL,
    type: .securityScoped
)

// Resolve bookmark
let url = try await bookmarks.resolve(
    bookmark: bookmark
)
```

## Security Types

### SecurityTypes

Base security primitives and protocols:

```swift
// Secure data container
struct SecureData: SecureContainer {
    let data: Data
    let metadata: SecurityMetadata
}

// Security context
struct SecurityContext {
    let accessLevel: AccessLevel
    let permissions: Permissions
    let origin: SecurityOrigin
}
```

### CryptoTypes

Cryptographic types and operations:

```swift
// Encryption parameters
struct EncryptionParameters {
    let algorithm: EncryptionAlgorithm
    let keySize: KeySize
    let iterations: Int
}

// Key types
enum KeyType {
    case aes256
    case rsa2048
    case rsa4096
}
```

## Utilities

### UmbraLogging

Centralised logging infrastructure:

```swift
// Initialize logger
let logger = UmbraLogger(
    subsystem: "com.example.app",
    category: "backup"
)

// Log events
logger.info("Starting backup", metadata: [
    "repository": "main",
    "files": 100
])

logger.error("Backup failed", metadata: [
    "error": error,
    "repository": "main"
])
```

### UmbraXPC

XPC communication infrastructure:

```swift
// Define service protocol
protocol BackupService: XPCService {
    func backup(source: URL) async throws
    func restore(to: URL) async throws
}

// Create service connection
let service = try XPCConnection<BackupService>()

// Call service
try await service.backup(source: sourceURL)
```

## Error Types

### CommonError

Shared error types across the framework:

```swift
enum CommonError: Error {
    case invalidArgument(String)
    case resourceNotFound(String)
    case permissionDenied(String)
    case operationFailed(String)
}

enum KeychainError: Error {
    case itemNotFound(String)
    case duplicateItem(String)
    case accessDenied(String)
}

enum CryptoError: Error {
    case encryptionFailed(String)
    case decryptionFailed(String)
    case invalidKey(String)
}
```

## Best Practices

### Thread Safety

All services are designed to be thread-safe:

```swift
// Safe concurrent access
let service = try UmbraKeychainService()
async let task1 = service.store(password: "secret1", forKey: "key1")
async let task2 = service.store(password: "secret2", forKey: "key2")
try await [task1, task2]
```

### Error Handling

Implement comprehensive error handling:

```swift
do {
    try await service.backup(source: url)
} catch CommonError.invalidArgument(let reason) {
    logger.error("Invalid argument: \(reason)")
} catch CommonError.permissionDenied(let operation) {
    logger.error("Permission denied: \(operation)")
} catch {
    logger.error("Unknown error: \(error)")
}
```

### Performance

Follow performance best practices:

```swift
// Use batch operations
try await service.storeBatch([
    ("key1", "value1"),
    ("key2", "value2"),
    ("key3", "value3")
])

// Implement cancellation
let task = Task {
    try await service.longOperation()
}
// Later...
task.cancel()
```

## Related Documentation

- [Security Guide](security.md) - Security implementation details
- [Configuration Guide](configuration.md) - Configuration options
- [Advanced Features](advanced-features.md) - Advanced usage
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
