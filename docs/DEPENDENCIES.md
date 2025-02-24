# UmbraCore Dependencies Documentation

## Core Module Structure

### Main Components

1. **API Layer**
   - `//Sources/API:Sources_API`
   - Dependencies:
     - Core/UmbraCore

2. **Core Services**
   - `//Sources/Core:Sources_Core`
   - `//Sources/Core/Services:CoreServices`
   - `//Sources/Core/UmbraCore:Sources_Core_UmbraCore`

3. **Security Components**
   - `//Sources/UmbraSecurity:Sources_UmbraSecurity`
   - `//Sources/SecurityUtils:Sources_SecurityUtils`
   - `//Sources/UmbraCrypto:UmbraCrypto`
   - `//Sources/UmbraCryptoService:Sources_UmbraCryptoService`
   - `//Sources/CryptoTypes:CryptoTypes`

4. **Restic Integration**
   - `//Sources/ResticCLIHelper:Sources_ResticCLIHelper`
   - `//Sources/ResticCLIHelper/Protocols:Sources_ResticCLIHelper_Protocols`
   - `//Sources/ResticCLIHelper/Types:Sources_ResticCLIHelper_Types`

5. **Storage & Persistence**
   - `//Sources/UmbraBookmarkService:Sources_UmbraBookmarkService`
   - `//Sources/UmbraKeychainService:UmbraKeychainService`
   - `//Sources/Repositories:Sources_Repositories`
   - `//Sources/Snapshots:Sources_Snapshots`

6. **Error Handling**
   - `//Sources/ErrorHandling:ErrorHandling`
   - `//Sources/ErrorHandling/Common:Sources_ErrorHandling_Common`
   - `//Sources/ErrorHandling/Models:Sources_ErrorHandling_Models`
   - `//Sources/ErrorHandling/Protocols:Sources_ErrorHandling_Protocols`

7. **Features**
   - `//Sources/Features:Sources_Features`
   - Crypto Features:
     - `//Sources/Features/Crypto/Models:Sources_Features_Crypto_Models`
     - `//Sources/Features/Crypto/Protocols:Sources_Features_Crypto_Protocols`
   - Logging Features:
     - `//Sources/Features/Logging/Errors:Sources_Features_Logging_Errors`
     - `//Sources/Features/Logging/Models:Models`
     - `//Sources/Features/Logging/Protocols:Protocols`
     - `//Sources/Features/Logging/Services:LoggingServices`

8. **Testing Support**
   - `//Sources/UmbraTestKit:UmbraTestKit`
   - `//Sources/UmbraMocks:UmbraMocks`

## Dependency Graph

### Key Dependencies

1. **API Layer**
   ```
   API
   └── Core/UmbraCore
   ```

2. **Security Stack**
   ```
   UmbraSecurity
   ├── SecurityUtils
   │   └── Services/SecurityUtils/Services
   └── CryptoTypes
       ├── Protocols
       ├── Services
       └── Types
   ```

3. **Restic Integration**
   ```
   ResticCLIHelper
   ├── Protocols
   └── Types
   ```

4. **Storage Stack**
   ```
   UmbraBookmarkService
   ├── XPC/Core
   └── SecurityUtils
   
   UmbraKeychainService
   └── XPC/Core
   
   Repositories
   └── Protocols
   
   Snapshots
   └── Protocols
   ```

## External Dependencies

1. **Swift Package Manager Dependencies**
   - `@swiftpkg_cryptoswift//:CryptoSwift`
   - `@swiftpkg_swiftybeaver//:SwiftyBeaver`

2. **Build System**
   - `@build_bazel_rules_swift//swift:swift.bzl`
   - `@bazel_gazelle//label:label.go`

## Module Responsibilities

### Core Modules

1. **API (`//Sources/API`)**
   - Public interface for the UmbraCore framework
   - Entry point for external applications

2. **Core (`//Sources/Core`)**
   - Core functionality and business logic
   - Service coordination
   - Application state management

3. **Security (`//Sources/UmbraSecurity`, `//Sources/SecurityUtils`)**
   - Encryption and decryption operations
   - Key management
   - Security protocol implementations

4. **ResticCLIHelper (`//Sources/ResticCLIHelper`)**
   - Restic command-line interface integration
   - Backup and restore operations
   - Repository management

### Support Modules

1. **Error Handling (`//Sources/ErrorHandling`)**
   - Error type definitions
   - Error handling protocols
   - Error reporting and logging

2. **Features (`//Sources/Features`)**
   - Feature-specific implementations
   - Modular functionality
   - Feature configuration

3. **Testing (`//Sources/UmbraTestKit`, `//Sources/UmbraMocks`)**
   - Test utilities
   - Mock implementations
   - Testing protocols

## Build Configuration

### Compiler Options
All Swift libraries are built with:
```
copts = [
    "-target",
    "arm64-apple-macos14.0",
    "-strict-concurrency=complete",
    "-warn-concurrency",
    "-enable-actor-data-race-checks",
]
```

### Visibility
Most modules have `visibility = ["//visibility:public"]` to allow for internal dependencies.

## Notes

1. **Concurrency Safety**
   - All modules are built with strict concurrency checking
   - Actor data race checks are enabled
   - Concurrency warnings are treated as errors

2. **Module Independence**
   - Each module has its own protocols package
   - Clear separation between interfaces and implementations
   - Minimal cross-module dependencies

3. **Testing Support**
   - Comprehensive mock implementations
   - Dedicated test utilities
   - Protocol-based design for testability

4. **Security Considerations**
   - XPC for secure inter-process communication
   - Encrypted storage for sensitive data
   - Secure bookmark management

---
Last Updated: 2025-02-24
