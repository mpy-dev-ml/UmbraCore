---
layout: default
title: Home
nav_order: 1
description: Documentation for the UmbraCore secure backup programme
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

### Getting Started
[Learn how to integrate UmbraCore into your project and start using its features.](getting-started)

### Architecture Guide
[Understand UmbraCore's design principles and component architecture.](guides/architecture)

### API Documentation
[Detailed API reference for all UmbraCore components.](api)

### Security Guidelines
[Learn about UmbraCore's security features and best practices.](security/guidelines)

### Contributing Guide
[Join the UmbraCore community and contribute to its development.](contributing)

## Support

If you find UmbraCore useful, please consider:

1. [Contributing](contributing) to the project
2. [Supporting Restic](https://github.com/sponsors/fd0)
3. Starring us on [GitHub](https://github.com/mpy-dev-ml/UmbraCore)
4. Sharing your experience with others

## Licence

UmbraCore is available under the MIT licence. See the [LICENCE](LICENCE) file for more info.
