# Security Module Migration Guide

## Overview

This guide outlines how to migrate from the legacy security modules to the new consolidated modules:
- `SecurityProtocolsCore`: Foundation-free protocols and types
- `SecurityBridge`: Bridge between Foundation and foundation-free types

## Migration Steps

### 1. Update Import Statements

| Legacy Import | Replacement |
|---------------|-------------|
| `import SecurityInterfaces` | `import SecurityProtocolsCore` (if only using protocols)<br>`import SecurityBridge` (if requiring Foundation interop) |
| `import SecurityInterfacesBase` | `import SecurityProtocolsCore` |
| `import SecurityInterfacesProtocols` | `import SecurityProtocolsCore` |
| `import SecurityInterfacesFoundation` | `import SecurityBridge` |
| `import SecurityInterfacesFoundationBridge` | `import SecurityBridge` |
| `import SecurityInterfacesFoundationCore` | `import SecurityBridge` |
| `import SecurityInterfacesFoundationMinimal` | `import SecurityBridge` |
| `import SecurityInterfacesFoundationNoFoundation` | `import SecurityProtocolsCore` |

### 2. Update Protocol Usage

#### For Foundation-free contexts:
- Use `SecurityProviderProtocol` (from SecurityProtocolsCore)
- Use `CryptoServiceProtocol` (from SecurityProtocolsCore)
- Use `KeyManagementProtocol` (from SecurityProtocolsCore)

#### For Foundation-dependent contexts:
- Use `FoundationSecurityProvider` (from SecurityBridge)
- Use `FoundationCryptoService` (from SecurityBridge)
- Use `FoundationKeyManagement` (from SecurityBridge)

### 3. Using Adapters

To bridge between Foundation and foundation-free types:

```swift
// Create a foundation-free interface from a Foundation implementation
let foundationProvider: FoundationSecurityProvider = getFoundationProvider()
let provider: SecurityProviderProtocol = SecurityProviderAdapter(implementation: foundationProvider)

// Use the foundation-free interface
let result = await provider.cryptoService.encrypt(data: secureBytes, key: key)

// To convert Foundation types to domain types
import SecurityBridge

// Convert Data to SecureBytes
let data: Data = getData()
let secureBytes = DataAdapter.toSecureBytes(data)

// Convert SecureBytes to Data
let bytes: SecureBytes = getSecureBytes()
let data = DataAdapter.toData(bytes)
```

### 4. XPC Communication

For XPC service protocols:
- Use `XPCServiceProtocolCore` (from SecurityProtocolsCore) for foundation-free definitions
- Use `XPCBridgeAdapter` (from SecurityBridge) for Foundation adaptation

## Testing

After migration, run:

```bash
bazel test //Sources/SecurityBridge/...
bazel test //Sources/SecurityProtocolsCore/...
```

Plus any tests for your updated client code.

## Common Issues

### Type Conversion
- Always use the adapters in SecurityBridge for type conversion
- Never manually convert between Foundation and domain types

### Protocol Conformance
- Ensure complete protocol implementation
- Verify Sendable conformance for all types

### Missing Functionality
- If you find missing functionality, extend the appropriate module
- Add to SecurityProtocolsCore for foundation-free functionality
- Add to SecurityBridge for Foundation interoperability
