# UmbraCore Error Domain Refactoring: Implementation Plan

This document outlines the concrete tasks required to implement the error domain refactoring proposed in the design document. It provides a structured, phased approach to ensure the clean-break transition is carried out systematically across the codebase.

## Phase 1: Foundation Setup (Estimated: 1 week)

### 1.1 Error Domain Structure
- [x] Create UmbraErrors namespace
- [x] Implement Security error domain hierarchy (Core, XPC, Protocol)
- [x] Implement Storage error domain hierarchy
- [x] Implement Network error domain hierarchy
- [x] Implement Application error domain hierarchy
- [ ] Add comprehensive documentation for each error type

### 1.2 Error Mapping Utilities
- [x] Implement UmbraErrorMapper for Security domain
- [x] Implement mapping utilities for Storage domain
- [x] Implement mapping utilities for Network domain
- [x] Implement mapping utilities for Application domain
- [ ] Create unit tests for all mapping utilities

### 1.3 Module Version Information
- [x] Define ModuleInfo pattern
- [x] Create template for version information
- [x] Implement version checking utilities

## Phase 2: Module-Specific Refactoring (Estimated: 2 weeks)

### 2.1 SecurityProtocolsCore Module
- [x] Remove SecurityProtocolsCore.SecurityError enum
- [x] Replace with import of UmbraErrors.Security.Protocols
- [x] Update all type references
- [x] Replace module-named enum with ModuleInfo structure
- [x] Update unit tests to use new error types

### 2.2 XPCProtocolsCore Module
- [x] Remove XPCProtocolsCore.SecurityError enum
- [x] Replace with import of UmbraErrors.Security.XPC
- [x] Update all type references
- [x] Replace module-named enum with ModuleInfo structure
- [x] Update unit tests to use new error types

### 2.3 CoreErrors Module
- [x] Remove CoreErrors.SecurityError enum
- [x] Replace with import of UmbraErrors.Security.Core
- [x] Update all type references
- [x] Update unit tests to use new error types

### 2.4 SecurityBridge Module
- [x] Update imports to use UmbraErrors
- [x] Replace all references to SecurityProtocolsCore.SecurityError
- [x] Replace all references to XPCProtocolsCore.SecurityError
- [x] Replace all references to CoreErrors.SecurityError
- [x] Update error handling in XPCServiceAdapter
- [x] Update error handling in CryptoServiceAdapter
- [ ] Update unit tests to use new error types

### 2.5 Other Security-Related Modules
- [x] Identify all modules using existing SecurityError types
- [x] Update imports for each module
- [x] Replace all type references
- [x] Update error handling code
- [ ] Update unit tests

## Phase 3: Testing & Validation (Estimated: 1 week)

### 3.1 Comprehensive Testing
- [ ] Create test suite for error domain usage
- [ ] Verify error propagation across module boundaries
- [ ] Test error mapping in diverse scenarios
- [ ] Verify error handling in XPC bridge
- [ ] Run all existing unit tests with new error structure

### 3.2 Build Verification
```bash
# Run full build with verbose errors to catch any issues
bazelisk build --verbose_failures //...

# Run all tests to ensure error handling works correctly
bazelisk test --verbose_failures //...
```

### 3.3 Edge Case Validation
- [x] Fix warnings related to unused `self` references
- [x] Address non-exhaustive switch statements for Swift 6 compatibility
- [x] Fix conditional downcasting issues
- [x] Fix warnings about unused results from function calls
- [ ] Verify error handling with nil values
- [ ] Test behavior with nested errors
- [ ] Validate serialisation/deserialisation of errors
- [ ] Check performance impact of new error domain structure

## Phase 4: Documentation & Guidelines (Estimated: 3 days)

### 4.1 Developer Documentation
- [ ] Update API documentation to reflect new error domains
- [ ] Create guide for error handling best practices
- [ ] Document error mapping patterns
- [ ] Create examples of typical error handling scenarios

### 4.2 Migration Guide
- [ ] Document how to migrate custom error types
- [ ] Provide guidance for handling errors across module boundaries
- [ ] Explain pattern for extending error domains

### 4.3 Code Reviews & Knowledge Transfer
- [x] Successfully merged error-domain-refactoring branch into umbracore-alpha
- [ ] Schedule code walkthrough sessions
- [ ] Create review checklist for error handling patterns
- [ ] Document lessons learned from the refactoring

## Implementation Approach

### Command-line Execution
For each phase, use the following commands to test your changes:

```bash
# Check if the changes compile
bazelisk build --verbose_failures //Sources/ErrorHandling/...

# Run tests for the error handling domain
bazelisk test --verbose_failures //Sources/ErrorHandling/...

# Check if your changes affect other modules
bazelisk build --verbose_failures //Sources/SecurityBridge/...
bazelisk test --verbose_failures //Sources/SecurityBridge/...

# Run all tests to ensure no regressions
bazelisk test --verbose_failures //...
```

### Risk Mitigation
- Work in feature branches for each module refactoring
- Create detailed tests before major modifications
- Implement changes incrementally, focusing on one module at a time
- Use pair programming for complex error handling transitions

## Next Steps

1. Address remaining compilation errors in SecurityBridge module
2. Complete unit test updates for all modified modules
3. Focus on Phase 2 remaining tasks - removing old error enums
4. Enhance documentation with comprehensive examples
5. Validate error serialisation/deserialisation across module boundaries
