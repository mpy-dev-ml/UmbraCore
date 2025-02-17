---
layout: docs
title: Thread Safety Guide
description: Learn about thread safety in UmbraCore
nav_order: 6
parent: Guides
---

# Thread Safety in UmbraCore

## Overview
UmbraCore is designed to be thread-safe by default. All public APIs can be safely called from multiple threads concurrently. This guide explains our thread safety guarantees and best practices.

## Core Principles

### 1. Actor-Based Services
All core services in UmbraCore use Swift's actor system to ensure thread safety:

```swift
actor KeychainService {
    private var cache: [String: Data] = [:]
    
    func store(_ data: Data, forKey key: String) async throws {
        // Thread-safe access to cache
        cache[key] = data
        try await persistToKeychain(data, key)
    }
}
```

### 2. Immutable State
We prefer immutable state to minimize synchronization needs:

```swift
struct BackupConfig {
    // Immutable properties
    let sourcePath: String
    let destinationPath: String
    let excludePatterns: [String]
    
    // Instead of mutating, create new instance
    func withExcludePattern(_ pattern: String) -> BackupConfig {
        var patterns = excludePatterns
        patterns.append(pattern)
        return BackupConfig(
            sourcePath: sourcePath,
            destinationPath: destinationPath,
            excludePatterns: patterns
        )
    }
}
```

### 3. Synchronized Collections
When mutable state is necessary, we use synchronized collections:

```swift
actor CacheManager {
    private var cache = [String: Any]()
    private let queue = DispatchQueue(label: "com.umbracore.cache")
    
    func set(_ value: Any, forKey key: String) {
        queue.sync { cache[key] = value }
    }
    
    func get(_ key: String) -> Any? {
        queue.sync { cache[key] }
    }
}
```

## Best Practices

### 1. Async/Await Usage
Always use async/await for asynchronous operations:

```swift
// Good
func backupFiles() async throws {
    try await prepareBackup()
    try await performBackup()
    try await cleanup()
}

// Avoid
func backupFiles(completion: @escaping (Error?) -> Void) {
    prepareBackup { error in
        guard error == nil else {
            completion(error)
            return
        }
        // Callback hell continues...
    }
}
```

### 2. Resource Access
Use proper resource access patterns:

```swift
actor ResourceManager {
    private var isLocked = false
    
    func acquireResource() async throws {
        guard !isLocked else {
            throw ResourceError.alreadyLocked
        }
        isLocked = true
    }
    
    func releaseResource() {
        isLocked = false
    }
}
```

### 3. Shared State
Minimize shared state, use message passing:

```swift
actor BackupCoordinator {
    private var activeBackups: Set<UUID> = []
    
    func startBackup() async throws -> UUID {
        let id = UUID()
        activeBackups.insert(id)
        return id
    }
    
    func completeBackup(_ id: UUID) {
        activeBackups.remove(id)
    }
}
```

## Common Patterns

### 1. Double-Checked Locking
For expensive initialization:

```swift
actor ConfigurationManager {
    private var config: Configuration?
    
    func getConfiguration() async throws -> Configuration {
        if let existing = config {
            return existing
        }
        
        let loaded = try await loadConfiguration()
        config = loaded
        return loaded
    }
}
```

### 2. Reader-Writer Pattern
For concurrent read access:

```swift
actor DatabaseManager {
    private var isWriting = false
    private var activeReaders = 0
    
    func read() async throws -> Data {
        while isWriting {
            try await Task.sleep(nanoseconds: 100_000)
        }
        activeReaders += 1
        defer { activeReaders -= 1 }
        return try getData()
    }
    
    func write(_ data: Data) async throws {
        while activeReaders > 0 {
            try await Task.sleep(nanoseconds: 100_000)
        }
        isWriting = true
        defer { isWriting = false }
        try await writeData(data)
    }
}
```

### 3. Task Management
For concurrent operations:

```swift
class BackupTask {
    func executeParallel(_ operations: [Operation]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for operation in operations {
                group.addTask {
                    try await operation.execute()
                }
            }
            try await group.waitForAll()
        }
    }
}
```

## Troubleshooting

### 1. Deadlock Prevention
```swift
actor Service {
    // Avoid nested actor calls
    func operation1() async {
        await operation2() // Could deadlock if not careful
    }
    
    func operation2() async {
        // Implementation
    }
}

// Better approach
actor Service {
    func operation1() async {
        // Execute independently
        try await Task.sleep(nanoseconds: 100_000)
        await operation2()
    }
}
```

### 2. Race Condition Detection
```swift
actor StateManager {
    private var state: State
    private var version: UInt64 = 0
    
    func modify(_ change: (State) -> State) async {
        let currentVersion = version
        state = change(state)
        
        // Detect concurrent modifications
        guard version == currentVersion else {
            throw ConcurrencyError.stateModified
        }
        version += 1
    }
}
```

### 3. Performance Issues
```swift
actor PerformanceOptimized {
    // Batch operations to reduce actor hops
    func batchOperation(_ items: [Item]) async {
        // Single actor hop for batch
        items.forEach { process($0) }
    }
    
    // Avoid frequent actor hops
    private func process(_ item: Item) {
        // Local processing
    }
}
```

## Testing

### 1. Concurrency Testing
```swift
func testConcurrentAccess() async throws {
    let service = SharedService()
    
    try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<100 {
            group.addTask {
                try await service.operation()
            }
        }
        try await group.waitForAll()
    }
}
```

### 2. Race Condition Testing
```swift
func testRaceConditions() async throws {
    let service = SharedService()
    
    async let operation1 = service.modify()
    async let operation2 = service.modify()
    
    // This should handle concurrent modifications gracefully
    try await [operation1, operation2]
}
