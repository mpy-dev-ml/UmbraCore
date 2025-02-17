---
layout: default
title: Home
nav_order: 1
description: "UmbraCore documentation - A Swift library for Restic backup management"
permalink: /
---

# UmbraCore Documentation

[![CI](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml/badge.svg)](https://github.com/mpy-dev-ml/UmbraCore/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/mpy-dev-ml/UmbraCore/branch/main/graph/badge.svg)](https://codecov.io/gh/mpy-dev-ml/UmbraCore)
[![Known Vulnerabilities](https://snyk.io/test/github/mpy-dev-ml/UmbraCore/badge.svg)](https://snyk.io/test/github/mpy-dev-ml/UmbraCore)

UmbraCore is a Swift library that extends and adapts [Restic](https://restic.net) for macOS application developers. It provides a type-safe, Swift-native interface to Restic's powerful backup capabilities.

## Quick Links

- [Getting Started](getting-started)
- [Architecture Guide](guides/architecture)
- [API Documentation](api)
- [Security Guidelines](security/guidelines)
- [Contributing Guide](contributing)

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

## Installation

Add UmbraCore as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mpy-dev-ml/UmbraCore.git", from: "1.0.0")
]
```

## License

UmbraCore is available under the MIT license. See the [LICENSE](https://github.com/mpy-dev-ml/UmbraCore/blob/main/LICENSE) file for more info.
