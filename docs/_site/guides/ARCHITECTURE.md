# UmbraCore Architecture Guide

## Overview
UmbraCore is designed as a modular Swift library that provides a type-safe interface to Restic backup functionality. The architecture follows a service-oriented approach with clear separation of concerns.

## Core Components

### 1. Security Layer
- `SecurityTypes`: Base security primitives
- `CryptoTypes`: Cryptographic operations
- `UmbraKeychainService`: Secure credential storage

### 2. Service Layer
- `UmbraCryptoService`: Encryption/decryption operations
- `UmbraBookmarkService`: File system bookmark management
- `UmbraXPC`: Inter-process communication

### 3. Logging Infrastructure
- `UmbraLogging`: Centralised logging system
- Structured logging with context
- Log level management

## Design Patterns

### 1. XPC Service Pattern
Used for secure inter-process communication:
```swift
protocol KeychainXPCProtocol {
    func store(password: String, forKey: String) async throws
    func retrieve(forKey: String) async throws -> String
}
```

### 2. Protocol-Oriented Design
Services are defined by protocols for better testability:
```swift
protocol CryptoServiceProtocol {
    func encrypt(_ data: Data) async throws -> Data
    func decrypt(_ data: Data) async throws -> Data
}
```

### 3. Error Handling Pattern
Structured error types with context:
```swift
enum KeychainError: Error {
    case itemNotFound(String)
    case duplicateItem(String)
    case accessDenied(String)
}
```

## Threading Model
- All services are thread-safe
- Async/await for asynchronous operations
- XPC for background processing

## Security Considerations
- Keychain integration for secure storage
- XPC for privilege separation
- Audit logging
- Secure defaults

## Performance Considerations
- Efficient memory usage
- Background processing
- Cache management
- Resource cleanup

## Testing Strategy
- Unit tests for all components
- Integration tests for workflows
- Mock services for testing
- Performance benchmarks

## Dependency Management
- Minimal external dependencies
- Version pinning
- Security scanning
- Regular updates
