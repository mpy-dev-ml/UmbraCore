# UmbraCryptoService Module

The UmbraCryptoService module provides cryptographic operations and services for the UmbraCore framework.

## Overview

UmbraCryptoService implements secure cryptographic functions required for encrypting and decrypting data, generating secure keys, and providing other essential cryptographic operations needed by the UmbraCore framework.

## Features

- Secure encryption and decryption operations
- Cryptographic key generation and management
- Password hashing with modern algorithms
- Secure random data generation
- Digital signature verification

## Usage

```swift
import UmbraCryptoService

// Create a crypto service instance
let cryptoService = UmbraCryptoService()

// Generate a secure key
let key = try cryptoService.generateKey(
    strength: .high,
    purpose: .encryption
)

// Encrypt sensitive data
let encryptedData = try cryptoService.encrypt(
    data: sensitiveData,
    using: key,
    algorithm: .aes256GCM
)

// Decrypt the encrypted data
let decryptedData = try cryptoService.decrypt(
    data: encryptedData,
    using: key,
    algorithm: .aes256GCM
)
```

## Integration

UmbraCryptoService integrates with:

- SecurityTypes for core security primitives
- SecurityProtocolsCore for protocol conformance
- UmbraKeychainService for secure key storage
- UmbraCore for high-level security operations

## Security Considerations

- Implements industry-standard cryptographic algorithms
- Uses secure key management practices
- Implements key rotation capabilities
- Provides secure memory handling for sensitive data

## Source Code

The source code for this module is located in the `Sources/UmbraCryptoService` directory of the UmbraCore repository.
