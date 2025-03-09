# UmbraCore Error Handling Style Guide

This document provides guidelines for defining and using error types in the UmbraCore framework.

## Error Case Naming

### Verb Tense Conventions

- **Past tense** for failure events that occurred:
  - ✅ `authenticationFailed`
  - ✅ `connectionLost`
  - ✅ `encryptionFailed`
  - ❌ `authenticationFailure`
  - ❌ `connectionLoss`

- **Present tense** for state descriptions:
  - ✅ `invalidState`
  - ✅ `insufficientPrivileges`
  - ✅ `resourceMissing`
  - ❌ `stateBroken`
  - ❌ `privilegesInsufficient`

### Parameter Naming

- **General explanations** should use `reason:`:
  - ✅ `authenticationFailed(reason: "Invalid credentials")`
  - ❌ `authenticationFailed(message: "Invalid credentials")`
  - ❌ `authenticationFailed(error: "Invalid credentials")`

- **Specific values** should use semantic names:
  - ✅ `invalidState(state: "Offline", expectedState: "Online")`
  - ✅ `resourceNotFound(resource: "config.json")`
  - ❌ `invalidState(current: "Offline", expected: "Online")`
  - ❌ `resourceNotFound(name: "config.json")`

- **When referencing other errors** use `underlyingError:`:
  - ✅ `operationFailed(operation: "encrypt", underlyingError: error)`
  - ❌ `operationFailed(operation: "encrypt", error: error)`

## Common Error Patterns

### Authentication Errors

- `authenticationFailed(reason: String)`
- `invalidCredentials(reason: String)`
- `sessionExpired(reason: String)`
- `tokenExpired(reason: String)`
- `unauthorisedAccess(resource: String, reason: String)`

### Resource Errors

- `resourceNotFound(resource: String)`
- `resourceAlreadyExists(resource: String)`
- `resourceInvalidFormat(resource: String, reason: String)`
- `resourceLocked(resource: String, owner: String?)`

### State Errors

- `invalidState(state: String, expectedState: String)`
- `notInitialised(component: String)`
- `alreadyInitialised(component: String)`

### Operation Errors

- `operationFailed(operation: String, reason: String)`
- `operationTimeout(operation: String, timeoutMs: Int)`
- `operationCancelled(operation: String)`

### Configuration Errors

- `invalidConfiguration(reason: String)`
- `missingConfiguration(key: String)`
- `incompatibleConfiguration(reason: String)`

### Security Errors

- `encryptionFailed(reason: String)`
- `decryptionFailed(reason: String)`
- `signatureInvalid(reason: String)`
- `hashingFailed(reason: String)`
- `certificateExpired(reason: String)`
- `certificateInvalid(reason: String)`

### Network Errors

- `connectionFailed(reason: String)`
- `hostUnreachable(host: String)`
- `requestFailed(statusCode: Int, reason: String)`
- `responseInvalid(reason: String)`

## Documentation Guidelines

### Error Type Documentation

- All error types should have a class-level documentation comment
- Include a brief description of when and how the error type is used
- Note any special handling or recovery mechanisms

Example:
```swift
/// Domain-specific error type for security operations
///
/// Used for all security-related errors in the UmbraCore framework.
/// These errors can be mapped to public API errors via the `SecurityErrorMapper`.
public enum SecurityError: Error, UmbraError, Sendable, CustomStringConvertible {
    // Error cases...
}
```

### Error Case Documentation

- Each error case should have a documentation comment
- Explain when this error occurs and what it means
- Include recovery suggestions if applicable

Example:
```swift
/// Authentication failed due to invalid credentials or expired session
/// 
/// This error indicates that the user could not be authenticated.
/// Recovery options include requesting new credentials or signing in again.
case authenticationFailed(reason: String)
```

## British English Spelling

Use British English spelling in error documentation and user-facing error messages:

- ✅ "initialisation failed"
- ✅ "unauthorised access"
- ✅ "resource utilisation"
- ❌ "initialization failed" 
- ❌ "unauthorized access"
- ❌ "resource utilization"

American English spelling is acceptable in code identifiers to maintain consistency with Swift standard library conventions.
