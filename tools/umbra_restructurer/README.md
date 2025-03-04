# UmbraCore Restructurer

This tool automates the restructuring of the UmbraCore project. It helps reorganise code, create appropriate directory structures, and update build files.

## Features

- Plans and executes file and directory operations
- Updates method signatures as needed
- Supports dry-run mode to preview changes
- Verbose output option for detailed logging
- Generates and updates BUILD files

## Usage

```bash
cd /Users/mpy/CascadeProjects/UmbraCore/tools/umbra_restructurer
go run main.go [flags]
```

### Flags

- `--project-root`: Path to the project root directory
- `--dry-run`: Preview changes without making them
- `--verbose`: Show detailed logging
- `--skip-bazel-conf`: Skip Bazel configuration updates
- `--skip-scripts`: Skip script generation

See the code for additional options and implementation details.
