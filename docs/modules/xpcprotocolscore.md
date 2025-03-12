# XPCProtocolsCore Module

The XPCProtocolsCore module defines the foundation-free protocols used for XPC communication between the sandboxed application and XPC service.

## Overview

XPCProtocolsCore provides a consistent set of protocols and interfaces for secure cross-process communication, enabling sandboxed applications to perform privileged operations without compromising security. This module is designed to work without Foundation dependencies, making it lightweight and suitable for use in security-critical contexts.

## Features

- Foundation-free protocol definitions
- Standardised error handling
- Type-safe message passing
- Secure parameter validation

## Usage

```swift
import XPCProtocolsCore

// Define a service conforming to XPC protocols
class MyXPCService: XPCServiceProtocol {
    func performOperation(
        parameters: OperationParameters, 
        withReply reply: @escaping (Result<OperationResult, XPCSecurityError>) -> Void
    ) {
        // Implementation
    }
}
```

## Integration

XPCProtocolsCore is primarily integrated with:

- UmbraXPC for XPC service implementation
- SecurityProtocolsCore for security protocols
- UmbraCore for main application integration

## Source Code

The source code for this module is located in the `Sources/XPCProtocolsCore` directory of the UmbraCore repository.
