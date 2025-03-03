# CoreErrors Module Refactoring Plan

## Overview

This document outlines the plan for creating a consolidated `CoreErrors` module in UmbraCore to address the current issues with duplicated error types and inconsistent error handling across the codebase.

## Current Issues

1. **Error Type Duplication**: Multiple modules define the same error types (e.g., `SecurityError` in both SecurityProtocolsCore and XPCProtocolsCore)
2. **Ambiguity in Error References**: When a module imports multiple modules with the same error type, type ambiguity occurs
3. **Inconsistent Error Handling**: Different modules handle errors in different ways
4. **Circular Dependencies**: Error types can contribute to circular dependencies between modules
5. **Maintainability Issues**: Changes to error types require updates in multiple places

## Solution: CoreErrors Module

The solution is to create a dedicated `CoreErrors` module that will serve as a single source of truth for all error types in the codebase.

### Benefits

1. **Elimination of Ambiguity**: No more ambiguous references to error types
2. **Reduced Dependencies**: Modules only need to import CoreErrors, not multiple error-defining modules
3. **Improved Maintainability**: Changes to error types only need to be made in one place
4. **Consistent Error Handling**: Standardized approach to error handling across the codebase
5. **Better Separation of Concerns**: Error definitions separate from the functionality that generates them

## Implementation Strategy

### Phase 1: Analysis (Current)

1. Use the Error Analyzer tool to scan the codebase and identify:
   - All error type definitions
   - Duplicate error types
   - References to error types
   - Dependencies between modules

2. Generate a comprehensive report of findings
3. Develop a detailed migration plan based on analysis results

### Phase 2: CoreErrors Module Creation

1. Create the CoreErrors module structure:
   ```
   Sources/CoreErrors/
   ├── BUILD.bazel
   ├── Sources/
   │   ├── SecurityError.swift
   │   ├── NetworkError.swift
   │   ├── StorageError.swift
   │   └── ...
   └── Tests/
       └── CoreErrorsTests.swift
   ```

2. Implement each error type with all cases from existing definitions
3. Add comprehensive documentation
4. Write tests to ensure CoreErrors behaves identically to existing error types

### Phase 3: Incremental Migration

1. Update one module at a time to use CoreErrors
2. For each module:
   - Add CoreErrors as a dependency
   - Replace error definitions with imports from CoreErrors
   - Add typealiases for backward compatibility if needed
   - Update all references to use the CoreErrors types
   - Run tests to ensure nothing breaks

3. Focus on resolving current issues first (SecurityError ambiguity)
4. Gradually expand to the rest of the codebase

### Phase 4: Legacy Code Removal

1. Once all modules use CoreErrors, remove redundant error definitions
2. Update remaining typealiases and references
3. Clean up any leftover code

### Phase 5: Documentation and Standardization

1. Document the new error handling approach
2. Create guidelines for defining new error types
3. Update the architecture documentation to reflect the changes

## Current Focus: Ambiguity Resolution

Our immediate focus is resolving the ambiguity between SecurityError types in SecurityProtocolsCore and XPCProtocolsCore, which is causing build failures in SecurityBridgeProtocolAdapters.

## Timeline

1. **Week 1**: Analysis and planning
2. **Week 2**: CoreErrors module creation and initial migration
3. **Week 3**: Broader migration across the codebase
4. **Week 4**: Testing, cleanup, and documentation

## Risks and Mitigations

1. **Backward Compatibility**: Use typealiases to maintain compatibility with existing code
2. **Overlooked Error Cases**: Comprehensive analysis ensures we capture all error cases
3. **Integration Challenges**: Incremental approach minimizes disruption
4. **Test Coverage**: Write extensive tests for CoreErrors to ensure reliability
