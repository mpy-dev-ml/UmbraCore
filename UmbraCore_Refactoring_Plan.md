# UmbraCore Foundation Decoupling and Architecture Refactoring Plan

## Table of Contents
1. [Current State Analysis](#current-state-analysis)
2. [Core Issues Identified](#core-issues-identified)
3. [Refactoring Strategy](#refactoring-strategy)
4. [Proposed Architecture](#proposed-architecture)
5. [Implementation Plan](#implementation-plan)
6. [Refactoring Priority Matrix](#refactoring-priority-matrix)
7. [Module Consolidation Strategy](#module-consolidation-strategy)
8. [Module Structure and Organization](#module-structure-and-organization)
9. [Build System Integration](#build-system-integration)
10. [Code Examples](#code-examples)
11. [Implementation Workflow](#implementation-workflow)
12. [Design Decisions and Rationale](#design-decisions-and-rationale)
13. [Performance Considerations](#performance-considerations)
14. [Versioning and Compatibility](#versioning-and-compatibility)
15. [Error Handling Strategy](#error-handling-strategy)
16. [Alternatives to @objc for XPC Protocols](#alternatives-to-objc-for-xpc-protocols)

{{ ... }}

We have updated our priority matrix to include these consolidation tasks, with SecureBytes implementation and SecurityInterfaces consolidation as our highest priorities.

## Module Consolidation Strategy

After analyzing the codebase, we've identified several areas where multiple bridging modules have been created in attempts to break circular dependencies. This section outlines a consolidation strategy to simplify the architecture while achieving our dependency-breaking goals.

### 1. Current Module Fragmentation Analysis

We've identified three main areas with significant module fragmentation:

| Area | Fragmented Modules | Severity | Root Cause |
|------|-------------------|----------|------------|
| Security Interfaces | 8+ modules including SecurityInterfaces, SecurityInterfacesBase, SecurityInterfacesFoundation, etc. | High | Multiple iterations of attempting to break Foundation dependencies |
| Umbra Security Services | 4 modules including UmbraSecurity, UmbraSecurityFoundation, UmbraSecurityNoFoundation, etc. | Medium | Segregating Foundation dependencies |
| Core Services Types | CoreServicesTypes, CoreServicesTypesNoFoundation | Low | Early stage fragmentation |

This fragmentation has led to:
- Complex dependency graphs
- Unclear ownership of functionality
- Redundant code across modules
- Higher maintenance burden
- Difficult onboarding for new developers

### 2. Consolidation Approach

For each fragmented area, we will apply the following consolidation pattern:

#### Foundation-Free Core
- Create/consolidate into a single core module (e.g., `SecurityProtocolsCore`)
- Use only domain-specific types (SecureBytes, ResourceLocator, etc.)
- No Foundation imports whatsoever
- Clear, focused protocols with minimal surface area

#### Single Bridge Module
- Create one consolidated bridge module per functional area
- This module handles all Foundation conversions
- Acts as the only module with both Foundation and core module imports
- Contains adapter classes and conversion utilities

#### Implementation Module(s)
- May have one or more implementation modules
- Each implementation has a clear purpose (e.g., Foundation-based, XPC-based)
- Dependencies flow in one direction through the bridge

### 3. Consolidation Targets and Plan

#### 3.1 Security Interfaces (Highest Priority)

**Current State:**
- 8+ fragmented modules
- Circular dependencies between Foundation and security protocols
- Overlapping responsibilities

**Consolidation Plan:**
1. Create `SecurityProtocolsCore` with foundation-free types and protocols
2. Implement `SecurityBridge` for all Foundation conversions
3. Remove redundant modules:
   - SecurityInterfacesFoundationBase
   - SecurityInterfacesFoundationBridge
   - SecurityInterfacesFoundationCore
   - SecurityInterfacesFoundationMinimal
   - SecurityInterfacesFoundationNoFoundation

**Module Reduction:** 8+ → 2-3 modules

#### 3.2 Umbra Security Services (Medium Priority)

**Current State:**
- 4 fragmented modules
- Similar pattern to Security Interfaces
- Implementation-specific fragmentation

**Consolidation Plan:**
1. Create `UmbraSecurityCore` with foundation-free implementation
2. Implement `UmbraSecurityBridge` for Foundation interop
3. Remove redundant modules:
   - UmbraSecurityNoFoundation
   - UmbraSecurityServicesNoFoundation
   - UmbraSecurityFoundation

**Module Reduction:** 4 → 2 modules

#### 3.3 Core Services Types (Medium Priority)

**Current State:**
- Beginning signs of fragmentation
- Foundation dependencies creeping in

**Consolidation Plan:**
1. Create `CoreTypesProtocols` for foundation-free definitions
2. Implement `CoreTypesBridge` for Foundation interop
3. Migrate and consolidate existing types

**Module Reduction:** 2+ → 2 focused modules

#### 3.4 ObjC Bridging Types (Medium Priority)

**Current State:**
- ObjCBridgingTypes and ObjCBridgingTypesFoundation
- Foundation dependencies causing cycles

**Consolidation Plan:**
1. Create foundation-free base interfaces
2. Implement single bridge module for Foundation
3. Clear separation of ObjC and Foundation concerns

**Module Reduction:** 2+ → 2 focused modules

#### 3.5 CryptoSwift Integration (Lower Priority)

**Current State:**
- CryptoSwiftNoFoundation attempts to remove Foundation
- Not fully integrated with domain types

**Consolidation Plan:**
1. Integrate with domain-specific types
2. Provide clean crypto interfaces

**Module Reduction:** 2 → 1-2 focused modules

### 4. Implementation Approach for SecurityInterfaces

As a prototype for our consolidation approach, we will tackle SecurityInterfaces first with the following steps:

1. **Initial scaffolding** (1-2 days):
   - Create the new SecurityProtocolsCore module
   - Define basic domain types and protocols
   - Set up the bridge module structure

2. **Migration** (3-5 days):
   - Port essential functionality from existing modules to the new structure
   - Update imports and type usage
   - Create necessary bridging functions

3. **Integration testing** (2-3 days):
   - Ensure all functionality works with the new structure
   - Test boundary cases and error conditions
   - Validate no circular dependencies exist

4. **Cleanup** (1-2 days):
   - Once the new structure is proven, remove the redundant modules
   - Update all references to use the new modules
   - Document the new architecture

### 5. Benefits of Consolidation

This consolidation approach will deliver several key benefits:

1. **Architectural Clarity**
   - Clear module boundaries and responsibilities
   - One-way dependency flow
   - Simplified mental model

2. **Reduced Codebase Size**
   - Elimination of redundant code
   - Fewer files to maintain
   - Consolidated build artifacts

3. **Improved Build Performance**
   - Fewer module boundaries to cross
   - Reduced compile-time dependencies
   - More efficient incremental builds

4. **Better Developer Experience**
   - Easier navigation of the codebase
   - Clear patterns to follow for new development
   - More intuitive organization

5. **Foundation Independence**
   - Core functionality isolated from Foundation
   - Easier to port to other platforms
   - Better testing without Foundation dependencies

### 6. Integration with Priority Matrix

This consolidation strategy aligns with our priority matrix by:

1. Focusing first on high-impact, high-dependency areas
2. Breaking circular dependencies as a primary goal
3. Starting with clear architectural boundaries
4. Providing quick wins through module simplification

We have updated our priority matrix to include these consolidation tasks, with SecureBytes implementation and SecurityInterfaces consolidation as our highest priorities.

## Module Structure and Organization

This section details the specific structure and organization of the consolidated modules. The architecture follows a clean, modular design with clear boundaries between Foundation-dependent and Foundation-free code.

### 1. Overall Project Structure

The consolidated project structure will organize modules by their primary responsibility and Foundation dependency status:

```
UmbraCore/
├── UmbraCoreTypes/                          # Domain-specific foundation-free types
├── SecurityProtocolsCore/                   # Foundation-free protocol definitions
├── SecurityBridge/                          # Bridge between core types and Foundation
├── SecurityImplementation/                  # Concrete implementation (Foundation-free)
├── SecurityImplementationFoundation/        # Foundation-dependent implementation
├── XPCProtocolsCore/                        # Foundation-free XPC protocol definitions
├── XPCBridge/                               # XPC bridge for Foundation interoperability
└── [other domain-specific modules]          # Following the same pattern
```

### 2. Detailed Module Structure

#### 2.1 UmbraCoreTypes

This module contains foundational, domain-specific types that replace Foundation dependencies:

```
UmbraCoreTypes/
├── BUILD.bazel
├── Sources/
│   ├── SecureBytes.swift                # Replacement for Data
│   ├── ResourceLocator.swift            # Replacement for URL
│   ├── TimePoint.swift                  # Replacement for Date
│   ├── Result.swift                     # Domain-specific result type
│   └── Errors/
│       ├── ErrorProtocol.swift          # Base error protocol
│       └── CommonErrors.swift           # Common error definitions
└── Tests/
    └── [unit tests]
```

Key characteristics:
- Zero Foundation imports
- All types conform to `Sendable`
- Implement value semantics (struct-based design)
- Provide comprehensive initializers and conversion methods
- Include clear documentation and examples

#### 2.2 SecurityProtocolsCore

This module defines security interfaces using only core types with no Foundation dependencies:

```
SecurityProtocolsCore/
├── BUILD.bazel
├── Sources/
│   ├── Protocols/
│   │   ├── CryptoServiceProtocol.swift
│   │   ├── KeyManagementProtocol.swift
│   │   └── SecurityProviderProtocol.swift
│   ├── Types/
│   │   ├── SecurityOperation.swift
│   │   └── SecurityErrors.swift
│   └── DTOs/
│       ├── SecurityConfigDTO.swift
│       └── SecurityResultDTO.swift
└── Tests/
    └── [unit tests]
```

Key characteristics:
- Depends only on UmbraCoreTypes
- Zero Foundation imports
- Protocol-based design
- Clear, focused interfaces

#### 2.3 SecurityBridge

This module bridges between Foundation types and domain-specific types:

```
SecurityBridge/
├── BUILD.bazel
├── Sources/
│   ├── Adapters/
│   │   ├── DataAdapter.swift            # SecureBytes <-> Data conversion
│   │   ├── URLAdapter.swift             # ResourceLocator <-> URL conversion
│   │   └── DateAdapter.swift            # TimePoint <-> Date conversion
│   ├── ProtocolAdapters/
│   │   ├── CryptoServiceAdapter.swift   # Adapts Foundation implementation to core protocol
│   │   └── KeyManagementAdapter.swift   # Adapts Foundation implementation to core protocol
│   └── XPCBridge/
│       ├── XPCServiceAdapter.swift      # Adapts XPC protocols for Foundation
│       └── FoundationConversions.swift  # Utility conversions
└── Tests/
    └── [unit tests]
```

Key characteristics:
- Only module with both Foundation and Core imports
- Clear boundary between type systems
- Comprehensive conversion utilities
- Adapter pattern implementation

#### 2.4 Implementation Modules

Concrete implementations are divided by their Foundation dependency:

```
SecurityImplementation/                  # Foundation-free implementation
├── BUILD.bazel
├── Sources/
│   ├── Services/
│   │   ├── CryptoServiceImpl.swift      # Implementation using only core types
│   │   └── KeyManagementImpl.swift      # Implementation using only core types
│   ├── Utilities/
│   │   └── SecurityHelpers.swift        # Utility functions
│   └── Factory/
│       └── SecurityFactory.swift        # Creates service instances
└── Tests/
    └── [unit tests]

SecurityImplementationFoundation/        # Foundation-dependent implementation
├── BUILD.bazel
├── Sources/
│   ├── Services/
│   │   ├── CryptoKitService.swift       # Implementation using CryptoKit/Foundation
│   │   └── KeychainService.swift        # Implementation using Keychain/Foundation
│   ├── Extensions/
│   │   └── FoundationExtensions.swift   # Extensions on Foundation types
│   └── Factory/
│       └── FoundationSecurityFactory.swift  # Creates Foundation-based services
└── Tests/
    └── [unit tests]
```

Key characteristics:
- Clear separation of Foundation and non-Foundation implementations
- Dependency injection design pattern
- Factory-based instantiation
- Comprehensive unit tests

### 3. Module Dependencies

The dependency relationships between modules follow a strict pattern to eliminate circular dependencies:

```
┌──────────────────┐
│  UmbraCoreTypes  │◄────────────────────────────┐
└──────────────────┘                             │
         ▲                                       │
         │                                       │
         │                                       │
┌──────────────────┐                    ┌──────────────────┐
│ SecurityProtocols│◄───────────────────│    XPCProtocols  │
│      Core        │                    │       Core       │
└──────────────────┘                    └──────────────────┘
         ▲                                       ▲
         │                                       │
         │                                       │
┌──────────────────┐                    ┌──────────────────┐
│    Security      │                    │       XPC        │
│  Implementation  │                    │  Implementation   │
└──────────────────┘                    └──────────────────┘
         ▲                                       ▲
         │                                       │
         │                                       │
┌──────────────────┐                    ┌──────────────────┐
│ SecurityBridge   │◄───────────────────│    XPCBridge     │
└──────────────────┘                    └──────────────────┘
         ▲                                       ▲
         │                                       │
         │                                       │
┌──────────────────┐                    ┌──────────────────┐
│ SecurityImplFdn  │◄───────────────────│  XPCImplFdn      │
└──────────────────┘                    └──────────────────┘
```

### 4. Foundation Dependency Boundary

A critical aspect of this architecture is the clear boundary between Foundation-dependent and Foundation-free code:

```
                        │             │
 Foundation-Free        │  BOUNDARY   │  Foundation-Dependent
                        │             │
                        V             V
┌────────────────────┐  │  ┌────────────────────────────┐
│ UmbraCoreTypes     │  │  │                            │
├────────────────────┤  │  │                            │
│ ProtocolsCore      │  │  │       Bridge Modules       │
├────────────────────┤  │  │                            │
│ Implementation     │  │  │                            │
└────────────────────┘  │  └────────────────────────────┘
                        │             │
                        │             V
                        │  ┌────────────────────────────┐
                        │  │ Implementation             │
                        │  │ Foundation                 │
                        │  └────────────────────────────┘
```

### 5. Module Naming Conventions

For consistency across the project, we adopt these naming conventions:

| Module Type | Naming Pattern | Example |
|-------------|----------------|---------|
| Core Types | UmbraCoreTypes | UmbraCoreTypes |
| Protocol Definitions | [Domain]ProtocolsCore | SecurityProtocolsCore |
| Foundation Bridge | [Domain]Bridge | SecurityBridge |
| Foundation-Free Implementation | [Domain]Implementation | SecurityImplementation |
| Foundation-Dependent Implementation | [Domain]ImplementationFoundation | SecurityImplementationFoundation |

### 6. Implementation Guidelines

When implementing code within these modules, follow these guidelines:

#### 6.1 UmbraCoreTypes

- Use only Swift standard library types
- Ensure all types conform to `Sendable`
- Implement value semantics (struct-based design)
- Provide comprehensive initializers and conversion methods
- Include clear documentation and examples

#### 6.2 Protocol Modules

- Define protocols using only UmbraCoreTypes and Swift standard library
- Keep protocols focused and cohesive
- Use Swift concurrency patterns (async/await)
- Define clear error types
- Include documentation comments

#### 6.3 Bridge Modules

- Provide bidirectional conversion between type systems
- Implement the Adapter pattern
- Handle all edge cases and error conditions
- Document conversion limitations
- Implement type erasure where needed

#### 6.4 Implementation Modules

- Implement protocols from core modules
- Use dependency injection for extensibility
- Provide factory methods for object creation
- Implement comprehensive error handling
- Include detailed logging

### 7. Interaction Flows

This section illustrates how common operations flow through this module structure:

#### 7.1 Data Encryption Flow

```
┌─────────────┐    ┌────────────────┐    ┌─────────────────┐
│ Client Code │───►│ CryptoProtocol │───►│ CryptoService   │
└─────────────┘    └────────────────┘    │ Implementation  │
                                         └─────────────────┘
                                                  │
                   ┌────────────────┐             │
                   │ SecureBytes    │◄────────────┘
                   └────────────────┘
```

For Foundation interoperability:

```
┌─────────────┐    ┌────────────────┐    ┌─────────────────┐
│ Client with │───►│ SecurityBridge │───►│ Data            │
│ SecureBytes │    └────────────────┘    └─────────────────┘
└─────────────┘
```

#### 7.2 XPC Service Call Flow

```
┌─────────────┐    ┌────────────────┐    ┌─────────────────┐
│ Client Code │───►│ XPCProtocolCore│───►│ XPCService      │
└─────────────┘    └────────────────┘    │ Implementation  │
                                         └─────────────────┘
                                                  │
                   ┌────────────────┐             │
                   │ Bridge Module  │◄────────────┘
                   └────────────────┘
                           │
                           ▼
                   ┌────────────────┐
                   │ Foundation API │
                   └────────────────┘
```

## Example Implementation

Below is an example of how a protocol would be defined in the new structure:

**Before (SecurityInterfaces with Foundation dependency):**

```swift
import Foundation

public protocol CryptoServiceProtocol {
    func encrypt(_ data: Data, key: Data) throws -> Data
    func decrypt(_ data: Data, key: Data) throws -> Data
    func generateKey(size: Int) -> Data
}
```

**After (SecurityProtocolsCore with no Foundation):**

```swift
import UmbraCoreTypes

public protocol CryptoServiceProtocol {
    func encrypt(_ data: SecureBytes, key: SecureBytes) throws -> SecureBytes
    func decrypt(_ data: SecureBytes, key: SecureBytes) throws -> SecureBytes
    func generateKey(size: Int) -> SecureBytes
}
```

**Bridge Implementation:**

```swift
import Foundation
import UmbraCoreTypes
import SecurityProtocolsCore

public class CryptoServiceBridge: CryptoServiceProtocol {
    private let foundationService: FoundationCryptoService
    
    public init(foundationService: FoundationCryptoService) {
        self.foundationService = foundationService
    }
    
    public func encrypt(_ data: SecureBytes, key: SecureBytes) throws -> SecureBytes {
        let foundationData = Data(secureBytes: data)
        let foundationKey = Data(secureBytes: key)
        let result = try foundationService.encrypt(foundationData, key: foundationKey)
        return SecureBytes(data: result)
    }
    
    // Other methods follow similar pattern
}
```

This example demonstrates how the architecture cleanly separates Foundation dependencies while maintaining type safety and clear interfaces.

## Build System Integration

### Custom Starlark Rules

These rules enforce architectural boundaries and validate module dependencies:

#### Module Types and Architectural Boundaries

We define two distinct types of modules to enforce architectural boundaries and manage Foundation dependencies:

1. **Foundation-Free Modules** (`umbracore_foundation_free_module`):
   - Absolutely no Foundation dependencies, direct or indirect
   - Core primitive types and essential protocols
   - Form the lowest level in the dependency graph
   - Example: SecureBytes - a completely independent binary data structure
   - Critical for breaking circular dependencies

2. **Foundation-Independent Modules** (`umbracore_foundation_independent_module`):
   - No direct Foundation imports but may use other modules that bridge to Foundation
   - Middle-tier modules that implement interfaces using Foundation-free primitives
   - May indirectly interact with Foundation through bridge modules
   - Example: SecurityImplementation - implements protocols using primitive types but might interact with Foundation-bridging code

#### Foundation-Free Module Rule

```python
# In tools/build_defs/umbracore_module.bzl
def umbracore_foundation_free_module(name, srcs, deps = [], **kwargs):
    """
    A swift_library that enforces no Foundation dependencies whatsoever.
    """
    # Validation aspects
    _validate_no_foundation_imports(name = name + "_validation", srcs = srcs)
    
    # Standard swift_library with constraints
    swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        copts = [
            "-strict-concurrency=complete",
            "-warn-concurrency",
            "-enable-actor-data-race-checks",
            "-target", "arm64-apple-macos14.0",
        ] + kwargs.get("copts", []),
        **{k: v for k, v in kwargs.items() if k != "copts"}
    )
```

#### Foundation-Independent Module Rule 

```python
# In tools/build_defs/umbracore_module.bzl
def umbracore_foundation_independent_module(name, srcs, deps = [], **kwargs):
    """
    A swift_library that avoids direct Foundation dependencies but may
    interact with Foundation through bridge modules.
    """
    # Validation aspects (allows bridge modules)
    _validate_no_direct_foundation_imports(name = name + "_validation", srcs = srcs)
    
    # Standard swift_library with constraints
    swift_library(
        name = name,
        srcs = srcs,
        deps = deps,
        copts = [
            "-strict-concurrency=complete",
            "-warn-concurrency",
            "-enable-actor-data-race-checks",
            "-target", "arm64-apple-macos14.0",
        ] + kwargs.get("copts", []),
        **{k: v for k, v in kwargs.items() if k != "copts"}
    )
```

### Validation and Enforcement

Build-time validation to ensure compliance:

```bash
# Validate architectural boundaries
bazel build //... --aspects=//tools/aspects:architecture_validator.bzl%architecture_validator

# Generate dependency graph
bazel query --output graph 'deps(//Sources/...)' > dependencies.dot
dot -Tpng dependencies.dot -o dependencies.png
```

## Code Examples

### Domain-Specific Types

```swift
// Sources/UmbraCoreTypes/SecureBytes.swift
// NO import Foundation!

public struct SecureBytes: Hashable, Sendable {
    private let bytes: [UInt8]
    
    public init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }
    
    public var isEmpty: Bool { bytes.isEmpty }
    public var count: Int { bytes.count }
    
    public func subdata(in range: Range<Int>) -> SecureBytes {
        SecureBytes(Array(bytes[range]))
    }
    
    // Method to securely clear contents when no longer needed
    public func secureClear() -> SecureBytes {
        var mutableBytes = Array(bytes)
        for i in 0..<mutableBytes.count {
            mutableBytes[i] = 0
        }
        return SecureBytes([])
    }
}
```

### Foundation-Free Protocol

```swift
// Sources/SecurityProtocolsCore/SecurityProvider.swift
// NO import Foundation!
import UmbraCoreTypes

public protocol SecurityProvider: Sendable {
    func encrypt(_ content: SecureBytes, using key: EncryptionKey) async throws -> SecureBytes
    func decrypt(_ content: SecureBytes, using key: EncryptionKey) async throws -> SecureBytes
    func generateKey() async throws -> EncryptionKey
}
```

### Bridge Implementation

```swift
// Sources/FoundationBridge/SecureBytesBridge.swift
import Foundation
import UmbraCoreTypes

public extension SecureBytes {
    init(_ data: Foundation.Data) {
        self.init([UInt8](data))
    }
    
    func asData() -> Foundation.Data {
        return Foundation.Data(self.bytes)
    }
}

public extension Foundation.Data {
    func asSecureBytes() -> SecureBytes {
        return SecureBytes([UInt8](self))
    }
}
```

### XPC Protocol with @Sendable

```swift
// Sources/XPCProtocolsBridge/XPCCryptoServiceProtocol.swift
import Foundation

@objc public protocol XPCCryptoServiceProtocol: NSObjectProtocol {
    @objc func encryptData(_ data: NSData, 
                        withReply reply: @escaping @Sendable (NSData?, NSError?) -> Void)
                        
    @objc func decryptData(_ data: NSData, 
                        withReply reply: @escaping @Sendable (NSData?, NSError?) -> Void)
                        
    @objc func generateKey(withReply reply: @escaping @Sendable (NSData?, NSError?) -> Void)
}
```

## Implementation Workflow

### Branching Strategy

To facilitate our refactoring effort while minimizing risk and ensuring proper testing, we will implement a structured branching strategy:

#### 1. Long-running Integration Branch

We will create a long-running integration branch called `umbracore-alpha` from `main`:

```bash
git checkout main
git checkout -b umbracore-alpha
```

This branch serves as:
- An integration branch for all refactoring changes
- A safe testing ground without affecting production code
- A complete implementation of the new architecture before merging to main

#### 2. Feature Branches for Each Module

For each module identified in our consolidation strategy, we will create focused feature branches from `umbracore-alpha`:

```bash
git checkout umbracore-alpha
git checkout -b feature/UmbraCoreTypes
git checkout umbracore-alpha
git checkout -b feature/SecurityProtocolsCore
git checkout umbracore-alpha
git checkout -b feature/SecurityBridge
# And so on for each module
```

The primary feature branches will include:
- `feature/UmbraCoreTypes` - Foundation-free domain types
- `feature/SecurityProtocolsCore` - Core security protocols
- `feature/SecurityBridge` - Foundation bridging layer
- `feature/SecurityImplementation` - Foundation-free implementation
- `feature/SecurityImplementationFoundation` - Foundation-dependent implementation
- `feature/XPCProtocolsCore` - XPC protocol definitions

#### 3. Integration Process

Our workflow for integrating changes follows these steps:

1. **Develop in Feature Branch**
   - Complete implementation of a specific module
   - Add unit tests and documentation
   - Ensure code compiles and tests pass

2. **Create Pull Request to umbracore-alpha**
   - Submit PR for code review
   - Address review feedback
   - Verify that integration tests still pass

3. **Merge to Integration Branch**
   - Once approved, merge feature branch to `umbracore-alpha`
   - Run integration tests on `umbracore-alpha`
   - Verify no regressions occur

4. **Update Dependent Feature Branches**
   - For in-progress feature branches that depend on the merged changes:
   ```bash
   git checkout feature/DependentFeature
   git fetch origin
   git merge origin/umbracore-alpha
   # Resolve any conflicts
   git push origin feature/DependentFeature
   ```

5. **Repeat Process**
   - Continue with remaining feature branches
   - Follow priority order from our refactoring matrix

#### 4. Final Integration to Main

Once all modules have been merged and thoroughly tested in `umbracore-alpha`:

1. **Complete Integration Testing**
   - Run comprehensive test suite on `umbracore-alpha`
   - Verify all functionality across the system
   - Perform performance benchmarking

2. **Create Final PR**
   - Create a PR to merge `umbracore-alpha` into `main`
   - Request thorough review of the complete architecture

3. **Deploy to Production**
   - Once approved, merge to `main`
   - Tag with appropriate version
   - Deploy through normal CI/CD process

### Migration Strategy for Existing Code

When refactoring existing functionality, follow these guidelines:

1. **Parallel Implementation**
   - Begin by implementing the new structure alongside existing code
   - Don't remove old code until the new implementation is proven

2. **Feature Flagging**
   - Use feature flags to toggle between old and new implementations
   - This enables gradual migration and easy rollback if needed

3. **Incremental Migration**
   - Move functionality one module at a time
   - Maintain backward compatibility where possible
   - Update clients to use new APIs incrementally

4. **Comprehensive Testing**
   - Write tests that verify equivalent functionality between old and new implementations
   - Test both implementations with the same input data
   - Verify outputs match or any differences are expected and documented

### Commit Guidelines

For all work within this refactoring project, adhere to these commit guidelines:

1. **Atomic Commits**
   - Each commit should represent a single logical change
   - Group related changes within a single commit
   - Keep unrelated changes in separate commits

2. **Descriptive Commit Messages**
   - Format: `[Module] Brief description of change`
   - Example: `[UmbraCoreTypes] Implement SecureBytes with Sendable conformance`
   - Include detailed description in commit body when necessary

3. **Reference Plan in Commits**
   - Link commits to the relevant section of this refactoring plan
   - Example: `Implements Section 2.1 of refactoring plan`

4. **Code Quality**
   - Run linters and formatters before committing
   - Ensure tests pass for all commits
   - Follow the style guidelines established for the project

By following this structured branching and implementation strategy, we can manage the complexity of this large refactoring project, maintain code quality, and minimize disruption to ongoing development.

## Design Decisions and Rationale

This section documents the reasoning behind key architectural decisions to aid future maintainers and developers.

### Domain-Specific Type Names

We've chosen more specific type names to better reflect their security-focused purpose:

- **SecureBytes** (vs. BinaryContent): This name clearly indicates the security-sensitive nature of the data and that it contains binary information requiring secure handling.

- **ResourceLocator** (vs. ResourceIdentifier): This emphasizes the purpose of locating resources rather than just identifying them, aligning better with URL's primary function.

- **TimePoint** (vs. Timestamp): This better represents a moment in time rather than just a marker, making it conceptually closer to Date's purpose.

**Rationale**: More precise naming helps developers understand the purpose and proper usage of these types, reduces confusion when mapping between Foundation and domain types, and makes security-sensitive operations more explicit.

### Layered Architecture

The decision to use a strict layered architecture with Foundation bridge modules serves multiple purposes:

**Rationale**:
1. **Maintainability**: Clear separation makes the codebase easier to understand and maintain
2. **Testability**: Foundation-free core is easier to test without complex mocking
3. **Evolution**: Foundation and Swift evolution can be accommodated by updating only bridge modules
4. **Security**: Security-critical code can be isolated from Foundation dependencies
5. **Performance**: Foundation-dependent code can be optimized separately from core business logic

### Type Erasure vs. Protocol Inheritance

We've chosen type erasure patterns over protocol inheritance to break dependencies:

**Rationale**:
1. **Avoids Circular Dependencies**: Type erasure allows bridging between type systems without circular imports
2. **Static Typing**: Maintains Swift's static type safety while allowing flexibility
3. **Performance**: Compared to protocol witnesses, type erasure has better performance characteristics
4. **Evolution**: Easier to evolve individual components without breaking compatibility

### Single Bridge Module vs. Multiple Adapters

We've consolidated all bridging in a single module rather than distributed adapters:

**Rationale**:
1. **Centralized Maintenance**: Easier to update when Foundation changes
2. **Consistent Conversion**: Single source of truth for type conversion
3. **Dependency Control**: Clear, single point of dependency on Foundation
4. **Build Performance**: Fewer module boundaries to cross during compilation

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

## Build System Architecture Configuration

The UmbraCore codebase requires consistent architecture configuration across all modules to ensure proper module resolution and compatibility. This section outlines critical configuration requirements for the Bazel build system.

### Target Triple Configuration

All Swift modules must use a consistent target triple configuration:

```swift
copts = [
    "-target", "arm64-apple-macos15.4",  // Must match across all modules
    "-g",
    "-swift-version", "5",
]
```

**Requirements**:
1. **Consistency**: Use the same target triple across all modules
2. **Configuration Locations**: Update all occurrences in:
   - `bazel/macros/swift.bzl` for global defaults
   - `.bazelrc` for global settings
   - Individual `BUILD.bazel` files for specific overrides

### Library Evolution Support

Modules in a dependency chain must all have library evolution support to ensure binary compatibility:

```swift
additional_copts = [
    "-Xfrontend", "-enable-library-evolution",
]
```

**Requirements**:
1. **Module Dependencies**: If module A imports module B, both need library evolution support
2. **Documentation**: Document dependency chains to ensure consistent configuration
3. **Build Verification**: Test module imports throughout the dependency chain

### SDK and Xcode Version Configuration

The build system must use consistent SDK and Xcode version settings:

```
build --macos_minimum_os=15.4
test --test_env=MACOS_SDK_VERSION=15.4
test --test_env=XCODE_VERSION_OVERRIDE=16.2.0.16C5032a
```

**Requirements**:
1. **Environment Synchronization**: Keep these values in sync with the development environment
2. **Regular Updates**: Update when macOS or Xcode versions change
3. **CI Configuration**: Ensure CI systems use matching versions

### Module Dependency Management

To improve build reliability and debugging:

1. **Explicit Module Names**: Always specify module_name in swift_library rules
2. **Build Order**: For troubleshooting, build modules in dependency order
   ```bash
   bazel build //Sources/CoreModule:CoreModule //Sources/DependentModule:DependentModule
   ```
3. **Clean Builds**: Use `bazel clean --expunge` when changing architectural settings

### Common Troubleshooting Patterns

When encountering cross-module integration issues:

1. **Target Triple Mismatch**: Check for inconsistent architecture settings
2. **Library Evolution Missing**: Add to dependent modules
3. **Module Not Found**: Ensure build order and module names are correct
4. **Binary Compatibility Errors**: Add library evolution to both modules in dependency chain

By maintaining these consistent build configurations, we ensure reliable builds, proper module resolution, and compatibility across the UmbraCore project.

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
