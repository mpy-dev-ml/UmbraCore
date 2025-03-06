# Integrated Refactoring Analysis: CoreTypes Removal & XPC Protocol Consolidation

## Background

UmbraCore is currently undergoing two major refactoring initiatives:

1. **CoreTypes Module Removal**: Split functionality between CoreTypesInterfaces and CoreTypesImplementation
2. **XPC Protocol Consolidation**: Standardising XPC protocols and error types across modules

These efforts are interdependent, as CoreTypes previously contained error types and data structures used by XPC protocols.

## Dependency Analysis

### Shared Type Definitions

| Type | Old Location | New Location(s) | Affected Modules |
|------|--------------|----------------|-----------------|
| `BinaryData` | CoreTypes | CoreTypesInterfaces, SecurityProtocolsCore | SecurityBridge, XPC/Core |
| `SecureBytes` | CoreTypes | CoreTypesInterfaces | SecurityBridge, XPC/Core |
| `SecurityError` | CoreTypes | CoreTypesInterfaces, XPCProtocolsCore | SecurityBridge, SecurityProtocolsCore |
| `XPCSecurityError` | XPCProtocolsCore | XPCProtocolsCore (as type alias) | SecurityBridge |

### Error Mapping Flow

The error handling architecture has been affected by both refactorings:

1. **Before**: All modules used `CoreTypes.SecurityError`
2. **CoreTypes Refactoring**: Moved to `CoreTypesInterfaces.SecurityError`
3. **XPC Protocol Consolidation**: Created `XPCProtocolsCore.XPCSecurityError` (alias to `UmbraCoreTypes.CESecurityError`)

This has created inconsistencies in error types across the codebase.

## Critical Path Analysis

The following modules form the critical path that must be addressed for both refactorings to succeed:

1. **SecurityBridge**: Adapts between XPC protocols and security protocols, using both error types
2. **XPCProtocolsCore**: Defines core XPC protocols with error types
3. **SecurityProtocolsCore**: Defines security protocols that use CoreTypes error types

## Integration Plan

### Phase 1: Resolve Type Ambiguities

1. Define canonical type locations:
   - `BinaryData` → CoreTypesInterfaces (remove from SecurityProtocolsCore)
   - `SecureBytes` → CoreTypesInterfaces
   - `SecurityError` → CoreTypesInterfaces
   - `XPCSecurityError` → Type alias to `SecurityError` in XPCProtocolsCore

2. Update imports across affected modules

### Phase 2: Fix Protocol Conformance

1. Update `XPCCryptoServiceAdapter` to conform exactly to `CryptoServiceProtocol`
2. Create bidirectional error mapping between `SecurityError` and any XPC-specific errors
3. Implement type conversion utilities for `SecureBytes` and other shared types

### Phase 3: Update Adapter Implementations

1. Fix `SecureBytes.bytes` access in SecurityBridge
2. Update foundation bridging code in XPCServiceProtocolFoundationBridge
3. Fix `DataAdapter` implementation and ensure no duplicate declarations

### Phase 4: Verification and Testing

1. Build and test primary targets incrementally
2. Ensure full test coverage of error mapping scenarios
3. Document all changes in the refactoring plans

## Integration Schedule

| Phase | Estimated Complexity | Priority Modules |
|-------|---------------------|-----------------|
| Type Ambiguities | Medium | CoreTypesInterfaces, SecurityProtocolsCore |
| Protocol Conformance | High | SecurityBridge, XPCProtocolsCore |
| Adapter Updates | Medium | SecurityBridge |
| Verification | Low | All |

## Risk Assessment

The highest risk components are:

1. Error mapping between domains
2. Protocol conformance with async/await and Result types
3. Potential regressions in XPC communication

## Recommendations

1. Create a new feature branch that incorporates both refactoring efforts
2. Implement changes in order of the phases above
3. Consider adding more comprehensive tests for XPC communication
4. Update documentation to reflect the new architecture
