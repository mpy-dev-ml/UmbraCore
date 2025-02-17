# Getting Started with UmbraCore

## Prerequisites
- macOS 14.0 or later
- Xcode 15.2 or later
- Swift 6.0.3 or later
- [Restic](https://restic.net) installed

## Installation

### Swift Package Manager
Add UmbraCore as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mpy-dev-ml/UmbraCore.git", from: "1.0.0")
]
```

### Manual Installation
1. Clone the repository
2. Build the package
3. Link the framework

## Quick Start Guide

### 1. Basic Setup
```swift
import UmbraCore

// Initialize the core services
let keychainService = try UmbraKeychainService()
let cryptoService = try UmbraCryptoService()
```

### 2. Configure Logging
```swift
import UmbraLogging

UmbraLogger.configure(level: .info)
```

### 3. Basic Operations
```swift
// Example: Store credentials
try await keychainService.store(
    password: "repository-password",
    forKey: "backup-repo"
)

// Example: Create a bookmark
try await bookmarkService.create(
    for: URL(fileURLWithPath: "/path/to/backup"),
    withName: "documents"
)
```

## Next Steps
- Read the [Architecture Guide](guides/ARCHITECTURE.md)
- Check out [Security Best Practices](security/SECURITY_GUIDELINES.md)
- View [API Documentation](api/README.md)
