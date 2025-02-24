# UmbraCore Refactoring Plan

## Overview

This document outlines our approach to refactoring UmbraCore, using the Security and Crypto modules as templates. The plan combines functional improvements with progressive style guide compliance.

## Completed Work

### Phase 1: Service Architecture
✓ Core Service Infrastructure
- Implemented UmbraService protocol
- Created service state management
- Established actor-based architecture

✓ Security Service Implementation
- Implemented CryptoService with XPC support
- Created SecurityService with bookmark management
- Integrated KeyManager and CredentialManager
- Added security-scoped resource handling

✓ Resource Management Foundation
- Implemented ManagedResource protocol
- Created ResourcePool implementation
- Added SecureStorageResource
- Integrated KeychainResource

## Current Phase: Core Features Implementation

### 1. Repository Management (2 weeks)
#### Week 1: Core Repository Types
```swift
public protocol Repository: Actor {
    var identifier: String { get }
    var state: RepositoryState { get }
    var location: URL { get }
    
    func initialize() async throws
    func validate() async throws -> Bool
    func lock() async throws
    func unlock() async throws
}

public enum RepositoryState {
    case uninitialized
    case ready
    case locked
    case error(Error)
}
```

#### Week 2: Repository Service
```swift
public actor RepositoryService {
    private var repositories: [String: Repository]
    private let securityService: SecurityService
    private let cryptoService: CryptoService
    
    public func register(_ repository: Repository) async throws
    public func unregister(_ identifier: String) async
    public func getRepository(_ identifier: String) async throws -> Repository
}
```

### 2. Snapshot Management (2 weeks)
#### Week 1: Snapshot Types
```swift
public struct Snapshot: Identifiable {
    public let id: String
    public let timestamp: Date
    public let tags: Set<String>
    public let paths: [URL]
    public let size: UInt64
    public let stats: SnapshotStats
}

public protocol SnapshotManager: Actor {
    func create(_ paths: [URL], tags: Set<String>) async throws -> Snapshot
    func list() async throws -> [Snapshot]
    func restore(_ snapshot: Snapshot, to: URL) async throws
    func delete(_ snapshot: Snapshot) async throws
}
```

#### Week 2: Snapshot Service Implementation
```swift
public actor SnapshotService: SnapshotManager {
    private let repository: Repository
    private let securityService: SecurityService
    private let fileManager: FileManager
    
    public func create(_ paths: [URL], tags: Set<String>) async throws -> Snapshot
    public func restore(_ snapshot: Snapshot, to: URL) async throws
}
```

### 3. CLI Integration (2 weeks)
#### Week 1: Command Framework
- Design command execution system
- Implement process management
- Add output parsing

#### Week 2: Restic Integration
- Repository operations
- Snapshot management
- Backup and restore
- Error handling

## Next Phases

### Phase 4: Configuration Management (2 weeks)
- Repository settings
- Backup policies
- Security preferences
- Logging configuration

### Phase 5: Logging Enhancement (2 weeks)
- Privacy-aware logging
- Log rotation
- Performance metrics
- Debug information

### Phase 6: Error Handling (2 weeks)
- Error categorization
- Recovery strategies
- User feedback
- Diagnostic tools

## Timeline
- Current Phase (Core Features): March 2025
- Phase 4 (Configuration): April 2025
- Phase 5 (Logging): April 2025
- Phase 6 (Error Handling): May 2025

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
