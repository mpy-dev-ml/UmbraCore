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

  /// Migration status
  public static let migrationVersion="2.0.0"

  /// Migration date
  public static let migrationDate="2025-03-05"
}

// Export all necessary types and modules
@_exported import CoreErrors
@_exported import UmbraCoreTypes

// Export core types that are needed across the XPC boundary
@_exported import struct UmbraCoreTypes.SecureBytes

// Define standard error type for XPC protocols
public typealias XPCSecurityError=CoreErrors.SecurityError
