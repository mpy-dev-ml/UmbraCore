---
layout: docs
title: Error Handling Guide
description: Learn about error handling in UmbraCore
nav_order: 7
parent: Guides
---

# Error Handling in UmbraCore

## Overview
UmbraCore uses a structured error handling system that provides detailed error context, supports error recovery, and integrates with the logging system. This guide explains our error handling patterns and best practices.

## Error Types

### 1. Common Errors
Base error types shared across the library:

```swift
enum CommonError: Error {
    case invalidArgument(String)
    case resourceNotFound(String)
    case permissionDenied(String)
    case operationFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidArgument(let details):
            return "Invalid argument: \(details)"
        case .resourceNotFound(let resource):
            return "Resource not found: \(resource)"
        case .permissionDenied(let operation):
            return "Permission denied for operation: \(operation)"
        case .operationFailed(let reason):
            return "Operation failed: \(reason)"
        }
    }
}
```

### 2. Service-Specific Errors
Each service defines its domain-specific errors:

```swift
enum KeychainError: Error {
    case itemNotFound(String)
    case duplicateItem(String)
    case accessDenied(String)
    case invalidData(String)
}

enum CryptoError: Error {
    case encryptionFailed(String)
    case decryptionFailed(String)
    case invalidKey(String)
    case algorithmNotSupported(String)
}
```

### 3. Error Context
Additional context for debugging and recovery:

```swift
struct ErrorContext {
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
    let operationId: UUID
    var userInfo: [String: Any]
    
    var description: String {
        """
        Error occurred in \(function)
        File: \(file):\(line)
        Time: \(timestamp)
        Operation: \(operationId)
        Additional Info: \(userInfo)
        """
    }
}
```

## Best Practices

### 1. Error Creation
Create informative errors with context:

```swift
func processFile(_ url: URL) async throws {
    guard FileManager.default.fileExists(atPath: url.path) else {
        throw CommonError.resourceNotFound(
            """
            File not found at \(url.path)
            Check if the file exists and you have read permissions.
            """
        )
    }
}
```

### 2. Error Handling
Handle errors at appropriate levels:

```swift
func backupFiles() async throws {
    do {
        try await validatePermissions()
        try await performBackup()
        try await verifyBackup()
    } catch KeychainError.accessDenied(let details) {
        logger.error("Keychain access denied", metadata: [
            "details": details,
            "operation": "backup"
        ])
        throw CommonError.permissionDenied("Keychain access required for backup")
    } catch CryptoError.encryptionFailed(let reason) {
        logger.error("Encryption failed", metadata: [
            "reason": reason,
            "operation": "backup"
        ])
        throw CommonError.operationFailed("Backup encryption failed")
    }
}
```

### 3. Error Recovery
Implement recovery strategies:

```swift
actor RetryableOperation {
    func execute() async throws -> Result {
        var attempts = 0
        while attempts < maxRetries {
            do {
                return try await performOperation()
            } catch let error as RecoverableError {
                attempts += 1
                try await handleError(error, attempt: attempts)
            } catch {
                throw error // Non-recoverable error
            }
        }
        throw CommonError.operationFailed("Max retry attempts exceeded")
    }
}
```

## Error Patterns

### 1. Result Type Usage
For operations that might fail:

```swift
enum OperationResult<T> {
    case success(T)
    case failure(Error)
    case partial(T, [Error])
    
    var value: T? {
        switch self {
        case .success(let value), .partial(let value, _):
            return value
        case .failure:
            return nil
        }
    }
}

func processItems(_ items: [Item]) async -> OperationResult<[ProcessedItem]> {
    var processed: [ProcessedItem] = []
    var errors: [Error] = []
    
    for item in items {
        do {
            let result = try await process(item)
            processed.append(result)
        } catch {
            errors.append(error)
        }
    }
    
    if errors.isEmpty {
        return .success(processed)
    } else if processed.isEmpty {
        return .failure(CommonError.operationFailed("All items failed"))
    } else {
        return .partial(processed, errors)
    }
}
```

### 2. Error Transformation
Convert between error types while preserving context:

```swift
extension Error {
    func asCommonError() -> CommonError {
        switch self {
        case let error as KeychainError:
            return error.toCommonError()
        case let error as CryptoError:
            return error.toCommonError()
        default:
            return .operationFailed(localizedDescription)
        }
    }
}

extension KeychainError {
    func toCommonError() -> CommonError {
        switch self {
        case .accessDenied(let details):
            return .permissionDenied("Keychain: \(details)")
        case .itemNotFound(let key):
            return .resourceNotFound("Keychain item: \(key)")
        // ... other cases
        }
    }
}
```

### 3. Async Error Handling
Handle errors in async contexts:

```swift
actor ErrorHandler {
    func handle<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch {
            try await logError(error)
            try await notifyObservers(of: error)
            throw error
        }
    }
}
```

## Integration with Logging

### 1. Error Logging
Log errors with context:

```swift
extension Logger {
    func logError(
        _ error: Error,
        context: ErrorContext,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        error(
            "Error occurred",
            metadata: [
                "error": "\(error)",
                "context": "\(context)",
                "file": "\(file)",
                "function": "\(function)",
                "line": "\(line)"
            ]
        )
    }
}
```

### 2. Error Monitoring
Track error patterns:

```swift
actor ErrorMonitor {
    private var errorCounts: [String: Int] = [:]
    
    func record(_ error: Error) async {
        let key = String(describing: type(of: error))
        errorCounts[key, default: 0] += 1
        
        if errorCounts[key] ?? 0 > threshold {
            await notifyHighErrorRate(type: key)
        }
    }
}
```

## Testing

### 1. Error Scenarios
Test error handling paths:

```swift
func testErrorHandling() async throws {
    let service = TestService()
    
    do {
        try await service.operationThatFails()
        XCTFail("Expected error not thrown")
    } catch let error as CommonError {
        XCTAssertEqual(
            error.localizedDescription,
            "Expected error message"
        )
    }
}
```

### 2. Recovery Testing
Test error recovery mechanisms:

```swift
func testErrorRecovery() async throws {
    let operation = RetryableOperation()
    
    // Inject failures
    operation.injectFailures(count: 2)
    
    // Should succeed after retries
    let result = try await operation.execute()
    XCTAssertNotNil(result)
}
```

### 3. Error Context Testing
Verify error context information:

```swift
func testErrorContext() async throws {
    let operation = ContextualOperation()
    
    do {
        try await operation.execute()
        XCTFail("Expected error not thrown")
    } catch {
        let context = try XCTUnwrap(error.errorContext)
        XCTAssertEqual(context.function, "execute")
        XCTAssertNotNil(context.operationId)
    }
}
