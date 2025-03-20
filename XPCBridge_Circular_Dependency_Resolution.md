# XPCBridge Module: Circular Dependency Resolution

## Problem Statement

During the refactoring of the XPCBridge module as part of the broader XPC Protocol Consolidation effort, we encountered a circular dependency issue that prevented successful compilation. This document details the issue, our resolution approach, and recommendations for future architectural improvements.

## Technical Context

The UmbraCore project is undergoing a significant refactoring to consolidate XPC protocols and remove Foundation dependencies across module boundaries. The XPCBridge module is a key component in this architecture, providing Foundation-independent implementations of XPC communication for security services.

### Relevant Components

1. **XPCBridge Module**: Provides adapter classes for XPC service communication using DTOs
2. **SecurityInterfaces Module**: Defines core security interfaces and error types
3. **XPCProtocolsCore Module**: Provides base protocols and typealias for XPC communication

## Issue Description

When attempting to refactor the `XPCServiceDTOAdapter.swift` file to use `SecurityInterfaces.SecurityError` directly instead of a typealias, we encountered build failures:

```
error: no such module 'SecurityInterfaces'
```

Even after adding SecurityInterfaces to the BUILD.bazel dependencies, the issue persisted, indicating a circular dependency:

- The XPCBridge module was trying to import SecurityInterfaces
- But SecurityInterfaces already had a dependency (direct or indirect) on XPCBridge (or a module that depends on XPCBridge)
- This created a circular dependency loop that the Bazel build system couldn't resolve

## Resolution Approach

Rather than complicating the dependency graph, we implemented a targeted solution that broke the circular dependency:

### 1. Use an Existing Dependency

Instead of importing SecurityInterfaces, we directly used `XPCProtocolsCore.SecurityError`, which was already a dependency of the XPCBridge module.

```swift
// Before
import SecurityInterfaces
// ...
public static func toDTO(_ error: SecurityInterfaces.SecurityError) -> XPCSecurityErrorDTO {
    // ...
}

// After
import XPCProtocolsCore
// ...
public static func toDTO(_ error: XPCProtocolsCore.SecurityError) -> XPCSecurityErrorDTO {
    // ...
}
```

### 2. Update Error Mapping

We refactored the `XPCSecurityDTOConverter.toDTO()` method to use the error cases defined in `XPCProtocolsCore.SecurityError`:

```swift
public static func toDTO(_ error: XPCProtocolsCore.SecurityError) -> XPCSecurityErrorDTO {
    switch error {
    case .serviceUnavailable:
        return XPCSecurityErrorDTO(code: .serviceUnavailable, details: ["message": "XPC service is unavailable"])
        
    case .serviceNotReady(let reason):
        return XPCSecurityErrorDTO(code: .serviceUnavailable, details: ["message": "XPC service not ready", "reason": reason])
        
    // Additional case mappings...
        
    @unknown default:
        // Handle future cases that might be added to the SecurityError enum
        return XPCSecurityErrorDTO(code: .unknown, details: ["message": "Unknown security error"])
    }
}
```

### 3. Update BUILD.bazel

We updated the BUILD.bazel file to include proper dependencies while avoiding the circular reference:

```python
swift_library(
    name = "XPCBridge",
    # ...
    deps = [
        "//Sources/CoreDTOs",
        "//Sources/CoreTypesInterfaces",
        "//Sources/SecureBytes",
        "//Sources/SecurityProtocolsCore",
        "//Sources/UmbraCoreTypes",
        "//Sources/XPCProtocolsCore",
    ],
)
```

## Results

The changes successfully resolved the compilation issues while maintaining the desired functionality:

1. Broke the circular dependency chain
2. Maintained proper error handling functionality
3. Kept the code clean and maintainable
4. Successfully built both XPCBridge and the entire SecurityBridge module
5. Added proper Swift 6 compatibility with `@unknown default` case handling

## Architectural Recommendations

While our solution is maintainable for the transitional period, there are several opportunities for architectural improvements:

### 1. Error Type Consolidation

**Issue:** Multiple error types (XPCSecurityErrorDTO, SecurityError) with conversions between them creates maintenance overhead.

**Recommendation:** Consolidate to a single core error type used consistently across modules.

```swift
// Example approach - create a unified error type in a base module
public enum UmbraCoreError: Error, Sendable {
    case security(SecurityErrorType)
    case network(NetworkErrorType)
    // Additional domains as needed
}
```

### 2. Clearer Dependency Hierarchy

**Issue:** Complex dependencies with potential for future circular references.

**Recommendation:** Implement a clearer layered architecture with unidirectional dependencies:

```
Core Types Layer → Protocol Layer → Implementation Layer
```

- **Core Types Layer**: Pure data types, errors, no dependencies
- **Protocol Layer**: Defines interfaces, depends only on Core Types
- **Implementation Layer**: Implements protocols, depends on Protocols and Core Types

### 3. Migration Plan Documentation

**Issue:** XPCServiceDTOAdapter is marked as deprecated, but migration path may not be clear to all developers.

**Recommendation:** Explicitly document the migration path with examples:

```markdown
## Migration Guide

### Deprecated Pattern
```swift
let adapter = XPCServiceDTOAdapter(connection: connection)
let result = await adapter.ping()
```

### New Pattern
```swift
let service = XPCServiceFactory.createService(for: serviceName)
let result = await service.ping()
```
```

### 4. Protocol Separation

**Issue:** XPCServiceProtocolStandardDTO combines multiple responsibilities.

**Recommendation:** Split into smaller, more focused protocols:

```swift
public protocol XPCServiceBasicOperations: Sendable {
    func ping() async -> Result<Bool, XPCSecurityErrorDTO>
    func getServiceStatus() async -> Result<XPCServiceDTO.ServiceStatusDTO, XPCSecurityErrorDTO>
}

public protocol XPCServiceSecurityOperations: Sendable {
    func resetSecurity() async -> Result<Void, XPCSecurityErrorDTO>
    func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    // Additional security operations
}

// Main protocol can compose these smaller protocols
public protocol XPCServiceProtocolStandardDTO: XPCServiceBasicOperations, XPCServiceSecurityOperations {}
```

### 5. Foundation Independence Strategy

**Issue:** Current approach still uses Foundation types (NSXPCConnection, NSLock).

**Recommendation:** Create wrappers or protocols to abstract these dependencies:

```swift
// Platform-agnostic protocol
public protocol LockProtocol {
    func lock()
    func unlock()
}

// Foundation implementation
#if canImport(Foundation)
public class FoundationLock: LockProtocol {
    private let lock = NSLock()
    
    public func lock() {
        lock.lock()
    }
    
    public func unlock() {
        lock.unlock()
    }
}
#endif

// POSIX implementation for other platforms
#if os(Linux)
public class POSIXLock: LockProtocol {
    // Implementation using pthread_mutex_t
}
#endif
```

## Implementation Priority

For immediate architectural improvement, focus on items #1 (Error Type Consolidation) and #2 (Clearer Dependency Hierarchy) first, as they would have the most significant impact on maintainability while requiring relatively modest changes to the existing codebase.

## Conclusion

The circular dependency resolution implemented for the XPCBridge module provides a solid foundation for the ongoing XPC Protocol Consolidation work. By carefully considering dependency relationships and leveraging existing code structures, we've maintained the system's integrity while enabling future architectural improvements.

The recommended improvements outlined above should be considered as part of the broader refactoring effort to create a more maintainable, extensible, and Foundation-independent architecture for UmbraCore.
