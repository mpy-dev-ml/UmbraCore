/// CoreErrors module extensions and namespace definitions
///
/// This file provides namespace support for the CoreErrors module to avoid type ambiguity.

import ErrorHandlingDomains

/// CoreErrors namespace container
/// Use this when you need to explicitly reference error types from this module
public enum CE {
    // This is a namespace container only
}

/// Extension for SecurityError type with namespace support
public extension ErrorHandlingDomains.SecurityError {
    /// Type alias for accessing this type through the namespace
    typealias CE = ErrorHandlingDomains.SecurityError
}

// Note: The following extensions were removed as the types don't exist in ErrorHandlingDomains
// - CryptoError
// - KeyManagerError
// - LoggingError
// - ResourceError
// - ServiceError

/// Extension for RepositoryError type with namespace support
public extension ErrorHandlingDomains.RepositoryErrorType {
    /// Type alias for accessing this type through the namespace
    typealias CE = ErrorHandlingDomains.RepositoryErrorType
}

/// Extension for ApplicationError type with namespace support
public extension ErrorHandlingDomains.ApplicationError {
    /// Type alias for accessing this type through the namespace
    typealias CE = ErrorHandlingDomains.ApplicationError
}

/// Module initialisation function
/// This ensures all components are properly registered
public func initialiseModule() {
    // Reserved for future registration logic
}
