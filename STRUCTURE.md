# UmbraCore Project Structure

This document outlines the modular structure of UmbraCore and maps the migration path from the legacy codebase.

## Project Overview

UmbraCore is organized into distinct modules, each with its own responsibility and public API surface. The modular design promotes:
- Clear separation of concerns
- Maintainable, testable code
- Flexible dependency management
- Scalable architecture

## Module Organization

Each module follows a consistent structure:
```
Module/
├─ Models/        # Domain models and data structures
├─ Services/      # Business logic and implementations
├─ Errors/        # Module-specific error types
├─ Extensions/    # Swift extensions related to the module
└─ Protocols/     # Public interfaces and protocols
```

## Module Details and File Mapping

### ResticCLIHelper
Core interaction with the Restic command-line interface.

```
ResticCLIHelper/
├─ Models/
│  ├─ ResticCommand.swift          <- UmbraCore/Models/ResticCommand.swift
│  ├─ PreparedCommand.swift        <- UmbraCore/Models/PreparedCommand.swift
│  └─ ProcessResult.swift          <- UmbraCore/Models/ProcessResult.swift
├─ Errors/
│  └─ ProcessError.swift           <- UmbraCore/Models/ProcessError.swift
└─ Services/
   └─ CommandExecutor.swift        <- New file
```

### Repositories
Repository management and operations.

```
Repositories/
├─ Models/
│  ├─ Repository.swift             <- UmbraCore/Models/Repository.swift
│  ├─ RepositoryHealth.swift       <- UmbraCore/Models/RepositoryHealth.swift
│  ├─ RepositoryStatus.swift       <- UmbraCore/Models/RepositoryStatus.swift
│  ├─ RepositoryType.swift         <- UmbraCore/Models/RepositoryType.swift
│  └─ DiscoveredRepository.swift   <- UmbraCore/Models/DiscoveredRepository.swift
└─ Services/
   └─ RepositoryManager.swift      <- New file
```

### Snapshots
Snapshot creation, management, and restoration.

```
Snapshots/
├─ Models/
│  ├─ ResticSnapshot.swift         <- UmbraCore/Models/ResticSnapshot.swift
│  ├─ Snapshot.swift               <- UmbraCore/Models/Snapshot.swift
│  └─ BackupTypes.swift            <- UmbraCore/Models/BackupTypes.swift
└─ Services/
   └─ SnapshotManager.swift        <- New file
```

### Config
Configuration and security management.

```
Config/
├─ Models/
│  ├─ KeychainCredentials.swift    <- UmbraCore/Models/KeychainCredentials.swift
│  └─ RepositoryCredentials.swift  <- UmbraCore/Models/RepositoryCredentials.swift
├─ Security/
│  └─ SecurityScopedAccess.swift   <- UmbraCore/Models/SecurityScopedAccess.swift
└─ Services/
   └─ ConfigurationManager.swift   <- New file
```

### Logging
Structured logging and performance monitoring.

```
Logging/
├─ Models/
│  └─ ProgressTracker.swift        <- UmbraCore/Models/ProgressTracker.swift
└─ Services/
   ├─ Logger.swift                 <- UmbraCore/Logging/Logger.swift
   └─ PerformanceMonitor.swift     <- New file
```

### ErrorHandling
Centralized error management.

```
ErrorHandling/
├─ Models/
│  └─ CommonErrors.swift           <- New file combining common error patterns
└─ Services/
   └─ ErrorReporter.swift          <- New file
```

### Autocomplete
Command and path completion.

```
Autocomplete/
├─ Models/
│  └─ CompletionItem.swift         <- New file
└─ Services/
   └─ CompletionProvider.swift     <- New file
```

## Implementation Guidelines

1. **Module Independence**
   - Each module should have a clear, well-defined public API
   - Dependencies between modules should be explicit in Package.swift
   - Internal implementation details should be private

2. **Error Handling**
   - Module-specific errors should be defined within the module
   - Error types should conform to LocalizedError
   - Error handling should be comprehensive and user-friendly

3. **Concurrency**
   - Use modern Swift concurrency (async/await)
   - Ensure thread safety with appropriate actor isolation
   - Handle task cancellation properly

4. **Documentation**
   - All public APIs must be documented
   - Include usage examples in documentation
   - Maintain comprehensive README files

5. **Testing**
   - Each module should have corresponding test target
   - Tests should cover public APIs thoroughly
   - Include performance tests where relevant

## Migration Strategy

1. **Phase 1: Core Infrastructure**
   - Set up module structure
   - Implement ErrorHandling and Logging
   - Establish basic testing framework

2. **Phase 2: Essential Features**
   - Migrate ResticCLIHelper
   - Implement Repositories
   - Set up Config module

3. **Phase 3: Advanced Features**
   - Migrate Snapshots
   - Implement Autocomplete
   - Add performance monitoring

4. **Phase 4: Polish**
   - Complete documentation
   - Add examples
   - Performance optimization
