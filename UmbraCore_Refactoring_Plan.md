{{ ... }}

This section tracks the implementation progress of the refactoring plan and identifies what should be prioritised next.

### XPC Protocol Consolidation Progress (92% Complete)

✓ Created XPCProtocolsCore foundation-free module
✓ Defined three-tier protocol hierarchy (Basic, Standard, Complete)
✓ Added standardized error handling via UmbraCoreTypes.CESecurityError alias
✓ Created migration adapters for legacy code compatibility
✓ Deprecated legacy protocols in SecurityInterfaces module
✓ Added comprehensive migration documentation
✓ Implemented example service using new protocols
✓ Fixed Swift 6 compatibility issues with error type handling
✓ Updated error types to use standardized CoreErrors.SecurityError
✓ Migrated UmbraSecurity module to use XPCProtocolsCore
✓ Updated Core/Services type aliases to use XPCProtocolsCore
✓ Migrated Features/Logging module to use XPCProtocolsCore
✓ Updated security-related error handling across multiple modules
✓ Fixed migration adapters to properly implement all XPCServiceProtocolStandard methods
✓ Corrected method signatures and data conversions in adapters
✓ Updated CryptoTypes module to use the new protocols
✓ Added CryptoXPCServiceAdapter for backwards compatibility
✓ Created comprehensive migration guide for CryptoTypes
✓ Added missing randomGenerationFailed case to SecurityError enum
✓ Updated error mapping in UmbraCoreTypes/CoreErrors for new error case
✓ Fixed SecurityUtils module to work with updated XPC error types
✓ Consolidated CryptoError in CoreErrors with full parameter support
✓ Updated CryptoTypes and Core modules to deprecate their local CryptoError definitions
✓ Fixed UmbraCryptoService to use consolidated CoreErrors.CryptoError
✓ Added comprehensive tests for all protocol implementations
✓ Marked all legacy XPC protocols with proper deprecation warnings
✓ Created detailed XPC_PROTOCOLS_MIGRATION_GUIDE.md
✓ Added DeprecationWarningTests to verify backward compatibility
✓ Created XPC Protocol Analyzer tool for tracking migration progress
✓ Updated SecurityProvider.swift to serve as a reference implementation
✓ Generated comprehensive report of modules requiring migration
✓ Migrated SecurityInterfaces/XPCServiceProtocol.swift to use XPCProtocolsCore
✓ Migrated SecurityInterfaces/SecurityProviderBase.swift to Result-based error handling
✓ Updated SecurityInterfaces/SecurityProviderFoundation.swift to use SecureBytes
✓ Migrated SecurityInterfaces/SecurityProviderFactory.swift to use modern type-safe protocols
✓ Added proper deprecation attributes to CryptoTypes/CryptoXPCServiceProtocol with migration messages
✓ Updated CryptoTypes/CredentialManager to use ModernCryptoXPCServiceProtocol for type safety
✓ Enhanced documentation for all migrated protocols and adapters
✓ Updated CryptoXPCServiceAdapter to implement exists method for SecureStorageServiceProtocol
✓ Updated XPCServiceProtocolBasic synchroniseKeys method to use Result-based error handling
✓ Updated all protocol adapters and mock implementations to use Result for error handling

Remaining tasks:
- Complete migration of Core module (20 files) - High Priority
- Complete migration of CryptoTypes module (10 files) - High Priority
- Complete migration of UmbraSecurity module (12 files) - High Priority
- Complete migration of SecurityInterfaces module (8 files) - High Priority
- Complete migration of Features module (10 files) - Medium Priority
- Complete migration of Services module (9 files) - Medium Priority
- Complete migration of CoreTypes module (6 files) - Medium Priority
- Complete migration of SecurityInterfacesBase module (5 files) - Medium Priority
- Complete migration of UmbraCryptoService module (5 files) - Medium Priority
- Remove legacy protocol definitions after migration period (scheduled for May 2025)

### Code Review Findings

#### 1. XPC Protocol Redundancies

We have identified multiple overlapping XPC protocol definitions across several modules:

- **XPCProtocolsCore** defines `XPCServiceProtocolBasic`, `XPCServiceProtocolStandard`, and `XPCServiceProtocolComplete` 
- **SecurityProtocolsCore** defines `XPCServiceProtocolCore` with similar functionality
- **SecurityInterfacesProtocols** defines `XPCServiceProtocolBase` with basic functionality
- **SecurityInterfacesBase** re-exports `XPCServiceProtocolBase` from SecurityInterfacesProtocols
- **SecurityInterfaces** includes `XPCServiceProtocol` and `XPCServiceProtocolBase`

#### 2. Bridge Implementation Duplication

Multiple modules implement bridge functionality between Foundation types and domain types:

- **SecurityBridge** contains comprehensive adapters (`DataAdapter`, `DateAdapter`, etc.)
- **SecurityInterfacesFoundation** contains similar conversion functions
- **UmbraSecurity/Extensions** contains extension methods for similar conversions

#### 3. Security Provider Protocol Hierarchy

The security provider protocol hierarchy is fragmented across several modules:

- **SecurityProtocolsCore** defines `SecurityProviderProtocol`
- **SecurityInterfacesProtocols** defines a similar `SecurityProviderProtocol`
- **SecurityInterfacesBase** defines `SecurityProviderBase`
- **SecurityInterfaces** defines additional security provider abstractions

#### 4. Error Type Duplication

Various error types related to security operations are defined in multiple places:

- **SecurityProtocolsCore** defines `SecurityError`
- **SecurityInterfacesProtocols** defines `SecurityProtocolError`
- **XPCProtocolsCore** defines `SecurityProtocolError`
- **UmbraCoreTypes/CoreErrors** includes common error definitions
- **CryptoTypes** defines `CryptoError` (now deprecated, use CoreErrors.CryptoError)
- **Core/Services** defines `CryptoError` (now deprecated, use CoreErrors.CryptoError)

### Consolidation Recommendations

Based on the above findings, the following specific consolidation steps are recommended:

#### 1. XPC Protocol Consolidation

1. **Immediate Actions:**
   - Migrate all XPC protocol definitions from SecurityInterfacesProtocols and SecurityInterfacesBase to XPCProtocolsCore
   - Update SecurityProtocolsCore to import XPCProtocolsCore instead of defining its own XPC protocols
   - Define clear protocol hierarchy within XPCProtocolsCore with documentation of each level's purpose

2. **Redundant Module Removal:**
   - Remove XPC-related protocols from SecurityInterfacesProtocols
   - Remove XPC-related re-exports from SecurityInterfacesBase
   - Remove XPC-related protocols from SecurityInterfaces where they duplicate XPCProtocolsCore

#### 2. Bridge Layer Consolidation

1. **Immediate Actions:**
   - Standardize on SecurityBridge as the primary bridge module
   - Migrate any unique functionality from SecurityInterfacesFoundation to SecurityBridge
   - Ensure all adapter implementations follow the same pattern as existing SecurityBridge adapters

2. **Redundant Module Removal:**
   - Deprecate and eventually remove SecurityInterfacesFoundation
   - Refactor UmbraSecurity/Extensions to use SecurityBridge adapters

#### 3. Security Provider Consolidation

1. **Immediate Actions:**
   - Standardize on SecurityProtocolsCore.SecurityProviderProtocol as the canonical definition
   - Update other modules to use this definition instead of duplicating it
   - Document the purpose and responsibility of each protocol in the hierarchy

2. **Redundant Module Removal:**
   - Remove SecurityProviderProtocol from SecurityInterfacesProtocols
   - Remove SecurityProviderBase from SecurityInterfacesBase if redundant

#### 4. Error Handling Standardization

1. **Immediate Actions:**
   - Centralize all security-related error definitions in UmbraCoreTypes/CoreErrors
   - Create mappings between different error types in SecurityBridge
   - Ensure all modules consistently use the centralized error types

### Updated Timeline

Based on the findings, the following updates to our existing timeline are recommended:

#### March 2025:
- Complete XPC protocol consolidation into XPCProtocolsCore (High Priority)
- Standardize bridge implementation in SecurityBridge (High Priority)
- Update error handling approach with centralized definitions (Medium Priority)

#### April 2025:
- Complete Security Provider protocol hierarchy consolidation (High Priority)
- Finish UmbraSecurityBridge implementation (Medium Priority)
- Begin deprecation of redundant modules (Medium Priority)

#### May 2025:
- Remove redundant modules following deprecation period (High Priority)
- Complete Core Services Types consolidation (Medium Priority)
- Address ObjC Bridging Types (Medium Priority)

#### June 2025:
- Complete CryptoSwift integration (Medium Priority)
- Final testing and validation of consolidated architecture (High Priority)
- Prepare umbracore-alpha for promotion to main branch (High Priority)

### Conclusion

The current module structure contains significant redundancy and overlap, particularly in the areas of XPC protocols, security providers, and bridge implementations. By following the consolidation recommendations outlined above, we can substantially reduce the number of modules while creating a clearer, more maintainable architecture.

The foundational work done so far with SecurityProtocolsCore, SecurityBridge, and XPCProtocolsCore provides a solid basis for this consolidation effort. The next phase should focus on standardizing on these modules and removing redundant implementations.

## Implementation Status Update (5 March 2025)

A comprehensive code review has been conducted to identify redundancies and consolidation opportunities in the UmbraCore codebase. The following findings and recommendations will help guide the next steps in our refactoring effort.

### XPC Protocol Consolidation Progress (92% Complete)

✓ Created XPCProtocolsCore foundation-free module
✓ Defined three-tier protocol hierarchy (Basic, Standard, Complete)
✓ Added standardized error handling via UmbraCoreTypes.CESecurityError alias
✓ Created migration adapters for legacy code compatibility
✓ Deprecated legacy protocols in SecurityInterfaces module
✓ Added comprehensive migration documentation
✓ Implemented example service using new protocols
✓ Fixed Swift 6 compatibility issues with error type handling
✓ Updated error types to use standardized CoreErrors.SecurityError
✓ Migrated UmbraSecurity module to use XPCProtocolsCore
✓ Updated Core/Services type aliases to use XPCProtocolsCore
✓ Migrated Features/Logging module to use XPCProtocolsCore
✓ Updated security-related error handling across multiple modules
✓ Fixed migration adapters to properly implement all XPCServiceProtocolStandard methods
✓ Corrected method signatures and data conversions in adapters
✓ Updated CryptoTypes module to use the new protocols
✓ Added CryptoXPCServiceAdapter for backwards compatibility
✓ Created comprehensive migration guide for CryptoTypes
✓ Added missing randomGenerationFailed case to SecurityError enum
✓ Updated error mapping in UmbraCoreTypes/CoreErrors for new error case
✓ Fixed SecurityUtils module to work with updated XPC error types
✓ Consolidated CryptoError in CoreErrors with full parameter support
✓ Updated CryptoTypes and Core modules to deprecate their local CryptoError definitions
✓ Fixed UmbraCryptoService to use consolidated CoreErrors.CryptoError
✓ Added comprehensive tests for all protocol implementations
✓ Marked all legacy XPC protocols with proper deprecation warnings
✓ Created detailed XPC_PROTOCOLS_MIGRATION_GUIDE.md
✓ Added DeprecationWarningTests to verify backward compatibility
✓ Created XPC Protocol Analyzer tool for tracking migration progress
✓ Updated SecurityProvider.swift to serve as a reference implementation
✓ Generated comprehensive report of modules requiring migration
✓ Migrated SecurityInterfaces/XPCServiceProtocol.swift to use XPCProtocolsCore
✓ Migrated SecurityInterfaces/SecurityProviderBase.swift to Result-based error handling
✓ Updated SecurityInterfaces/SecurityProviderFoundation.swift to use SecureBytes
✓ Migrated SecurityInterfaces/SecurityProviderFactory.swift to use modern type-safe protocols
✓ Added proper deprecation attributes to CryptoTypes/CryptoXPCServiceProtocol with migration messages
✓ Updated CryptoTypes/CredentialManager to use ModernCryptoXPCServiceProtocol for type safety
✓ Enhanced documentation for all migrated protocols and adapters
✓ Updated CryptoXPCServiceAdapter to implement exists method for SecureStorageServiceProtocol
✓ Updated XPCServiceProtocolBasic synchroniseKeys method to use Result-based error handling
✓ Updated all protocol adapters and mock implementations to use Result for error handling

Remaining tasks:
- Complete migration of Core module (20 files) - High Priority
- Complete migration of CryptoTypes module (10 files) - High Priority
- Complete migration of UmbraSecurity module (12 files) - High Priority
- Complete migration of SecurityInterfaces module (8 files) - High Priority
- Complete migration of Features module (10 files) - Medium Priority
- Complete migration of Services module (9 files) - Medium Priority
- Complete migration of CoreTypes module (6 files) - Medium Priority
- Complete migration of SecurityInterfacesBase module (5 files) - Medium Priority
- Complete migration of UmbraCryptoService module (5 files) - Medium Priority
- Remove legacy protocol definitions after migration period (scheduled for May 2025)

### Code Review Findings

#### 1. XPC Protocol Redundancies

We have identified multiple overlapping XPC protocol definitions across several modules:

- **XPCProtocolsCore** defines `XPCServiceProtocolBasic`, `XPCServiceProtocolStandard`, and `XPCServiceProtocolComplete` 
- **SecurityProtocolsCore** defines `XPCServiceProtocolCore` with similar functionality
- **SecurityInterfacesProtocols** defines `XPCServiceProtocolBase` with basic functionality
- **SecurityInterfacesBase** re-exports `XPCServiceProtocolBase` from SecurityInterfacesProtocols
- **SecurityInterfaces** includes `XPCServiceProtocol` and `XPCServiceProtocolBase`

#### 2. Bridge Implementation Duplication

Multiple modules implement bridge functionality between Foundation types and domain types:

- **SecurityBridge** contains comprehensive adapters (`DataAdapter`, `DateAdapter`, etc.)
- **SecurityInterfacesFoundation** contains similar conversion functions
- **UmbraSecurity/Extensions** contains extension methods for similar conversions

#### 3. Security Provider Protocol Hierarchy

The security provider protocol hierarchy is fragmented across several modules:

- **SecurityProtocolsCore** defines `SecurityProviderProtocol`
- **SecurityInterfacesProtocols** defines a similar `SecurityProviderProtocol`
- **SecurityInterfacesBase** defines `SecurityProviderBase`
- **SecurityInterfaces** defines additional security provider abstractions

#### 4. Error Type Duplication

Various error types related to security operations are defined in multiple places:

- **SecurityProtocolsCore** defines `SecurityError`
- **SecurityInterfacesProtocols** defines `SecurityProtocolError`
- **XPCProtocolsCore** defines `SecurityProtocolError`
- **UmbraCoreTypes/CoreErrors** includes common error definitions
- **CryptoTypes** defines `CryptoError` (now deprecated, use CoreErrors.CryptoError)
- **Core/Services** defines `CryptoError` (now deprecated, use CoreErrors.CryptoError)

### Consolidation Recommendations

Based on the above findings, the following specific consolidation steps are recommended:

#### 1. XPC Protocol Consolidation

1. **Immediate Actions:**
   - Migrate all XPC protocol definitions from SecurityInterfacesProtocols and SecurityInterfacesBase to XPCProtocolsCore
   - Update SecurityProtocolsCore to import XPCProtocolsCore instead of defining its own XPC protocols
   - Define clear protocol hierarchy within XPCProtocolsCore with documentation of each level's purpose

2. **Redundant Module Removal:**
   - Remove XPC-related protocols from SecurityInterfacesProtocols
   - Remove XPC-related re-exports from SecurityInterfacesBase
   - Remove XPC-related protocols from SecurityInterfaces where they duplicate XPCProtocolsCore

#### 2. Bridge Layer Consolidation

1. **Immediate Actions:**
   - Standardize on SecurityBridge as the primary bridge module
   - Migrate any unique functionality from SecurityInterfacesFoundation to SecurityBridge
   - Ensure all adapter implementations follow the same pattern as existing SecurityBridge adapters

2. **Redundant Module Removal:**
   - Deprecate and eventually remove SecurityInterfacesFoundation
   - Refactor UmbraSecurity/Extensions to use SecurityBridge adapters

#### 3. Security Provider Consolidation

1. **Immediate Actions:**
   - Standardize on SecurityProtocolsCore.SecurityProviderProtocol as the canonical definition
   - Update other modules to use this definition instead of duplicating it
   - Document the purpose and responsibility of each protocol in the hierarchy

2. **Redundant Module Removal:**
   - Remove SecurityProviderProtocol from SecurityInterfacesProtocols
   - Remove SecurityProviderBase from SecurityInterfacesBase if redundant

#### 4. Error Handling Standardization

1. **Immediate Actions:**
   - Centralize all security-related error definitions in UmbraCoreTypes/CoreErrors
   - Create mappings between different error types in SecurityBridge
   - Ensure all modules consistently use the centralized error types

### Updated Timeline

Based on the findings, the following updates to our existing timeline are recommended:

#### March 2025:
- Complete XPC protocol consolidation into XPCProtocolsCore (High Priority)
- Standardize bridge implementation in SecurityBridge (High Priority)
- Update error handling approach with centralized definitions (Medium Priority)

#### April 2025:
- Complete Security Provider protocol hierarchy consolidation (High Priority)
- Finish UmbraSecurityBridge implementation (Medium Priority)
- Begin deprecation of redundant modules (Medium Priority)

#### May 2025:
- Remove redundant modules following deprecation period (High Priority)
- Complete Core Services Types consolidation (Medium Priority)
- Address ObjC Bridging Types (Medium Priority)

#### June 2025:
- Complete CryptoSwift integration (Medium Priority)
- Final testing and validation of consolidated architecture (High Priority)
- Prepare umbracore-alpha for promotion to main branch (High Priority)

### Conclusion

The current module structure contains significant redundancy and overlap, particularly in the areas of XPC protocols, security providers, and bridge implementations. By following the consolidation recommendations outlined above, we can substantially reduce the number of modules while creating a clearer, more maintainable architecture.

The foundational work done so far with SecurityProtocolsCore, SecurityBridge, and XPCProtocolsCore provides a solid basis for this consolidation effort. The next phase should focus on standardizing on these modules and removing redundant implementations.

## Performance Considerations

The refactoring introduces several changes that may impact performance. This section analyzes these impacts and proposes mitigations.

### Type Conversion Overhead

The bridge layer introduces type conversion overhead when crossing module boundaries:

```swift
// Foundation type → Domain type → Foundation type conversion
let originalData: Data = getData()
let secureBytes = SecureBytes(originalData)  // Conversion 1
let processedData = process(secureBytes)
let resultData = processedData.asData()  // Conversion 2
```

**Mitigation Strategies**:
1. **Lazy Conversion**: Convert types only when necessary
2. **Bulk Operations**: Batch conversions where possible
3. **Compiler Optimizations**: Use whole-module optimization to potentially eliminate conversions
4. **Benchmarking**: Establish baseline performance metrics before and after refactoring

### Module Boundary Overhead

Additional module boundaries can affect performance:

**Mitigation Strategies**:
1. **Whole-Module Optimization**: Enable for production builds
2. **Strategic Inlining**: Mark key conversion functions as @inlinable
3. **Reduce Cross-Module Calls**: Design APIs to minimize boundary crossings

### Memory Usage

The refactoring may introduce additional memory usage due to type conversion:

**Mitigation Strategies**:
1. **Copy-on-Write Semantics**: Implement for large data structures
2. **Secure Memory Management**: Implement secure clearing for sensitive data
3. **Memory Profiling**: Monitor memory usage before and after changes

### Build Performance

The new architecture may impact build times:

**Mitigation Strategies**:
1. **Module Size Optimization**: Right-size modules for compile time
2. **Dependency Graph Optimization**: Minimize cross-module dependencies
3. **Parallel Compilation**: Ensure modules can be compiled in parallel

## Versioning and Compatibility

This section addresses how the refactoring impacts versioning and compatibility with dependent projects.

### Semantic Versioning

The refactoring constitutes a major version change:

```
UmbraCore 2.0.0 → UmbraCore 3.0.0
```

**Rationale**: The architectural changes break backward compatibility and require client code changes.

### Migration Path for Dependents

For projects depending on UmbraCore:

1. **Compatibility Layer**: Provide temporary adapters to ease migration
2. **Migration Guide**: Document required changes for dependent code
3. **Deprecation Period**: Support previous architecture for 6-12 months with deprecation warnings

### API Stability

Ensure API stability for the new architecture:

1. **API Documentation**: Thorough documentation of new interfaces
2. **Backward Compatibility Tests**: Validate against common usage patterns
3. **API Evolution**: Plan for future evolution without breaking changes

### Binary Compatibility

Address binary compatibility concerns:

1. **Module Stability**: Use @frozen for key types where appropriate
2. **ABI Stability**: Consider ABI implications for public interfaces
3. **Library Evolution**: Enable library evolution mode for framework targets

## Error Handling Strategy

A consistent error handling approach is essential for the new architecture. This section outlines the error management strategy.

### Domain-Specific Error Types

Create a hierarchy of error types without Foundation dependencies:

```swift
// Sources/UmbraCoreTypes/Errors.swift
// NO import Foundation!

public enum SecurityError: Error, Sendable {
    case encryptionFailed(reason: String)
    case decryptionFailed(reason: String)
    case keyGenerationFailed(reason: String)
    case invalidKey
    case dataCorrupted
}

public enum StorageError: Error, Sendable {
    case resourceNotFound(identifier: String)
    case accessDenied(reason: String)
    case storageFailure(reason: String)
}

public enum NetworkError: Error, Sendable {
    case connectionFailed(reason: String)
    case requestTimedOut(afterSeconds: Int)
    case invalidResponse(description: String)
}
```

### Error Translation in Bridge Layer

The bridge layer will translate between domain errors and Foundation/Cocoa errors:

```swift
// Sources/FoundationBridge/ErrorBridge.swift
import Foundation
import UmbraCoreTypes

public extension SecurityError {
    func asNSError() -> NSError {
        switch self {
        case .encryptionFailed(let reason):
            return NSError(domain: "UmbraSecurityErrorDomain", 
                           code: 1001, 
                           userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(reason)"])
        // Other cases...
        }
    }
    
    static func fromNSError(_ error: NSError) -> SecurityError? {
        if error.domain == "UmbraSecurityErrorDomain" {
            switch error.code {
            case 1001:
                return .encryptionFailed(reason: error.localizedDescription)
            // Other cases...
            default:
                return nil
            }
        }
        return nil
    }
}
```

### Error Propagation Across Module Boundaries

Guidelines for error propagation:

1. **Domain Errors in Core Modules**: Use only domain-specific error types
2. **Error Translation at Boundaries**: Convert between error types only at module boundaries
3. **Context Preservation**: Ensure error context is preserved during translation
4. **Async/Await Error Handling**: Leverage Swift's built-in error handling with try/catch

### Error Documentation and Recovery

For each error type:

1. **Document Causes**: Clearly document what can cause each error
2. **Recovery Strategies**: Provide recommended recovery strategies
3. **Error Codes**: Maintain consistent error codes across versions

### XPC Error Handling

Special considerations for XPC services:

1. **NSError Bridging**: Converting domain errors to NSError for Objective-C compatibility
2. **Error Serialization**: Ensuring errors can be properly serialized across XPC boundaries
3. **Consistent Error Domains**: Establishing consistent error domains for XPC services

## Alternatives to @objc for XPC Protocols

While @objc is currently required for XPC protocols, we've investigated alternatives and future possibilities:

### Current State

XPC services in macOS/iOS require NSXPCConnection and @objc protocols. This creates an inherent dependency on Foundation and Objective-C runtime.

### Potential Alternatives

1. **Swift-native XPC (Hypothetical)**
   - Not currently available but being discussed in the Swift community
   - Would allow pure Swift protocols without @objc requirements

2. **gRPC or Protocol Buffers**
   - Could be used for some inter-process communication needs
   - Provides strongly-typed interfaces without @objc
   - Not a direct replacement for XPC's security model

3. **Swift Distributed Actors**
   - Part of Swift's distributed actors proposal
   - Could potentially replace some XPC use cases in the future
   - Currently experimental

### Short-term Strategy

Until Swift-native XPC becomes available:

1. **Minimize @objc Surface Area**
   - Keep @objc protocols as thin as possible
   - Implement minimal interfaces at the boundary
   - Use Swift-native protocols for all internal communication

2. **Foundation-Free Protocol Definitions**
   - Define protocols without Foundation, then bridge to @objc implementations
   - Use type erasure to break dependency cycles

### Swift Evolution Watch

We'll monitor these Swift Evolution proposals:

- [SE-0302: Sendable and @Sendable closures](https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md)
- [SE-0336: Distributed Actor Runtime](https://github.com/apple/swift-evolution/blob/main/proposals/0336-distributed-actor-runtime.md)

As Swift evolves, we'll adapt our strategy to take advantage of new capabilities that reduce or eliminate the need for @objc in XPC communication.
