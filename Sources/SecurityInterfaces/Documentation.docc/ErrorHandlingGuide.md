# Handling Security Errors

Learn how to properly handle errors in the SecurityInterfaces module.

## Overview

The SecurityInterfaces module uses a structured approach to error handling with the `SecurityInterfacesError` type. This guide will help you understand how to handle these errors properly in your code.

## Error Types

The module uses several error types in different contexts:

- `SecurityInterfacesError`: For module-level security errors
- `UmbraErrors.Security.Core`: For core security errors defined in UmbraCoreTypes
- `XPCError`: For XPC communication errors

## Error Conversion Flow

```
UmbraErrors.Security.Core <---> SecurityInterfacesError ---> LocalizedError (for user-facing messages)
```

## Best Practices

### Converting Between Error Types

When working with security components that use different error types, convert between them using the appropriate methods:

```swift
// Converting from core error to interface error
let coreError: UmbraErrors.Security.Core = .authenticationFailed
let interfaceError = SecurityInterfacesError(from: coreError)

// Converting back to core error if possible
if let convertedCoreError = interfaceError.toCoreError() {
    // Handle core error
}
```

### Categorizing Errors

When catching errors, it's helpful to categorize them based on their type:

```swift
do {
    try securityProvider.authenticate(user: username, password: password)
} catch let error as SecurityInterfacesError {
    switch error {
    case .authenticationFailed, .authorizationFailed:
        // Handle authentication errors
    case .encryptionFailed, .decryptionFailed:
        // Handle cryptographic errors
    case let .wrapped(coreError):
        // Handle wrapped core errors
    default:
        // Handle other errors
    }
} catch {
    // Handle non-security errors
}
```

### Error Reporting

For logging and analytics, include enough context to understand the error without exposing sensitive information:

```swift
func handleSecurityError(_ error: SecurityInterfacesError) {
    // Log appropriate context but not sensitive data
    switch error {
    case .bookmarkCreationFailed(let path):
        log.error("Failed to create bookmark for path: \(path.lastPathComponent)")
    case .encryptionFailed(let reason):
        log.error("Encryption failed: \(reason)")
    default:
        log.error("Security error: \(error.localizedDescription)")
    }
}
```

## See Also

- <doc:SecurityInterfacesSymbols>
- <doc:SecurityErrorMigration>
