# UmbraBookmarkService Guide

## Overview
`UmbraBookmarkService` manages persistent file system access through security-scoped bookmarks. It provides safe and reliable access to files and directories across app launches.

## Features
- Security-scoped bookmarks
- Persistent file access
- Thread-safe operations
- Automatic bookmark resolution

## Basic Usage

### Creating Bookmarks
```swift
let service = try UmbraBookmarkService()

// Create bookmark for file
let fileURL = URL(fileURLWithPath: "/path/to/file")
try await service.create(
    for: fileURL,
    withName: "important-file"
)

// Create bookmark for directory
let dirURL = URL(fileURLWithPath: "/path/to/directory")
try await service.create(
    for: dirURL,
    withName: "backup-directory"
)
```

### Resolving Bookmarks
```swift
// Get URL from bookmark
let fileURL = try await service.resolve(name: "important-file")

// Access with scope
try await service.access(name: "backup-directory") { url in
    // Work with URL within security scope
    let contents = try FileManager.default.contentsOfDirectory(at: url)
}
```

### Removing Bookmarks
```swift
try await service.remove(name: "important-file")
```

## Error Handling
```swift
do {
    try await service.create(for: url, withName: name)
} catch BookmarkError.invalidURL(let url) {
    // Handle invalid URL
} catch BookmarkError.accessDenied(let reason) {
    // Handle access denied
} catch {
    // Handle other errors
}
```

## Best Practices

### 1. Bookmark Naming
- Use descriptive names
- Include context
- Follow naming conventions

```swift
// Good
"main-backup-directory"
"config-file-production"

// Bad
"bookmark1"
"file"
```

### 2. Access Scoping
- Use scoped access
- Clean up resources
- Handle access errors

### 3. Error Recovery
- Implement retry logic
- Provide user feedback
- Log access failures

## Advanced Usage

### 1. Custom Bookmark Options
```swift
let options = BookmarkOptions(
    securityScope: .workingDirectory,
    persistence: .permanent
)

try await service.create(
    for: url,
    withName: name,
    options: options
)
```

### 2. Batch Operations
```swift
let bookmarks = [
    "dir1": url1,
    "dir2": url2
]

try await service.createBatch(bookmarks)
```

### 3. Access Control
```swift
let access = BookmarkAccess(
    scope: .minimal,
    duration: .temporary
)

try await service.access(
    name: "secure-directory",
    access: access
) { url in
    // Limited scope access
}
```

## Integration Examples

### 1. Backup Directory Management
```swift
class BackupManager {
    private let bookmarks: UmbraBookmarkService
    
    init() throws {
        bookmarks = try UmbraBookmarkService()
    }
    
    func configureBackupDirectory(_ url: URL) async throws {
        // Create persistent bookmark
        try await bookmarks.create(
            for: url,
            withName: "backup-root"
        )
    }
    
    func performBackup() async throws {
        try await bookmarks.access("backup-root") { url in
            // Perform backup operations
            try await backupContents(of: url)
        }
    }
}
```

### 2. Configuration File Access
```swift
class ConfigManager {
    private let bookmarks: UmbraBookmarkService
    
    func saveConfig(_ config: Config) async throws {
        try await bookmarks.access("config-file") { url in
            let data = try JSONEncoder().encode(config)
            try data.write(to: url)
        }
    }
}
```

## Troubleshooting

### Common Issues

1. Stale Bookmarks
```swift
// Refresh bookmark if stale
if await service.isStale(name: "backup-dir") {
    try await service.refresh(name: "backup-dir")
}
```

2. Access Denied
```swift
// Request user permission if needed
func ensureAccess(to name: String) async throws {
    do {
        try await service.verifyAccess(name: name)
    } catch BookmarkError.accessDenied {
        try await requestUserPermission(for: name)
    }
}
```

3. Resource Management
```swift
// Proper resource cleanup
func processDirectory() async throws {
    try await service.access("work-dir") { url in
        defer {
            // Cleanup code
        }
        
        // Process directory
    }
}
```
