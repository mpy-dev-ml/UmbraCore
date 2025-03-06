# CoreTypes Migration Script

A Python utility to automate the migration from `CoreTypes` to `CoreTypesInterfaces` in the UmbraCore project.

## Features

- Automatically identifies Swift files with `CoreTypes` imports
- Finds BUILD.bazel files with `CoreTypes` dependencies
- Provides three operational modes:
  - Dry-run: Preview changes without applying them
  - Interactive: Confirm each file's migration individually
  - Apply-all: Migrate all files in a single operation
- Creates automatic backups of all modified files
- Generates detailed reports of all changes made

## Usage

First, make the script executable:

```bash
chmod +x Scripts/coretypes_migration.py
```

### Analysing potential changes (dry-run)

To see what changes would be made without actually modifying any files:

```bash
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --dry-run
```

### Interactive mode (recommended)

To review and confirm each change:

```bash
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --interactive
```

### Automatic application of all changes

To apply all changes automatically without confirmation:

```bash
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --apply-all
```

### Additional options

Limit to Swift or Bazel files only:

```bash
# Swift files only
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --interactive --swift-only

# Bazel files only
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --interactive --bazel-only
```

Generate a detailed report:

```bash
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --dry-run --output-report migration_report.txt
```

## Backups

All modified files are automatically backed up before changes are applied. By default, backups are stored in:

```
/Users/mpy/CascadeProjects/UmbraCore/migration_backups/
```

You can specify a custom backup directory:

```bash
./Scripts/coretypes_migration.py --project-dir /Users/mpy/CascadeProjects/UmbraCore --interactive --backup-dir /path/to/custom/backup
```

## Safety

This script is designed with safety in mind:
- All files are backed up before modification
- Dry-run mode allows previewing all changes
- Interactive mode lets you review each change
- Detailed reports help track all modifications

## After Migration

After running the migration script:

1. Build the project to verify all changes compile correctly:
   ```bash
   cd /Users/mpy/CascadeProjects/UmbraCore
   bazelisk build //...
   ```

2. Run unit tests to ensure functionality remains correct:
   ```bash
   bazelisk test //...
   ```

3. Review any build or test failures and adjust manually as needed
