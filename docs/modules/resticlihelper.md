# ResticCLIHelper Module

The ResticCLIHelper module provides type-safe Restic command execution capabilities for the UmbraCore framework.

## Overview

ResticCLIHelper encapsulates the interaction with the Restic command-line tool, providing a type-safe and structured API for executing Restic commands. This module handles command building, parameter validation, and execution in a secure environment.

## Features

- Type-safe Restic command building
- Secure parameter validation
- Structured output parsing
- Error handling and logging
- Sandboxed execution support

## Usage

```swift
import ResticCLIHelper

// Create a helper instance
let resticHelper = ResticCLIHelper()

// Configure a repository
let repoConfig = ResticRepositoryConfiguration(
    path: "/Volumes/Backup/main-repository",
    password: securePasswordReference,
    extraEnvironment: ["RESTIC_CACHE_DIR": "/tmp/restic-cache"]
)

// Initialise a repository
try await resticHelper.initialise(repository: repoConfig)

// Create a backup
try await resticHelper.backup(
    repository: repoConfig,
    sourcePaths: ["/Users/username/Documents"],
    excludePaths: ["/Users/username/Documents/temp"],
    tags: ["documents", "important"]
)

// List snapshots
let snapshots = try await resticHelper.listSnapshots(
    repository: repoConfig,
    tag: "documents"
)
```

## Integration

ResticCLIHelper integrates with:

- UmbraXPC for executing commands in a privileged context
- SecurityTypes for secure credential handling
- RepositoryManager for repository lifecycle operations
- BackupCoordinator for orchestrating backup operations

## Security Considerations

- Never exposes raw passwords in command-line arguments
- Validates all parameters before execution
- Uses secure environment variables for credentials
- Sanitises command output for logging

## Source Code

The source code for this module is located in the `Sources/ResticCLIHelper` directory of the UmbraCore repository.
