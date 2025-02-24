---
layout: docs
title: Performance Optimisation Guide
description: Learn about performance optimisation in UmbraCore
nav_order: 8
parent: Guides
---

# Performance Optimisation in UmbraCore

## Overview
Performance is crucial for backup operations. This guide covers performance optimisation techniques used in UmbraCore and best practices for maintaining high performance.

## Core Principles

### 1. Asynchronous Operations
Leverage Swift's async/await for non-blocking operations:

```swift
actor BackupCoordinator {
    func backupMultipleDirectories(_ paths: [String]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for path in paths {
                group.addTask {
                    try await backupDirectory(path)
                }
            }
            try await group.waitForAll()
        }
    }
}
```

### 2. Memory Management
Efficient memory usage patterns:

```swift
actor StreamProcessor {
    // Use streams for large data
    func processLargeFile(_ url: URL) async throws {
        for try await line in url.lines {
            try await processLine(line)
        }
    }
    
    // Batch small operations
    func processBatch(_ items: [Item]) async throws {
        let batchSize = 100
        for batch in items.chunked(into: batchSize) {
            try await processBatchItems(batch)
        }
    }
}
```

### 3. Resource Pooling
Pool and reuse expensive resources:

```swift
actor ConnectionPool {
    private var connections: [Connection] = []
    private let maxConnections = 10
    
    func acquire() async throws -> Connection {
        if let connection = connections.popLast() {
            return connection
        }
        
        guard connections.count < maxConnections else {
            throw PoolError.maxConnectionsReached
        }
        
        return try await createConnection()
    }
    
    func release(_ connection: Connection) async {
        if connections.count < maxConnections {
            connections.append(connection)
        } else {
            await connection.close()
        }
    }
}
```

## Optimisation Techniques

### 1. Caching
Implement efficient caching strategies:

```swift
actor CacheManager {
    private var cache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    
    func cachedValue(
        forKey key: String,
        generator: () async throws -> Any
    ) async throws -> Any {
        // Check memory cache
        if let cached = cache.object(forKey: key as NSString) {
            return cached
        }
        
        // Generate new value
        let value = try await generator()
        cache.setObject(value as AnyObject, forKey: key as NSString)
        return value
    }
    
    func clearStaleEntries() async {
        // Implement cache eviction policy
    }
}
```

### 2. Data Structures
Choose appropriate data structures:

```swift
struct PerformanceOptimised {
    // Use Set for fast lookups
    private var processedItems: Set<String> = []
    
    // Use Dictionary for O(1) access
    private var itemCache: [String: Item] = [:]
    
    // Use Array for ordered data
    private var processingQueue: [Item] = []
    
    // Use ContiguousArray for better performance with value types
    private var metrics: ContiguousArray<Double> = []
}
```

### 3. Lazy Loading
Defer expensive operations:

```swift
class LazyResource {
    private lazy var expensiveResource: Resource = {
        createExpensiveResource()
    }()
    
    private func createExpensiveResource() -> Resource {
        // Only created when first accessed
        Resource(configuration: loadConfiguration())
    }
}
```

## Performance Monitoring

### 1. Metrics Collection
Track performance metrics:

```swift
actor PerformanceMonitor {
    private var metrics: [String: [TimeInterval]] = [:]
    
    func measure<T>(
        operation: String,
        block: () async throws -> T
    ) async throws -> T {
        let start = ProcessInfo.processInfo.systemUptime
        let result = try await block()
        let duration = ProcessInfo.processInfo.systemUptime - start
        
        await record(operation: operation, duration: duration)
        return result
    }
    
    private func record(operation: String, duration: TimeInterval) {
        metrics[operation, default: []].append(duration)
        
        if metrics[operation]?.count ?? 0 > 1000 {
            metrics[operation]?.removeFirst(500)
        }
    }
    
    func getMetrics(for operation: String) -> PerformanceMetrics {
        guard let measurements = metrics[operation] else {
            return PerformanceMetrics.empty
        }
        
        return PerformanceMetrics(
            average: measurements.average,
            median: measurements.median,
            percentile95: measurements.percentile(95),
            count: measurements.count
        )
    }
}
```

### 2. Performance Logging
Log performance data:

```swift
extension Logger {
    func logPerformance(
        _ metrics: PerformanceMetrics,
        operation: String,
        file: String = #file,
        function: String = #function
    ) {
        info(
            "Performance metrics",
            metadata: [
                "operation": "\(operation)",
                "average": "\(metrics.average)",
                "median": "\(metrics.median)",
                "p95": "\(metrics.percentile95)",
                "count": "\(metrics.count)",
                "file": "\(file)",
                "function": "\(function)"
            ]
        )
    }
}
```

### 3. Alerts and Thresholds
Monitor performance thresholds:

```swift
actor PerformanceAlert {
    private let thresholds: [String: TimeInterval]
    private let notifier: AlertNotifier
    
    func checkThresholds(_ metrics: PerformanceMetrics, operation: String) async {
        guard let threshold = thresholds[operation] else { return }
        
        if metrics.percentile95 > threshold {
            await notifier.alert(
                """
                Performance degradation detected:
                Operation: \(operation)
                P95: \(metrics.percentile95)
                Threshold: \(threshold)
                """
            )
        }
    }
}
```

## Best Practices

### 1. Batch Processing
Batch operations for efficiency:

```swift
actor BatchProcessor {
    private let batchSize = 100
    
    func process(_ items: [Item]) async throws {
        let batches = items.chunked(into: batchSize)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for batch in batches {
                group.addTask {
                    try await processBatch(batch)
                }
            }
            try await group.waitForAll()
        }
    }
}
```

### 2. Resource Management
Proper resource cleanup:

```swift
class ManagedResource {
    private var resources: [Resource] = []
    
    func use<T>(_ resource: Resource, operation: (Resource) throws -> T) throws -> T {
        resources.append(resource)
        defer {
            resource.cleanup()
            resources.removeAll { $0 === resource }
        }
        return try operation(resource)
    }
}
```

### 3. Background Processing
Offload heavy work:

```swift
actor BackgroundProcessor {
    private let queue = DispatchQueue(
        label: "com.umbracore.background",
        qos: .background
    )
    
    func processInBackground(_ work: @escaping () -> Void) {
        queue.async {
            work()
        }
    }
}
```

## Testing

### 1. Performance Tests
Test performance metrics:

```swift
class PerformanceTests: XCTestCase {
    func testOperationPerformance() throws {
        measure {
            // Performance-critical code
        }
    }
    
    func testAsyncPerformance() async throws {
        let metrics = try await measureAsync {
            try await performOperation()
        }
        
        XCTAssertLessThan(metrics.average, 0.1)
        XCTAssertLessThan(metrics.percentile95, 0.2)
    }
}
```

### 2. Memory Tests
Test memory usage:

```swift
class MemoryTests: XCTestCase {
    func testMemoryUsage() throws {
        let tracker = MemoryTracker()
        
        autoreleasepool {
            // Memory-intensive operation
        }
        
        XCTAssertLessThan(
            tracker.peakMemoryUsage,
            50 * 1024 * 1024 // 50MB
        )
    }
}
```

### 3. Load Tests
Test under load:

```swift
class LoadTests: XCTestCase {
    func testConcurrentOperations() async throws {
        let operations = 1000
        let service = TestService()
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<operations {
                group.addTask {
                    try await service.operation()
                }
            }
            try await group.waitForAll()
        }
    }
}
