# RepositoryManager Module

The RepositoryManager module provides repository lifecycle management capabilities for the UmbraCore framework.

## Overview

RepositoryManager handles all aspects of repository management, including creation, initialisation, validation, and maintenance of Restic repositories. It ensures repositories are properly configured, accessible, and maintained throughout their lifecycle.

## Features

- Repository initialisation and setup
- Repository validation and health checks
- Repository configuration management
- Repository maintenance operations
- Multi-repository support

## Usage

```swift
import RepositoryManager

// Create a repository manager
let repoManager = RepositoryManager()

// Initialise a new repository
let repository = try await repoManager.initialise(
    at: "/Volumes/Backup/my-repository",
    withPassword: securePasswordReference,
    options: RepositoryOptions(
        compressionLevel: 6,
        encryptionAlgorithm: .aes256
    )
)

// Check repository health
let healthStatus = try await repoManager.checkHealth(repository)
if healthStatus.needsMaintenance {
    try await repoManager.performMaintenance(
        on: repository,
        operations: [.prune, .check, .rebuild]
    )
}

// List repositories
let allRepositories = try await repoManager.listRepositories()
for repo in allRepositories {
    print("Repository: \(repo.name), Status: \(repo.status)")
}
```

## Integration

RepositoryManager integrates with:

- ResticCLIHelper for Restic command execution
- UmbraKeychainService for secure password management
- UmbraXPC for privileged operations
- BackupCoordinator for coordinating backup operations

## Security Considerations

- Repository passwords are managed securely
- Repository access control is enforced
- Repository integrity is validated
- Secure storage locations are recommended

## Source Code

The source code for this module is located in the `Sources/RepositoryManager` directory of the UmbraCore repository.
