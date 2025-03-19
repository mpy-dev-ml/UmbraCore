# ``SecurityInterfacesError``

The primary error type for security-related operations in UmbraCore.

## Overview

The `SecurityInterfacesError` enum provides a comprehensive set of error cases for security operations
in the UmbraCore framework, including authentication failures, encryption/decryption errors, 
and access control issues.

## Topics

### Bookmark Errors

- ``bookmarkCreationFailed(_:)``
- ``bookmarkResolutionFailed``
- ``bookmarkStale``
- ``bookmarkError(_:)``

### Cryptographic Errors

- ``encryptionFailed(reason:)``
- ``decryptionFailed(reason:)``
- ``keyGenerationFailed(reason:)``
- ``hashingFailed``
- ``signatureFailed(reason:)``
- ``verificationFailed(reason:)``

### Authentication Errors

- ``authenticationFailed``
- ``authorizationFailed(_:)``

### Conversion Methods

- ``toCoreError()``
- ``wrapped(_:)``
