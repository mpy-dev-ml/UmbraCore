/// CoreErrors module extensions and namespace definitions
///
/// This file provides namespace support for the CoreErrors module to avoid type ambiguity.

/// CoreErrors namespace container
/// Use this when you need to explicitly reference error types from this module
public enum CE {
    // This is a namespace container only
}

/// Extension for SecurityError type with namespace support
extension SecurityError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = SecurityError
}

/// Extension for CryptoError type with namespace support
extension CryptoError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = CryptoError
}

/// Extension for KeyManagerError type with namespace support
extension KeyManagerError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = KeyManagerError
}

/// Extension for LoggingError type with namespace support
extension LoggingError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = LoggingError
}

/// Extension for RepositoryError type with namespace support
extension RepositoryError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = RepositoryError
}

/// Extension for ResourceError type with namespace support
extension ResourceError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = ResourceError
}

/// Extension for ServiceError type with namespace support
extension ServiceError {
    /// Type alias for accessing this type through the namespace
    public typealias CE = ServiceError
}

/// Module initialisation function
/// This ensures all components are properly registered
public func initialiseModule() {
    // Reserved for future registration logic
}
