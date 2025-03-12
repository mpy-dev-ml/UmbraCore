# SecurityProtocolsCore Module

The SecurityProtocolsCore module provides foundation-free security protocol definitions for the UmbraCore framework.

## Overview

SecurityProtocolsCore defines the core security interfaces used throughout the UmbraCore framework, allowing for consistent and reliable security operations across different modules. This module is designed to be foundation-free, enabling it to be used in contexts where Foundation dependencies would be problematic.

## Features

- Foundation-free security protocol definitions
- Secure credential management interfaces
- Cryptographic operation protocols
- Authentication validation interfaces

## Usage

```swift
import SecurityProtocolsCore

// Create a type that implements a security protocol
class MySecurityProvider: CryptoServiceProvider {
    func generateKey(strength: KeyStrength) throws -> SecureKey {
        // Implementation
    }
    
    func encryptData(_ data: Data, withKey key: SecureKey) throws -> EncryptedData {
        // Implementation
    }
}
```

## Integration

SecurityProtocolsCore integrates with:

- SecurityTypes for core security type definitions
- UmbraCryptoService for cryptographic operations
- UmbraKeychainService for secure storage
- UmbraXPC for secure cross-process operations

## Source Code

The source code for this module is located in the `Sources/SecurityProtocolsCore` directory of the UmbraCore repository.
