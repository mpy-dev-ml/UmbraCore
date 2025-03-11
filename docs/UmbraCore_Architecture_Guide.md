# UmbraCore Architecture Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Architectural Principles](#architectural-principles)
3. [Module Structure](#module-structure)
4. [Foundation-Free Architecture](#foundation-free-architecture)
5. [Namespace Resolution](#namespace-resolution)
6. [Error Handling Strategy](#error-handling-strategy)
7. [Build System](#build-system)
8. [Cross-Platform Support](#cross-platform-support)
9. [Testing Strategy](#testing-strategy)
10. [Appendix: Common Patterns](#appendix-common-patterns)

## Introduction

UmbraCore is a modular Swift framework designed to provide secure, cross-platform functionality with a focus on maintainability, type safety, and clear API boundaries. This document consolidates the architectural principles, patterns, and guidelines established across multiple implementation guides into a single, comprehensive reference.

## Architectural Principles

### Core Design Goals

1. **Modular Architecture**: Clear separation of concerns with well-defined interfaces
2. **Foundation Independence**: Core modules remain Foundation-free to support cross-platform usage
3. **Type Safety**: Leverage Swift's type system to catch errors at compile time
4. **Clear API Boundaries**: Explicit interfaces between modules with controlled visibility
5. **Testability**: Design for comprehensive testing at all levels

### Architectural Constraints

1. **Cross-Platform Compatibility**: Core functionality must work on all supported platforms
2. **Security as a First-Class Concern**: Security protocols and implementations follow rigorous separation
3. **Minimal Dependencies**: External dependencies limited to essential functionality

## Module Structure

UmbraCore follows a layered architecture with clear separation between:

### Core Layers

1. **Interfaces Layer**: Protocol definitions without implementation details
   - Foundation-free APIs
   - Type definitions
   - Minimal dependencies

2. **Implementation Layer**: Concrete implementations of interfaces
   - May be platform-specific
   - Contains business logic
   - May depend on specific frameworks

3. **Adapters Layer**: Bridges between different module implementations
   - Handles type conversion
   - Maps between error domains
   - Provides compatibility between different module versions

### Key Module Categories

1. **Core Types**: Base types used throughout the system
   - `UmbraCoreTypes`: Foundation-free type definitions
   - `CoreTypesInterfaces`: Interface definitions for core types

2. **Security Modules**:
   - `SecurityInterfaces`: Foundation-free security protocol definitions
   - `SecurityProtocolsCore`: Core security protocol implementations
   - `SecurityBridgeProtocolAdapters`: Connects security providers to Foundation-free interfaces

3. **Service Modules**:
   - `CoreServices`: Foundation-dependent service implementations
   - `CoreServicesTypes`: Foundation-free service type definitions

4. **Error Handling**:
   - `ErrorHandling`: Central error definition and handling
   - `ErrorHandlingDomains`: Domain-specific error types

## Foundation-Free Architecture

The Foundation-free architecture is a core design principle that enables cross-platform compatibility and clear separation of concerns.

### Principles

1. **Interface/Implementation Separation**:
   - Interfaces (protocols, type definitions) remain Foundation-free
   - Implementations may use Foundation when necessary

2. **Type Isolation**:
   - Core types defined without Foundation dependencies
   - Bridge types provided for conversion when necessary

3. **Error Domain Isolation**:
   - Error types defined without Foundation dependencies
   - Error mapping functions provided for cross-domain conversion

### Implementation Strategy

1. **Foundation-Free Interfaces**:
   - Use Swift's native types (`UInt8`, arrays, etc.) instead of Foundation types
   - Define protocols without Foundation dependencies
   - Isolate Foundation-dependent code in dedicated modules

2. **Platform-Specific Implementations**:
   - Implement interfaces with platform-specific code when necessary
   - Use conditional compilation for platform differences
   - Provide adapter layers for Foundation-dependent implementations

3. **Type Conversion**:
   - Provide explicit conversion between Foundation and non-Foundation types
   - Use extension methods for seamless conversion
   - Document conversion paths clearly

## Namespace Resolution

Swift's namespace handling presents unique challenges when working with modules with similar type names. UmbraCore employs specific patterns to resolve these conflicts.

### Namespace Conflict Patterns

1. **Module Name vs. Type Name Conflicts**:
   - Example: `SecurityProtocolsCore` module containing a `SecurityProtocolsCore` enum
   - Resolution: Use explicit module qualification for references

2. **Similar Type Names Across Modules**:
   - Example: Multiple modules defining `SecurityError` types
   - Resolution: Use type aliases with consistent prefixes

### Resolution Techniques

1. **Enhanced Isolation Pattern**:
   - Create dedicated files that only import one conflicting module at a time
   - Use subpackages with distinct module names for complete isolation
   - Add private type aliases to clarify which type is being used

2. **Type Qualification**:
   - Use fully qualified names (`ModuleName.TypeName`)
   - Add consistent type aliases with prefixes (e.g., `SPCProvider`)
   - Document expected type paths in comments

3. **Subpackage Approach**:
   - Main module depends on isolated subpackage
   - Subpackage handles all direct interactions with potentially conflicting module
   - Public re-exports provide a clean API

4. **Build System Configuration**:
   - Use `-enable-implicit-module-import-name-qualification` when available
   - Document module import constraints

## Error Handling Strategy

UmbraCore employs a structured approach to error handling, focusing on clarity, domain separation, and type safety.

### Error Hierarchy

1. **Root Error Namespace**: `UmbraErrors`
   - Domain-specific subnamespaces (e.g., `UmbraErrors.Security`)
   - Feature-specific error types (e.g., `UmbraErrors.Security.Protocols`)

2. **Error Categories**:
   - Interface errors: Defined in interface modules, Foundation-free
   - Implementation errors: May include platform-specific details
   - Cross-cutting errors: Defined in central error module

### Error Mapping

1. **Cross-Module Error Conversion**:
   - Explicit mapping functions between error domains
   - Consistent error property mapping
   - Preservation of error context

2. **Error Propagation**:
   - Define clear error boundaries
   - Document expected error types in function signatures
   - Use Swift's `throws` consistently

## Build System

UmbraCore uses Bazel as its build system, with specific configurations to ensure consistent builds across environments.

### Build Configuration

1. **Standard Targets**:
   - Library targets with clear dependencies
   - Test targets for each module
   - Conditional compilation for platform-specific code

2. **Build Flags**:
   - Foundation-free compilation flags
   - Library evolution support where needed
   - Conditional dependencies based on target platform

3. **Dependency Management**:
   - External dependencies defined in WORKSPACE
   - Version pinning for reproducible builds
   - Conditional inclusion of platform-specific dependencies

### Cross-Module Compatibility

1. **Library Evolution**:
   - Enable library evolution for stable APIs
   - Conditional compilation for non-compliant dependencies (e.g., CryptoSwift)
   - Document evolution constraints

2. **Module Structure**:
   - Consistent naming pattern for modules
   - Clear dependency graph
   - Minimal cyclic dependencies

## Cross-Platform Support

UmbraCore supports multiple platforms through careful API design and conditional implementation.

### Platform Abstraction

1. **Platform-Agnostic Interfaces**:
   - Foundation-free API definitions
   - Platform capability detection
   - Feature availability flags

2. **Platform-Specific Implementations**:
   - Dedicated implementation modules for each platform
   - Common patterns across platforms
   - Clear separation of platform-specific code

### Conditional Compilation

1. **Feature Flags**:
   - `USE_FOUNDATION_CRYPTO` for cryptographic implementations
   - Platform-specific compilation flags

2. **Implementation Selection**:
   - Runtime feature detection where possible
   - Compile-time platform selection
   - Dependency injection for platform-specific components

## Testing Strategy

UmbraCore employs a comprehensive testing strategy to ensure quality and maintainability.

### Test Categories

1. **Unit Tests**:
   - Module-level functionality testing
   - Mock dependencies for isolation
   - High coverage targets for core modules

2. **Integration Tests**:
   - Cross-module interaction testing
   - Focused on API boundaries
   - Validation of error propagation

3. **Cross-Platform Tests**:
   - Validation of platform-agnostic behaviour
   - Platform-specific feature testing
   - Compatibility verification

### Testing Patterns

1. **Mock Objects**:
   - Protocol-based mock implementations
   - Testable injection points
   - Consistent approach to verification

2. **Test Helpers**:
   - Shared test utilities
   - Test data generators
   - Error validation helpers

## Appendix: Common Patterns

### Type Conversion Patterns

1. **SecureBytes Conversion**:
   ```swift
   // Converting SecureBytes to raw bytes
   let rawBytes = Array(secureBytes)
   
   // Converting raw bytes to SecureBytes
   let secureBytes = SecureBytes(bytes: rawBytes)
   ```

2. **Error Domain Conversion**:
   ```swift
   // Converting from one error domain to another
   func convert(_ error: SecurityProtocolsCore.SecurityError) -> CoreErrors.SecurityError {
       switch error {
       case .encryptionFailed(let reason):
           return .encryptionFailed(reason: reason)
       // Other cases...
       }
   }
   ```

### Namespace Resolution Patterns

1. **Type Alias Approach**:
   ```swift
   // In a file that needs both types
   import SecurityProtocolsCore
   import CoreErrors
   
   // Create clear aliases
   typealias SPCSecurityError = SecurityProtocolsCore.SecurityError
   typealias CESecurityError = CoreErrors.SecurityError
   ```

2. **Module Isolation**:
   ```swift
   // SecurityInterfaces_SecurityProtocolsCore.swift
   import SecurityProtocolsCore
   
   // Export types with clear naming
   public typealias SPCProvider = SecurityProtocolsCore.SecurityProviderProtocol
   
   // Main module only imports the isolation layer
   ```

### Conditional Implementation

1. **Platform-Specific Code**:
   ```swift
   #if USE_FOUNDATION_CRYPTO
   import Foundation
   // Foundation-based implementation
   #else
   import CryptoSwift
   // CryptoSwift-based implementation
   #endif
   ```

2. **Feature Detection**:
   ```swift
   func createHasher() -> any Hasher {
       #if canImport(CryptoKit) && !DISABLE_CRYPTOKIT
       return CryptoKitHasher()
       #else
       return StandardHasher()
       #endif
   }
   ```
