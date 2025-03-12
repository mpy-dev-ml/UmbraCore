# UmbraCore Architecture

## Overview

UmbraCore follows a modular architecture with a strong focus on security, type safety, and maintainability. The system is designed around the principle of separation of concerns, with distinct modules handling specific aspects of the backup management process.

## Core Architecture Principles

### Security-First Design

- Foundation-free core modules for critical security operations
- XPC services for privileged operations
- Secure keychain integration with sandboxing support

### Module Organisation

UmbraCore is organised into several logical layers:

1. **Core Foundation-Free Layer**
   - SecurityProtocolsCore
   - XPCProtocolsCore
   - UmbraCoreTypes

2. **Foundation Bridge Layer**
   - SecurityBridge
   - XPCBridge

3. **Implementation Layer**
   - SecurityImplementation
   - UmbraSecurity

4. **Application Services**
   - UmbraKeychainService
   - ResticCLIHelper
   - RepositoryManager
   - BackupCoordinator

## Error Handling Architecture

UmbraCore implements a comprehensive error handling system with:

- Domain-specific error types
- Consistent error mapping between modules
- Rich error context for debugging

## Concurrency Model

The project uses Swift's structured concurrency model with:

- Async/await for asynchronous operations
- Actor-based isolation for thread safety
- Task management for cancellation support

## XPC Integration

UmbraCore uses XPC extensively for privilege separation:

- Main app remains sandboxed
- XPC services handle privileged operations
- Well-defined protocol interfaces using Swift's protocol system
