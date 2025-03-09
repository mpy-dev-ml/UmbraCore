# UmbraCore Error Handling Style Guide

This style guide establishes a standard approach for defining and using error types and cases throughout the UmbraCore project. Following these conventions will ensure consistency, improve readability, and facilitate easier maintenance.

## 1. Error Namespace Structure

### 1.1 Namespace Hierarchy

All UmbraCore errors should be organised within the `UmbraErrors` namespace using a hierarchical structure:

```swift
UmbraErrors                          // Root namespace
├── Security                         // Domain-specific namespace
│   ├── Protocols                    // Subdomain-specific namespace
│   │   ├── missingProtocolImplementation
│   │   ├── invalidFormat
│   │   └── ...
│   └── ...
├── Application                      // Another domain
│   ├── ...
└── ...
```

### 1.2 Domain Organisation

- Group errors by their functional domain (e.g., Security, Network, Storage)
- Use subdomains to further categorise errors where appropriate
- Ensure each error belongs to exactly one domain

## 2. Error Type Naming Conventions

### 2.1 General Rules

- Use PascalCase for all error type names
- Append "Error" to the type name
- Use descriptive, specific names that indicate the domain
- Avoid generic terms unless part of a broader domain

### 2.2 Error Type Examples

```swift
enum SecurityError: Error { ... }        // ✓ Good
enum UmbraSecurityError: Error { ... }   // ✓ Good (explicitly indicates UmbraCore origin)
enum GenericError: Error { ... }         // ✗ Bad (too generic)
enum ErrorSecurity: Error { ... }        // ✗ Bad (Error suffix should come last)
```

## 3. Error Case Naming Conventions

### 3.1 General Rules

- Use camelCase for all error case names
- Begin with a verb or noun that describes the error condition
- Be consistent with tense (prefer past tense for failures)
- Avoid abbreviations unless widely understood
- Parameter names should be clear and concise

### 3.2 Common Error Case Patterns

For consistency, use these standard patterns across domains:

| Error Pattern | Recommended Format | Example |
|---------------|-------------------|---------|
| Authentication | `authenticationFailed(reason: String)` | `authenticationFailed(reason: "Invalid credentials")` |
| Permission | `permissionDenied(resource: String)` | `permissionDenied(resource: "AccountData")` |
| Validation | `validationFailed(field: String, reason: String)` | `validationFailed(field: "email", reason: "Invalid format")` |
| Format | `invalidFormat(reason: String)` | `invalidFormat(reason: "Unexpected character")` |
| Operation | `operationFailed(name: String, reason: String)` | `operationFailed(name: "dataSync", reason: "Network unavailable")` |
| State | `invalidState(current: String, expected: String)` | `invalidState(current: "terminated", expected: "running")` |
| Configuration | `invalidConfiguration(component: String, issue: String)` | `invalidConfiguration(component: "cipher", issue: "Invalid key size")` |
| Timeout | `timeout(operation: String, limit: TimeInterval)` | `timeout(operation: "networkRequest", limit: 30.0)` |
| Not Found | `notFound(item: String)` | `notFound(item: "userProfile")` |
| Unknown | `unknown(details: String)` | `unknown(details: "Unexpected system failure")` |

### 3.3 Parameter Requirements

- Always include descriptive parameters rather than using bare cases
- Use `String` type for descriptive parameters when possible
- Include type-specific parameters where appropriate (e.g., `TimeInterval` for timeouts)
- Consider using typed enums for constrained value sets

## 4. Error Domain Definition

### 4.1 Domain Constant Format

Define error domains using constants with consistent naming:

```swift
static let SecurityErrorDomain = "security.umbracore.dev"
```

### 4.2 Domain Naming Conventions

- Use reverse DNS notation with the umbracore.dev domain
- Match the domain component to the error type name
- Define domains as static constants within the error type

## 5. Documentation Standards

### 5.1 General Guidelines

- Use British English spelling in all documentation
- Document each error type with a clear description of its purpose
- Document each error case with:
  - Description of the error condition
  - Potential causes
  - Recommended recovery actions

### 5.2 Documentation Format

```swift
/// Represents errors that occur within the security protocol subsystem.
/// These errors typically relate to issues with protocol implementation,
/// format validation, or unsupported operations.
enum UmbraErrors.Security.Protocols: Error {
    /// Thrown when a required protocol implementation cannot be found.
    /// - Parameter protocolName: The name of the missing protocol
    case missingProtocolImplementation(protocolName: String)
    
    /// Thrown when data is in an invalid format for the requested operation.
    /// - Parameter reason: Detailed description of the format issue
    case invalidFormat(reason: String)
    
    // Additional cases...
}
```

## 6. Migration Path for Existing Code

When refactoring existing error types:

1. Identify semantically similar error cases across different domains
2. Standardise naming and parameter patterns according to this guide
3. Update calling code to use the new pattern
4. Add comprehensive documentation in British English
5. Ensure all error cases have appropriate parameters

## 7. Examples

### 7.1 Before and After Examples

**Before:**
```swift
enum SecurityError: Error {
    case authFailed
    case permissionError(String)
    case invalidState(String, String)
}

enum ApplicationError: Error {
    case authenticationError(message: String)
    case permissionDenied(resource: String)
    case state_invalid(cur: String, expected: String)
}
```

**After:**
```swift
enum UmbraErrors.Security: Error {
    /// Thrown when authentication fails due to the provided reason.
    /// - Parameter reason: Detailed description of the authentication failure
    case authenticationFailed(reason: String)
    
    /// Thrown when permission to the specified resource is denied.
    /// - Parameter resource: The resource for which permission was denied
    case permissionDenied(resource: String)
    
    /// Thrown when the system is in an invalid state for the requested operation.
    /// - Parameters:
    ///   - current: The current state of the system
    ///   - expected: The state required for the operation
    case invalidState(current: String, expected: String)
}

enum UmbraErrors.Application: Error {
    /// Thrown when authentication fails due to the provided reason.
    /// - Parameter reason: Detailed description of the authentication failure
    case authenticationFailed(reason: String)
    
    /// Thrown when permission to the specified resource is denied.
    /// - Parameter resource: The resource for which permission was denied
    case permissionDenied(resource: String)
    
    /// Thrown when the system is in an invalid state for the requested operation.
    /// - Parameters:
    ///   - current: The current state of the system
    ///   - expected: The state required for the operation
    case invalidState(current: String, expected: String)
}
```

### 7.2 Error Domain Examples

**Before:**
```swift
static let SecurityErrorDomain = "com.umbra.security"
static let ApplicationErrorDomain = "com.umbra.app"
```

**After:**
```swift
static let SecurityErrorDomain = "security.umbracore.dev"
static let ApplicationErrorDomain = "application.umbracore.dev"
```

By following this style guide, the UmbraCore error handling will become more consistent, maintainable, and user-friendly. The standardised approach will also facilitate easier debugging and error recovery throughout the project.
