---
layout: default
title: Home
nav_order: 1
description: Documentation for the UmbraCore secure backup programme
permalink: /
---

![Deploy Documentation](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/docs.yml/badge.svg)

# UmbraCore Documentation

Welcome to the UmbraCore documentation. UmbraCore is a secure backup management system that provides a robust foundation for backup applications.

## Overview

UmbraCore serves as the core library for several backup applications:
- **Rbum**: Command-line interface
- **Rbx**: GUI application
- **ResticBar**: Menu bar application

## Key Features

### Core Functionality
- Repository initialisation and validation
- Backup creation and verification
- Restore operations
- Repository maintenance
- Snapshot management
- Tag handling

### Security & Credentials
- Repository password management
- SSH key handling
- Cloud provider credentials
- Secure credential persistence
- Access token management

### Advanced Features
- Multiple repository support
- Repository health monitoring
- Space usage optimisation
- Deduplication
- Bandwidth management
- Connection pooling

## Project Status

UmbraCore is currently in active development with the following milestones:

### Q1 2025
- ✓ Keychain integration
- ✓ XPC service implementation
- 🔄 SSH key management
- 🔄 Cloud provider credentials
- 🔄 Repository password handling

### Q2 2025
- Repository management
- Scheduling system
- Network operations
- State management

### Q3 2025
- Statistics & analytics
- Health monitoring
- Event system
- Cache optimisation

## Getting Started

- [Installation Guide](GETTING_STARTED.md)
- [Architecture Overview](guides/ARCHITECTURE.md)
- [API Reference](api/README.md)
- [Contributing Guidelines](contributing/CONTRIBUTING.md)

## Security

UmbraCore prioritises security in all aspects of its implementation. For details, see our [Security Guidelines](security/SECURITY_GUIDELINES.md).

## Implementation Guides

- [Error Handling](guides/error-handling.md)
- [Performance Optimisation](guides/performance.md)
- [Thread Safety](guides/thread-safety.md)
- [Bookmarks](guides/bookmarks.md)
- [Cryptography](guides/crypto.md)
- [Keychain Integration](guides/keychain.md)
- [Logging](guides/logging.md)
- [XPC Services](guides/xpc.md)

## Support

If you find UmbraCore useful, please consider:

1. [Contributing](contributing/CONTRIBUTING.md) to the project
2. [Supporting Restic](https://github.com/sponsors/fd0)
3. Starring us on [GitHub](https://github.com/mpy-dev-ml/UmbraCore)
4. Sharing your experience with others

## License

UmbraCore is available under the MIT license. See the [LICENSE](LICENSE.md) file for more info.
