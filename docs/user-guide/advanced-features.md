---
layout: default
title: Advanced Features
nav_order: 4
description: Advanced features and capabilities of UmbraCore
---

# Advanced Features

UmbraCore provides several advanced features for secure backup management. This guide covers cryptographic operations, keychain integration, and other advanced capabilities.

## Cryptographic Operations

### Overview

The `UmbraCryptoService` provides comprehensive cryptographic operations:

```swift
let service = try UmbraCryptoService()

// Basic encryption
let data = "sensitive data".data(using: .utf8)!
let encrypted = try await service.encrypt(data)

// Custom key encryption
let key = try service.generateKey()
let customEncrypted = try await service.encrypt(data, using: key)

// Decryption
let decrypted = try await service.decrypt(encrypted)
```

### Advanced Encryption

Configure custom encryption parameters:

```swift
let params = EncryptionParameters(
    algorithm: .aes256GCM,
    keySize: .bits256,
    iterations: 10000
)

let encrypted = try await service.encrypt(
    data,
    parameters: params
)
```

### Key Management

Secure key handling:

```swift
// Generate new key
let key = try service.generateKey()

// Export key (protected)
let exportedKey = try service.exportKey(key)

// Import key
let importedKey = try service.importKey(exportedKey)

// Key derivation
let derivedKey = try service.deriveKey(
    fromPassword: "user-password",
    salt: salt,
    iterations: 10000
)
```

## Keychain Integration

### Overview

The `UmbraKeychainService` provides secure credential storage:

```swift
let service = try UmbraKeychainService()

// Store credentials
try await service.store(
    password: "secret-password",
    forKey: "backup-repository"
)

// Retrieve credentials
let password = try await service.retrieve(forKey: "backup-repository")

// Update credentials
try await service.update(
    password: "new-password",
    forKey: "backup-repository"
)

// Remove credentials
try await service.remove(forKey: "backup-repository")
```

### Advanced Keychain Usage

Custom item attributes:

```swift
let attributes = KeychainItemAttributes(
    label: "Main Backup Repository",
    comment: "Production backup credentials"
)

try await service.store(
    password: "secret",
    forKey: "main-repo",
    attributes: attributes
)
```

## Best Practices

### Cryptographic Security

1. Key Management
   - Rotate keys regularly
   - Secure key storage
   - Use key derivation when appropriate

2. Data Protection
   - Encrypt sensitive data immediately
   - Clear sensitive data from memory
   - Use secure random generation

3. Error Recovery
   - Implement retry logic
   - Log cryptographic failures
   - Provide appropriate user feedback

### Keychain Security

1. Key Naming
   ```swift
   // Good
   "backup-repo-main-password"
   "aws-access-key-prod"

   // Bad
   "pwd1"
   "key"
   ```

2. Error Recovery
   - Implement retry logic
   - Provide user feedback
   - Log failures appropriately

3. Security Practices
   - Never store keys in code
   - Use appropriate access control
   - Clean up unused credentials

## Error Handling

### Cryptographic Errors

```swift
do {
    let encrypted = try await cryptoService.encrypt(data)
} catch CryptoError.invalidKey {
    // Handle invalid key
} catch CryptoError.encryptionFailed(let reason) {
    // Handle encryption failure
} catch {
    // Handle other errors
}
```

### Keychain Errors

```swift
do {
    try await keychainService.store(password: "secret", forKey: "key")
} catch KeychainError.duplicateItem(let key) {
    // Handle duplicate item
} catch KeychainError.accessDenied(let reason) {
    // Handle access denied
} catch {
    // Handle other errors
}
```

## Related Documentation

- [Security Guide](security.md) - Comprehensive security information
- [Configuration Guide](configuration.md) - Configuration options
- [API Reference](api-reference.md) - Complete API documentation
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
