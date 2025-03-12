# UmbraCore Module Structure

## Overview

This document outlines the modular architecture of UmbraCore, explaining how the various modules interact and depend on each other.

## Core Module Organisation

UmbraCore follows a layered architecture with clearly defined responsibilities:

### Foundation-Free Core Layer

These modules have no dependencies on Foundation or other Apple frameworks, making them portable and easier to test:

- **UmbraCoreTypes**: Core type definitions used throughout the system
- **SecurityProtocolsCore**: Security protocol definitions without Foundation dependencies
- **XPCProtocolsCore**: XPC communication protocols without Foundation dependencies
- **SecureBytes**: Foundation-free binary data handling

### Bridge Layer

These modules bridge between Foundation-free and Foundation-dependent code:

- **SecurityBridge**: Adapts between Foundation-free security protocols and Foundation types
- **XPCBridge**: Provides Foundation-compatible XPC service implementations

### Implementation Layer

These modules provide concrete implementations of the protocols:

- **SecurityImplementation**: Implements security protocols using CryptoKit
- **UmbraSecurity**: High-level security services
- **UmbraXPC**: XPC service implementations

### Application Services

These modules provide application-specific functionality:

- **UmbraKeychainService**: Keychain access and management
- **ResticCLIHelper**: Interface to the Restic command-line tool
- **RepositoryManager**: Repository configuration and management
- **BackupCoordinator**: Coordinates backup operations
- **Configuration**: Application and service configuration

## Dependency Graph

```
Application Services
      ↑
Implementation Layer
      ↑
   Bridge Layer
      ↑
Foundation-Free Core
```

## Module Import Guidelines

When importing modules, follow these guidelines:

1. Always import the most specific module required
2. Avoid importing both a module and its submodules
3. Use explicit imports instead of `@_exported import`
4. Be consistent with import ordering
5. Keep Foundation imports separate from project module imports

## Circular Dependency Prevention

The layered architecture is designed to prevent circular dependencies:

- Foundation-free modules must not import Foundation-dependent modules
- Lower-layer modules must not import higher-layer modules
- Use protocol-based design to maintain separation of concerns
