---
layout: default
title: Configuration
nav_order: 3
description: Configuration options and error handling in UmbraCore
---

# Configuration Guide

## Overview

UmbraCore provides a robust configuration system with built-in error handling and validation. This guide covers configuration options and error handling patterns.

## Error Handling

### Error Types

UmbraCore uses a structured error handling system:

```swift
// Common base errors
enum CommonError: Error {
    case invalidArgument(String)
    case resourceNotFound(String)
    case permissionDenied(String)
    case operationFailed(String)
}

// Service-specific errors
enum KeychainError: Error {
    case itemNotFound(String)
    case duplicateItem(String)
    case accessDenied(String)
    case invalidData(String)
}
```

### Error Context

Errors include detailed context for debugging:

```swift
struct ErrorContext {
    let file: String
    let function: String
    let line: Int
    let timestamp: Date
    let operationId: UUID
    var userInfo: [String: Any]
}
```

### Error Handling Patterns

Handle errors appropriately in your code:

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
    }
}
```

## Configuration Options

### Backup Settings

Configure backup behaviour:

```swift
struct BackupConfiguration {
    let compressionLevel: CompressionLevel
    let excludePatterns: [String]
    let retentionPolicy: RetentionPolicy
    let verifyAfterBackup: Bool
    
    static let `default` = BackupConfiguration(
        compressionLevel: .balanced,
        excludePatterns: [".DS_Store", "*.tmp"],
        retentionPolicy: .standard,
        verifyAfterBackup: true
    )
}
```

### Network Settings

Control network behaviour:

```swift
struct NetworkConfiguration {
    let timeoutSeconds: Double
    let maxRetries: Int
    let retryDelay: TimeInterval
    let rateLimit: RateLimit?
    
    static let `default` = NetworkConfiguration(
        timeoutSeconds: 30,
        maxRetries: 3,
        retryDelay: 1.0,
        rateLimit: .init(requestsPerMinute: 60)
    )
}
```

### Logging Configuration

Configure logging behaviour:

```swift
struct LogConfiguration {
    let level: LogLevel
    let destination: LogDestination
    let includeMetadata: Bool
    let retentionDays: Int
    
    static let `default` = LogConfiguration(
        level: .info,
        destination: .file,
        includeMetadata: true,
        retentionDays: 30
    )
}
```

## Best Practices

### Configuration Validation

Always validate configuration:

```swift
func validateConfiguration(_ config: BackupConfiguration) throws {
    guard config.compressionLevel.isSupported else {
        throw CommonError.invalidArgument(
            "Unsupported compression level: \(config.compressionLevel)"
        )
    }
    
    for pattern in config.excludePatterns {
        guard pattern.isValidGlobPattern else {
            throw CommonError.invalidArgument(
                "Invalid exclude pattern: \(pattern)"
            )
        }
    }
}
```

### Error Recovery

Implement retry logic for recoverable errors:

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

## Related Documentation

- [Security Guide](security.md) - Security configuration
- [Advanced Features](advanced-features.md) - Advanced configuration options
- [API Reference](api-reference.md) - Complete API documentation
- [Troubleshooting Guide](troubleshooting.md) - Common issues and solutions
