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

## Project Architecture

### Core Libraries

#### SecurityTypes
Base security primitives and protocols with no external dependencies.

#### CryptoTypes
Cryptographic operations and types, built on SecurityTypes and CryptoSwift.

#### UmbraLogging
Centralised logging infrastructure using SwiftyBeaver.

### Service Layer

#### UmbraKeychainService
Secure keychain operations with comprehensive error handling.

#### UmbraCryptoService
Cryptographic operations service with XPC integration.

#### UmbraBookmarkService
File system bookmark management service.

#### UmbraXPC
XPC communication infrastructure ensuring secure inter-process communication.

### Error Handling
Comprehensive error handling system with structured logging and recovery strategies.

### Features
- **Crypto**: Advanced cryptographic features
- **Logging**: Advanced logging capabilities

## Dependencies

### External
- **CryptoSwift** (v1.8.0+): Cryptographic operations
- **SwiftyBeaver** (v2.0.0+): Logging infrastructure

### Internal Dependency Graph
```
SecurityTypes
    ↑
    |
CryptoTypes ← CryptoSwift
    ↑
    |
UmbraLogging ← SwiftyBeaver
    ↑
    |
UmbraXPC
    ↑
    |
    ├── UmbraKeychainService
    ├── UmbraCryptoService
    └── UmbraBookmarkService
```

## Key Design Patterns

1. **XPC Service Pattern**
   - Secure inter-process communication
   - Async/await support
   - Service boundaries

2. **Protocol-Oriented Design**
   - Heavy protocol usage
   - Clear service boundaries
   - Testable interfaces

3. **Error Handling Pattern**
   - Structured error types
   - Comprehensive error context
   - Logging integration

4. **Service Layer Pattern**
   - Clear separation of concerns
   - Modular design
   - Independent service scaling

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
