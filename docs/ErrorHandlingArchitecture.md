# UmbraCore Error Handling Architecture

## Design Goals

1. **Uniform Error Structure**: Establish a single source of truth for each error domain
2. **Clear Module Boundaries**: Each module has distinct responsibilities with well-defined interfaces
3. **Consistent Error Mapping**: Standardised approach to converting between error types
4. **Improved Maintainability**: Reduce duplication and ensure consistency

## Module Structure

### ErrorHandlingDomains

Primary responsibility: Define the core error namespace (`UmbraErrors`) containing domain-specific errors

```
UmbraErrors
│
├── Security
│   ├── Core           - Core security errors
│   ├── Protocols      - Protocol-level security errors
│   └── XPC            - XPC-specific security errors
│
├── Application
│   ├── Core           - Core application errors
│   ├── UI             - User interface errors
│   └── Lifecycle      - Application lifecycle errors
│
├── Network
│   ├── HTTP           - HTTP-specific errors
│   └── Socket         - Socket-level errors
│
└── Storage
    ├── Database       - Database-related errors
    └── FileSystem     - File system errors
```

### ErrorHandlingTypes

Primary responsibility: Provide consolidated error types for external consumption

```
ErrorHandlingTypes
│
├── SecurityError      - Consolidated security errors
├── ApplicationError   - Consolidated application errors
├── NetworkError       - Consolidated network errors
└── StorageError       - Consolidated storage errors
```

### ErrorHandlingInterfaces

Primary responsibility: Define the protocols for error mapping and handling

```
ErrorHandlingInterfaces
│
├── ErrorMapper            - Basic error mapping protocol
├── BidirectionalMapper    - Two-way mapping protocol
└── ErrorHandlingProtocol  - Error handling strategy protocol
```

### ErrorHandlingMapping

Primary responsibility: Implement concrete error mappers between domains and types

```
ErrorHandlingMapping
│
├── SecurityErrorMapper    - Maps security domain errors
├── ApplicationErrorMapper - Maps application domain errors
├── NetworkErrorMapper     - Maps network domain errors
├── StorageErrorMapper     - Maps storage domain errors
└── UmbraErrorMapper       - Central mapper for all domains
```

## Key Interfaces

### ErrorMapper Protocol

```swift
/// A protocol for defining a one-way mapping between error types
public protocol ErrorMapper<SourceType, TargetType> {
  /// The source error type
  associatedtype SourceType: Error

  /// The target error type
  associatedtype TargetType: Error

  /// Maps from the source error type to the target error type
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  func mapError(_ error: SourceType) -> TargetType
}
```

### BidirectionalErrorMapper Protocol

```swift
/// A protocol for defining a bidirectional mapping between error types
public protocol BidirectionalErrorMapper<ErrorTypeA, ErrorTypeB>: ErrorMapper {
  /// The first error type
  associatedtype ErrorTypeA: Error

  /// The second error type
  associatedtype ErrorTypeB: Error

  /// Maps from ErrorTypeA to ErrorTypeB
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  func mapAtoB(_ error: ErrorTypeA) -> ErrorTypeB

  /// Maps from ErrorTypeB to ErrorTypeA
  /// - Parameter error: The source error
  /// - Returns: The mapped target error
  func mapBtoA(_ error: ErrorTypeB) -> ErrorTypeA
}
```

## Implementation Strategy

1. **Refine Domain Errors**:
   - Ensure all domain errors have consistent naming patterns
   - Complete documentation for all error cases

2. **Standardise Consolidated Types**:
   - Make Types use the Domains as the canonical source
   - Maintain compatibility while improving internal structure

3. **Update Error Mappers**:
   - Implement proper protocol conformance
   - Fix ambiguous references with full qualification

4. **Dependency Management**:
   - Ensure BUILD files reflect the proper dependency graph
   - Types depend on Domains, not vice versa
