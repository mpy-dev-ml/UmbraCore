# BackupCoordinator Module

The BackupCoordinator module orchestrates backup operations across the UmbraCore framework, providing a streamlined approach to managing backup processes.

## Overview

BackupCoordinator handles the orchestration of backup operations, managing the creation, scheduling, execution, and monitoring of backups. It coordinates between different modules to provide a cohesive backup experience.

## Features

- Backup task orchestration
- Backup scheduling and timing
- Progress monitoring and reporting
- Error handling and recovery
- Backup verification and validation

## Usage

```swift
import BackupCoordinator

// Create a backup coordinator
let coordinator = BackupCoordinator()

// Configure a backup job
let backupJob = BackupJob(
    sources: ["/Users/username/Documents", "/Users/username/Pictures"],
    excludes: ["**/.DS_Store", "**/node_modules"],
    repository: mainRepository,
    schedule: BackupSchedule(
        frequency: .daily,
        preferredTime: "02:00",
        retryStrategy: .exponentialBackoff(maxAttempts: 3)
    ),
    tags: ["documents", "pictures", "important"]
)

// Register the backup job
try coordinator.registerBackupJob(backupJob)

// Run a backup immediately
try await coordinator.runBackupJob(
    id: backupJob.id,
    options: BackupOptions(
        compressionLevel: 6,
        verifyAfterCompletion: true
    )
)

// Monitor progress
coordinator.progressHandler = { progress in
    print("Backup progress: \(progress.percentage)%")
    print("Files processed: \(progress.filesProcessed)")
    print("Bytes processed: \(progress.bytesProcessed)")
}

// Get backup history
let history = try await coordinator.getBackupHistory(
    forRepository: mainRepository,
    limit: 10
)
```

## Integration

BackupCoordinator integrates with:

- RepositoryManager for repository access and management
- ResticCLIHelper for executing backup commands
- UmbraXPC for privileged operations
- Configuration for backup settings

## Advanced Features

- Incremental backups
- Snapshot management
- Differential backup strategies
- Backup chains and dependencies
- Resource-aware backup throttling

## Source Code

The source code for this module is located in the `Sources/BackupCoordinator` directory of the UmbraCore repository.
