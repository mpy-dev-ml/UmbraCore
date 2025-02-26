/Users/mpy/CascadeProjects/UmbraCore
|-- Sources
|   |-- API
|   |   `-- UmbraAPI.swift
|   |-- Autocomplete
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |   `-- AutocompleteProtocol.swift
|   |   |-- Services
|   |   `-- README.md
|   |-- Config
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |   `-- ConfigurationProtocol.swift
|   |   |-- Services
|   |   `-- README.md
|   |-- Core
|   |   |-- CryptoTypes
|   |   |-- Protocols
|   |   |-- SecurityTypes
|   |   |-- Services
|   |   |   `-- CoreService.swift
|   |   |-- Types
|   |   `-- UmbraCore
|   |       |-- Security
|   |       `-- UmbraCore.swift
|   |-- CryptoTypes
|   |   |-- Models
|   |   |   `-- SecureStorageData.swift
|   |   |-- Protocols
|   |   |   `-- CryptoServiceProtocol.swift
|   |   |-- Services
|   |   |   |-- CredentialManager.swift
|   |   |   `-- CryptoService.swift
|   |   `-- Types
|   |       |-- CryptoConfiguration.swift
|   |       `-- CryptoError.swift
|   |-- ErrorHandling
|   |   |-- Errors
|   |   |-- Extensions
|   |   |   `-- Error+Context.swift
|   |   |-- Models
|   |   |   |-- CommonError.swift
|   |   |   |-- CoreError.swift
|   |   |   |-- ErrorContext.swift
|   |   |   `-- ServiceErrorTypes.swift
|   |   |-- Protocols
|   |   |   |-- ErrorHandlingProtocol.swift
|   |   |   |-- ErrorReporting.swift
|   |   |   `-- ServiceErrorProtocol.swift
|   |   |-- Services
|   |   `-- README.md
|   |-- Features
|   |   |-- Crypto
|   |   |   |-- Errors
|   |   |   |-- Models
|   |   |   |   `-- SecureStorageData.swift
|   |   |   |-- Protocols
|   |   |   |   `-- SecureStorageProvider.swift
|   |   |   `-- Services
|   |   `-- Logging
|   |       |-- Errors
|   |       |   `-- LoggingError.swift
|   |       |-- Extensions
|   |       |-- Models
|   |       |   `-- LogEntry.swift
|   |       |-- Protocols
|   |       |   `-- LoggingProtocol.swift
|   |       |-- Services
|   |       |   |-- LoggingService.swift
|   |       |   `-- SwiftyBeaverLoggingService.swift
|   |       `-- README.md
|   |-- Mocks
|   |   |-- MockKeychain.swift
|   |   |-- MockSecurityProvider.swift
|   |   `-- MockURLProvider.swift
|   |-- Repositories
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |   `-- RepositoryProtocol.swift
|   |   |-- Services
|   |   `-- README.md
|   |-- ResticCLIHelper
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |   `-- ResticCLIHelperProtocol.swift
|   |   |-- Services
|   |   `-- README.md
|   |-- SecurityTypes
|   |   |-- Models
|   |   |   |-- FilePermission.swift
|   |   |   `-- SecurityError.swift
|   |   |-- Protocols
|   |   |   |-- SecureStorageProvider.swift
|   |   |   `-- SecurityProvider.swift
|   |   |-- Testing
|   |   `-- Types
|   |       `-- SecurityErrorHandler.swift
|   |-- Services
|   |   `-- SecurityUtils
|   |       |-- Extensions
|   |       |-- Protocols
|   |       |   `-- URLProvider.swift
|   |       |-- Services
|   |       |   |-- EncryptedBookmarkService.swift
|   |       |   `-- SecurityBookmarkService.swift
|   |       |-- Testing
|   |       `-- Types
|   |-- Snapshots
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |   `-- SnapshotProtocol.swift
|   |   |-- Services
|   |   `-- README.md
|   |-- UmbraCore
|   |   `-- UmbraCore.swift
|   |-- UmbraMocks
|   |   |-- MockCryptoService.swift
|   |   |-- MockKeychain.swift
|   |   `-- MockSecurityProvider.swift
|   |-- UmbraSecurity
|   |   |-- Extensions
|   |   |   `-- URL+SecurityScoped.swift
|   |   `-- Services
|   |       `-- SecurityService.swift
|   `-- XPC
|       |-- Core
|       |   |-- XPCConnectionManager.swift
|       |   |-- XPCError.swift
|       |   `-- XPCServiceProtocols.swift
|       |-- CryptoService
|       `-- SecurityService
|-- Tests
|   |-- AutocompleteTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   `-- Services
|   |-- ConfigTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   `-- Services
|   |-- CoreTests
|   |   |-- CoreServiceTests.swift
|   |   `-- URLSecurityTests.swift
|   |-- CryptoTests
|   |   |-- Mocks
|   |   |-- CredentialManagerTests.swift
|   |   `-- CryptoServiceTests.swift
|   |-- ErrorHandlingTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |-- Services
|   |   |-- CommonErrorTests.swift
|   |   `-- CoreErrorTests.swift
|   |-- LoggingTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   |-- Services
|   |   `-- LoggingServiceTests.swift
|   |-- RepositoriesTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   `-- Services
|   |-- ResticCLIHelperTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   `-- Services
|   |-- SecurityTypesTests
|   |   |-- MockSecurityProviderTests.swift
|   |   `-- SecurityErrorTests.swift
|   |-- SecurityUtilsTests
|   |   |-- EncryptedBookmarkServiceTests.swift
|   |   `-- SecurityBookmarkServiceTests.swift
|   |-- SnapshotsTests
|   |   |-- Errors
|   |   |-- Extensions
|   |   |-- Models
|   |   |-- Protocols
|   |   `-- Services
|   |-- UmbraCoreTests
|   |   `-- UmbraCoreTests.swift
|   `-- UmbraSecurityTests
|       `-- SecurityServiceTests.swift
|-- .gitignore
|-- LICENSE
|-- Package.resolved
|-- Package.swift
|-- README.md
|-- STRUCTURE.md
|-- UmbraCore.md
`-- project_structure.md

136 directories, 77 files

# UmbraCore Project Structure Documentation

## Project Overview
- Name: UmbraCore
- Version: 1.0.0
- Swift Version: 5.9.2/6.0.3
- Platform: macOS 14+
- Package Manager: Swift Package Manager (SPM)

## Key Dependencies
- SwiftyBeaver: v2.1.1 (logging)
- CryptoSwift: v1.8.4 (crypto operations)

## Core Components

### Security Infrastructure
- SecurityTypes Module: Core security types and protocols
- CryptoTypes Module: Cryptographic operations and types
- UmbraMocks Module: Mock implementations for testing

### Implementation Details
- Encryption: AES-256-GCM with combined auth mode
- Key Derivation: PBKDF2 with SHA-256 (10,000 iterations)
- IV Length: 12 bytes (GCM requirement)
- Salt Length: 32 bytes
- HMAC: SHA-256 based

### XPC Integration (In Progress)
- Core XPC infrastructure
- CryptoService XPC implementation
- SecurityService XPC implementation

## Build Instructions
```bash
swift build
swift test
```

## Note
This structure snapshot was created on 2025-02-17 before implementing XPC services.
Keep this file for reference in case rollback is needed.

