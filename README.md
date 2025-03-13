# UmbraCore

[![Stable Production Build](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/stable-build.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/stable-build.yml) [![Documentation](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/docs.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/docs.yml) [![codecov](https://codecov.io/gh/mpy-dev-ml/UmbraCore/branch/main/graph/badge.svg)](https://codecov.io/gh/mpy-dev-ml/UmbraCore)

[![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-lightgrey.svg)](https://github.com/mpy-dev-ml/UmbraCore) [![Swift](https://img.shields.io/badge/Swift-5.9.2-orange.svg)](https://swift.org) [![Build](https://img.shields.io/badge/Build-Bazel%208.1.0-43A047.svg)](https://bazel.build)

[![Known Vulnerabilities](https://snyk.io/test/github/mpy-dev-ml/UmbraCore/badge.svg)](https://snyk.io/test/github/mpy-dev-ml/UmbraCore) [![Made with ❤️ in London](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F%20in-London-D40000.svg)](https://github.com/mpy-dev-ml/UmbraCore) [![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)

UmbraCore is built to extend the foundation of [Restic](https://restic.net), a remarkable open-source backup programme that has set the standard for secure, efficient, and reliable backups. We are deeply grateful to the Restic team for their years of dedication in creating and maintaining such an exceptional tool, without whom UmbraCore would not exist.

In particular, we have focussed extensively on enable Restic to work more fully within Swift sandboxed enviornments as well as using native macOS security features coupled with Restic for those of us who struggle to remember passwords. 

Our mission with UmbraCore is to extend Restic's capabilities specifically for macOS application developers, providing a type-safe, Swift-native interface whilst maintaining complete compatibility with Restic's core functionality. UmbraCore is not an alternative to Restic but, rather, a complementary tool that makes Restic's powerful features more accessible in the macOS development ecosystem.

If you find UmbraCore useful, please consider:
- [Supporting the Restic project](https://github.com/sponsors/fd0)
- [Contributing to Restic](https://github.com/restic/restic/blob/master/CONTRIBUTING.md)
- [Joining the Restic community](https://forum.restic.net)

## Quick Start

### Requirements
- macOS 14.0+
- Swift 5.9.2+
- Bazel 8.1.0+

### Installation
1. Add UmbraCore to your dependencies in `MODULE.bazel`:
```python
swift_deps = use_extension("@rules_swift_package_manager//:extensions.bzl", "swift_deps")
swift_deps.from_json(
    deps_json = "//:.deps.json",
)
```

2. Add the dependency to your `.deps.json`:
```json
{
  "umbracore": {
    "url": "https://github.com/mpy-dev-ml/UmbraCore.git",
    "version": "0.2.0"
  }
}
```

## Core Applications
UmbraCore powers several macOS backup management tools:
- ResticBar (macOS menu bar app for developers)
- Rbx (VS Code extension)
- Rbum (user-friendly GUI)

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

## Cross-Functional Cryptographic Strategy

UmbraCore implements a dual-library cryptographic approach to support both native macOS security features and cross-process operations:

### CryptoKit Integration
- Native macOS security features for ResticBar
- Hardware-backed security operations
- Secure key storage with Secure Enclave
- Optimised for sandboxed environments

### CryptoSwift Integration
- Cross-process operations for Rbum and Rbx
- Platform-independent implementation
- Flexible XPC service support
- Consistent cross-application behaviour

### KeyManager
The KeyManager orchestrates cryptographic operations across both implementations:
- Intelligent routing between CryptoKit and CryptoSwift
- Unified key lifecycle management
- Secure key storage and rotation
- Context-aware security boundaries
- Cross-process synchronisation

This dual-library strategy enables UmbraCore to provide:
- Native security features in ResticBar
- Cross-functional operation in Rbum and Rbx
- Consistent security model across all implementations
- Flexible deployment options

## XPC Protocol Migration

As part of the UmbraCore refactoring plan, we're consolidating XPC protocols across multiple modules into a single foundation-free module: `XPCProtocolsCore`.

### Migration Progress

Currently, we're in Phase 2 of the migration process (client code migration). Progress is tracked in the `UmbraCore_Refactoring_Plan.md` document.

### Migration Tools

We've created several tools to help with the migration process:

#### 1. XPC Protocol Analyzer

Scans the codebase to identify files that need to be migrated to use the new XPC protocols.

```bash
./Scripts/run_xpc_analyzer.sh
```

This generates two reports:
- `xpc_protocol_analysis.json`: Detailed JSON report
- `xpc_protocol_migration_report.md`: Human-readable Markdown report

#### 2. XPC Migration Manager

Helps manage and track the migration process for individual files.

```bash
# Initialize migration status
./Scripts/xpc_migration_manager.sh init

# View migration status
./Scripts/xpc_migration_manager.sh status

# Get suggested next file to migrate
./Scripts/xpc_migration_manager.sh next

# Start migration for a file
./Scripts/xpc_migration_manager.sh start /path/to/file.swift

# Mark a file as completed
./Scripts/xpc_migration_manager.sh complete /path/to/file.swift
```

#### 3. Single File Migration Tool

Performs basic migration transforms on a single file:

```bash
./Scripts/migrate_xpc_file.sh /path/to/file.swift
```

### Migration Documentation

For detailed migration guidance, see:
- `XPC_PROTOCOLS_MIGRATION_GUIDE.md`: Comprehensive guide with examples
- `UmbraCore_Refactoring_Plan.md`: Overall project refactoring plan

## Development

### Building
```bash
# Generate/update BUILD files
bazel run //:update_build_files

# Build all targets
bazel build //...

# Build only production modules
./build_production.sh

# Run tests
bazel test //...
```

### Repository Management
UmbraCore uses a clean Git repository approach with:
- Development scripts and utilities kept locally but excluded from Git
- Production code focused on the main branch
- Clear separation between build outputs and source code

If you're contributing, please note that certain file types are excluded from Git tracking:
- Python scripts (.py)
- Shell scripts (.sh)
- Dot files (.dot)
- Most .md files (except README.md files)
- .txt files (except test_targets.txt and production_targets.txt)
- Various analyser and utility files

This approach keeps the repository clean while maintaining the necessary tools for development locally.

### Documentation
The complete documentation is available at [https://mpy-dev-ml.github.io/UmbraCore](https://mpy-dev-ml.github.io/UmbraCore).


## Security
UmbraCore prioritises security through:
- Secure keychain integration
- XPC service isolation
- Regular dependency scanning
- Comprehensive security testing

## Contributing
1. Fork the repository
2. Create your feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

Please follow our [contribution guidelines](CONTRIBUTING.md) and [code of conduct](CODE_OF_CONDUCT.md).

## Roadmap
See our detailed [Development Roadmap](ROADMAP.md) for upcoming features and milestones.

## Dependencies

UmbraCore builds upon the work of several outstanding open-source projects:

### [Restic](https://restic.net)
A truly unique backup programme that sets the standard for secure, efficient, and reliable backups. The dedication of the Restic team in creating and maintaining this exceptional tool has been instrumental in making UmbraCore possible.

### [CryptoSwift](https://cryptoswift.io)
An outstanding cryptography framework created and maintained by [Marcin Krzyżanowski](https://github.com/krzyzanowskim). We are grateful for the years of work that have gone into making this comprehensive, pure-Swift implementation of popular cryptographic algorithms. CryptoSwift's excellent design and thorough testing have been crucial for UmbraCore's security features.

### [SwiftyBeaver](https://swiftybeaver.com)
A sophisticated logging system developed by [Sebastian Kreutzberger](https://github.com/skreutzberger) and contributors. SwiftyBeaver's elegant API design and robust feature set have significantly enhanced UmbraCore's logging capabilities. We deeply appreciate the maintainers' commitment to providing such a reliable and well-documented logging solution.

## Licence
This project is licensed under the MIT Licence - see [LICENCE](LICENCE) for details.

---

## Copyright

Copyright 2024-2025 Tzel Agentic Development. All rights reserved.

UmbraCore is a trademark of Tzel Agentic Development.

This software includes components from other projects, each under its own licence. See [DEPENDENCIES.md](docs/DEPENDENCIES.md) for details.
