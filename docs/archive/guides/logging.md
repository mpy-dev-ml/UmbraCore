# UmbraLogging Guide

## Overview
`UmbraLogging` provides a centralised, structured logging system built on SwiftyBeaver. It supports multiple destinations, log levels, and contextual metadata.

## Features
- Structured logging
- Multiple log levels
- Context metadata
- File output
- Console output
- Custom formatters

## Basic Usage

### Configuration
```swift
import UmbraLogging

// Basic setup
UmbraLogger.configure(level: .info)

// Custom configuration
let config = LoggerConfiguration(
    level: .debug,
    destinations: [.console, .file],
    metadata: ["app": "UmbraCore"]
)
UmbraLogger.configure(config)
```

### Logging Messages
```swift
// Basic logging
logger.info("Backup started")
logger.error("Failed to access repository")

// With metadata
logger.info("File processed", metadata: [
    "size": fileSize,
    "path": filePath
])

// With error context
logger.error("Backup failed", error: error, metadata: [
    "repository": repoId,
    "files": fileCount
])
```

## Log Levels

### Available Levels
```swift
// Verbose - detailed information
logger.verbose("Entering backup loop")

// Debug - debugging information
logger.debug("Processing file: \(filename)")

// Info - general information
logger.info("Backup completed successfully")

// Warning - potential issues
logger.warning("Repository space low")

// Error - operation failures
logger.error("Failed to store credential")

// Critical - system-wide issues
logger.critical("Database corruption detected")
```

## Best Practices

### 1. Log Level Selection
```swift
// Development
#if DEBUG
    UmbraLogger.configure(level: .debug)
#else
    UmbraLogger.configure(level: .info)
#endif

// Production with environment override
if let levelString = Environment.logLevel {
    UmbraLogger.configure(level: LogLevel(string: levelString))
}
```

### 2. Contextual Information
```swift
// Add operation context
logger.info("Starting backup", metadata: [
    "operation": "backup",
    "type": "incremental",
    "source": sourcePath,
    "destination": destPath
])

// Add error context
logger.error("Operation failed", metadata: [
    "operation": operation.name,
    "duration": duration,
    "retries": retryCount,
    "error": error.localizedDescription
])
```

### 3. Sensitive Data
```swift
// Never log credentials
logger.info("Connecting to repository", metadata: [
    "url": repository.url,
    "type": repository.type
    // DON'T include passwords or keys
])

// Mask sensitive data
logger.info("User authenticated", metadata: [
    "user": user.id,
    "token": "****" // Masked token
])
```

## Advanced Usage

### 1. Custom Destinations
```swift
let customDestination = LogDestination(
    identifier: "analytics",
    minimumLevel: .info,
    formatter: AnalyticsFormatter()
)

UmbraLogger.addDestination(customDestination)
```

### 2. Custom Formatters
```swift
class JSONFormatter: LogFormatter {
    func format(_ entry: LogEntry) -> String {
        let json: [String: Any] = [
            "timestamp": entry.timestamp,
            "level": entry.level.rawValue,
            "message": entry.message,
            "metadata": entry.metadata
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
```

### 3. Context Managers
```swift
class OperationContext {
    private var metadata: [String: Any]
    
    func execute(_ operation: String) async throws {
        logger.withMetadata(metadata) {
            logger.info("Starting operation")
            // Execute operation
            logger.info("Operation completed")
        }
    }
}
```

## Integration Examples

### 1. Service Integration
```swift
class BackupService {
    private let logger = UmbraLogger.forModule("BackupService")
    
    func performBackup() async throws {
        logger.info("Starting backup", metadata: [
            "type": backupType,
            "files": fileCount
        ])
        
        do {
            try await runBackup()
            logger.info("Backup completed")
        } catch {
            logger.error("Backup failed", error: error)
            throw error
        }
    }
}
```

### 2. Error Tracking
```swift
class ErrorTracker {
    private let logger = UmbraLogger.forModule("ErrorTracker")
    
    func track(_ error: Error, context: [String: Any]) {
        logger.error("Error occurred", metadata: [
            "error": error.localizedDescription,
            "type": String(describing: type(of: error)),
            "context": context
        ])
    }
}
```

## Troubleshooting

### Common Issues

1. Log File Management
```swift
// Rotate log files
UmbraLogger.configure(
    fileConfig: FileConfiguration(
        directory: logDirectory,
        maxFileSize: 10_000_000,  // 10MB
        maxFileCount: 5
    )
)
```

2. Performance Optimization
```swift
// Avoid expensive logging in production
if logger.isEnabled(for: .debug) {
    let expensive = calculateExpensiveMetadata()
    logger.debug("Details", metadata: expensive)
}
```

3. Error Investigation
```swift
// Enable full debug logging temporarily
UmbraLogger.configure(
    level: .verbose,
    destinations: [.console, .file],
    metadata: ["debug": true]
)
```
