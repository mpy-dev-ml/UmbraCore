# Getting Started with UmbraCore

Learn how to integrate and use UmbraCore in your macOS applications.

## Overview

UmbraCore is designed to make secure keychain management simple and robust. This guide will help you get started with the basic features.

## Adding UmbraCore to Your Project

Add UmbraCore to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/UmbraCore.git", from: "1.0.0")
]
```

## Basic Usage

Here's a simple example of using UmbraCore to store and retrieve a password:

```swift
import UmbraCore

let keychain = UmbraKeychainService()

// Store a password
try await keychain.store(
    password: "mySecurePassword",
    for: "user@example.com",
    accessControl: .init(requiresBiometrics: true)
)

// Retrieve a password
let password = try await keychain.retrievePassword(for: "user@example.com")
```

## Next Steps

- Learn about <doc:Security>
- Explore the password validation features
- Set up biometric authentication
