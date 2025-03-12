# SecurityTypes Module

The SecurityTypes module provides the core security primitives and types used throughout the UmbraCore framework.

## Overview

SecurityTypes defines foundational security-related types, enumerations, and structures that are shared across different modules of the UmbraCore framework. It serves as a central library of security primitives designed to be used consistently throughout the system.

## Features

- Core security primitive types
- Cryptographic key representations
- Secure credential containers
- Error types for security operations
- Serialisation protocols for secure types

## Usage

```swift
import SecurityTypes

// Create a secure credential
let credential = SecureCredential(
    username: "repouser",
    passwordData: encryptedPasswordData,
    metadata: [
        "repository": "backup-main",
        "created": ISO8601DateFormatter().string(from: Date())
    ]
)

// Use a security error
func handleError(_ error: SecurityError) {
    switch error {
    case .authenticationFailed:
        // Handle authentication failure
    case .keyGenerationFailed(let reason):
        // Handle key generation failure
    case .encryptionFailed(let underlyingError):
        // Handle encryption failure
    // ...other cases
    }
}
```

## Integration

SecurityTypes is a foundational module that integrates with:

- SecurityProtocolsCore for protocol definitions
- UmbraCryptoService for cryptographic operations
- UmbraKeychainService for secure storage
- UmbraXPC for secure cross-process operations

## Source Code

The source code for this module is located in the `Sources/SecurityTypes` directory of the UmbraCore repository.
