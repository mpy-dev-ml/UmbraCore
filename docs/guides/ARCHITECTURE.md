# UmbraCore Architecture Guide

## Overview
UmbraCore is designed as a modular Swift library that provides a type-safe interface to Restic backup functionality. The architecture follows a service-oriented approach with clear separation of concerns.

## Core Components

### 1. Security Layer
- `SecurityTypes`: Base security primitives
- `CryptoTypes`: Cryptographic operations
  - Uses Apple's CryptoKit for hardware-backed security
  - Provides core cryptographic primitives
  - Handles secure key generation and management
- `UmbraKeychainService`: Secure credential storage

### 2. Service Layer
- `UmbraCryptoService`: Encryption/decryption operations
  - Uses CryptoSwift for XPC service operations
  - Platform-independent implementation
  - Handles cross-process cryptographic operations
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

## Cryptographic Architecture
The framework employs a dual-library approach for cryptographic operations:

1. **CryptoKit (Main App Context)**
   - Hardware-backed security on Apple platforms
   - Used in `DefaultCryptoService`
   - Handles core cryptographic operations
   - Optimal security for main app operations

2. **CryptoSwift (XPC Service Context)**
   - Platform-independent implementation
   - Used in `CryptoXPCService`
   - Enables reliable cross-process encryption
   - Provides necessary flexibility for XPC operations

This split architecture ensures:
- Maximum security through hardware backing where available
- Reliable cross-process cryptographic operations
- Clear separation of concerns between contexts
- Consistent cryptographic operations in each context

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

## Implementation Plan

### Phase 1: Core Foundation

Currently in progress (Q1 2025):

- Command execution system
- Keychain integration
- XPC service implementation
- SSH key management
- Cloud provider integration

### Phase 2: Advanced Features

Planned for Q2 2025:

- Repository management
- Scheduling system
- Network operations
- State persistence

### Phase 3: Optimisation

Scheduled for Q3 2025:

- Statistics & analytics
- Health monitoring
- Event system
- Cache optimisation

## Design Principles

### 1. Security First
- Secure by default
- Least privilege principle
- Comprehensive audit logging
- Regular security reviews

### 2. Reliability
- Comprehensive error handling
- Automatic retry mechanisms
- Circuit breakers
- Fallback strategies

### 3. Performance
- Efficient resource usage
- Optimised I/O operations
- Memory management
- Cache strategies

### 4. Maintainability
- Protocol-oriented design
- Clear documentation
- Comprehensive testing
- Code review process

## Integration Points

UmbraCore serves as the foundation for:

- **Rbum**: Command-line interface
- **Rbx**: GUI application
- **ResticBar**: Menu bar application

Each application utilises UmbraCore's components through well-defined protocols and interfaces.

## Testing Strategy

Comprehensive testing approach:

1. **Unit Tests**
   - Component isolation
   - Edge case coverage
   - Mock implementations

2. **Integration Tests**
   - Component interaction
   - System workflows
   - Error scenarios

3. **Performance Tests**
   - Resource usage
   - Throughput metrics
   - Scalability checks

4. **Security Tests**
   - Vulnerability scanning
   - Penetration testing
   - Compliance verification
