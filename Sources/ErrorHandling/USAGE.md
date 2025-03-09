# UmbraCore Error Handling Usage Guide

This document provides practical guidance for working with the UmbraCore error handling system, including the newly standardised error domains.

## Standardised Error Domains

UmbraCore now features a comprehensive set of standardised error domains following a consistent pattern:

```
UmbraErrors
├── <Domain>
│   ├── <Subdomain> (specific types of errors within the domain)
```

### Recently Standardised Domains

The following domains have been recently standardised:

1. **Resource Errors** 
   - `UmbraErrors.Resource.File` - File system operations
   - `UmbraErrors.Resource.Pool` - Resource pool management

2. **Logging Errors**
   - `UmbraErrors.Logging.Core` - Logging system errors

3. **Bookmark Errors**
   - `UmbraErrors.Bookmark.Core` - Security-scoped bookmark operations

4. **XPC Errors**
   - `UmbraErrors.XPC.Core` - Core XPC communication
   - `UmbraErrors.XPC.Protocols` - XPC protocol implementations

5. **Crypto Errors**
   - `UmbraErrors.Crypto.Core` - Cryptography operations

## Using Domain-Specific Errors

### Creating Errors

Each error domain provides factory methods to create errors with appropriate context:

```swift
// Resource file error example
let fileError = UmbraErrors.Resource.File.fileNotFound(
    path: "/Users/documents/report.pdf"
)

// XPC error example
let xpcError = UmbraErrors.XPC.Core.connectionFailed(
    serviceName: "com.umbra.security",
    reason: "Service not running"
)

// Crypto error example
let cryptoError = UmbraErrors.Crypto.Core.encryptionFailed(
    reason: "Invalid key size"
)
```

### Handling Errors

When catching errors, use pattern matching to handle specific error types:

```swift
do {
    try fileManager.copyItem(at: sourceURL, to: destinationURL)
} catch let error as UmbraErrors.Resource.File {
    switch error {
    case let .fileNotFound(path):
        // Handle missing file
    case let .permissionDenied(path, operation):
        // Handle permission issues
    default:
        // Handle other resource errors
    }
} catch {
    // Handle other error types
}
```

### Error Mapping

Use the `UmbraErrorMapper` to convert between internal domain-specific errors and public API errors:

```swift
// Map from internal domain-specific error to public API error
let resourceError = UmbraErrorMapper.shared.mapResourceFileError(fileError)
let cryptoError = UmbraErrorMapper.shared.mapCryptoError(cryptoError)
```

## Error Context and Source Tracking

Enhance errors with context information for better debugging:

```swift
let error = UmbraErrors.Resource.File.fileNotFound(path: filePath)
    .with(context: ErrorContext(
        source: ErrorSource(file: #file, function: #function, line: #line),
        metadata: ["operation": "read", "userInitiated": true]
    ))
```

## Error Recovery

Register recovery options for common errors:

```swift
ErrorRecoveryRegistry.shared.register(
    forErrorType: UmbraErrors.Resource.File.fileNotFound,
    recoveryOptions: [
        RecoveryOption(
            title: "Retry",
            action: { try await retryFileOperation() }
        ),
        RecoveryOption(
            title: "Select Different File",
            action: { try await selectAlternativeFile() }
        )
    ]
)
```

## Best Practices

1. **Be Specific**: Use the most specific error type available to provide clear information about what went wrong.

2. **Include Context**: Always include relevant context information to assist with debugging.

3. **Consistent Naming**: 
   - Use past tense for failure events: `connectionFailed`, `encryptionFailed`
   - Use present tense for state descriptions: `invalidState`, `fileInUse`

4. **Documentation**: Document all possible error cases in public APIs, including potential recovery strategies.

5. **Error Mapping**: At API boundaries, map internal errors to public-facing error types using the appropriate mapper.

## Documentation Standards

When documenting error-throwing methods, follow this pattern:

```swift
/// Performs encryption of the provided data
/// - Parameters:
///   - data: The data to encrypt
///   - key: The encryption key to use
/// - Returns: The encrypted data
/// - Throws: `UmbraErrors.Crypto.Core.encryptionFailed` if encryption fails due to invalid inputs
///           `UmbraErrors.Crypto.Core.keyNotFound` if the specified key cannot be located
///           `UmbraErrors.Crypto.Core.algorithmNotSupported` if the encryption algorithm is not supported
func encrypt(data: Data, using key: CryptoKey) throws -> Data
```
