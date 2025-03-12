---
layout: default
title: Home
nav_order: 1
description: Documentation for the UmbraCore secure backup programme
permalink: /
---

![Deploy Documentation](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/docs.yml/badge.svg)

# UmbraCore Documentation

UmbraCore is built upon the foundation of [Restic](https://restic.net), a remarkable open-source backup programme that has set the standard for secure, efficient, and reliable backups. We are deeply grateful to the Restic team for their years of dedication in creating and maintaining such an exceptional tool.

Our mission with UmbraCore is to extend Restic's capabilities specifically for macOS application developers, providing a type-safe, Swift-native interface while maintaining complete compatibility with Restic's core functionality. UmbraCore is not an alternative to Restic, but rather a complementary tool that makes Restic's powerful features more accessible in the macOS development ecosystem.

## Core Applications

UmbraCore powers several macOS backup management tools:
- **ResticBar**: macOS menu bar app for developers
- **Rbx**: VS Code extension
- **Rbum**: User-friendly GUI

## Features

### Implemented
- Secure keychain operations with XPC service
- Comprehensive error handling and logging
- Thread-safe operations
- SwiftyBeaver logging integration
- Modular architecture
- Extensive test coverage

### In Development
- SSH key management
- Cloud provider credentials
- Repository password handling

## Architecture

### Core Libraries
- **SecurityTypes**: Base security primitives and protocols
- **CryptoTypes**: Cryptographic operations and types
- **UmbraLogging**: Centralised logging infrastructure

### Service Layer
- **UmbraKeychainService**: Secure keychain operations
- **UmbraCryptoService**: Cryptographic operations service
- **UmbraBookmarkService**: File system bookmark management
- **UmbraXPC**: XPC communication infrastructure

### Features
- **ResticCLIHelper**: Command-line interface integration
- **Repositories**: Repository management and operations
- **Snapshots**: Snapshot creation and management
- **Config**: Configuration and settings management
- **Logging**: Privacy-aware structured logging
- **ErrorHandling**: Comprehensive error management
- **Autocomplete**: Context-aware command completion

## Project Status

UmbraCore is currently in active development with the following features:

### Tested & Operable
- **Repository Management**
    - Secure repository initialisation
    - Repository health monitoring
    - Multi-repository support
- **Core Restic Integration**
    - Command execution system
    - Output parsing
    - Error handling
    - Process management
- **Security Layer**
    - XPC protocol consolidation
    - Keychain integration
    - Secure error handling
- **Testing Infrastructure**
    - Unit testing framework
    - Integration test suite
    - Performance benchmarks
    - Mock services

### Future Development
- **Advanced Security Features**
    - SSH key management
    - Cloud provider credentials
    - Enhanced repository password handling
- **Configuration System**
    - Configuration file format
    - Validation system
    - Migration support
- **Analytics & Monitoring**
    - Progress reporting protocol
    - Performance metrics
    - Usage statistics
    - System diagnostics
- **Event System**
    - Event dispatching
    - Notification management
    - Webhook support

## Getting Started

Please refer to our [Quick Start Guide](getting-started/quick-start.md) for installation and basic usage instructions.

## Security

UmbraCore prioritises security in all aspects of its implementation. For details, see our [Security Guide](user-guide/security.md).

## Documentation

Key documentation sections:

- Configuration: [Configuration Guide](user-guide/configuration.md)
- Features: [Advanced Features](user-guide/advanced-features.md)
- Development: [API Reference](api/reference.md)
- Support: [Troubleshooting Guide](support/troubleshooting.md)

## Support

If you find UmbraCore useful, please consider:

1. [Contributing](development/contributing.md) to the project
2. [Supporting Restic](https://github.com/sponsors/fd0)
3. Starring us on [GitHub](https://github.com/mpy-dev-ml/UmbraCore)
4. Sharing your experience with others

## License

UmbraCore is available under the MIT license. See the [LICENSE](https://github.com/mpy-dev-ml/UmbraCore/blob/main/LICENSE) file for more info.
