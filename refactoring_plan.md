# UmbraCore Dependency Refactoring Plan

## Current Issues

1. **Circular Dependencies**: Modules have circular reference chains, particularly:
   - Foundation <-> XPCServiceProtocolDefinition
   - Multiple interdependencies between Security modules

2. **Inconsistent Type Aliases**: Inconsistent use of type aliases across modules leading to redundant imports

3. **Unclear Module Boundaries**: Module responsibilities and boundaries are not clearly defined

4. **Scalability Concerns**: Current architecture may not support growing codebase and multiple apps efficiently

## Guiding Principles

### 1. Sources/Tests Separation

A fundamental principle of this refactoring is maintaining a strict separation between production code (Sources) and test code (Tests):

1. **Sources/...** - Contains all production code, can be built independently
2. **Tests/...** - Contains all test code, depends on Sources but built separately
3. **TestSupport/...** - Contains shared test utilities

Key aspects of this separation:
- Production code NEVER depends on test code
- Test code MAY depend on production code
- Both Sources and Tests can be built and verified independently
- Clear ownership boundaries between modules

### 2. Long-term Maintainability

Our refactoring must address not just immediate issues but long-term maintainability:

1. **Minimize complexity** through:
   - Clear module boundaries
   - Explicit dependencies
   - Protocol-oriented design
   - Consistent patterns

2. **Increase readability** through:
   - Following the Google Swift Style Guide
   - Self-documenting code
   - Comprehensive API documentation
   - Logical code organization

3. **Support codebase growth** through:
   - Modular architecture that can scale
   - Patterns that work for very large codebases
   - Support for multiple apps sharing the same foundation

4. **Ensure consistency** through:
   - Standardized build configurations
   - Consistent file and code organization
   - Unified error handling approach
   - Common patterns across modules

## Refactoring Approach

### 1. Establish a Clear Layering Structure

Create a strict layering of modules with unidirectional dependencies while maintaining the Sources/Tests separation:

```
Sources/                           Tests/
  ├── Foundation Layer               ├── Unit Tests
  │   └── CoreTypes                  │   ├── CoreTests
  │                                  │   ├── SecurityTests
  │                                  │   └── ServicesTests
  ├── Protocol Definitions Layer     │
  │   └── SecurityInterfacesBase     │
  │                                  ├── Integration Tests
  ├── Protocol Implementations Layer │   ├── APITests
  │   ├── SecurityInterfaces         │   └── UmbraSecurityTests
  │   └── SecurityUtils              │
  │                                  └── TestSupport
  ├── Service Layer                      ├── Common
  │   ├── Core/Services                  ├── Core
  │   └── UmbraSecurity/Services         └── Security
  │
  └── Application Layer
      └── UmbraCore
```

### 2. Create a Protocol Foundations Module in Sources

1. **Sources/SecurityInterfacesBase** module:
   - Will contain only Foundation-dependent protocol definitions
   - No dependencies other than CoreTypes
   - Acts as a clear dependency boundary
   - Follows protocol-oriented design principles

### 3. Restructure Security Protocol Modules in Sources

Break down the current SecurityInterfaces module into:

1. **Sources/SecurityInterfacesBase**: Only contains protocol definitions, minimal dependencies
2. **Sources/SecurityInterfaces**: Contains concrete implementations, depends on definitions

This separation follows the Interface Segregation Principle from SOLID design principles.

### 4. Refactor XPC Service Protocol Hierarchy

Replace the current inheritance-based approach with a compositional approach:

1. Define base protocols in SecurityInterfacesBase
2. Use protocol extensions over inheritance where possible
3. Make all dependencies explicit in BUILD files

This approach follows the Swift idiom of "Protocol-oriented programming" and reduces tight coupling.

### 5. Update BUILD Files for Correct Dependencies

1. Ensure each module's BUILD.bazel explicitly lists all dependencies
2. Verify target triples are consistent: arm64-apple-macos14.0
3. Remove any redundant or circular dependency paths
4. Create umbrella targets for Sources and Tests

### 6. Standardize Code Style and Documentation

1. Apply Google Swift Style Guide principles consistently
2. Add comprehensive documentation to all public APIs
3. Create module-level documentation explaining purpose and usage
4. Standardize file organization and naming conventions

## Implementation Plan

### Phase 1: Restructure Protocol Definitions in Sources

1. Create the SecurityInterfacesBase module in Sources:
   - Move protocol definitions from SecurityInterfaces
   - Remove any inheritance from NSObjectProtocol, use extensions instead
   - Create clear BUILD.bazel with minimal dependencies
   - Document all public APIs following Swift documentation standards

2. Refactor XPCServiceProtocolDefinition:
   - Move to SecurityInterfacesBase
   - Remove dependencies on other security modules
   - Keep only the essential protocol definition
   - Use protocol composition over inheritance

### Phase 2: Update Implementation Modules in Sources

1. Update SecurityInterfaces to depend on SecurityInterfacesBase
2. Update all service implementations to use the new protocol structure
3. Fix any remaining type issues in service implementations
4. Apply consistent error handling patterns
5. Standardize code style across refactored files

### Phase 3: Update Core Services in Sources

1. Update Core/Services to use the new protocol structure
2. Fix dependencies in all BUILD.bazel files
3. Verify no circular dependencies remain
4. Apply consistent naming conventions
5. Improve documentation of service responsibilities

### Phase 4: Update Tests to Match New Structure

1. Update test imports to reference the new module structure
2. Ensure all test dependencies are properly declared
3. Create umbrella targets for building all Sources or all Tests separately
4. Maintain or improve test coverage during refactoring

### Phase 5: Code Style and Documentation

1. Apply Google Swift Style Guide consistently across refactored modules
2. Add module-level documentation explaining architecture
3. Create visual dependency diagrams
4. Document patterns for future development

## Build Configuration Updates

Update BUILD.bazel files to reflect the new structure:

1. Update module dependencies to follow the new layering
2. Explicitly specify all Foundation dependencies
3. Ensure consistent target triple specification (arm64-apple-macos14.0)
4. Add umbrella targets:
   - `//Sources/...` - Builds all production code
   - `//Tests/...` - Builds all test code

## Testing Strategy

1. Start with foundational modules and work upward
2. Test each module in isolation before integration testing
3. Confirm absence of circular dependencies using Bazel query
4. Verify that Sources and Tests can be built independently:
   ```bash
   # Build only production code
   bazel build //Sources/... --platforms=//:macos_arm64

   # Build and run tests
   bazel test //Tests/... --platforms=//:macos_arm64
   ```
5. Maintain or improve test coverage during refactoring

## Long-term Maintenance Guidance

1. **Prevent module sprawl**: Keep modules focused and avoid creating too many small modules
2. **Maintain layering discipline**: Honor the dependency hierarchy in all future additions
3. **Consistently apply style guide**: Follow the Google Swift Style Guide for all new code
4. **Document architecture decisions**: Keep architecture documentation updated
5. **Support for multiple apps**: Design modules to be reusable across multiple applications

See the comprehensive [Architecture and Style Guide](./architecture_and_style_guide.md) for detailed guidance on long-term maintainability practices.
