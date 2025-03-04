# Security Module Consolidator

This tool automates the consolidation of UmbraCore security modules. It helps merge SecurityInterfacesProtocols and SecurityInterfacesBase into SecurityProtocolsCore to reduce module fragmentation.

## Features

- Moves Swift files from source modules to target module
- Updates import statements in Swift files
- Updates BUILD.bazel files to reflect consolidation
- Creates backups of all modified files
- Generates a report of all changes made

## Usage

```bash
cd /Users/mpy/CascadeProjects/UmbraCore/tools/security_module_consolidator
go run main.go [flags]
```

See the code comments for available flags and configuration options.
