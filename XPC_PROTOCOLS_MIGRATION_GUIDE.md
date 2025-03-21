# XPC Protocol Consolidation Migration Guide

## Overview

The UmbraCore project has gone through a significant refactoring effort to consolidate XPC protocols and eliminate redundant code and type definitions across modules. This document explains the key changes and provides guidance for migrating code that uses the deprecated `XPCProtocolsCore` module.

## Key Changes

1. **Deprecated XPCProtocolsCore Module**: The `XPCProtocolsCore` module has been deprecated in favour of fully qualified type references and standardised error types.

2. **XPCSecurityError Type Replacement**: The `XPCSecurityError` type alias (which was previously defined in `XPCProtocolsCore.swift`) has been replaced with `ErrorHandlingDomains.UmbraErrors.Security.Protocols`.

3. **Foundation-Independent DTOs**: New Foundation-independent DTOs have been introduced for XPC communication, resulting in improved type safety and reduced dependencies.

4. **Standardised Error Handling**: Error handling now uses the canonical `ErrorHandlingDomains.UmbraErrors.Security.Protocols` type, which provides richer error information and better type safety.

5. **Migration Adapters**: Adapters have been created to help bridge old and new protocols during the transition period.

## Migration Steps

### 1. Replace XPCSecurityError References

Replace all references to `XPCProtocolsCore.XPCSecurityError` with `ErrorHandlingDomains.UmbraErrors.Security.Protocols`:

**Before:**
```swift
func encryptData(_ data: Data) -> Result<Data, XPCProtocolsCore.XPCSecurityError> {
    // Implementation
}
```

**After:**
```swift
func encryptData(_ data: Data) -> Result<Data, ErrorHandlingDomains.UmbraErrors.Security.Protocols> {
    // Implementation
}
```

### 2. Update Import Statements

Add the necessary import for `ErrorHandlingDomains`:

```swift
import ErrorHandlingDomains
```

### 3. Update Error Mapping Functions

Update any functions that map to/from `XPCSecurityError`:

**Before:**
```swift
private func mapXPCError(_ error: XPCSecurityError) -> Error {
    // Implementation
}
```

**After:**
```swift
private func mapXPCError(_ error: ErrorHandlingDomains.UmbraErrors.Security.Protocols) -> Error {
    // Implementation
}
```

### 4. Use Modern XPC Components

Instead of using the deprecated XPC protocols, use the modern equivalents:

**Before:**
```swift
let adapter = XPCProtocolMigrationFactory.createStandardAdapter()
```

**After:**
```swift
let adapter = ModernXPCService()
```

### 5. Adopt Foundation-Independent DTOs

For XPC communication, use the new Foundation-independent DTOs:

**Before:**
```swift
func processData(_ data: NSData) -> NSData?
```

**After:**
```swift
func processData(_ data: SecureBytes) -> Result<SecureBytes, ErrorHandlingDomains.UmbraErrors.Security.Protocols>
```

## Automated Migration

The `xpc_security_error_migration.py` script has been provided to help automate this migration process. It will:

1. Find all Swift files containing references to the deprecated `XPCSecurityError` type
2. Replace those references with the new `ErrorHandlingDomains.UmbraErrors.Security.Protocols` type
3. Add any necessary import statements
4. Report on the changes made

To run the script:

```bash
./xpc_security_error_migration.py
```

## Manual Testing

After migration, test your code thoroughly to ensure all error handling works correctly. Pay special attention to:

1. Functions that return results with the new error type
2. Error mapping functions
3. Error handling in catch blocks and switch statements

## Advantages of the New Approach

1. **Unified Error Types**: All security protocol errors now use a unified error type hierarchy.
2. **Type Safety**: The new approach provides better type safety through Swift's Result type and enum-based errors.
3. **Improved Portability**: Foundation-independent types make the code more portable across Apple platforms.
4. **Clearer Semantics**: The new error types have clearer semantic meaning, making the code more self-documenting.
5. **Simplified Dependencies**: The removal of circular dependencies improves build times and simplifies the module structure.

## Need Help?

If you encounter any issues during migration, please consult the detailed examples in the `Examples/XPCMigration` directory or contact the UmbraCore team for assistance.
