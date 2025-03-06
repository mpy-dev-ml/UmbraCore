# CoreTypes Module Removal Plan

## Background
The CoreTypes module has been successfully refactored with functionality split between CoreTypesInterfaces and CoreTypesImplementation. However, removing the module entirely requires addressing several dependency issues that have been identified.

## Issues Identified

### 1. Type Ambiguities
- `BinaryData` is defined in both CoreTypesInterfaces and SecurityProtocolsCore
- Solution: Choose one canonical definition and update all dependent modules

### 2. Missing Type Adaptations
- Several adapters in SecurityBridge rely on properties or methods from types in CoreTypes that may not exist in the replacement modules
- Example: `SecureBytes.bytes` is missing
- Solution: Update adapters to use available methods/properties or implement adapter extensions

### 3. Error Type Mismatches
- XPCSecurityError and SecurityError type confusions
- SecurityProtocolError compatibility issues
- Solution: Create clear type aliases and ensure consistent error mapping

### 4. Protocol Implementation Mismatches
- Method signatures in adapters don't match required protocol definitions
- Return types (Result) with different error types
- Solution: Update implementations to match protocol requirements exactly

## Migration Steps

### Phase 1: Address Type Ambiguities
1. Examine all occurrences of ambiguous types (BinaryData, etc.)
2. Choose the canonical definition (likely in CoreTypesInterfaces)
3. Update other modules to explicitly use the canonical type
4. Add import aliases where needed to disambiguate

### Phase 2: Update Type Adapters
1. Identify all adapter code that references missing properties/methods
2. Implement appropriate extensions or adapter methods
3. Ensure consistent property access patterns

### Phase 3: Error Type Mapping
1. Create a consistent error mapping strategy
2. Update all error conversions to use explicit mapping functions
3. Standardise on one set of error types

### Phase 4: Fix Protocol Implementations
1. Update all protocol implementations to match the required signatures
2. Ensure return types are consistent, especially with error types
3. Test protocol conformance

### Phase 5: Final Removal and Testing
1. Remove CoreTypes module directory
2. Run full build and test suite
3. Document the migration in the refactoring plan

## Affected Modules
- SecurityBridge
- XPC
- Resources
- Other modules that may have implicit dependencies

## Fallback Plan
If issues persist, we can:
1. Temporarily restore CoreTypes
2. Create more detailed isolation patterns
3. Address each issue individually with more targeted fixes
