# UmbraCore

[![CI](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/mpy-dev-ml/UmbraCore/branch/main/graph/badge.svg)](https://codecov.io/gh/mpy-dev-ml/UmbraCore)
[![SwiftLint](https://img.shields.io/badge/SwiftLint-Passing-brightgreen.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-blue.svg)](https://mpy-dev-ml.github.io/UmbraCore/)
[![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-lightgrey.svg)](https://github.com/mpy-dev-ml/UmbraCore)
[![Swift](https://img.shields.io/badge/Swift-6.0.3-orange.svg)](https://swift.org)
[![Known Vulnerabilities](https://snyk.io/test/github/mpy-dev-ml/UmbraCore/badge.svg)](https://snyk.io/test/github/mpy-dev-ml/UmbraCore)

A Swift library that extends and adapts [Restic](https://restic.net) for macOS application developers. UmbraCore provides a type-safe, Swift-native interface to Restic's powerful backup capabilities.

## Core Applications
UmbraCore powers several macOS backup management tools:
- ResticBar (macOS menu bar app for developers)
- Rbx (VS Code extension)
- Rbum (user friendly GUI)

## Current Status

### Implemented Features
- Secure keychain operations with XPC service
- Comprehensive error handling and logging
- Thread-safe operations
- SwiftyBeaver logging integration
- Modular architecture
- Extensive test coverage

### In Progress
- SSH key management
- Cloud provider credentials
- Repository password handling

## Requirements
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9.2+

## Overview

UmbraCore is organised into distinct modular components:

### ResticCLIHelper
Handles direct interaction with the Restic command-line interface:
- Command construction and validation
- Async execution management
- Output parsing and error handling

### Repositories
Manages Restic repository operations:
- Repository initialisation and validation
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

## Security

UmbraCore prioritises security and follows best practices to ensure the integrity of your data.

### Security Scanning

UmbraCore uses Snyk to scan for known vulnerabilities and ensure the security of its dependencies.

## Integration Roadmap

### Phase 1: Core Foundation (Q1 2025)
#### 1.1 Restic Command Framework (March 2025)
- Command execution system
- Output parsing
- Error handling
- Process management
- Command queuing

#### 1.2 Security Layer (March-April 2025)
- ✓ Keychain integration
- ✓ XPC service implementation
- SSH key management
- Cloud provider credentials
- Repository password handling

#### 1.3 Configuration System (April 2025)
- Configuration file format
- Validation system
- Migration support
- Default configurations
- Configuration versioning

#### 1.4 Progress Monitoring (April-May 2025)
- Progress reporting protocol
- Status updates system
- Metrics collection
- Event dispatching
- Cancellation support

### Phase 2: Advanced Features (Q2 2025)
- Repository Management (May 2025)
- Scheduling System (May-June 2025)
- Network Operations (June 2025)
- State Management (June-July 2025)

### Phase 3: Enhancement & Optimisation (Q3 2025)
- Statistics & Analytics (July 2025)
- Health Monitoring (August 2025)
- Event System (August-September 2025)
- Cache Optimisation (September 2025)

For detailed feature plans and implementation guidelines, see our [Development Roadmap](ROADMAP.md).

## Documentation

The complete documentation for UmbraCore is available at [https://mpy-dev-ml.github.io/UmbraCore](https://mpy-dev-ml.github.io/UmbraCore). This includes:

- Getting Started Guide
- API Documentation
- Security Guidelines
- Performance Optimisation Guide
- Thread Safety Guide
- Error Handling Guide
- Logging Guide

The documentation is built using Jekyll and hosted on GitHub Pages. To build the documentation locally:

1. Navigate to the `docs` directory
2. Install dependencies: `bundle install`
3. Start the local server: `bundle exec jekyll serve`
4. Visit `http://localhost:4000/UmbraCore`

## Dependencies

### External
- [Restic](https://restic.net) - Fast, secure backup programme
- [SwiftyBeaver](https://swiftybeaver.com) - Sophisticated logging system
- [CryptoSwift](https://cryptoswift.io) - Comprehensive cryptography framework

For more information about our dependencies and acknowledgments, see our [Acknowledgments](docs/ACKNOWLEDGMENTS.md) page.

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support Restic

If you find UmbraCore useful, please consider [supporting the Restic project](https://github.com/sponsors/fd0).

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
