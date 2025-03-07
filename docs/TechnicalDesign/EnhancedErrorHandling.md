# UmbraCore Enhanced Error Handling - Technical Design Document

**Date:** 7 March 2025  
**Status:** Draft  
**Author:** UmbraCore Team  

## 1. Introduction

This document outlines the technical design for enhancing the error handling system in UmbraCore. The current approach has several limitations that can be addressed through a more unified and robust architecture. This design proposes a new error hierarchy, type-safe mapping, and improved context preservation to create a more maintainable and developer-friendly error handling system.

## 2. Goals and Non-Goals

### Goals

- Create a unified error type hierarchy across the codebase
- Implement type-safe error mapping between domains
- Enhance error context with source information and cause chains
- Provide a centralized error management system
- Improve developer experience with better error diagnostics

### Non-Goals

- Maintaining backward compatibility with existing error handling
- Modifying external API contracts for error reporting
- Redesigning the Swift standard error handling approach

## 3. Table of Contents

1. Introduction
2. Goals and Non-Goals
3. Table of Contents
4. Current Architecture
5. Proposed Architecture
6. Implementation Plan
7. Migration Strategy
8. Testing Strategy
9. References

## 4. Current Architecture

The current error handling architecture in UmbraCore has evolved organically and presents several challenges:

### 4.1 Dual Module Structure

UmbraCore currently handles errors through two separate modules:

- **CoreErrors** (`/Sources/CoreErrors/`): Contains basic error type definitions
- **UmbraCoreTypes/CoreErrors** (`/Sources/UmbraCoreTypes/CoreErrors/`): Provides error mapping functionality

This dual structure creates potential namespace conflicts and makes it difficult to maintain a coherent error handling strategy.

### 4.2 Inconsistent Error Implementations

Error types across the codebase exhibit inconsistent implementation patterns:

- **Simple Enumerations**: Some errors like `CoreErrors.RepositoryError` are implemented as basic enumerations without associated values or additional conformances.
- **Rich Implementations**: Others like `Repositories.RepositoryError` provide comprehensive implementations with associated values, localization support, and `Codable` conformance.

This inconsistency makes error handling unpredictable and requires developers to understand multiple patterns.

### 4.3 String-Based Error Mapping

The current error mapping system:

- Relies on `String(describing:)` for type identification
- Uses string parsing to map between error domains
- Lacks compile-time safety for error mapping operations

This approach is brittle and error-prone, particularly when types are renamed or restructured.

### 4.4 Limited Error Context

Errors currently provide limited context:

- No standardised source information (file, function, line)
- No consistent mechanism for preserving error chains
- Unstructured, text-based debug information

This makes debugging more challenging and limits the utility of error information for diagnosis.

### 4.5 Distributed Error Management

Error management is distributed across the codebase:

- No central registry for error types and domains
- Inconsistent error creation and transformation patterns
- Duplicated error handling logic in multiple places

This fragmentation makes it difficult to maintain and evolve the error handling system.

## 5. Proposed Architecture

The proposed architecture addresses the limitations of the current system by introducing a unified, type-safe, and context-rich error handling framework.

### 5.1 Unified Error Type Hierarchy

We propose a consolidated error type hierarchy with the following structure:

#### 5.1.1 Core Protocols

```swift
/// Base protocol for all UmbraCore errors
public protocol UmbraError: Error, Sendable, Equatable, CustomStringConvertible {
    /// A unique identifier for the error type
    var errorDomain: String { get }
    
    /// A code identifying the specific error
    var errorCode: Int { get }
    
    /// Human-readable description of the error
    var errorDescription: String { get }
    
    /// Optional underlying cause of this error
    var underlyingError: Error? { get }
    
    /// Source information where the error was created
    var source: ErrorSource { get }
}

/// Represents the source of an error
public struct ErrorSource: Sendable, Equatable {
    let file: StaticString
    let function: StaticString
    let line: UInt
    let module: String
}
```

#### 5.1.2 Base Implementations

```swift
/// Common base for all UmbraCore error implementations
public struct ErrorContext: Sendable, Equatable {
    public let source: ErrorSource
    public let underlyingError: Error?
    public let additionalInfo: [String: Any]?
    
    public init(
        source: ErrorSource,
        underlyingError: Error? = nil,
        additionalInfo: [String: Any]? = nil
    ) {
        self.source = source
        self.underlyingError = underlyingError
        self.additionalInfo = additionalInfo
    }
}

/// Base implementation for domain-specific error enums
public protocol DomainError: UmbraError {
    var context: ErrorContext { get }
}

/// Default implementation for domain errors
extension DomainError {
    public var underlyingError: Error? { context.underlyingError }
    public var source: ErrorSource { context.source }
}
```

### 5.2 Type-Safe Error Mapping

The new error mapping system will use generics and explicit type conversions:

```swift
public protocol ErrorMapper {
    associatedtype SourceError: UmbraError
    associatedtype TargetError: UmbraError
    
    func map(_ error: SourceError) -> TargetError
}

public struct AnyErrorMapper<Source: UmbraError, Target: UmbraError>: ErrorMapper {
    private let _map: (Source) -> Target
    
    public init(_ mapper: (Source) -> Target) {
        self._map = mapper
    }
    
    public func map(_ error: Source) -> Target {
        _map(error)
    }
}
```

### 5.3 Error Context Enhancement

Errors will carry rich contextual information:

```swift
/// Creates an error with source information automatically included
public func makeError<T: DomainError>(
    _ error: T,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    cause: Error? = nil,
    info: [String: Any]? = nil
) -> T {
    // Create error with embedded source information
    // ...
}
```

### 5.4 Centralised Error Management

A central error registry will manage error types and transformations:

```swift
/// Central registry for error domains and mappers
public final class ErrorRegistry {
    public static let shared = ErrorRegistry()
    
    private var mappers: [String: Any] = [:]
    
    /// Register a mapper between error domains
    public func register<S, T>(
        mapper: AnyErrorMapper<S, T>
    ) where S: UmbraError, T: UmbraError {
        let key = "\(S.self)->\(T.self)"
        mappers[key] = mapper
    }
    
    /// Transform an error to a different domain
    public func transform<S, T>(_ error: S) -> T? where S: UmbraError, T: UmbraError {
        let key = "\(S.self)->\(T.self)"
        guard let mapper = mappers[key] as? AnyErrorMapper<S, T> else {
            return nil
        }
        return mapper.map(error)
    }
}

## 6. Implementation Plan

The implementation of the enhanced error handling system will be carried out in several phases to ensure a smooth transition and maintain code stability.

### 6.1 Core Framework Implementation

#### 6.1.1 Create Base Module Structure

1. Create a new Swift package `UmbraErrors` to contain the core error handling framework
2. Implement the base protocols (`UmbraError`, `DomainError`)
3. Implement supporting types (`ErrorSource`, `ErrorContext`)
4. Implement error factory functions (`makeError`)

#### 6.1.2 Implement Error Mapping System

1. Implement the `ErrorMapper` protocol
2. Create the type-erased `AnyErrorMapper` implementation
3. Implement the `ErrorRegistry` for centralised mapping
4. Add convenience extensions for error transformation

#### 6.1.3 Implement Error Logging and Reporting

1. Create an `ErrorReporter` protocol for logging errors
2. Implement a default reporter that integrates with the UmbraCore logging system
3. Add convenience methods for error reporting with contextual information

### 6.2 SecurityError Refactoring (Proof of Concept)

As a proof of concept, we will refactor the `SecurityError` type to use the new architecture:

1. Create a new `SecurityErrorDomain` that conforms to `DomainError`
2. Implement all existing error cases with enhanced context
3. Create bidirectional mappers with existing `SecurityError` types
4. Update client code to use the new error types
5. Implement comprehensive tests to verify correctness

### 6.3 Error Reporting Integration

1. Integrate with the existing logging system
2. Add diagnostic reporting capabilities
3. Implement error chain visualisation for debugging
4. Create developer tools for error inspection

### 6.4 Documentation and Examples

1. Create comprehensive API documentation
2. Implement example code for common error handling patterns
3. Create a migration guide for existing error types
4. Document best practices for error handling

## 7. Migration Strategy

The migration to the new error handling system will be phased to minimise disruption while ensuring a smooth transition. This section outlines the systematic approach to migrating existing error types.

### 7.1 Existing Error Type Inventory

First, we'll conduct a comprehensive inventory of all existing error types in the codebase:

1. Identify all error types across all modules
2. Catalogue their current implementation patterns
3. Map relationships and dependencies between error types
4. Identify usage patterns and integration points

This inventory will help prioritise migration efforts and identify potential challenges.

### 7.2 Module Consolidation

A key part of the migration strategy is consolidating error handling into a more cohesive structure:

1. Merge the duplicate CoreErrors implementations
2. Centralise error mapping functionality in the new UmbraErrors module
3. Resolve namespace conflicts between security modules with explicit type resolution
4. Eliminate redundant error type definitions

This consolidation will address the current namespace ambiguity issues that exist between SecurityProtocolsCore and XPCProtocolsCore modules.

### 7.3 Phased Migration Approach

The migration will occur in the following phases:

#### Phase 1: Foundation Layer

1. Implement the core UmbraErrors module
2. Create adapter layer for existing errors
3. Add logging and diagnostic capabilities
4. Deploy comprehensive tests

#### Phase 2: Core Domain Errors

1. Migrate primary domain errors (SecurityError, ResourceError)
2. Update their implementations to use the new architecture
3. Create bidirectional mappers with existing types
4. Verify full compatibility with existing code

#### Phase 3: Secondary Domain Errors

1. Migrate remaining domain-specific errors
2. Implement domain-specific error reporting
3. Update all client code to use new APIs
4. Validate with comprehensive tests

#### Phase 4: Legacy Support Removal

Once all code has been migrated to the new system:

1. Deprecate old error types and mapping functions
2. Create documentation for any remaining legacy code
3. Remove obsolete components after an appropriate transition period

### 7.4 Addressing Namespace Resolution

Special attention will be paid to addressing the namespace resolution issues with SecurityError types:

1. Ensure clear type resolution paths for all error types
2. Avoid creating enums with the same name as their modules
3. Use proper type aliasing to avoid ambiguity
4. Create explicit import patterns for modules with similar type names

### 7.5 Risk Mitigation

Potential migration risks and their mitigations:

| Risk | Mitigation |
|------|------------|
| Breaking existing error handling | Implement bidirectional mappers before migration |
| Performance degradation | Benchmark new implementation against existing system |
| Development delays | Implement in phases with interim deliverables |
| Partial adoption | Create comprehensive documentation and examples |
| Security impacts | Validate error handling in security-critical paths |

## 8. Testing Strategy

A comprehensive testing strategy is critical to ensure the new error handling system is robust, reliable, and performs as expected. This section outlines the testing approach.

### 8.1 Unit Testing

Comprehensive unit tests will be implemented at multiple levels:

1. **Core Protocol Tests**
   - Test conformance to UmbraError protocol
   - Verify ErrorContext functionality
   - Test error source tracking and reporting

2. **Mapping Tests**
   - Test bidirectional mapping between error domains
   - Verify error context preservation during mapping
   - Test edge cases and error transformation chains

3. **Factory Function Tests**
   - Test error creation with source attribution
   - Verify error cause chains are correctly established
   - Test additional context information preservation

4. **Registry Tests**
   - Test error mapper registration
   - Verify correct mapper lookup and execution
   - Test error transformation between domains

### 8.2 Integration Testing

Integration tests will verify how error handling works across module boundaries:

1. **Cross-Module Error Propagation**
   - Test error transformation across multiple modules
   - Verify error context is preserved end-to-end
   - Test error reporting and logging integration

2. **API Boundary Tests**
   - Test error handling at public API boundaries
   - Verify error translation for external consumers
   - Test error serialisation and deserialisation

3. **Security Module Tests**
   - Test SecurityError mapping in security-critical paths
   - Verify error handling in encryption/decryption operations
   - Test error propagation in XPC service communications

### 8.3 Performance Testing

Performance testing will ensure the new system doesn't introduce unacceptable overhead:

1. **Benchmarks**
   - Measure error creation performance
   - Benchmark error mapping operations
   - Compare memory usage to existing implementation

2. **Overhead Analysis**
   - Analyse impact of added context on error objects
   - Measure error chain traversal performance
   - Test error reporting performance under load

### 8.4 Namespace Resolution Testing

Specific tests will target the namespace resolution issues identified in previous work:

1. **Type Resolution Tests**
   - Test explicit module qualification for error types
   - Verify correct resolution of similarly named types
   - Test import patterns for modules with name conflicts

2. **Ambiguity Tests**
   - Create test cases with potential namespace ambiguity
   - Verify compiler errors are correctly addressed
   - Test migration patterns for ambiguous code

### 8.5 Test Coverage Goals

The testing plan establishes the following coverage targets:

| Component | Line Coverage | Branch Coverage | Mutation Score |
|-----------|--------------|-----------------|----------------|
| Core Protocols | 100% | 95% | 90% |
| Error Mapping | 100% | 95% | 90% |
| Factory Functions | 100% | 90% | 85% |
| Error Registry | 95% | 90% | 85% |
| SecurityError Implementation | 100% | 95% | 90% |

### 8.6 Continuous Integration

Tests will be integrated into the UmbraCore CI/CD pipeline:

1. Run all tests on every pull request
2. Enforce coverage requirements for new code
3. Add performance regression testing to prevent slowdowns
4. Implement static analysis to catch error handling anti-patterns

## 9. References

### 9.1 Internal References

1. UmbraCore_Refactoring_Plan.md - Contains overall architectural guidance for UmbraCore modules
2. UmbraCore Security Module Type References - Analyses namespace conflicts in security modules
3. XPC_PROTOCOLS_MIGRATION_GUIDE.md - Provides context for XPC protocol migration work
4. SecurityInterfaces documentation - Defines interface contracts and error handling requirements
5. UmbraCore Build Documentation - Contains build system and module organisation guidelines

### 9.2 Swift Language References

1. [Swift Error Handling Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/)
2. [Swift Evolution - Result Type](https://github.com/apple/swift-evolution/blob/master/proposals/0235-add-result.md)
3. [Swift Evolution - Throwing Properties](https://github.com/apple/swift-evolution/blob/master/proposals/0320-throwing-properties.md) 
4. [Swift Evolution - Structured Concurrency](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md)

### 9.3 Best Practices References

1. [Swift Style Guide](https://google.github.io/swift/) - Error handling conventions
2. [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) - For designing error APIs
3. [Swift Error Handling Best Practices](https://www.swiftbysundell.com/articles/error-handling-in-swift/) - External article on error handling patterns
4. [Result Builders in Swift](https://www.swiftbysundell.com/articles/result-builders-in-swift/) - For advanced error composition

### 9.4 Related Work

1. [Swift Error Handling Evolution](https://forums.swift.org/t/concurrency-structured-error-handling/41972) - Ongoing discussions about error handling
2. [Swift Result Builders for Errors](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md) - For potential future work
3. [Swift Logging System](https://github.com/apple/swift-log) - For error reporting integration
4. [Swift Type-Safe Path](https://github.com/apple/swift-evolution/blob/main/proposals/0329-codeitem-declaration-references.md) - For referencing source locations
