# UmbraCore Restic Integration

UmbraCore provides a secure, Swift-native interface to Restic backup functionality while maintaining full macOS sandbox compliance. This document explains how UmbraCore integrates with Restic and handles sandboxing requirements.

## Architecture Overview

```
┌─────────────────────────┐
│    Sandboxed Main App   │
│ (Limited Permissions)   │
├─────────────────────────┤
│  • User Interface      │
│  • Security Bookmarks  │
│  • State Management    │
└──────────┬──────────────┘
           ↓ XPC Protocol
┌─────────────────────────┐
│     XPC Service         │
│ (Elevated Privileges)   │
├─────────────────────────┤
│  • Command Execution   │
│  • File System Access  │
│  • Process Management  │
└──────────┬──────────────┘
           ↓ Swift Interface
┌─────────────────────────┐
│    ResticCLIHelper      │
├─────────────────────────┤
│  • Command Building    │
│  • Output Parsing      │
│  • Error Handling      │
└──────────┬──────────────┘
           ↓ CLI Execution
┌─────────────────────────┐
│    Native Restic CLI    │
│    (restic binary)      │
└─────────────────────────┘
```

## Component Responsibilities

### 1. Sandboxed Main App
- Manages user interface and interactions
- Handles security-scoped bookmarks
- Maintains repository state
- Communicates with XPC service
- Never executes Restic commands directly

### 2. XPC Service
- Runs with elevated privileges
- Executes Restic commands
- Manages file system access
- Handles process lifecycle
- Provides secure IPC channel

### 3. ResticCLIHelper
- Constructs type-safe Restic commands
- Validates command parameters
- Parses command output
- Handles errors and logging
- Manages environment variables

### 4. Native Restic Binary
- Performs actual backup operations
- Manages repository structure
- Handles data encryption
- Implements deduplication
- Maintains snapshot history

## Supported Restic Commands

UmbraCore provides Swift interfaces for all major Restic operations:

1. Repository Management
   - `init` - Initialize repository
   - `check` - Check repository integrity
   - `prune` - Remove unused data
   - `rebuild-index` - Rebuild repository index
   - `repair` - Repair repository

2. Backup Operations
   - `backup` - Create new backup
   - `restore` - Restore from backup
   - `copy` - Copy snapshots between repos

3. Snapshot Management
   - `snapshots` - List snapshots
   - `forget` - Remove snapshots
   - `diff` - Compare snapshots

4. Information and Search
   - `stats` - Show statistics
   - `list` - List repository contents
   - `find` - Find files in snapshots
   - `ls` - List snapshot contents

## Security Considerations

### Sandbox Compliance
- Main app runs in strict sandbox
- File access via security-scoped bookmarks
- Command execution via XPC service
- Proper entitlements configuration

### Credential Management
- Secure password handling
- Environment variable sanitisation
- Keychain integration
- Memory security practices

### File System Access
- Bookmark-based file access
- Path sanitisation
- Access scope validation
- Temporary permission handling

## Error Handling

1. Command-Level Errors
   - Parameter validation
   - Execution failures
   - Output parsing errors
   - Resource constraints

2. XPC Communication Errors
   - Connection failures
   - Message delivery issues
   - Service interruption
   - Privilege escalation

3. Repository Errors
   - Integrity issues
   - Lock conflicts
   - Access permission
   - Corruption detection

## Usage Examples

### Basic Repository Operations
```swift
// Initialize repository
let repo = try await repository.initialize(at: url)

// Check repository health
try await repository.checkHealth(
    options: .full,  // Includes data verification
    force: false     // Stop on first error
)

// Perform maintenance
try await repository.maintain(
    rebuildIndex: true  // Also rebuild repository index
)
```

### Backup Operations
```swift
// Create backup
try await repository.backup(
    source: sourceURL,
    tags: ["documents", "daily"],
    excludes: ["*.tmp"]
)

// Restore files
try await repository.restore(
    snapshot: "latest",
    target: restoreURL
)
```

## Best Practices

1. Repository Management
   - Regular health checks
   - Scheduled maintenance
   - Proper locking
   - State monitoring

2. Error Recovery
   - Graceful degradation
   - Automatic retry
   - User notification
   - State recovery

3. Performance
   - Async operations
   - Progress reporting
   - Resource management
   - Cache utilisation

4. Security
   - Minimal privileges
   - Secure defaults
   - Access validation
   - Audit logging

## Further Reading

- [Restic Documentation](https://restic.readthedocs.io/)
- [Apple Sandbox Documentation](https://developer.apple.com/documentation/security/app_sandbox)
- [XPC Programming Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html)
