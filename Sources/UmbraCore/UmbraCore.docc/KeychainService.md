# Keychain Service

Secure keychain integration and credential management.

## Overview

The Keychain Service module provides secure storage and management of credentials using macOS Keychain and XPC services.

## Topics

### Core Services

- ``UmbraKeychainService/KeychainXPCService``
- ``UmbraKeychainService/KeychainService``
- ``UmbraKeychainService/KeychainServiceProtocol``

### XPC Integration

- ``XPC/Core/UmbraXPC``
- ``XPC/Core/XPCServiceProtocol``
- ``XPC/Core/XPCServiceConnection``

### Security Integration

- ``CryptoTypes/Services/CredentialManager``
- ``Features/Crypto/Protocols/SecureStorageProvider``
- ``Features/Crypto/Models/SecureStorageData``

### Error Handling

- ``ErrorHandling/Models/ServiceErrorTypes``
- ``ErrorHandling/Protocols/ServiceErrorProtocol``

## See Also

- ``Core/Services/CoreService``
- ``Features/Logging/Services/LoggingService``
- ``SecurityTypes/SecurityTypes``
