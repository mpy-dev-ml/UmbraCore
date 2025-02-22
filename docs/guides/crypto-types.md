# Cryptographic Types

This guide covers the cryptographic types used in UmbraCore for secure data handling.

## Overview

UmbraCore provides several cryptographic types to ensure secure handling of sensitive data:

- `SecureString`: For handling passwords and other sensitive strings
- `EncryptedData`: For encrypted binary data
- `KeyMaterial`: For cryptographic key material

## SecureString

`SecureString` provides secure storage for sensitive string data:

```swift
let password = SecureString("sensitive-data")
// Memory is automatically zeroed when deallocated
```

## EncryptedData

`EncryptedData` handles encrypted binary data:

```swift
let encrypted = EncryptedData(data: someData, key: keyMaterial)
let decrypted = try encrypted.decrypt(using: keyMaterial)
```

## KeyMaterial

`KeyMaterial` manages cryptographic keys:

```swift
let key = try KeyMaterial.generate()
let derived = try key.deriveKey(salt: salt, rounds: 100_000)
```

## Best Practices

1. Always use `SecureString` for passwords and sensitive data
2. Zero memory after use
3. Use appropriate key derivation functions
4. Implement proper key rotation
5. Follow cryptographic hygiene
