# UmbraCore Documentation Tools

This directory contains Go-based tools for managing and analysing the UmbraCore codebase.

## Installation

Make sure you have Go 1.16 or later installed on your system. You can check your Go version with:

```bash
go version
```

## Available Tools

### DocC Documentation Generator

Generates DocC documentation for UmbraCore modules.

#### Usage

```bash
# Navigate to the tools/go directory
cd tools/go

# Build the documentation for a module
go run cmd/docc/main.go -module SecurityInterfaces

# Build and serve the documentation
go run cmd/docc/main.go -module SecurityInterfaces -serve

# Serve on a specific port (default is 8000)
go run cmd/docc/main.go -module SecurityInterfaces -serve -port 8080
```

#### Options

- `-module`: Name of the module to document (required)
- `-serve`: Serve the documentation after building
- `-port`: Port to serve the documentation on (default: 8000)

### Typealias Analyser

Analyses typealiases in the UmbraCore codebase to help with refactoring efforts.

#### Usage

```bash
# Navigate to the tools/go directory
cd tools/go

# Analyse all modules
go run cmd/typealias/main.go

# Analyse a specific module
go run cmd/typealias/main.go -module SecurityInterfaces

# Specify a custom output file
go run cmd/typealias/main.go -output custom_inventory.md
```

#### Options

- `-module`: Name of the module to scan (empty for all modules)
- `-output`: Output file path for the typealias inventory (default: typealias_inventory.md)

## Building Standalone Executables

You can build standalone executables for these tools to make them easier to run:

```bash
# Navigate to the tools/go directory
cd tools/go

# Build the DocC tool
go build -o bin/docc cmd/docc/main.go

# Build the typealias analyser
go build -o bin/typealias cmd/typealias/main.go
```

The executables will be created in the `bin` directory.
