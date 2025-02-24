# UmbraCore Security Architecture

## Overview

The UmbraCore security architecture is built on multiple layers to provide secure data handling, encryption, and access control. This document details the security components and their interactions.

## Component Architecture

### 1. Cryptographic Stack

#### CryptoTypes Module
- **Purpose**: Core cryptographic type definitions and protocols
- **Location**: `//Sources/CryptoTypes`
- **Key Components**:
  ```
  CryptoTypes
  ├── Protocols
  │   └── CryptoService.swift
  ├── Services
  │   └── DefaultCryptoService.swift
  └── Types
      ├── CryptoConfig.swift
      ├── CryptoConfiguration.swift
      └── CredentialManager.swift
  ```
- **External Dependencies**:
  - `CryptoSwift` for cryptographic operations

#### UmbraCrypto Module
- **Purpose**: Implementation of cryptographic operations
- **Location**: `//Sources/UmbraCrypto`
- **Dependencies**:
  - `CryptoTypes`
  - `CryptoSwift`
- **Testing Status**: Test-only module

### 2. Security Services

#### UmbraCryptoService
- **Purpose**: XPC-based secure crypto service
- **Location**: `//Sources/UmbraCryptoService`
- **Key Components**:
  ```
  UmbraCryptoService
  ├── CryptoServiceListener.swift
  ├── CryptoXPCService.swift
  └── UmbraCryptoService.swift
  ```
- **Entitlements**:
  - App sandbox enabled
  - Keychain access groups
  - Application group access
  - Network client capabilities

#### UmbraSecurity
- **Purpose**: High-level security interface
- **Location**: `//Sources/UmbraSecurity`
- **Components**:
  - Security service implementation
  - Security-scoped bookmark handling
  - URL security extensions

### 3. Security Utils

#### SecurityUtils Module
- **Purpose**: Common security utilities
- **Location**: `//Sources/SecurityUtils`
- **Features**:
  - Encrypted bookmark service
  - Security bookmark service
  - Security protocols

## Security Features

### 1. Encryption
- AES-256 encryption (via CryptoSwift)
- Secure key generation and management
- IV (Initialization Vector) handling
- Secure memory handling

### 2. Access Control
- Security-scoped bookmarks
- Keychain integration
- Sandboxed operations
- XPC service isolation

### 3. Credential Management
```swift
public struct CredentialManager {
    public let keyLength: Int
    public let ivLength: Int
    
    // Secure credential storage
    private let secureStorage: SecureStorageProvider
    
    // Credential lifecycle management
    public func store(_ credentials: Credentials) async throws
    public func retrieve() async throws -> Credentials
    public func clear() async throws
}
```

## External Dependencies

### 1. CryptoSwift
- **Version**: Latest stable
- **Usage**: Core cryptographic operations
- **Features Used**:
  - AES encryption
  - Key generation
  - Secure random number generation
  - Hash functions

### 2. Apple Security Framework
- **Features Used**:
  - Keychain Services
  - Security-scoped bookmarks
  - Certificate handling
  - Secure enclave operations

## Security Protocols

### 1. CryptoService Protocol
```swift
public protocol CryptoService {
    func encrypt(_ data: Data, using key: SymmetricKey) async throws -> EncryptedData
    func decrypt(_ data: EncryptedData, using key: SymmetricKey) async throws -> Data
    func generateKey(length: Int) async throws -> SymmetricKey
    func generateIV(length: Int) async throws -> Data
}
```

### 2. SecureStorageProvider Protocol
```swift
public protocol SecureStorageProvider {
    func store(_ data: Data, for identifier: String) async throws
    func retrieve(for identifier: String) async throws -> Data
    func remove(for identifier: String) async throws
}
```

## Security Configuration

### 1. Default Configuration
```swift
public struct CryptoConfig {
    public static let `default` = CryptoConfig(
        keyLength: 256,  // AES-256
        ivLength: 16     // 128 bits
    )
}
```

### 2. XPC Service Configuration
- Sandboxed environment
- Limited file system access
- Specific keychain access groups
- Application group sharing

## Known Issues and Mitigations

### 1. Memory Management
- **Issue**: Sensitive data in memory
- **Mitigation**: Secure memory wiping after use

### 2. Key Storage
- **Issue**: Secure key storage
- **Mitigation**: Keychain with access control

### 3. IPC Security
- **Issue**: Inter-process communication security
- **Mitigation**: XPC with entitlement checking

## Testing

### 1. Security Testing
- Unit tests for all crypto operations
- Integration tests for service communication
- Fuzzing tests for input validation
- Memory leak detection

### 2. Mock Implementations
```swift
public final class MockCryptoService: CryptoService {
    public var encryptionBehavior: EncryptionBehavior
    public var decryptionBehavior: DecryptionBehavior
    // Implementation for testing
}
```

## Future Improvements

1. **Hardware Security**
   - Secure Enclave integration
   - Touch ID/Apple Watch authentication
   - Smart card support

2. **Key Management**
   - Key rotation policies
   - Multi-factor key derivation
   - Quantum-resistant algorithms

3. **Audit Logging**
   - Comprehensive security event logging
   - Real-time alerts
   - Compliance reporting

## Security Guidelines

1. **Development**
   - Always use secure random number generation
   - Implement proper error handling
   - Clear sensitive data from memory

2. **Testing**
   - Test with different key sizes
   - Validate all error paths
   - Check memory handling

3. **Deployment**
   - Review entitlements
   - Validate sandbox configuration
   - Check keychain access groups

---
Last Updated: 2025-02-24
