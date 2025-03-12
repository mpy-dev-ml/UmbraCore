# Configuration Module

The Configuration module provides settings and preferences management capabilities for the UmbraCore framework.

## Overview

The Configuration module handles application settings, user preferences, and framework configuration, offering a consistent and type-safe approach to managing configuration across the UmbraCore framework.

## Features

- Type-safe configuration management
- Default value handling
- Configuration validation
- Secure storage for sensitive settings
- Configuration migration support

## Usage

```swift
import Configuration

// Access application configuration
let config = Configuration.shared

// Read configuration values
let backupInterval = config.get(\.backupSchedule.intervalHours)
let compressionLevel = config.get(\.backup.compressionLevel)
let isEncryptionEnabled = config.get(\.security.encryptBackups)

// Update configuration values
try config.set(\.backup.compressionLevel, to: 6)
try config.set(\.security.encryptBackups, to: true)

// Use strongly-typed configuration
struct BackupSettings: ConfigurationProvider {
    @ConfigurationProperty(\.backup.excludedPaths)
    var excludedPaths: [String]
    
    @ConfigurationProperty(\.backup.maxParallelOperations)
    var maxParallelOperations: Int
}

let backupSettings = BackupSettings()
print("Excluded paths: \(backupSettings.excludedPaths)")
print("Max parallel operations: \(backupSettings.maxParallelOperations)")
```

## Integration

The Configuration module integrates with:

- UmbraCore for framework-level settings
- UmbraKeychainService for secure settings storage
- RepositoryManager for repository configuration
- BackupCoordinator for backup settings

## Security Considerations

- Sensitive configuration values are stored securely
- Configuration validation prevents insecure settings
- Configuration access is controlled through appropriate access levels
- Configuration migration handles changes safely

## Source Code

The source code for this module is located in the `Sources/Configuration` directory of the UmbraCore repository.
