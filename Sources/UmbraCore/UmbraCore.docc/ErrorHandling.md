# Error Handling

Error handling types and protocols for UmbraCore.

## Overview

The error handling module provides a comprehensive system for error management, reporting, and context preservation across UmbraCore services.

## Topics

### Core Types

- ``ErrorHandling/Models/CommonError``
- ``ErrorHandling/Models/CoreError``
- ``ErrorHandling/Models/ErrorContext``
- ``ErrorHandling/Models/ServiceErrorTypes``

### Error Protocols

- ``ErrorHandling/Protocols/ErrorHandlingProtocol``
- ``ErrorHandling/Protocols/ErrorReporting``
- ``ErrorHandling/Protocols/ServiceErrorProtocol``

### Error Extensions

- ``ErrorHandling/Extensions/Error_Context``

### Service Errors

- ``Features/Logging/Errors/LoggingError``
- ``CryptoTypes/Types/CryptoError``

## See Also

- ``Core/Services/CoreService``
- ``Features/Logging/Services/LoggingService``
- ``CryptoTypes/Services/DefaultCryptoService``
