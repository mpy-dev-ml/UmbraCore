# UmbraCore Modules

UmbraCore is organised into a set of specialised modules that work together to provide a comprehensive backup solution for macOS applications. Each module has a specific responsibility within the framework.

## Core Modules

| Module | Description |
|--------|-------------|
| [UmbraCore](umbracore.md) | The main integration module providing core functionality |
| [XPCProtocolsCore](xpcprotocolscore.md) | Foundation-free XPC protocol definitions |
| [SecurityProtocolsCore](securityprotocolscore.md) | Foundation-free security interfaces |

## Security Modules

| Module | Description |
|--------|-------------|
| [SecurityTypes](securitytypes.md) | Core security primitives and types |
| [UmbraCryptoService](umbracryptoservice.md) | Cryptographic operations implementation |
| [UmbraKeychainService](umbrakeychainservice.md) | Secure credential storage |

## Infrastructure Modules

| Module | Description |
|--------|-------------|
| [UmbraXPC](umbraxpc.md) | Cross-process communication infrastructure |
| [ErrorTypes](errortypes.md) | Error handling architecture |
| [Configuration](configuration.md) | Settings and preferences management |

## Repository and Backup Modules

| Module | Description |
|--------|-------------|
| [RepositoryManager](repositorymanager.md) | Repository lifecycle management |
| [BackupCoordinator](backupcoordinator.md) | Backup orchestration |
| [ResticCLIHelper](resticlihelper.md) | Type-safe Restic command execution |

## Module Integration

These modules are designed to work together seamlessly whilst maintaining clear boundaries and separation of concerns. The modular architecture allows for flexible integration into different types of applications.
