# ErrorTypes Module

The ErrorTypes module provides a comprehensive error handling architecture for the UmbraCore framework.

## Overview

ErrorTypes defines a structured approach to error handling across the UmbraCore framework, ensuring consistency, proper error propagation, and meaningful error reporting. This module establishes error domains, error types, and conventions for error handling throughout the codebase.

## Features

- Comprehensive error type definitions
- Domain-specific error categorisation
- Structured error propagation
- Localised error descriptions
- Error recovery strategies

## Usage

```swift
import ErrorTypes

// Define a function that can throw specific errors
func performOperation() throws {
    guard isAvailable else {
        throw CoreError.serviceUnavailable(
            reason: "The service is currently offline", 
            suggestion: "Try again later"
        )
    }
    
    guard hasPermission else {
        throw SecurityError.insufficientPermissions(
            resource: "backup-repository",
            requiredPermission: "write"
        )
    }
    
    // Perform operation
}

// Handle errors with structured catching
do {
    try performOperation()
} catch let error as CoreError {
    // Handle core framework errors
    switch error {
    case .serviceUnavailable(let reason, let suggestion):
        log("Service unavailable: \(reason). \(suggestion)")
    // Handle other core errors
    }
} catch let error as SecurityError {
    // Handle security-specific errors
} catch {
    // Handle unexpected errors
}
```

## Integration

ErrorTypes integrates with all UmbraCore modules to provide consistent error handling throughout the framework:

- UmbraCore for framework-level errors
- UmbraXPC for cross-process error propagation
- SecurityTypes for security-specific errors
- ResticCLIHelper for command execution errors

## Design Philosophy

The ErrorTypes module follows these key principles:

- Errors should be specific and meaningful
- Error types should include helpful context
- Errors should suggest recovery actions when possible
- Error handling should be consistent across the framework

## Source Code

The source code for this module is located in the `Sources/ErrorTypes` directory of the UmbraCore repository.
