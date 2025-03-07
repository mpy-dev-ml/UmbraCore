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

### Concurrency Safety

The error handling system is designed to be concurrency-safe, with proper actor isolation for UI-related components:

```swift
@MainActor
public protocol ErrorNotificationProtocol {
    func presentError<E: UmbraError>(_ error: E, recoveryOptions: [RecoveryOption]) async -> UUID?
}
```

Key concurrency features:
- `@MainActor` isolation for UI components
- Asynchronous error presentation and recovery
- Thread-safe error notifiers and handlers
- `Sendable` conformance for error types and recovery options

### Recovery Options

Error recovery options now use UUID-based identification for improved type safety and uniqueness:

```swift
let retryOption = ErrorRecoveryOption(
    id: UUID(), // Auto-generated if nil
    title: "Retry Connection",
    description: "Attempt to reconnect to the server",
    successLikelihood: .possible,
    isDisruptive: false,
    recoveryAction: { @Sendable in
        try await networkService.reconnect()
    }
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

### Error Recovery with Async/Await

```swift
import ErrorHandling
import ErrorHandlingRecovery

// Create recovery options for an error
let recoveryOptions = [
    ErrorRecoveryOption(
        title: "Retry Connection",
        description: "Try connecting again",
        successLikelihood: .possible,
        recoveryAction: { @Sendable in
            try await networkService.reconnect()
        }
    ),
    ErrorRecoveryOption(
        title: "Work Offline",
        description: "Continue without connection",
        successLikelihood: .likely,
        recoveryAction: { @Sendable in
            await appState.enableOfflineMode()
        }
    )
]

// Handle the error with recovery options
let error = NetworkError.connectionFailed("Server unavailable")
Task {
    await ErrorHandler.shared.handle(error, recoveryOptions: recoveryOptions)
}
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

// Present the notification asynchronously
Task {
    let selectedOptionId = await notificationHandler.present(notification: notification)
    if let id = selectedOptionId {
        // Handle the selected recovery option
    }
}
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

2. **Use Factory Methods**: Leverage the `ErrorFactory` for consistent error creation
   ```swift
   let error = ErrorFactory.makeError(
       SecurityError.authenticationFailed,
       context: ErrorContext(source: "Authentication Service")
   )
   ```

3. **Consistent Recovery Options**: Define reusable recovery options for common error scenarios
   ```swift
   // Maintain consistent recovery option IDs for analytics and testing
   struct RecoveryOptionIDs {
       static let retryAuthentication = UUID()
       static let workOffline = UUID()
   }
   ```

4. **Actor Isolation**: Ensure UI-related error handlers use proper actor isolation
   ```swift
   @MainActor
   func showErrorAlert(for error: UmbraError) async {
       // UI code is safely executed on the main thread
   }
   ```

5. **Explicit Module References**: When dealing with ambiguous types, use explicit module references
   ```swift
   // Avoid ambiguity with explicitly qualified types
   func handleError(_ error: ErrorHandlingInterfaces.UmbraError) {
       // ...
   }
   ```

## Recent Improvements

### 2025-03-07 Updates
- Converted recovery option identifiers from String to UUID for improved type safety
- Added @MainActor isolation to error notification services for thread safety 
- Resolved type ambiguity issues with ErrorContext and other shared types
- Fixed circular dependencies between error handling components
- Enhanced error factory methods with proper parameter ordering
- Improved documentation throughout the system

## Contributing

When extending the error handling system, please follow these guidelines:

1. Maintain actor isolation for UI components
2. Ensure all error types conform to `UmbraError` and `Sendable`
3. Use UUIDs for identification rather than strings
4. Follow British spelling in user-facing text
5. Add appropriate documentation for new error types and handlers
6. Include tests that verify error recovery paths

## License

Copyright 2025 UmbraCorp. All rights reserved.
