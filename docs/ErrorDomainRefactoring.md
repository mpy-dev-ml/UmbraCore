# UmbraCore Error Domain Architecture Refactoring

## Problem Statement

UmbraCore currently suffers from error type ambiguity across multiple modules, resulting in compiler errors and developer confusion. Specific issues include:

1. Multiple modules define their own `SecurityError` enums with similar purposes but different case structures
2. Module-level enums share names with their containing modules (e.g., `enum SecurityProtocolsCore` inside the SecurityProtocolsCore module)
3. No clear hierarchical organisation of error types across the system
4. Compiler struggles to resolve ambiguous type references

## Proposed Solution: Centralised Error Domain Architecture

We propose a clean-break approach to establish a single source of truth for all error types in UmbraCore.

### Core Principles

1. **Single Source of Truth**: One module defines all error domains
2. **Hierarchical Organisation**: Clear parent-child relationships between error domains
3. **Explicit Qualification**: No ambiguous type names
4. **No Transitional Compatibility**: Clean break from previous approach

## Architecture Overview

### 1. New Module: `UmbraErrorDomains`

A dedicated module will house all error types in a hierarchical structure:

```
UmbraErrors (root namespace)
├── Security
│   ├── Core
│   ├── XPC
│   └── Protocol
├── Storage
├── Network
└── ... (other domains)
```

### 2. Error Domain Structure

Each error domain will be organised as an enum hierarchy:

```swift
public enum UmbraErrors {
    public enum Security {
        public enum Core: Error, Sendable, Equatable { 
            // Core security errors
        }
        
        public enum XPC: Error, Sendable, Equatable { 
            // XPC-specific security errors
        }
        
        public enum Protocol: Error, Sendable, Equatable { 
            // Protocol-related security errors
        }
    }
    
    public enum Storage { /* ... */ }
    // Other domains
}
```

### 3. Error Type Cases

For each error domain, cases will be designed to:
- Capture all existing error scenarios
- Provide appropriate associated values for context
- Support rich error handling

Example:

```swift
// Core security errors
public enum Core: Error, Sendable, Equatable {
    case encryptionFailed(reason: String)
    case decryptionFailed(reason: String)
    case keyGenerationFailed(reason: String)
    case invalidKey(reason: String)
    // Additional cases...
}
```

### 4. Module Version Information

Replace module-named enums with a dedicated structure:

```swift
public enum ModuleInfo {
    public static let name = "ModuleName"
    public static let version = "1.0.0"
    public static let buildDate = "2025-03-08"
}
```

### 5. Error Mapping Utilities

Each module will provide extension methods for mapping between related error domains:

```swift
public extension UmbraErrors.Security.Core {
    static func from(xpcError: UmbraErrors.Security.XPC) -> Self {
        // Mapping implementation
    }
}
```

## Migration Strategy

### 1. Initial Implementation

- Create the `UmbraErrorDomains` module
- Define the complete error hierarchy
- Implement basic error mapping utilities

### 2. Coordinated Refactoring

- Remove all module-specific error types
- Update all references to use the new error domains
- Fix any compilation issues

### 3. Testing and Validation

- Ensure comprehensive test coverage for error handling
- Verify correct error propagation across module boundaries
- Confirm that error mapping preserves context

## Backward Compatibility

This is a clean-break approach with no backward compatibility provisions. All code must be updated to use the new error domain structure in a single coordinated change.

## Documentation and Usage Guidelines

### Error Type Selection

- Use the most specific error domain for the current context
- Map to broader domains when crossing module boundaries
- Include contextual information in associated values

### Error Handling Patterns

```swift
do {
    try someOperation()
} catch let error as UmbraErrors.Security.Core {
    // Handle core security error
} catch let error as UmbraErrors.Security.XPC {
    // Handle XPC security error
} catch {
    // Handle other errors
}
```

## Implementation Timeline

1. Design approval and refinement (1 week)
2. Initial implementation of `UmbraErrorDomains` (1 week)
3. Coordinated refactoring across all modules (2 weeks)
4. Testing and validation (1 week)
5. Documentation updates (1 week)

## Next Steps

1. Review this design document with the team
2. Implement a proof-of-concept branch
3. Develop a detailed refactoring plan
