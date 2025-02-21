---
layout: default
title: Getting Started
nav_order: 2
description: Getting started with UmbraCore development
---

# Getting Started with UmbraCore

## Prerequisites

Before you begin working with UmbraCore, ensure you have the following installed:

- Xcode 15.0 or later
- Swift 5.9 or later
- [Restic](https://restic.net) 0.16.0 or later
- macOS 13.0 (Ventura) or later

## Installation

### Via Swift Package Manager

Add UmbraCore as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mpy-dev-ml/UmbraCore.git", from: "0.1.0")
]
```

### Manual Build

1. Clone the repository:
   ```bash
   git clone https://github.com/mpy-dev-ml/UmbraCore.git
   cd UmbraCore
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. Run the tests:
   ```bash
   swift test
   ```

## Basic Usage

Here's a simple example of initialising UmbraCore and creating a backup:

```swift
import UmbraCore

// Initialize the backup service
let service = try UmbraBackupService()

// Create a backup
try await service.backup(
    source: "/path/to/source",
    repository: "rest:https://backup.example.com/repo",
    password: "your-secure-password"
)
```

## Security Considerations

UmbraCore prioritises security in several ways:

1. **Keychain Integration**: All sensitive data is stored in the macOS Keychain
2. **XPC Services**: Security-critical operations run in isolated processes
3. **Secure Defaults**: Conservative security defaults that follow best practices

## Next Steps

- Learn about [Configuration Options](configuration.md)
- Explore [Advanced Features](advanced-features.md)
- Read our [Security Guide](security.md)
- Check out the [API Reference](api-reference.md)

## Getting Help

If you encounter any issues or have questions:

1. Check our [Troubleshooting Guide](troubleshooting.md)
2. Search existing [GitHub Issues](https://github.com/mpy-dev-ml/UmbraCore/issues)
3. Create a new issue if your problem hasn't been reported

## Contributing

We welcome contributions! Please read our [Contributing Guide](contributing.md) to get started.
