/// XPCProtocolsCore
///
/// Provides a comprehensive set of XPC service protocols for the UmbraCore security infrastructure.
/// These protocols define the boundaries for inter-process communication in a type-safe,
/// Foundation-free manner.
///
/// The module provides three main protocol levels:
/// - XPCServiceProtocolBasic: Core functionality for all XPC services
/// - XPCServiceProtocolStandard: Mid-level protocol with key management
/// - XPCServiceProtocolComplete: Full-featured protocol with encryption/decryption

/// Provides access to module-level functionality and version information
public enum XPCProtocolsCore {
  /// Current module version
  public static let version="1.0.0"
}

@_exported import CoreErrors

// Export the main protocols
@_exported import struct UmbraCoreTypes.SecureBytes

/// Type alias to standardize on CoreErrors.SecurityError for all XPC security error handling
public typealias XPCSecurityError=CoreErrors.SecurityError
