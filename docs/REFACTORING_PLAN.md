# UmbraCore Refactoring Plan

## Overview

This document outlines our approach to refactoring UmbraCore, using the Security and Crypto modules as templates. The plan combines functional improvements with progressive style guide compliance.

## Phase 1: Service Architecture (4 weeks)

### Week 1-2: Core Service Infrastructure

#### 1. Service Protocol Definition
```swift
/// Protocol defining the base requirements for all UmbraCore services
public protocol UmbraService: Actor {
    /// Unique identifier for the service type
    static var serviceIdentifier: String { get }
    
    /// Current state of the service
    var state: ServiceState { get }
    
    /// Initialize the service
    /// - Throws: ServiceError if initialization fails
    func initialize() async throws
    
    /// Gracefully shut down the service
    func shutdown() async
}

/// Represents the current state of a service
public enum ServiceState: String {
    case uninitialized
    case initializing
    case ready
    case error
    case shuttingDown
    case shutdown
}
```

#### 2. Service Container Implementation
```swift
/// Thread-safe container for managing service instances
public actor ServiceContainer {
    /// Registered services
    private var services: [String: any UmbraService]
    
    /// Service initialization queue
    private let initializationQueue: TaskGroup
    
    /// Register a service with the container
    /// - Parameter service: The service to register
    /// - Throws: ServiceError if registration fails
    public func register<T: UmbraService>(_ service: T) async throws
    
    /// Resolve a service of the specified type
    /// - Returns: The requested service instance
    /// - Throws: ServiceError if service not found
    public func resolve<T: UmbraService>(_ type: T.Type) async throws -> T
}
```

### Week 3-4: Security Service Refactoring

#### 1. Crypto Service Implementation
```swift
/// Handles cryptographic operations
public actor CryptoService: UmbraService {
    public static let serviceIdentifier = "com.umbracore.crypto"
    public private(set) var state: ServiceState
    
    private let keyManager: KeyManager
    private let config: CryptoConfig
    
    /// Initialize with the specified configuration
    /// - Parameter config: Cryptographic configuration
    public init(config: CryptoConfig) async throws
    
    /// Encrypt data using the specified key
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - key: Encryption key
    /// - Returns: Encrypted data
    /// - Throws: CryptoError on failure
    public func encrypt(_ data: Data, using key: SymmetricKey) async throws -> EncryptedData
}
```

#### 2. Security Service Implementation
```swift
/// Manages security operations and access control
public actor SecurityService: UmbraService {
    public static let serviceIdentifier = "com.umbracore.security"
    public private(set) var state: ServiceState
    
    private let cryptoService: CryptoService
    private let accessController: AccessController
    
    /// Initialize security service
    /// - Parameter container: Service container for dependencies
    public init(container: ServiceContainer) async throws
    
    /// Secure a resource with the specified protection level
    /// - Parameters:
    ///   - resource: Resource to protect
    ///   - level: Protection level
    /// - Returns: Protected resource handle
    /// - Throws: SecurityError on failure
    public func secure<T>(_ resource: T, level: ProtectionLevel) async throws -> SecureHandle<T>
}
```

## Phase 2: Resource Management (4 weeks)

### Week 1-2: Resource Handling

#### 1. Resource Protocol
```swift
/// Protocol for managed resources
public protocol ManagedResource: Actor {
    /// Resource type identifier
    static var resourceType: String { get }
    
    /// Current state of the resource
    var state: ResourceState { get }
    
    /// Acquire the resource
    func acquire() async throws
    
    /// Release the resource
    func release() async
    
    /// Clean up any allocated resources
    func cleanup() async
}
```

#### 2. Resource Pool Implementation
```swift
/// Manages a pool of reusable resources
public actor ResourcePool<T: ManagedResource> {
    /// Available resources
    private var available: [T]
    
    /// Resources currently in use
    private var inUse: [T]
    
    /// Resource creation factory
    private let factory: () async throws -> T
    
    /// Acquire a resource from the pool
    /// - Returns: An available resource
    /// - Throws: ResourceError if no resources available
    public func acquire() async throws -> T
    
    /// Release a resource back to the pool
    /// - Parameter resource: Resource to release
    public func release(_ resource: T) async
}
```

### Week 3-4: Security Resource Implementation

#### 1. Secure Storage Resource
```swift
/// Manages secure storage operations
public actor SecureStorageResource: ManagedResource {
    public static let resourceType = "com.umbracore.secure-storage"
    public private(set) var state: ResourceState
    
    private let storage: SecureStorage
    private let cryptoService: CryptoService
    
    /// Store data securely
    /// - Parameters:
    ///   - data: Data to store
    ///   - key: Storage key
    /// - Throws: StorageError on failure
    public func store(_ data: Data, forKey key: String) async throws
}
```

#### 2. Keychain Resource
```swift
/// Manages keychain operations
public actor KeychainResource: ManagedResource {
    public static let resourceType = "com.umbracore.keychain"
    public private(set) var state: ResourceState
    
    private let accessGroup: String
    private let accessibility: KeychainAccessibility
    
    /// Store an item in the keychain
    /// - Parameters:
    ///   - item: Item to store
    ///   - identifier: Item identifier
    /// - Throws: KeychainError on failure
    public func store(_ item: KeychainItem, identifier: String) async throws
}
```

## Phase 3: Error Handling (4 weeks)

### Week 1-2: Error Infrastructure

#### 1. Error Context
```swift
/// Provides context for error handling
public struct ErrorContext {
    /// Source file where error occurred
    public let file: String
    
    /// Function where error occurred
    public let function: String
    
    /// Line number where error occurred
    public let line: Int
    
    /// Time when error occurred
    public let timestamp: Date
    
    /// Additional context information
    public var userInfo: [String: Any]
}
```

#### 2. Error Protocol
```swift
/// Protocol for contextual errors
public protocol ContextualError: Error {
    /// Error context
    var context: ErrorContext { get }
    
    /// Available recovery options
    var recoveryOptions: [RecoveryOption] { get }
    
    /// Attempt to recover from the error
    /// - Parameter option: Recovery option to attempt
    /// - Returns: Whether recovery was successful
    func attemptRecovery(_ option: RecoveryOption) async -> Bool
}
```

### Week 3-4: Security Error Implementation

#### 1. Crypto Errors
```swift
/// Represents cryptographic operation errors
public enum CryptoError: ContextualError {
    case invalidKey(reason: String)
    case encryptionFailed(reason: String)
    case decryptionFailed(reason: String)
    case invalidData(reason: String)
    
    public var context: ErrorContext
    public var recoveryOptions: [RecoveryOption]
    
    public func attemptRecovery(_ option: RecoveryOption) async -> Bool
}
```

#### 2. Security Errors
```swift
/// Represents security operation errors
public enum SecurityError: ContextualError {
    case accessDenied(resource: String)
    case invalidCredentials(reason: String)
    case resourceUnavailable(identifier: String)
    case secureStorageFailed(reason: String)
    
    public var context: ErrorContext
    public var recoveryOptions: [RecoveryOption]
    
    public func attemptRecovery(_ option: RecoveryOption) async -> Bool
}
```

## Style Guide Compliance

### Documentation Standards
- Use /// for documentation comments
- Document all public APIs
- Include parameter descriptions
- Document error conditions
- Add usage examples

### Code Organization
- Properties first
- Then initializers
- Then methods
- Protocol conformance in extensions

### Naming Conventions
- Use verb phrases for functions
- Clear, self-documenting names
- Consistent capitalization
- Follow Swift API guidelines

### Swift Best Practices
- Use let over var
- Early returns with guard
- Proper access control
- Type inference where clear

## Implementation Strategy

### 1. Service Layer (Weeks 1-4)
- [ ] Define base protocols
- [ ] Implement service container
- [ ] Refactor crypto service
- [ ] Refactor security service

### 2. Resource Management (Weeks 5-8)
- [ ] Define resource protocols
- [ ] Implement resource pool
- [ ] Refactor secure storage
- [ ] Refactor keychain access

### 3. Error Handling (Weeks 9-12)
- [ ] Define error protocols
- [ ] Implement error context
- [ ] Refactor crypto errors
- [ ] Refactor security errors

## Testing Strategy

### 1. Unit Tests
- Test each component in isolation
- Mock dependencies
- Test error conditions
- Verify resource cleanup

### 2. Integration Tests
- Test service interactions
- Verify resource management
- Test error recovery
- Check memory handling

### 3. Performance Tests
- Measure operation timing
- Check resource usage
- Test under load
- Verify cleanup efficiency

## Success Metrics

### 1. Code Quality
- Reduced coupling
- Improved cohesion
- Better error handling
- Cleaner interfaces

### 2. Performance
- Faster operations
- Lower memory usage
- Better resource utilization
- Quicker error recovery

### 3. Maintainability
- Easier to test
- Simpler to debug
- Clearer documentation
- More consistent style

---
Last Updated: 2025-02-24
