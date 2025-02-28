# UmbraCore Build System Restructuring

This document outlines the build system restructuring process for UmbraCore, explaining the changes made and how to use the new build system.

## Overview

The UmbraCore build system has been restructured to improve modularity, build performance, and separation of concerns between production and test code.

### Key Changes

1. **Directory Structure Reorganisation**
   - Created dedicated `TestSupport` directories for test-only code
   - Separated test utilities by domain (Security, Core, Common)
   - Created missing packages like `CoreServicesTypes`

2. **Build Configuration**
   - Added build configurations for production, development, and test-only builds
   - Improved dependency management between modules
   - Fixed target configuration issues

3. **Build Scripts**
   - Added convenience scripts for common build operations
   - Created selective build capability for affected targets

## Directory Structure

The new structure follows this pattern:

```
/UmbraCore
├── Sources/            # Production code only
│   ├── Core/
│   ├── CoreTypes/
│   ├── CoreServicesTypes/
│   ├── Security/
│   ├── SecurityInterfaces/
│   └── SecurityTypes/
├── Tests/              # Test code
│   ├── CoreTests/
│   ├── SecurityTests/
│   └── XPCTests/
└── TestSupport/        # Test utilities and mocks
    ├── Security/
    ├── Core/
    └── Common/
```

## Restructuring Tool

A Go-based restructuring tool (`umbra_restructure.go`) has been created to automate the migration process. This tool:

1. Creates the necessary directory structure
2. Moves test-related code to appropriate TestSupport directories
3. Creates and updates BUILD.bazel files
4. Configures Bazel build settings
5. Creates build scripts

### Using the Restructuring Tool

```bash
# Perform a dry run to see planned changes without applying them
go run umbra_restructure.go --dry-run

# Execute the restructuring
go run umbra_restructure.go

# Additional options
go run umbra_restructure.go --help
```

Options:
- `--root`: Specify the project root directory (default: current directory)
- `--dry-run`: Perform a dry run without making changes
- `--verbose`: Enable verbose output
- `--skip-bazel`: Skip Bazel configuration updates
- `--skip-scripts`: Skip build script creation

## Build Scripts

The restructuring adds several convenience scripts:

1. **build_prod.sh**: Builds only production code
   ```bash
   ./build_prod.sh
   ```

2. **build_test.sh**: Builds and runs all tests
   ```bash
   ./build_test.sh
   ```

3. **build_affected.sh**: Builds only targets affected by recent changes
   ```bash
   ./build_affected.sh
   ```

## Bazel Configuration

The `.bazelrc` file has been updated with configurations for different build types:

- `--config=prod`: Production build (no tests)
- `--config=dev`: Development build with tests
- `--config=test`: Test-only build

Example usage:
```bash
bazel build --config=prod //Sources/...
bazel test --config=dev //...
```

## Troubleshooting

If you encounter build issues after restructuring:

1. Check that all dependencies are correctly specified in BUILD.bazel files
2. Verify that imports have been updated to reflect the new package structure
3. Run `bazel clean --expunge` to clear the build cache
4. Check for any remaining test code in production directories

## Future Improvements

Planned improvements for the build system:

1. Dependency visualization tools
2. Comprehensive CI/CD pipeline integration
3. Build performance metrics and optimization
4. Automated dependency management
