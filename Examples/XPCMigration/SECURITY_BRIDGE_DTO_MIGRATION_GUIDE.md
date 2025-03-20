# Security Bridge DTO Migration Guide

This guide explains how to migrate existing code that uses the Foundation-dependent SecurityBridge to use the new Foundation-independent DTOs for improved portability and type safety.

## Overview

The UmbraCore project is moving away from Foundation dependencies in favour of platform-independent types. As part of this transition, we've created Foundation-independent DTOs for the SecurityBridge module, allowing it to work directly with XPCProtocolsCore while eliminating Foundation dependencies.

## Key Components

1. **XPCSecurityErrorDTO**: A Foundation-independent representation of XPC security errors
2. **XPCServiceDTO**: A Foundation-independent representation of XPC service operations and data
3. **XPCSecurityDTOConverter**: Conversion utilities between Foundation-dependent and Foundation-independent types
4. **XPCServiceDTOAdapter**: An adapter that implements XPCServiceProtocolStandardDTO using the underlying XPCServiceStandardAdapter
5. **XPCServiceDTOFactory**: A factory for creating XPC service adapters that use Foundation-independent DTOs
6. **XPCProtocolsDTOCore**: Foundation-independent interfaces for XPC service communication

## Migration Steps

### 1. Replace Foundation-dependent Types with DTOs

When working with XPC services, replace Foundation types like NSData with `SecureBytes` and `XPCSecurityErrorDTO`.

**Before:**
```swift
func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    // Use NSData and return NSObject or NSError
}
```

**After:**
```swift
func encryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityErrorDTO> {
    // Use SecureBytes and return a proper Result type
}
```

### 2. Use the XPCServiceDTOAdapter

Instead of directly using the XPCServiceStandardAdapter, use the XPCServiceDTOAdapter, which provides a Foundation-independent interface.

**Before:**
```swift
let adapter = XPCServiceStandardAdapter(connection: connection)
let result = await adapter.encryptData(data, keyIdentifier: keyId)
```

**After:**
```swift
let adapter = XPCServiceDTOAdapter(connection: connection)
let result = await adapter.encryptData(data, keyIdentifier: keyId)
```

### 3. Use the XPCServiceDTOFactory

For convenience, use the XPCServiceDTOFactory to create adapters for XPC services.

```swift
// Create an adapter for a service by name
let adapter = XPCServiceDTOFactory.createStandardAdapter(forService: "com.umbra.xpc.security")

// Create an adapter for a service by mach service name
let adapter = XPCServiceDTOFactory.createStandardAdapter(forMachService: "com.umbra.xpc.security.mach")

// Create an adapter for a service by endpoint
let adapter = XPCServiceDTOFactory.createStandardAdapter(forEndpoint: endpoint)
```

### 4. Working with Results

The new DTOs use Swift's Result type for error handling, which provides better type safety than NSObject or NSError.

**Before:**
```swift
if let result = await adapter.encryptData(data, keyIdentifier: keyId) {
    if let error = result as? NSError {
        // Handle error
    } else if let resultData = result as? NSData {
        // Process data
    }
}
```

**After:**
```swift
let result = await adapter.encryptData(data, keyIdentifier: keyId)
switch result {
case .success(let encryptedData):
    // Process data
case .failure(let error):
    // Handle error
}
```

### 5. Converting Between Types

If you need to interoperate with code that still uses Foundation types, use the XPCSecurityDTOConverter to convert between them.

```swift
// Convert from XPCSecurityError to XPCSecurityErrorDTO
let errorDTO = XPCSecurityDTOConverter.toDTO(error)

// Convert from XPCSecurityErrorDTO to XPCSecurityError
let xpcError = XPCSecurityDTOConverter.fromDTO(errorDTO)

// Convert from dictionary to ServiceStatusDTO
let statusDTO = XPCSecurityDTOConverter.toStatusDTO(statusDict)

// Convert from ServiceStatusDTO to dictionary
let statusDict = XPCSecurityDTOConverter.fromStatusDTO(statusDTO)
```

## Best Practices

1. **Prefer DTOs for New Code**: Always use the Foundation-independent DTOs for new code.
2. **Use SecureBytes**: Use SecureBytes instead of NSData or [UInt8] for secure data handling.
3. **Use Result Type**: Leverage Swift's Result type for clear error handling.
4. **Adapt Gradually**: You can mix old and new approaches during the transition period, using the converter utilities when needed.
5. **Update Tests**: Make sure to update your tests to work with the new DTOs and Result types.

## Example Implementation

See the `SecurityBridgeDTOExample.swift` file in this directory for a complete example of how to use the new Foundation-independent DTOs with the SecurityBridge module.

## Benefits of Using DTOs

1. **Cross-Platform Compatibility**: DTOs eliminate dependencies on Foundation, making the code more portable.
2. **Type Safety**: Using proper Swift types and Result provides better type safety than NSObject-based APIs.
3. **Modern Swift**: The DTO-based API is more aligned with modern Swift practices.
4. **Clear Intent**: The DTO classes have clear, focused responsibilities.
5. **Improved Testing**: DTOs make it easier to write comprehensive unit tests.

## Future Direction

As we continue to modernise UmbraCore, we'll gradually eliminate all Foundation dependencies from public interfaces, creating more DTO-based APIs for various subsystems. This will make UmbraCore more portable and easier to maintain, while providing a better developer experience for library consumers.
