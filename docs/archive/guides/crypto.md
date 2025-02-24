# UmbraCryptoService Guide

## Overview
`UmbraCryptoService` provides cryptographic operations for securing sensitive data. It supports encryption, decryption, and key management.

## Features
- Secure encryption/decryption
- Key management
- Thread-safe operations
- XPC-based processing

## Basic Usage

### Encryption
```swift
let service = try UmbraCryptoService()

// Encrypt data
let data = "sensitive data".data(using: .utf8)!
let encrypted = try await service.encrypt(data)

// Encrypt with custom key
let key = try service.generateKey()
let customEncrypted = try await service.encrypt(data, using: key)
```

### Decryption
```swift
// Decrypt data
let decrypted = try await service.decrypt(encrypted)

// Decrypt with custom key
let customDecrypted = try await service.decrypt(customEncrypted, using: key)
```

### Key Management
```swift
// Generate new key
let key = try service.generateKey()

// Export key (protected)
let exportedKey = try service.exportKey(key)

// Import key
let importedKey = try service.importKey(exportedKey)
```

## Error Handling
```swift
do {
    let encrypted = try await service.encrypt(data)
} catch CryptoError.invalidKey {
    // Handle invalid key
} catch CryptoError.encryptionFailed(let reason) {
    // Handle encryption failure
} catch {
    // Handle other errors
}
```

## Best Practices

### 1. Key Management
- Rotate keys regularly
- Secure key storage
- Use key derivation when appropriate

### 2. Data Protection
- Encrypt sensitive data immediately
- Clear sensitive data from memory
- Use secure random generation

### 3. Error Recovery
- Implement retry logic
- Log cryptographic failures
- Provide appropriate user feedback

## Advanced Usage

### 1. Custom Encryption Parameters
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

### 2. Key Derivation
```swift
let derivedKey = try service.deriveKey(
    fromPassword: "user-password",
    salt: salt,
    iterations: 10000
)
```

### 3. Batch Operations
```swift
let dataItems = [
    "item1": data1,
    "item2": data2
]

let encrypted = try await service.encryptBatch(dataItems)
```

## Integration Examples

### 1. Secure Configuration
```swift
class SecureConfig {
    private let crypto: UmbraCryptoService
    
    init() throws {
        crypto = try UmbraCryptoService()
    }
    
    func saveConfig(_ config: Config) async throws {
        let data = try JSONEncoder().encode(config)
        let encrypted = try await crypto.encrypt(data)
        
        try await FileManager.default.createFile(
            at: configURL,
            contents: encrypted
        )
    }
}
```

### 2. Secure Data Transfer
```swift
class SecureTransfer {
    private let crypto: UmbraCryptoService
    
    func secureUpload(_ data: Data) async throws {
        // Encrypt before upload
        let encrypted = try await crypto.encrypt(data)
        
        // Upload encrypted data
        try await uploadToServer(encrypted)
    }
}
```

## Troubleshooting

### Common Issues

1. Key Validation
```swift
// Validate key before use
guard try service.validateKey(key) else {
    throw CryptoError.invalidKey
}
```

2. Memory Management
```swift
// Clear sensitive data
defer {
    key.zero()
    plaintext.zero()
}
```

3. Performance Optimization
```swift
// Use batch operations for multiple items
let results = try await withThrowingTaskGroup(of: (String, Data).self) { group in
    for (id, data) in items {
        group.addTask {
            let encrypted = try await service.encrypt(data)
            return (id, encrypted)
        }
    }
    return try await group.reduce(into: [:]) { $0[$1.0] = $1.1 }
}
```
