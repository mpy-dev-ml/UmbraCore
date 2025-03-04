# Error Migration Strategy for UmbraCore

## Background and Motivation

UmbraCore has developed several issues related to duplicated error types across multiple modules:

1. **Namespace Collisions**: The same error type name exists in multiple modules, creating ambiguity when referencing them.
2. **Inconsistent Error Definitions**: The same conceptual error is defined differently across modules.
3. **Circular Dependencies**: Modules with cross-dependencies on error types create complex build problems.
4. **Code Duplication**: Repeated error definitions lead to maintenance challenges.

Specifically, the `SecurityError` type exists in both `SecurityProtocolsCore` and `XPCProtocolsCore` modules, causing significant build issues where type resolution is ambiguous.

## Migration Strategy

The error migration strategy involves:

1. **Consolidation**: Move duplicated error types to a central `CoreErrors` module.
2. **Type Aliasing**: Maintain backward compatibility via type aliases in original modules.
3. **Import Management**: Update import statements in files that reference migrated errors.
4. **Gradual Migration**: Follow a phased approach prioritizing errors causing immediate issues.

## Implementation Approach

### 1. Analysis Phase

- Use the `error_analyzer` tool to identify all error types, their definitions, and references.
- Generate an analysis report to inform migration decisions.
- Identify duplicated error types across modules.

### 2. Planning Phase

- Create a migration configuration file specifying which errors to migrate.
- Prioritize migration of errors causing immediate issues (e.g., `SecurityError`).
- Consider module dependencies to prevent circular references.

### 3. Migration Phase

- Create the `CoreErrors` module to host consolidated error types.
- Run the `error_migrator` tool to:
  - Extract error definitions from source modules
  - Generate consolidated error types in `CoreErrors`
  - Create type aliases in original modules
  - Update import statements in referencing files

### 4. Verification Phase

- Build the project to verify no compilation errors.
- Run tests to ensure functionality is preserved.
- Verify type resolution issues are resolved.

## Tool Workflow

The error migration process uses two main tools:

1. **error_analyzer**: Analyzes the codebase to identify error types and their usage.
   - Input: Swift source code
   - Output: Analysis report (Markdown and JSON formats)

2. **error_migrator**: Performs the actual migration based on configuration.
   - Input: Analysis report, configuration file
   - Output: Generated Swift code, updated imports

## File Structure

The migrated error types will be organized as follows:

```
CoreErrors/
├── Sources/
│   ├── CoreErrors.swift     # Main file with error definitions
│   ├── ErrorAliases.swift   # Type aliases for backward compatibility
│   └── [ErrorGroup].swift   # Optional files for logical grouping
├── Tests/
│   └── CoreErrorsTests.swift # Tests for error types
└── BUILD.bazel              # Build configuration
```

## Migration Tool Usage

1. Run the error analyzer to generate a report:
   ```
   cd tools/error_analyzer
   ./run_analyzer.sh
   ```

2. Generate a default migration configuration:
   ```
   cd ../error_migrator
   ./run_migration.sh --init
   ```

3. Edit the configuration file to specify which errors to migrate:
   ```json
   {
     "TargetModule": "CoreErrors",
     "ErrorsToMigrate": {
       "SecurityError": ["SecurityProtocolsCore", "XPCProtocolsCore"],
       "OtherError": ["Module1", "Module2"]
     }
   }
   ```

4. Run in dry-run mode to preview changes:
   ```
   ./run_migration.sh
   ```

5. Apply the migration:
   ```
   ./run_migration.sh --apply
   ```

## Best Practices

1. **Start Small**: Begin with a small set of errors to validate the approach.
2. **Test Thoroughly**: Verify each migration with comprehensive tests.
3. **Review Generated Code**: Always review the generated code before applying changes.
4. **Incremental Migration**: Migrate errors in logical groups rather than all at once.
5. **Documentation**: Document the migration process and updated module structure.

## Priority Error Types

The following error types should be prioritized for migration due to known issues:

1. `SecurityError` - Exists in both `SecurityProtocolsCore` and `XPCProtocolsCore`, causing build failures
2. `ResourceError` - Duplicated across resource management modules
3. `LoggingError` - Multiple variants across logging subsystems
4. `CredentialError` - Duplicated in security-related modules
5. `ResticError` - Found in multiple backup-related modules

## Timeline

1. **Phase 1** (Immediate): Migrate `SecurityError` to resolve critical build issues
2. **Phase 2** (Short-term): Migrate resource and credential errors
3. **Phase 3** (Medium-term): Migrate logging errors
4. **Phase 4** (Long-term): Migrate remaining duplicated errors

## Conclusion

This error migration strategy provides a systematic approach to consolidating duplicated error types into a central `CoreErrors` module. This will resolve current build issues, reduce code duplication, and improve maintainability of the UmbraCore project.
