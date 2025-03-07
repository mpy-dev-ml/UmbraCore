# UmbraCore Error Handling System

Comprehensive error management system for UmbraCore, providing a consistent interface for error handling, logging, recovery, and notification.

## Module Structure

- `Core/` - Core error handling functionality and interfaces
- `Domains/` - Domain-specific error types (Security, Network, etc.)
- `Logging/` - Error logging via SwiftyBeaver
- `Models/` - Error models and context types
- `Notification/` - User-facing error notifications
- `Protocols/` - Core error protocols and interfaces
- `Recovery/` - Error recovery mechanisms
- `Mapping/` - Converters between different error types
- `Utilities/` - Helper utilities for common error handling scenarios

## Core Concepts

### UmbraError Protocol

All errors in the system implement the `UmbraError` protocol, which provides:

- Consistent error identification via domain and code
- Rich contextual information through the `ErrorContext` type
- Source tracking for debugging and logging
- Metadata for additional error details

### Error Context and Source Tracking

Every error can carry context information:

```swift
let error = GenericUmbraError(
    domain: "Security",
    code: "authentication_failed",
    description: "Authentication failed due to invalid credentials",
    context: ErrorContext(
        source: ErrorSource(file: #file, function: #function, line: #line),
        metadata: ["user_id": userId, "attempt": attemptCount]
    )
)
```

## Usage Examples

### Basic Error Handling

```swift
import ErrorHandling

// Handle a basic error
do {
    try someRiskyOperation()
} catch {
    ErrorHandler.shared.handle(error)
}
```

### Domain-Specific Error Handling

```swift
import ErrorHandling
import ErrorHandlingDomains

// Create and handle a security error
let securityError = SecurityError.authenticationFailed("Invalid credentials")
SecurityErrorHandler.shared.handleSecurityError(securityError)
```

### Error Recovery

```swift
import ErrorHandling
import ErrorHandlingRecovery

// Create recovery options for an error
let recoveryOptions = RecoveryOptions.retryCancel(
    title: "Connection Failed",
    message: "Could not connect to the server. Would you like to retry?",
    retryHandler: {
        // Retry logic
        print("Retrying connection...")
    },
    cancelHandler: {
        // Cancel logic
        print("Connection attempt cancelled")
    }
)

// Handle the error with recovery options
let error = NetworkError.connectionFailed("Server unavailable")
ErrorHandler.shared.handle(error, recoveryOptions: recoveryOptions)
```

### Custom Error Notification

```swift
import ErrorHandling
import ErrorHandlingNotification

// Create a custom error notification
let notification = ErrorNotification(
    error: error,
    title: "Connection Error",
    message: "Could not connect to the server",
    severity: .medium,
    recoveryOptions: recoveryOptions
)

// Present the notification
notificationHandler.present(notification: notification)
```

### Structured Logging

```swift
import ErrorHandlingLogging

// Log an error directly
ErrorLogger.shared.log(error, withSeverity: .high)

// Configure destinations
ErrorLogger.shared.configure(destinations: [
    ConsoleDestination(),
    FileDestination(logFileURL: fileURL),
    // Custom destinations can be added here
])
```

## Handling Namespace Conflicts

### Problem Overview

UmbraCore has multiple modules that define their own `SecurityError` types, leading to namespace conflicts:

1. `SecurityProtocolsCore.SecurityError` - Defined at module level, not inside enum namespace
2. `XPCProtocolsCore.SecurityError` - Defined at module level, also with same-named module enum
3. `CoreErrors.SecurityError` - Different implementation with similar cases

This creates problems when trying to use qualified names as the compiler confuses:
- Module-level types
- Types nested inside similarly named enums

### Resolution Strategy

The ErrorHandling system resolves these conflicts through:

#### 1. Type Mappers

```swift
import ErrorHandlingMapping

// Create a mapper for SecurityError types
let mapper = SecurityErrorMapper()

// Convert external security errors to our domain
if let mappedError = mapper.mapFromAny(externalError) {
    // Handle our unified SecurityError type
    ErrorHandler.shared.handle(mappedError)
}
```

#### 2. Context-Aware Type Resolution

```swift
// Instead of trying to use fully qualified names that might be ambiguous:
// let error: SecurityProtocolsCore.SecurityError 

// Define local type aliases in component scope:
typealias ProtocolsSecurityError = SecurityError
import XPCProtocolsCore
typealias XPCSecurityError = SecurityError

func handleMixedErrors(protocolError: ProtocolsSecurityError, xpcError: XPCSecurityError) {
    // Now the types are unambiguous in this context
}
```

#### 3. Centralised Error Handling

The `SecurityErrorHandler` utility provides a single point for handling all security-related errors:

```swift
import ErrorHandlingUtilities

// No need to determine the error type - the handler resolves it
SecurityErrorHandler.shared.handleSecurityError(anySecurityError)
```

## Best Practices

1. **Always Include Context**: Provide `ErrorContext` when creating errors for better debugging
   ```swift
   let error = GenericUmbraError(
       domain: "Network",
       code: "connection_timeout",
       description: "Connection timed out after 30 seconds",
       context: ErrorContext(source: .current())
   )
   ```

2. **Use Domain Handlers**: Use domain-specific handlers for specialised error handling
   ```swift
   SecurityErrorHandler.shared.handleSecurityError(securityError)
   ```

3. **Provide Recovery Options**: Where appropriate, give users a way to recover from errors
   ```swift
   let options = RecoveryOptions.factory.retryCancel(
       retryHandler: { /* retry logic */ },
       cancelHandler: { /* cancel logic */ }
   )
   ```

4. **Custom Error Types**: Implement `UmbraError` protocol for all custom error types
   ```swift
   extension YourCustomError: UmbraError {
       var errorDomain: String { "YourDomain" }
       var errorCode: String { "your_error_code" }
       var errorDescription: String { "Your error description" }
       var errorContext: ErrorContext? { /* your context */ }
   }
   ```

## Testing the Error Handling System

The system includes comprehensive unit tests:

```swift
// Run tests with:
bazel test //Tests/ErrorHandlingTests
```

See `ErrorHandlingSystemTests.swift` for examples of testing error handling, recovery, and notification components.

## Migration Status

- [x] Core error handling protocols
- [x] ErrorContext and ErrorSource models
- [x] Security domain errors
- [x] Error logging infrastructure
- [x] Recovery options framework
- [x] Error notification system
- [x] Error mapping between different types
- [x] Unit testing framework
- [ ] Network domain errors
- [ ] Storage domain errors
- [ ] UI integration for error presentation
