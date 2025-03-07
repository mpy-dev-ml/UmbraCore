# UmbraCore Error Handling Architecture

This document provides a technical overview of the UmbraCore error handling system architecture, implementation details, and design decisions.

## System Architecture

The error handling system follows a modular, layered architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Code                       │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Error Handler                          │
└─────┬──────────────────────┬──────────────────────────┬─────┘
      │                      │                          │
      ▼                      ▼                          ▼
┌─────────────┐     ┌─────────────────┐     ┌────────────────┐
│ Error Logger│     │ Error Notifier  │     │ Error Recovery │
└─────────────┘     └─────────────────┘     └────────────────┘
      │                      │                          │
      ▼                      ▼                          ▼
┌─────────────┐     ┌─────────────────┐     ┌────────────────┐
│Log Adapters │     │Notification UI  │     │Recovery Actions│
└─────────────┘     └─────────────────┘     └────────────────┘
```

### Key Components

1. **ErrorHandlingInterfaces**
   - Contains protocol definitions (`UmbraError`, `ErrorNotificationProtocol`)
   - Defines core interfaces that allow the system to be modular
   - Ensures proper separation between components

2. **ErrorHandlingModels**
   - Defines data structures for error context, severity, and other metadata
   - Provides standard model types shared across modules
   - Includes `GenericUmbraError` implementation

3. **ErrorHandlingCore**
   - Houses the central `ErrorHandler` that coordinates error processing
   - Provides the `ErrorFactory` for creating properly sourced errors
   - Manages error routing and delegation

4. **ErrorHandlingNotification**
   - Implements UI presentation adapters for different platforms
   - Contains `ErrorNotifier` for coordinating error notifications
   - Platform-specific implementations (macOS, iOS)

5. **ErrorHandlingRecovery**
   - Defines recovery option protocols and implementations
   - Provides domain-specific recovery services
   - Manages recovery execution and reporting

## Type System

### Error Type Hierarchy

```
UmbraError (Protocol)
├── GenericUmbraError
├── SecurityError
├── NetworkError
├── RepositoryError
└── ... (Domain-specific errors)
```

### Recovery Type Hierarchy

```
RecoveryOption (Protocol)
└── ErrorRecoveryOption
    ├── RetryRecoveryOption
    ├── CancelRecoveryOption
    └── ... (Specific recovery types)
```

## Thread Safety & Concurrency Model

The error handling system employs Swift concurrency features to ensure thread safety:

1. **Actor Isolation**
   - `@MainActor` for UI-related notification components
   - Safe access to shared mutable state through actor isolation

2. **Asynchronous Processing**
   - `async/await` APIs for error notification and recovery
   - Non-blocking error handling to maintain application responsiveness

3. **Sendable Conformance**
   - Error types and recovery options conform to `Sendable`
   - Safe transfer across actor and task boundaries

## Error Recovery Process

The error recovery flow follows this sequence:

1. Error is caught or generated within application code
2. Error is passed to the appropriate error handler
3. Handler determines severity and processes the error
4. Recovery options are generated based on error type and context
5. Notification is presented to the user with recovery options
6. User selects a recovery option (or system auto-selects)
7. Selected recovery action is executed
8. Result of recovery is reported back to the handler

## Module Dependencies

```
ErrorHandlingInterfaces
       ↑
       │
ErrorHandlingModels
       ↑
       │
ErrorHandlingCore ← ErrorHandlingCommon
       ↑
       │
       ├────────────────┬─────────────────┐
       │                │                 │
ErrorHandlingRecovery   │                 │
       ↑                │                 │
       │                │                 │
ErrorHandlingNotification                 │
       ↑                                  │
       │                                  │
       └────────────────┬─────────────────┘
                        │
                        ↓
             Domain-specific handlers
```

## Type Resolution Strategy

To avoid namespace conflicts with similarly named types across modules:

1. **Module-qualified references**
   - Use fully qualified type names where necessary
   - Example: `ErrorHandlingModels.ErrorContext` vs `ErrorHandlingCommon.ErrorContext`

2. **Type aliasing**
   - Create local type aliases when working with ambiguous types
   - Example: `typealias CoreContext = ErrorHandlingCore.ErrorContext`

3. **Import strategy**
   - Selective importing to avoid name collisions
   - Example: `import class SecurityCore.SecurityError`

## Testing Approach

The error handling system is tested through:

1. **Unit tests** - Testing individual components in isolation
2. **Integration tests** - Testing interaction between components
3. **End-to-end tests** - Testing full error handling flow

Test utilities include:

- Mock error notifiers for headless testing
- Test recovery options with controlled behaviour
- Error generators for comprehensive error coverage

## Migration Strategy

When migrating older code to use the new error handling system:

1. **Wrap legacy errors**
   ```swift
   do {
       try legacyOperation()
   } catch let legacyError {
       let umbraError = ErrorFactory.makeGenericError(
           domain: "Legacy",
           code: String(describing: legacyError._code),
           errorDescription: legacyError.localizedDescription
       )
       ErrorHandler.shared.handle(umbraError)
   }
   ```

2. **Update error construction**
   - Replace string IDs with UUIDs
   - Ensure proper actor isolation for UI code
   - Use factory methods consistently

3. **Add concurrency annotations**
   - Mark UI-related methods with `@MainActor`
   - Ensure proper `Sendable` conformance
   - Convert blocking calls to async versions

## Design Decisions

### UUID vs String for Identifiers

We've moved from String to UUID for recovery option IDs because:

1. UUIDs guarantee uniqueness without coordination
2. Type safety benefits (can't accidentally use a string as an ID)
3. Consistent with other ID systems in UmbraCore
4. Better for cross-platform storage and serialisation

### MainActor Isolation

UI-related components use `@MainActor` isolation to:

1. Prevent data races when updating UI
2. Provide compile-time thread safety checks
3. Make code intentions explicit
4. Follow Swift concurrency best practices

### Modular Architecture

The highly modular approach allows:

1. Independent development of components
2. Better testing in isolation
3. Flexible deployment options
4. Clearer dependency management

## Performance Considerations

The error handling system is designed with performance in mind:

1. **Lazy evaluation** - Heavy operations only occur when needed
2. **Resource pooling** - Notification windows are reused
3. **Prioritised processing** - Critical errors get priority
4. **Batched logging** - Log operations are batched for efficiency

## Localisation Support

Error messages support localisation through:

1. Localised error descriptions via `NSLocalizedString`
2. Separate localisation bundle for error messages
3. Support for dynamic language switching
4. Culturally appropriate recovery options

## Security Considerations

The error handling system is designed with security in mind:

1. **Information disclosure** - Sensitive data is scrubbed from logs
2. **Permission handling** - Recovery options respect permissions
3. **Privilege escalation** - Recovery actions are limited by user permissions
4. **Audit logging** - Security-related errors are specially logged

---

Copyright © 2025 UmbraCorp. All rights reserved.
