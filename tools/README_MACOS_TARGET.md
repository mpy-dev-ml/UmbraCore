# macOS Target Configuration Tools

This directory contains tools for managing macOS target version settings across the UmbraCore project.

## Available Tools

### 1. macOS_target_manager.sh

Comprehensive script to manage macOS target settings with race condition prevention.

Usage:
```bash
./tools/macOS_target_manager.sh [command]
```

Available commands:
- `fix` - Fix hardcoded macOS target versions in BUILD files
- `validate` - Validate that all targets are using macOS 14.7.4
- `enforce` - Enforce macOS 14.7.4 settings across central config files
- `check` - Check for any remaining macOS target issues
- `all` - Run all operations in the correct order

### 2. validate_macos_target.sh

Validates that all Swift compilations use the correct macOS target version (14.7.4).

Usage:
```bash
./tools/validate_macos_target.sh
```

This script:
- Optionally cleans the build cache
- Runs a build with verbose output
- Checks compiler commands for target flags
- Reports any non-compliant targets

### 3. enforce_macos_target.sh

Enforces consistent macOS 14.7.4 target settings across the project.

Usage:
```bash
./tools/enforce_macos_target.sh
```

This script:
- Verifies central configuration files are set to macOS 14.7.4
- Optionally cleans the build cache
- Runs a build with the updated settings
- Optionally runs the validation script

### 4. fix_target_in_build_files.sh

Updates hardcoded macOS target versions in individual BUILD.bazel files.

Usage:
```bash
./tools/fix_target_in_build_files.sh
```

This script:
- Finds BUILD.bazel files with hardcoded macOS targets
- Updates them to use macOS 14.7.4
- Reports the number of files updated

## Recommended Workflow

When updating the minimum macOS version:

1. Run `./tools/fix_target_in_build_files.sh` to update hardcoded targets
2. Run `./tools/enforce_macos_target.sh` to update central configuration
3. Run `./tools/validate_macos_target.sh` to verify all targets

## Full Documentation

For complete documentation on macOS target settings, see:
[MACOS_TARGET_SETTINGS.md](/docs/MACOS_TARGET_SETTINGS.md)
