# UmbraCore

A Swift library that extends and adapts [Restic](https://restic.net) for macOS application developers. UmbraCore provides a type-safe, Swift-native interface to Restic's powerful backup capabilities.

## Core Applications
UmbraCore powers several macOS backup management tools:
- ResticBar (macOS menu bar app)
- Rbx (VS Code extension)
- Rbum (consumer GUI)

## Requirements
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9.2+

## Overview

UmbraCore is organized into several modular components:

### ResticCLIHelper
Handles direct interaction with the Restic command-line interface:
- Command construction and validation
- Async execution management
- Output parsing and error handling

### Repositories
Manages Restic repository operations:
- Repository initialization and validation
- Credential management
- Health checks and maintenance

### Snapshots
Handles snapshot-related operations:
- Snapshot creation and deletion
- Browsing and filtering
- Restoration management

### Config
Manages configuration and settings:
- Repository configurations
- Global preferences
- Secure credential storage

### Logging
Provides structured logging capabilities:
- Privacy-aware logging
- Log level management
- Performance monitoring

### ErrorHandling
Comprehensive error management:
- Structured error types
- Error recovery strategies
- User-friendly error messages

### Autocomplete
Intelligent command completion:
- Context-aware suggestions
- Path completion
- Repository-aware completions

## Installation

Add UmbraCore to your Swift package:

```swift
dependencies: [
    .package(url: "https://github.com/mpy-dev-ml/UmbraCore.git", from: "1.0.0")
]
```

## Usage

### Basic Example

```swift
import UmbraCore

// Initialize a repository
let repo = try await Repository(path: "/path/to/repo", password: "secret")

// Create a snapshot
let snapshot = try await repo.createSnapshot(
    paths: ["/Users/me/Documents"],
    tags: ["documents", "weekly"]
)

// List snapshots
let snapshots = try await repo.listSnapshots(
    matching: .init(tags: ["documents"])
)
```

## Documentation

Comprehensive documentation is available in the [Wiki](https://github.com/mpy-dev-ml/UmbraCore/wiki).

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support Restic

If you find UmbraCore useful, please consider [supporting the Restic project](https://github.com/sponsors/fd0).
