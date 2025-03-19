# Security Error Migration Guide

Learn how to migrate between different error types in the UmbraCore security stack.

## Overview

The UmbraCore security stack uses several error types to represent failures across different layers of the security architecture. This guide explains how to migrate between these error types while maintaining compatibility and clear error handling.

## Error Types Overview

UmbraCore security operations typically use these error types:

- **UmbraErrors.Security.Core**: Core error types shared across the UmbraCore framework
- **SecurityInterfacesError**: Errors specific to the SecurityInterfaces module
- **NSError/Error**: Platform-level errors returned by Foundation APIs

## Migration Paths

### UmbraErrors.Security.Core to SecurityInterfacesError

When receiving a core error but needing to work within the SecurityInterfaces API:

```swift
let coreError: UmbraErrors.Security.Core = .authenticationFailed
let interfaceError = SecurityInterfacesError(from: coreError)
```

This initializer handles the conversion of matching error types. For core errors without a direct mapping, they'll be wrapped:

```swift
let customCoreError: UmbraErrors.Security.Core = .custom("Unknown error")
let wrappedError = SecurityInterfacesError(from: customCoreError)
// Results in SecurityInterfacesError.wrapped(customCoreError)
```

### SecurityInterfacesError to UmbraErrors.Security.Core

When you have a SecurityInterfacesError but need to convert back to a core error:

```swift
let interfaceError: SecurityInterfacesError = .encryptionFailed(reason: "Invalid key")
if let coreError = interfaceError.toCoreError() {
    // We successfully converted to a core error
} else {
    // This interface error doesn't have a core equivalent
}
```

### Platform Errors to SecurityInterfacesError

For platform errors (like NSError), use specific conversion methods:

```swift
let nsError = NSError(domain: NSOSStatusErrorDomain, code: -67050, userInfo: nil)
let securityError = SecurityInterfacesError(from: nsError)
```

## Best Practices

### Centralized Error Conversion

Implement central error conversion methods to ensure consistent mapping:

```swift
class SecurityErrorConverter {
    static func convertToCoreError(_ error: Error) -> UmbraErrors.Security.Core {
        if let interfaceError = error as? SecurityInterfacesError,
           let coreError = interfaceError.toCoreError() {
            return coreError
        }
        return .unknown
    }
}
```

### Preserving Error Context

When converting errors, preserve as much context as possible:

```swift
func convertToInterfaceError(_ error: Error) -> SecurityInterfacesError {
    if let nsError = error as NSError {
        if nsError.domain == NSOSStatusErrorDomain {
            switch nsError.code {
            case -25293:
                return .authenticationFailed
            // More cases...
            }
        }
    }
    return .unknown(error.localizedDescription)
}
```

## See Also

- <doc:SecurityInterfacesSymbols>
- <doc:ErrorHandlingGuide>
- <doc:TypealiasRefactoring>
