/**
 # XPC Protocols Core

 This file provides the core definitions and functionality for XPC protocols used by the Umbra
 security infrastructure. These protocols define the boundaries for inter-process communication in
 a type-safe, secure manner.

 ## Features

 * Protocol hierarchy with clear abstraction levels
 * Type-safe message passing between processes
 * Comprehensive error handling
 * Support for both legacy and modern interfaces
 * Protocol version management

 XPCProtocolsCore serves as the foundation for all secure XPC communication in the Umbra platform,
 enabling isolated processes to communicate while maintaining security boundaries.
 */

import CoreErrors
@_exported import ErrorHandling
import Foundation
import UmbraCoreTypes
@_exported import struct UmbraCoreTypes.SecureBytes

/// Provides access to the XPC protocol factory methods and module-level information
public enum XPCProtocolsCore {
  /// Current version of the XPC protocols core module
  public static let version="1.0.0"

  /// Returns whether the current protocol version is compatible with the given version
  /// - Parameter version: Version to check compatibility with
  /// - Returns: Degree of compatibility between versions
  public static func checkCompatibility(with version: String) -> XPCProtocolCompatibility {
    // For now, treat all 1.x versions as compatible
    // In a real implementation, this would do proper semantic version checking
    if version.hasPrefix("1.") {
      return .compatible
    }

    // Otherwise, assume incompatible
    return .incompatible
  }

  /// Factory method to create an XPC service client based on a service connection
  /// - Parameters:
  ///   - serviceConnection: The underlying service connection to use
  ///   - protocolLevel: The desired protocol level (basic, standard, complete)
  /// - Returns: A client implementing the requested protocol, or nil if unavailable
  public static func createServiceClient(
    serviceConnection _: NSXPCConnection,
    protocolLevel _: ProtocolLevel
  ) -> Any? {
    // Simple implementation for now
    nil
  }

  /// Protocol levels supported by the XPC service hierarchy
  public enum ProtocolLevel: Int, CaseIterable {
    /// Basic protocol with minimal functionality
    case basic=0

    /// Standard protocol with comprehensive security operations
    case standard=1

    /// Complete protocol with all advanced features
    case complete=2

    /// Get the Swift protocol type for this level
    public var protocolType: Any.Type {
      switch self {
        case .basic:
          XPCServiceProtocolBasic.self
        case .standard:
          XPCServiceProtocolStandard.self
        case .complete:
          XPCServiceProtocolComplete.self
      }
    }

    /// Get the protocol identifier
    public var identifier: String {
      switch self {
        case .basic:
          "com.umbra.xpc.service.protocol.basic"
        case .standard:
          "com.umbra.xpc.service.protocol.standard"
        case .complete:
          "com.umbra.xpc.service.protocol.complete"
      }
    }
  }

  /// Common error type used throughout the XPC protocol hierarchy
  public typealias XPCSecurityError=SecurityError

  /// Structured error type for XPC protocol errors
  public enum SecurityError: Error {
    /// Service is not available at all
    case serviceUnavailable

    /// Service exists but is not in a state where it can fulfill requests
    case serviceNotReady(reason: String)

    /// Operation timed out after waiting for the specified interval
    case timeout(after: TimeInterval)

    /// Authentication with the service failed
    case authenticationFailed(reason: String)

    /// User is not authorised to perform the requested operation
    case authorizationDenied(operation: String)

    /// The requested operation is not supported by this service
    case operationNotSupported(name: String)

    /// Input parameters to the operation were invalid
    case invalidInput(details: String)

    /// The operation cannot be performed in the current state
    case invalidState(details: String)

    /// The specified key was not found
    case keyNotFound(identifier: String)

    /// The wrong key type was provided for the operation
    case invalidKeyType(expected: String, received: String)

    /// A cryptographic operation failed
    case cryptographicError(operation: String, details: String)

    /// An internal error occurred in the service
    case internalError(reason: String)

    /// The connection to the service was interrupted
    case connectionInterrupted

    /// The connection to the service was invalidated
    case connectionInvalidated(reason: String)
  }
}

/// Compatibility level between different protocol versions
public enum XPCProtocolCompatibility {
  /// Protocols are compatible and should work together
  case compatible

  /// Protocols are incompatible and should not be used together
  case incompatible

  /// Protocols may be compatible but with reduced functionality
  case partiallyCompatible
}

/**
 # UmbraCore XPC Protocols

 This module provides a comprehensive set of XPC service protocols for the UmbraCore security
 infrastructure. These protocols define the boundaries for inter-process communication in a
 type-safe, secure, and maintainable manner.

 ## Features

 * Hierarchical protocol design with multiple abstraction levels
 * Strong type safety for all inter-process communication
 * Comprehensive error handling with detailed diagnostics
 * Support for both synchronous and asynchronous operations
 * Compatibility with legacy systems through protocol adaptation

 XPC protocols enable secure isolation of sensitive security operations while maintaining
 usability and performance.
 */
