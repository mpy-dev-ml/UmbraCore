# Repository Handling

The repository handling system in UmbraCore manages repository health, space usage, and maintenance.

## Features

- Repository health checks
- Space usage monitoring
- Cache management
- Deduplication statistics
- Repository maintenance
- Performance optimization

## Core Types

### Health Monitoring

```swift
protocol RepositoryHealth {
    func checkHealth() async throws -> HealthStatus
    func runMaintenance() async throws
    func repairIndex() async throws
    func validateData() async throws -> ValidationResult
}
```

### Space Management

```swift
protocol SpaceManager {
    func getUsage() async throws -> SpaceUsage
    func forecast(days: Int) async throws -> SpaceForecast
    func cleanup(policy: RetentionPolicy) async throws -> CleanupResult
}
```

## Usage Examples

### Health Check

```swift
let health = RepositoryHealth()
let status = try await health.checkHealth()
if status.needsMaintenance {
    try await health.runMaintenance()
}
```

### Space Management

```swift
let space = SpaceManager()
let usage = try await space.getUsage()
print("Used: \(usage.used), Available: \(usage.available)")
```

### Cache Management

```swift
let cache = CacheManager()
try await cache.optimize()
try await cache.prune(olderThan: .days(7))
```

## Error Handling

Common repository-related errors:

- `HealthCheckError`: Health check failures
- `MaintenanceError`: Maintenance issues
- `SpaceError`: Space management problems
- `CacheError`: Cache operation failures

## Best Practices

1. Regular health checks
2. Proactive maintenance
3. Space monitoring
4. Cache optimization
5. Error recovery
