# UmbraCore Error Migration Strategy

## Overview

This document outlines our strategy for consolidating error types across the UmbraCore project. The goal is to eliminate duplication, improve consistency, and enable better error handling throughout the codebase.

## Current Issues

Our error analysis has identified several issues with the current error handling approach:

1. **Duplicated Error Types**: Many error types are defined in multiple modules with varying cases:
   - `SecurityError` is defined in 7 different modules
   - `ResourceError` is defined in 4 different modules
   - `LoggingError` is defined in 5 different modules
   - Other duplicated errors include `CredentialError` and `ResticError`

2. **Inconsistent Error Handling**: The same logical errors have different names and structures across modules, making error handling inconsistent.

3. **Coupling Issues**: Error definitions create implicit dependencies between modules that should be independent.

4. **Ambiguity Problems**: When multiple modules define the same error type, it creates import ambiguities that lead to build failures.

## Migration Approach

We are implementing a comprehensive error migration strategy with these key components:

1. **Error Analysis Tool**: We have developed an `error_analyzer` tool that scans the codebase to identify all error types, their locations, and usage patterns.

2. **Error Migration Tool**: We have created an `error_migrator` tool that automates the consolidation of error types into a central `CoreErrors` module.

3. **Phased Migration**: The migration will be performed in phases, starting with the most problematic error types (like `SecurityError`).

## CoreErrors Module

The foundation of our strategy is a new `CoreErrors` module that will serve as the central location for all common error types. This module will:

1. Contain consolidated definitions of error types used across multiple modules
2. Provide a consistent error hierarchy and naming conventions
3. Support error wrapping and contextual information
4. Maintain backward compatibility through type aliases

## Migration Process

The migration process consists of these steps:

1. **Analysis**: Run the `error_analyzer` tool to generate a comprehensive report of all error types, their definitions, and usage.

2. **Planning**: Create a migration configuration file that specifies which error types to migrate and their source modules.

3. **Code Generation**: Run the `error_migrator` tool to:
   - Create consolidated error definitions in the `CoreErrors` module
   - Generate type aliases in original modules for backward compatibility
   - Update import statements where necessary

4. **Validation**: Verify that the migrated code compiles and behaves correctly.

5. **Integration**: Merge the changes into the main codebase incrementally to minimize disruption.

## Tooling Details

### Error Analyzer Tool

The `error_analyzer` tool:
- Scans Swift files across the project
- Identifies error type definitions
- Tracks error references and imports
- Generates a detailed analysis report

### Error Migrator Tool

The `error_migrator` tool:
- Parses the error analysis report
- Constructs a migration plan based on configuration
- Generates consolidated error definitions
- Creates type aliases for backward compatibility
- Updates import statements

## Example Migration

For a concrete example, let's consider the `SecurityError` that is defined in both `SecurityProtocolsCore` and `XPCProtocolsCore`:

1. Create a consolidated `SecurityError` in `CoreErrors` that includes all cases from both modules.
2. Create type aliases in both original modules: `public typealias SecurityError = CoreErrors.SecurityError`.
3. Update import statements in files that referenced the original error types.

## Timeline and Priorities

1. **Phase 1**: Migrate `SecurityError` to resolve the immediate build ambiguity issues
2. **Phase 2**: Migrate other high-priority error types (`ResourceError`, `LoggingError`)
3. **Phase 3**: Migrate remaining duplicated error types
4. **Phase 4**: Standardize error patterns across the codebase

## Development Guidelines

Moving forward, developers should follow these guidelines:

1. Define new error types in the `CoreErrors` module when they are likely to be used across multiple modules.
2. Use consistent naming patterns for error types and cases.
3. Include descriptive error messages and context information.
4. Leverage type safety through enums with associated values for complex errors.

## Conclusion

This error migration strategy will significantly improve the error handling in UmbraCore by:

1. Eliminating duplication and ambiguity
2. Providing a consistent error handling pattern
3. Reducing coupling between modules
4. Enabling better error reporting and debugging

The automated tooling we've developed ensures that this migration can be performed efficiently and with minimal manual effort, reducing the risk of errors and inconsistencies.
