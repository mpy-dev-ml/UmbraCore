# UmbraXPC Guide

## Overview
`UmbraXPC` provides a secure inter-process communication layer for UmbraCore services. It enables privilege separation and sandboxing while maintaining type safety and async/await support.

## Features
- Secure IPC communication
- Type-safe protocols
- Async/await support
- Error handling
- Privilege separation

## Basic Usage

### Service Definition
```swift
// Define XPC protocol
@objc protocol KeychainXPCProtocol {
    func store(password: String, forKey: String) async throws
    func retrieve(forKey: String) async throws -> String
    func remove(forKey: String) async throws
}

// Implement service
class KeychainXPCService: NSObject, KeychainXPCProtocol {
    func store(password: String, forKey: String) async throws {
        // Implementation
    }
    
    // Other implementations...
}
```

### Service Registration
```swift
// Register service
let service = XPCService(
    service: KeychainXPCService(),
    protocol: KeychainXPCProtocol.self
)

try await service.register()
```

### Client Usage
```swift
// Connect to service
let client = try XPCClient<KeychainXPCProtocol>()

// Use service
try await client.store(password: "secret", forKey: "key")
let value = try await client.retrieve(forKey: "key")
```

## Error Handling
```swift
do {
    try await client.store(password: "secret", forKey: "key")
} catch XPCError.connectionFailed {
    // Handle connection failure
} catch XPCError.serviceStopped {
    // Handle service stop
} catch {
    // Handle other errors
}
```

## Best Practices

### 1. Protocol Design
```swift
// Good protocol design
@objc protocol BackupXPCProtocol {
    // Clear operation names
    func startBackup(source: URL, destination: URL) async throws
    
    // Specific error types
    func checkAccess(path: String) async throws -> Bool
    
    // Progress reporting
    func getProgress() async throws -> Double
}
```

### 2. Error Handling
```swift
// Define specific errors
enum BackupXPCError: Error {
    case accessDenied(String)
    case insufficientSpace(needed: UInt64, available: UInt64)
    case connectionLost
}

// Handle errors appropriately
do {
    try await service.startBackup(source: src, destination: dest)
} catch BackupXPCError.accessDenied(let path) {
    // Handle access denied
} catch BackupXPCError.insufficientSpace(let needed, let available) {
    // Handle space issues
}
```

### 3. Resource Management
```swift
// Proper cleanup
class XPCManager {
    private var client: XPCClient<BackupXPCProtocol>?
    
    func shutdown() async {
        await client?.disconnect()
        client = nil
    }
}
```

## Advanced Usage

### 1. Custom Message Handling
```swift
class CustomXPCService: XPCServiceDelegate {
    func handleCustomMessage(_ message: [String: Any]) async throws -> Any {
        // Custom message handling
        switch message["type"] as? String {
        case "status":
            return await getStatus()
        case "control":
            return try await handleControl(message)
        default:
            throw XPCError.invalidMessage
        }
    }
}
```

### 2. Progress Reporting
```swift
protocol ProgressReporting {
    func reportProgress(_ progress: Double) async
}

class BackupXPCService: ProgressReporting {
    private var progress: Double = 0
    
    func reportProgress(_ progress: Double) async {
        self.progress = progress
        await notifyObservers()
    }
}
```

### 3. Connection Management
```swift
class XPCConnectionManager {
    private var connections: [String: XPCClient<Any>] = [:]
    
    func getConnection<T>(_ type: T.Type) async throws -> XPCClient<T> {
        let id = String(describing: type)
        
        if let existing = connections[id] as? XPCClient<T> {
            return existing
        }
        
        let new = try XPCClient<T>()
        connections[id] = new
        return new
    }
}
```

## Integration Examples

### 1. Backup Service
```swift
class BackupManager {
    private let xpc: XPCClient<BackupXPCProtocol>
    
    func startBackup() async throws {
        // Connect to XPC service
        try await xpc.connect()
        
        // Start backup operation
        try await xpc.startBackup(
            source: sourceURL,
            destination: destURL
        )
        
        // Monitor progress
        for await progress in xpc.progressUpdates() {
            updateUI(progress)
        }
    }
}
```

### 2. Security Service
```swift
class SecurityManager {
    private let xpc: XPCClient<SecurityXPCProtocol>
    
    func validateAccess() async throws -> Bool {
        try await xpc.withConnection { service in
            try await service.checkSecurity([
                "operation": "backup",
                "level": "system"
            ])
        }
    }
}
```

## Troubleshooting

### Common Issues

1. Connection Issues
```swift
// Implement retry logic
func connectWithRetry() async throws -> XPCClient<T> {
    var attempts = 0
    while attempts < 3 {
        do {
            return try await XPCClient<T>().connect()
        } catch {
            attempts += 1
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
    throw XPCError.connectionFailed
}
```

2. Service Recovery
```swift
// Handle service interruption
func handleServiceFailure() async throws {
    try await xpc.disconnect()
    try await Task.sleep(nanoseconds: 1_000_000_000)
    try await xpc.connect()
}
```

3. Resource Cleanup
```swift
// Proper resource management
class XPCResource {
    private var resources: Set<XPCClient<Any>> = []
    
    func cleanup() async {
        for resource in resources {
            await resource.disconnect()
        }
        resources.removeAll()
    }
}
```
