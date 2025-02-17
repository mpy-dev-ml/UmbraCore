---
layout: homepage
title: UmbraCore Documentation
description: A Swift library for Restic backup management
permalink: /
---

# UmbraCore Documentation

[![CI](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/mpy-dev-ml/UmbraCore/branch/main/graph/badge.svg)](https://codecov.io/gh/mpy-dev-ml/UmbraCore)
[![Known Vulnerabilities](https://snyk.io/test/github/mpy-dev-ml/UmbraCore/badge.svg)](https://snyk.io/test/github/mpy-dev-ml/UmbraCore)

UmbraCore is a Swift library that extends and adapts [Restic](https://restic.net) for macOS application developers. It provides a type-safe, Swift-native interface to Restic's powerful backup capabilities.

## Quick Start

Add UmbraCore as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mpy-dev-ml/UmbraCore.git", from: "1.0.0")
]
```

## Core Features

- Secure credential management
- File system bookmark handling
- Cryptographic operations
- XPC service infrastructure
- Comprehensive logging
- Thread-safe operations

## Requirements

- macOS 14.0+
- Swift 6.0.3+
- Xcode 15.2+

## Documentation Sections

### [Getting Started](getting-started)
Learn how to integrate UmbraCore into your project and start using its features.

### [Architecture Guide](guides/architecture)
Understand UmbraCore's design principles and component architecture.

### [API Documentation](api)
Detailed API reference for all UmbraCore components.

### [Security Guidelines](security/guidelines)
Learn about UmbraCore's security features and best practices.

### [Contributing Guide](contributing)
Join the UmbraCore community and contribute to its development.

## Support

If you find UmbraCore useful, please consider:

1. [Contributing](CONTRIBUTING.md) to the project
2. [Supporting Restic](https://github.com/sponsors/fd0)
3. Starring us on [GitHub](https://github.com/mpy-dev-ml/UmbraCore)
4. Sharing your experience with others

## License

UmbraCore is available under the MIT license. See the [LICENSE](https://github.com/mpy-dev-ml/UmbraCore/blob/main/LICENSE) file for more info.
