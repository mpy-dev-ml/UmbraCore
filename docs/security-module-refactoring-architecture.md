# UmbraCore Security Module Refactoring Architecture

## Executive Summary

This document outlines the architecture for refactoring the UmbraCore security modules based on the UmbraCore Refactoring Plan and Security Module Migration. The goal is to consolidate redundant modules, break circular dependencies, and establish a clean architecture with clear separation between Foundation-dependent and Foundation-free components.

## Current Module Analysis

### Module Fragmentation Issues

The security components are currently fragmented across multiple modules:

| Module Category | Current Modules | Issues |
|-----------------|----------------|---------|
| Protocol Definitions | SecurityInterfaces, SecurityInterfacesBase, SecurityInterfacesProtocols, SecurityProtocolsCore | Duplicate protocols, unclear ownership, circular dependencies |
| Foundation Bridges | SecurityInterfacesFoundation, SecurityInterfacesFoundationBridge, SecurityProviderBridge | Overlapping responsibilities, ambiguous type references |
| Implementations | UmbraSecurity, SecurityImplementation | Mixed concerns, direct Foundation dependencies |
| Supporting Types | SecurityTypes, SecureBytes, CryptoTypes | Inconsistent usage, multiple versions of similar types |

### Key Circular Dependencies

1. `SecurityInterfaces` ↔ `SecurityInterfacesFoundation`
2. `SecurityBridge` ↔ `SecurityInterfacesFoundationBridge`
3. `UmbraSecurity` ↔ `SecurityImplementation`

## Target Architecture

We will consolidate the modules into a clean, layered architecture:

### 1. Core Foundation-Free Layer

**Primary Module: `SecurityProtocolsCore`**

- Contains only foundation-free protocols and types
- Uses `SecureBytes` for binary data representation
- No direct or indirect Foundation dependencies
- Core protocols:
  - `SecurityProviderProtocol`
  - `CryptoServiceProtocol`
  - `KeyManagementProtocol`
- Core types:
  - `SecurityError`
  - `SecurityOperation`
  - `SecurityConfigDTO`
  - `SecurityResultDTO`

### 2. Foundation Bridge Layer

**Primary Module: `SecurityBridge`**

- Single point of integration between Foundation and foundation-free types
- Contains adapters and type converters
- Depends on `SecurityProtocolsCore` and Foundation
- Key components:
  - `DataAdapter`: Converts between `Data` and `SecureBytes`
  - `URLAdapter`: Converts between `URL` and `ResourceLocator`
  - `FoundationSecurityProvider`: Foundation-specific security provider
  - Protocol adapters for all core protocols

### 3. Implementation Layer

**Primary Module: `SecurityImplementation`**

- Concrete implementations of security protocols
- May have Foundation dependencies (through `SecurityBridge`)
- Contains service implementations and factories
- Example components:
  - `DefaultSecurityProvider`
  - `CryptoServiceImpl`
  - `KeyManagementImpl`

**Primary Module: `UmbraSecurity`**

- High-level security service used by client code
- Orchestrates security operations
- Handles security-scoped bookmarks
- Key components:
  - `SecurityService`
  - `BookmarkService`

### 4. Binary Data Foundation

**Primary Module: `SecureBytes`**

- Core binary data representation
- Zero Foundation dependencies
- Fully Sendable for Swift concurrency
- Memory-secure implementations
- Used by all foundation-free modules

## Module Dependency Diagram

```
┌─────────────────┐      ┌───────────────┐
│   Client Code   │─────►│ UmbraSecurity │
└─────────────────┘      └───────┬───────┘
                                 │
                                 ▼
┌─────────────────┐      ┌───────────────┐
│   SecureBytes   │◄─────┤SecurityBridge │
└─────────────────┘      └───────┬───────┘
         ▲                       │
         │                       ▼
         │               ┌───────────────┐
         └───────────────┤SecurityProtocolsCore│
                         └───────────────┘
```

## Type Mapping Strategy

| Domain Concept | Foundation-Free Type | Foundation Type | Bridge Function |
|----------------|---------------------|----------------|----------------|
| Binary Data | `SecureBytes` | `Data` | `DataAdapter.toSecureBytes(data)` |
| Resource Location | `ResourceLocator` | `URL` | `URLAdapter.toResourceLocator(url)` |
| Error | `SecurityError` | `NSError` | `ErrorAdapter.toSecurityError(error)` |
| Configuration | `SecurityConfigDTO` | `SecurityConfiguration` | `ConfigAdapter.toDTO(config)` |

## Module Consolidation Plan

### Phase 1: Establish Foundation-Free Core

1. Audit and consolidate `SecurityProtocolsCore`
   - Ensure all core protocols are defined here
   - Remove any Foundation dependencies
   - Ensure Sendable conformance
   - Standardize on `SecureBytes` for binary data

2. Create comprehensive error model in `SecurityProtocolsCore.SecurityError`
   - Define all security error cases
   - Provide localization keys
   - Document error recovery options

### Phase 2: Implement Single Bridge Layer

1. Consolidate all Foundation bridges into `SecurityBridge`
   - Migrate adapters from `SecurityInterfacesFoundationBridge`
   - Implement type converters for all domain types
   - Ensure proper error propagation

2. Create factory functions for module integration
   - Simplify creation of security services
   - Provide default implementations
   - Support dependency injection

### Phase 3: Clean Implementation Layer

1. Update `SecurityImplementation` to use `SecurityProtocolsCore`
   - Remove direct Foundation dependencies
   - Use bridge layer for Foundation operations
   - Implement all required protocols

2. Refactor `UmbraSecurity` for clean service integration
   - Focus on high-level security operations
   - Use factories from bridge layer
   - Maintain backward compatibility

### Phase 4: Remove Redundant Modules

After successful migration, remove these redundant modules:
- `SecurityInterfacesFoundationBase`
- `SecurityInterfacesFoundationBridge`
- `SecurityInterfacesFoundationCore`
- `SecurityInterfacesFoundationMinimal`
- `SecurityInterfacesFoundationNoFoundation`
- `SecurityProviderBridge` (functionality moved to `SecurityBridge`)

## Implementation Guidelines

### Protocol Consolidation

For each protocol currently defined in multiple places:

1. Choose one canonical location in `SecurityProtocolsCore`
2. Update all implementations to conform to this protocol
3. Create adapters in `SecurityBridge` if Foundation types are needed

### Error Handling

1. Define a single `SecurityError` enum in `SecurityProtocolsCore`
2. Use Result<Success, SecurityError> for error propagation
3. Create mapping functions in `SecurityBridge` for NSError conversion

### Sendable Conformance

1. All types in `SecurityProtocolsCore` must be Sendable
2. Use actor isolation for state management
3. Avoid shared mutable state

### Module Verification

After implementing each phase, verify:
1. No circular dependencies (use `dependency_analyzer.sh`)
2. All tests pass (run appropriate test suites)
3. Client code integrates correctly

## Migration Path for Client Code

1. Update import statements
   - Replace `import SecurityInterfaces` with `import SecurityProtocolsCore`
   - Replace `import SecurityInterfacesFoundation*` with `import SecurityBridge`

2. Update type usage
   - Replace Foundation types with domain types
   - Use adapters for type conversion

3. Verify protocol conformance
   - Ensure all required methods are implemented
   - Check Sendable conformance where needed

## Conclusion

This architecture provides a clean separation of concerns, breaks circular dependencies, and reduces module count while maintaining functionality and performance. By following this plan, we will achieve the goals outlined in the UmbraCore Refactoring Plan while ensuring a smooth migration path for client code.
