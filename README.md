# UmbraCore

[![CI](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml)
[![Documentation](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/docs.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/docs.yml)
[![codecov](https://codecov.io/gh/mpy-dev-ml/UmbraCore/branch/main/graph/badge.svg)](https://codecov.io/gh/mpy-dev-ml/UmbraCore)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-blue.svg)](https://mpy-dev-ml.github.io/UmbraCore/)

[![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-lightgrey.svg)](https://github.com/mpy-dev-ml/UmbraCore)
[![Swift](https://img.shields.io/badge/Swift-5.9.2-orange.svg)](https://swift.org)
[![Build](https://img.shields.io/badge/Build-Bazel%208.1.0-43A047.svg)](https://bazel.build)

[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/mpy-dev-ml/UmbraCore)
[![Known Vulnerabilities](https://snyk.io/test/github/mpy-dev-ml/UmbraCore/badge.svg)](https://snyk.io/test/github/mpy-dev-ml/UmbraCore)
[![Made with ❤️ in London](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F%20in-London-D40000.svg)](https://github.com/mpy-dev-ml/UmbraCore)
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)

UmbraCore is built upon the foundation of [Restic](https://restic.net), a remarkable open-source backup programme that has set the standard for secure, efficient, and reliable backups. We are deeply grateful to the Restic team for their years of dedication in creating and maintaining such an exceptional tool.

Our mission with UmbraCore is to extend Restic's capabilities specifically for macOS application developers, providing a type-safe, Swift-native interface while maintaining complete compatibility with Restic's core functionality. UmbraCore is not an alternative to Restic, but rather a complementary tool that makes Restic's powerful features more accessible in the macOS development ecosystem.

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

## Development

### Building
```bash
# Generate/update BUILD files
bazel run //:update_build_files

# Build all targets
bazel build //...

# Run tests
bazel test //...
```

### Documentation
The complete documentation is available at [https://mpy-dev-ml.github.io/UmbraCore](https://mpy-dev-ml.github.io/UmbraCore).

To build documentation locally:
```bash
cd docs
bundle install
bundle exec jekyll serve
```
Then visit `http://localhost:4000/UmbraCore`

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
A remarkable backup programme that sets the standard for secure, efficient, and reliable backups. The dedication of the Restic team in creating and maintaining this exceptional tool has been instrumental in making UmbraCore possible.

### [CryptoSwift](https://cryptoswift.io)
An outstanding cryptography framework created and maintained by [Marcin Krzyżanowski](https://github.com/krzyzanowskim). We are grateful for the years of work that have gone into making this comprehensive, pure-Swift implementation of popular cryptographic algorithms. CryptoSwift's excellent design and thorough testing have been crucial for UmbraCore's security features.

### [SwiftyBeaver](https://swiftybeaver.com)
A sophisticated logging system developed by [Sebastian Kreutzberger](https://github.com/skreutzberger) and contributors. SwiftyBeaver's elegant API design and robust feature set have significantly enhanced UmbraCore's logging capabilities. We deeply appreciate the maintainers' commitment to providing such a reliable and well-documented logging solution.

## Licence
This project is licensed under the MIT Licence - see [LICENCE](LICENCE) for details.
