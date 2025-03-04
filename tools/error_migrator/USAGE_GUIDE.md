# Error Migrator Tool - Usage Guide

## Introduction

The Error Migrator is a command-line tool designed to help consolidate duplicate error types across multiple modules in the UmbraCore project. This guide provides step-by-step instructions for using the tool effectively.

## Prerequisites

Before using the Error Migrator, ensure that:

1. You have Go installed on your system
2. You have run the Error Analyzer tool to generate an error analysis report
3. You understand which error types need to be consolidated

## Quick Start

The simplest way to use the Error Migrator is via the provided scripts:

```bash
# Initialize a default configuration based on an error analysis report
./run_migration.sh --init --report path/to/error_analysis_report.md

# Review the generated config file (migration_config.json by default)
# Then run the migration in dry-run mode
./run_migration.sh

# Once satisfied with the plan, apply the migration
./run_migration.sh --apply
```

## Step-by-Step Guide

### 1. Analyze Error Types

Run the Error Analyzer tool to identify duplicate error types:

```bash
cd ../error_analyzer
./run_analysis.sh --output ../error_migrator/error_analysis_report.md
```

This generates a report containing all error types, their definitions, and duplications.

### 2. Initialize Configuration

Generate a default configuration file based on the error analysis report:

```bash
cd ../error_migrator
./run_migration.sh --init --report error_analysis_report.md --config migration_config.json
```

This creates a JSON configuration file with all duplicate error types identified for migration.

### 3. Customize Configuration

Edit the generated configuration file to customize which error types to migrate and where to migrate them:

```json
{
  "TargetModule": "CoreErrors",
  "ErrorsToMigrate": {
    "SecurityError": ["SecurityProtocolsCore", "XPCProtocolsCore"],
    "ResourceError": ["ResourceManagementCore", "StorageCore"]
  },
  "DryRun": true,
  "OutputDir": "./generated_code"
}
```

- `TargetModule`: The module where error types will be consolidated
- `ErrorsToMigrate`: Map of error names to source modules to migrate from
- `DryRun`: If true, no files will be modified (preview mode)
- `OutputDir`: Directory where generated files will be placed

You can remove error types from the configuration if you don't want to migrate them.

### 4. Run in Dry-Run Mode

Run the migration in dry-run mode to verify the changes without modifying any files:

```bash
./run_migration.sh --config migration_config.json
```

This will generate code in the specified output directory but won't modify any existing files.

### 5. Review Generated Code

Review the generated code in the output directory:

```bash
ls -la ./generated_code
```

The tool generates:

1. Swift files in the target module containing consolidated error definitions
2. Type alias files in the original modules for backward compatibility
3. Updated import statements in files that reference the migrated errors

### 6. Apply Migration

Once you're satisfied with the changes, apply the migration:

```bash
./run_migration.sh --apply --config migration_config.json
```

This will write the generated code to the appropriate locations.

### 7. Verify Changes

After applying the migration, verify that the codebase builds correctly:

```bash
# Build the project to ensure everything works
cd ../../
bazel build //...

# Run tests to ensure functionality is preserved
bazel test //...
```

## Advanced Usage

### Using the Tool Directly

You can use the Go tool directly for more control:

```bash
# Initialize configuration
go run . -initConfig -report error_analysis_report.md -config migration_config.json

# Run in dry-run mode
go run . -config migration_config.json -report error_analysis_report.md -outputDir ./generated_code

# Apply migration
go run . -config migration_config.json -report error_analysis_report.md -dryRun=false -outputDir ./generated_code
```

### Available Flags

- `-config`: Path to migration configuration file
- `-report`: Path to error analysis report
- `-outputDir`: Directory where generated code will be written
- `-dryRun`: If true, don't modify any files (default: true)
- `-initConfig`: Initialize a default configuration file
- `-apply`: Apply the migration (equivalent to -dryRun=false)

## Troubleshooting

### Common Issues

1. **Parsing errors in the error analysis report**:
   - Ensure the report follows the expected format
   - Check for any inconsistencies or formatting issues

2. **Error types not found in modules**:
   - Verify that the error types exist in the specified modules
   - Ensure the module names match exactly in the configuration

3. **Failed to update imports**:
   - Check if the files exist at the expected locations
   - Verify file permissions

### Getting Help

Run the following command to see available options:

```bash
./run_migration.sh --help
```

## Best Practices

1. **Always run in dry-run mode first**:
   This allows you to review changes before applying them.

2. **Start with a small subset of errors**:
   Begin by migrating a few error types to ensure the process works correctly.

3. **Keep a backup of your code**:
   Before applying migrations, ensure you have a backup or clean Git working directory.

4. **Run tests after migration**:
   Ensure all tests pass after the migration to verify functionality is preserved.

5. **Review generated code**:
   Check that the consolidated error types maintain the same behavior as their individual counterparts.

## Migration Strategy

For a comprehensive understanding of the error migration strategy, refer to:
`error_migration_strategy.md`
