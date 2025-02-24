# UmbraKeychainService Guide

## Overview
`UmbraKeychainService` provides secure credential storage using macOS Keychain. It handles repository passwords, API keys, and other sensitive data.

## Features
- Secure credential storage
- XPC-based access
- Thread-safe operations
- Automatic error handling

## Basic Usage

### Storing Credentials
```swift
let service = try UmbraKeychainService()

// Store a repository password
try await service.store(
    password: "secret-password",
    forKey: "backup-repository"
)

// Store an API key
try await service.store(
    password: "api-key-12345",
    forKey: "cloud-provider"
)
```

### Retrieving Credentials
```swift
// Get repository password
let password = try await service.retrieve(forKey: "backup-repository")

// Get API key
let apiKey = try await service.retrieve(forKey: "cloud-provider")
```

### Updating Credentials
```swift
try await service.update(
    password: "new-password",
    forKey: "backup-repository"
)
```

### Removing Credentials
```swift
try await service.remove(forKey: "backup-repository")
```

## Error Handling
```swift
do {
    try await service.store(password: "secret", forKey: "key")
} catch KeychainError.duplicateItem(let key) {
    // Handle duplicate item
} catch KeychainError.accessDenied(let reason) {
    // Handle access denied
} catch {
    // Handle other errors
}
```

## Best Practices

### 1. Key Naming
- Use descriptive, consistent keys
- Include context in key names
- Follow naming conventions

```swift
// Good
"backup-repo-main-password"
"aws-access-key-prod"

// Bad
"pwd1"
"key"
```

### 2. Error Recovery
- Implement retry logic
- Provide user feedback
- Log failures appropriately

### 3. Security
- Never store keys in code
- Use appropriate access control
- Clean up unused credentials

## Advanced Usage

### 1. Custom Item Attributes
```swift
let attributes = KeychainItemAttributes(
    label: "Main Backup Repository",
    comment: "Production backup credentials"
)

try await service.store(
    password: "secret",
    forKey: "backup-repo",
    attributes: attributes
)
```

### 2. Batch Operations
```swift
let credentials = [
    "repo1": "password1",
    "repo2": "password2"
]

try await service.storeBatch(credentials)
```

### 3. Access Control
```swift
let access = KeychainAccess(
    accessibility: .whenUnlocked,
    authentication: .biometric
)

try await service.store(
    password: "secret",
    forKey: "secure-key",
    access: access
)
```

## Integration Examples

### 1. Repository Setup
```swift
func setupRepository() async throws {
    let service = try UmbraKeychainService()
    
    // Store repository password
    try await service.store(
        password: repositoryPassword,
        forKey: "repo-\(repoId)"
    )
    
    // Store cloud credentials if needed
    if let cloudKey = cloudCredentials {
        try await service.store(
            password: cloudKey,
            forKey: "cloud-\(repoId)"
        )
    }
}
```

### 2. Credential Management
```swift
class CredentialManager {
    private let keychain: UmbraKeychainService
    
    init() throws {
        keychain = try UmbraKeychainService()
    }
    
    func rotateCredentials() async throws {
        let newPassword = generateSecurePassword()
        
        try await keychain.update(
            password: newPassword,
            forKey: "repo-main"
        )
        
        try await updateRemoteRepository(password: newPassword)
    }
}
```

## Troubleshooting

### Common Issues

1. Access Denied
```swift
// Check keychain access
try await service.checkAccess()

// Request user permission if needed
try await service.requestAccess()
```

2. Duplicate Items
```swift
// Update instead of store for existing items
if await service.exists(forKey: key) {
    try await service.update(password: newPassword, forKey: key)
} else {
    try await service.store(password: newPassword, forKey: key)
}
```

3. Item Not Found
```swift
// Implement fallback logic
func getCredential(forKey key: String) async throws -> String {
    do {
        return try await service.retrieve(forKey: key)
    } catch KeychainError.itemNotFound {
        // Implement recovery logic
        return try await recoverCredential(forKey: key)
    }
}
```
