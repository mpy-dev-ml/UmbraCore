# UmbraCore XPC Protocol Migration Guide

## Overview

This document outlines the migration of UmbraCore's XPC protocol architecture to a standardised three-tier system. The migration ensures better type safety, improved error handling, and prepares the codebase for Swift 6 compatibility.

## Protocol Hierarchy

The XPC protocol architecture now follows a three-tier hierarchy:

1. **Basic Protocol** (`XPCServiceProtocolBasic`)
   - Core functionality required by all XPC services
   - Foundation-free implementation
   - Minimal public API surface

2. **Standard Protocol** (`XPCServiceProtocolStandard`)
   - Inherits from Basic
   - Adds common security and cryptographic operations
   - Default implementation for most services

3. **Complete Protocol** (`XPCServiceProtocolComplete`)
   - Inherits from Standard
   - Adds advanced functionality for specific use cases
   - Full-featured implementation

## Error Handling

All XPC protocols now use the `Result<Value, XPCSecurityError>` pattern for error handling:

```swift
func operation() async -> Result<ReturnType, XPCSecurityError>
```

### Benefits:
- Type-safe error handling
- Clear error propagation
- Consistent error reporting across module boundaries

## Type Aliases

For backward compatibility and clarity, we provide type aliases:

```swift
// Core module
public typealias XPCServiceProtocol = XPCProtocolsCore.XPCServiceProtocolStandard
public typealias XPCServiceProtocolBase = XPCProtocolsCore.XPCServiceProtocolBasic
public typealias XPCServiceProtocolComplete = XPCProtocolsCore.XPCServiceProtocolComplete
public typealias XPCSecurityError = UmbraCoreTypes.CoreErrors.SecurityError
```

## Migration Strategy

When migrating existing code:

1. Replace direct protocol implementations with the appropriate tier
2. Update error handling to use Result<Value, XPCSecurityError>
3. Use type aliases for backward compatibility
4. Add CoreErrors import where needed
5. Ensure proper spacing in assignments (x = y instead of x=y)

## Deprecation Warnings

Legacy protocol implementations are marked with deprecation warnings:

```swift
@available(
  *,
  deprecated,
  message: "Use XPCServiceProtocol instead which points to XPCProtocolsCore.XPCServiceProtocolStandard"
)
public typealias LegacyXPCServiceProtocol = XPCServiceProtocol
```

Follow deprecation guidance to ensure future compatibility.
