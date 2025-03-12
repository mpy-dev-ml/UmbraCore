# API Documentation

## Core Services

### UmbraKeychainService
Secure credential storage service.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/UmbraKeychainService)
- Usage Guide: See modules/umbrakeychainservice.md

### UmbraCryptoService
Cryptographic operations service.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/UmbraCryptoService)
- Usage Guide: See modules/umbracryptoservice.md

### UmbraBookmarkService
File system bookmark management.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/UmbraBookmarkService)
- Usage Guide: Coming soon

## Security Types

### SecurityTypes
Base security primitives.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/SecurityTypes)
- Usage Guide: See modules/securitytypes.md

### CryptoTypes
Cryptographic types and operations.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/CryptoTypes)
- Usage Guide: Coming soon

## Utilities

### UmbraLogging
Logging infrastructure.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/UmbraLogging)
- Usage Guide: Coming soon

### UmbraXPC
XPC communication layer.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/UmbraXPC)
- Usage Guide: See modules/umbraxpc.md

## Error Types

### CommonError
Shared error types.
- [API Reference](https://mpy-dev-ml.github.io/UmbraCore/CommonError)
- Usage Guide: See modules/errortypes.md

## Best Practices

- **Thread Safety**: Ensure all service calls are thread-safe in your implementation
- **Error Handling**: Always handle errors appropriately
- **Logging**: Use the provided logging infrastructure for consistent logs
- **Performance**: Consider using async/await for operations that might take time

For more detailed information, please refer to the documentation in the development section.
