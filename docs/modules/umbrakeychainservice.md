# UmbraKeychainService Module

The UmbraKeychainService module provides secure credential storage and management using macOS Keychain for the UmbraCore framework.

## Overview

UmbraKeychainService encapsulates secure credential management functionality, allowing the application to store and retrieve sensitive information such as repository passwords and encryption keys securely using the macOS Keychain.

## Features

- Secure password storage and retrieval
- Encryption key management
- Access control for credential access
- Secure credential sharing with XPC service
- Automatic credential lifecycle management

## Usage

```swift
import UmbraKeychainService

// Store a repository password
let keychainService = UmbraKeychainService()
try await keychainService.storePassword(
    "my-secure-password",
    forRepository: repositoryID,
    accessGroup: "com.example.myapp.shared"
)

// Retrieve a repository password
let password = try await keychainService.retrievePassword(
    forRepository: repositoryID,
    accessGroup: "com.example.myapp.shared"
)
```

## Integration

UmbraKeychainService integrates with:

- SecurityTypes for secure credential types
- SecurityProtocolsCore for security interfaces
- UmbraCore for application integration
- UmbraXPC for secure credential passing to XPC service

## Security Considerations

- Passwords are never stored in plain text
- Credentials are accessible only to authorised processes
- Access control lists limit which processes can access credentials
- Automatic cleanup of orphaned credentials

## Source Code

The source code for this module is located in the `Sources/UmbraKeychainService` directory of the UmbraCore repository.
