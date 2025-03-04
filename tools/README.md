# UmbraCore Module Analyser

This tool helps analyse and remove redundant security modules in the UmbraCore project as part of the refactoring plan.

## Features

- Scans the entire codebase to identify dependencies between modules
- Detects redundant modules as defined in the refactoring plan
- Analyses which files import redundant modules
- Creates backups before removing any modules
- Automatically updates import statements to use replacement modules
- Provides detailed reports on migration requirements

## Prerequisites

- Go 1.20 or later
- UmbraCore project checked out

## Usage

1. Run the analyser script:

```bash
./tools/analyse_modules.sh
```

2. Review the analysis results, which will show:
   - Total modules and redundant modules
   - Import statistics
   - Which modules are safe to remove
   - Which files need migration

3. If prompted, confirm whether you want to proceed with removing modules that are safe to remove.

## Safety Features

- The tool creates backups of all removed modules in a timestamped backup directory
- It only automatically removes modules that are deemed "safe to remove"
- For modules that require manual migration, it provides detailed guidance
- You'll be asked for confirmation before any changes are made

## Redundant Modules

The following modules are identified as redundant in the current refactoring plan:

| Module | Replacement |
|--------|-------------|
| SecurityInterfacesFoundationBase | SecurityProtocolsCore |
| SecurityInterfacesFoundationBridge | SecurityBridge |
| SecurityInterfacesFoundationCore | SecurityProtocolsCore |
| SecurityInterfacesFoundationMinimal | SecurityProtocolsCore |
| SecurityInterfacesFoundationNoFoundation | SecurityProtocolsCore |
| SecurityProviderBridge | SecurityBridge |
| UmbraSecurityNoFoundation | UmbraSecurityCore |
| UmbraSecurityServicesNoFoundation | UmbraSecurityCore |
| UmbraSecurityFoundation | UmbraSecurityBridge |

## Additional Notes

1. A module is considered "safe to remove" if either:
   - No files import it
   - All imports can be automatically migrated to the replacement module

2. For modules that aren't safe to remove, manual migration guidance is provided, including:
   - List of files that need to be modified
   - Specific import changes required

3. The tool is designed to follow the UmbraCore Foundation Decoupling refactoring plan and should be used only as part of that planned refactoring effort.

## Examples

Example analysis output:

```
Analysis Results:
=================
Total modules: 53
Redundant modules: 9
Total imports: 287
Redundant imports: 42 (14.6%)

Redundant Modules:
=================
- SecurityInterfacesFoundationBase (15 imports, 15 files) - SAFE TO REMOVE
  Replacement: SecurityProtocolsCore
- SecurityInterfacesFoundationBridge (8 imports, 8 files) - MANUAL MIGRATION REQUIRED
  Replacement: SecurityBridge
...
```
