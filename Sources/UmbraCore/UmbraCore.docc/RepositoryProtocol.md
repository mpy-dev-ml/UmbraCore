# Repository Protocol

Core protocols and types for repository management.

## Overview

The Repository module defines protocols and types for managing backup repositories, providing a consistent interface for different storage backends.

## Topics

### Core Protocols

- ``Repositories/Protocols/RepositoryProtocol``

### Repository Operations

- ``ResticCLIHelper/Commands/InitCommand``
- ``ResticCLIHelper/Commands/CheckCommand``
- ``ResticCLIHelper/Commands/ListCommand``
- ``ResticCLIHelper/Commands/SnapshotCommand``

### Repository Models

- ``ResticCLIHelper/Models/RepositoryObject``
- ``ResticCLIHelper/Models/FileMetadata``
- ``ResticCLIHelper/Models/BackupProgress``

## See Also

- ``Core/Services/CoreService``
- ``Features/Logging/Services/LoggingService``
- ``ResticCLIHelper/Commands/ResticCommand``
