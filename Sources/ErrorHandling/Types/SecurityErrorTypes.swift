import Foundation
import ErrorHandlingDomains
import ErrorHandlingCommon

/// Core security error types used throughout the UmbraCore framework
///
/// This enum defines all security-related errors in a single, flat structure
/// that integrates with the domain-specific errors in UmbraErrors.Security hierarchy.
/// This approach promotes a consistent error taxonomy while maintaining clear
/// separation between internal and external error representations.
public enum SecurityError: Error, Equatable, Sendable {
  // MARK: - Domain Error Wrappers
  
  /// Core security error from UmbraErrors.Security.Core
  case domainCoreError(UmbraErrors.Security.Core)
  
  /// Protocol-related security error from UmbraErrors.Security.Protocols
  case domainProtocolError(UmbraErrors.Security.Protocols)
  
  /// XPC-related security error from UmbraErrors.Security.XPC
  case domainXPCError(UmbraErrors.Security.XPC)
  
  // MARK: - Authentication Errors

  /// Authentication process failed
  case authenticationFailed(reason: String)

  /// User attempted to access resource without proper authorisation
  case unauthorizedAccess(reason: String)

  /// Provided credentials are invalid
  case invalidCredentials(reason: String)

  /// User session has expired
  case sessionExpired(reason: String)

  /// Authentication token has expired
  case tokenExpired(reason: String)

  // MARK: - Cryptographic Errors

  /// Encryption operation failed
  case encryptionFailed(reason: String)

  /// Decryption operation failed
  case decryptionFailed(reason: String)

  /// Key generation failed
  case keyGenerationFailed(reason: String)

  /// Hashing operation failed
  case hashingFailed(reason: String)

  /// Digital signature verification failed
  case signatureInvalid(reason: String)

  // MARK: - Access Control Errors

  /// Permission denied for the requested operation
  case permissionDenied(reason: String)

  /// Certificate validation failed
  case certificateInvalid(reason: String)

  // MARK: - Communication Errors

  /// Secure communication channel failed
  case secureChannelFailed(reason: String)

  /// Security configuration error
  case securityConfigurationError(reason: String)

  // MARK: - General Errors

  /// Internal error within the security system
  case internalError(reason: String)
  
  /// Unknown security error
  case unknown(reason: String)
}

// MARK: - CustomStringConvertible

extension SecurityError: CustomStringConvertible {
  public var description: String {
    switch self {
      case let .domainCoreError(error):
        return "Core security error: \(String(describing: error))"
      case let .domainProtocolError(error):
        return "Protocol security error: \(String(describing: error))"
      case let .domainXPCError(error):
        return "XPC security error: \(String(describing: error))"
      case let .authenticationFailed(reason):
        return "Authentication failed: \(reason)"
      case let .unauthorizedAccess(reason):
        return "Unauthorized access: \(reason)"
      case let .invalidCredentials(reason):
        return "Invalid credentials: \(reason)"
      case let .sessionExpired(reason):
        return "Session expired: \(reason)"
      case let .tokenExpired(reason):
        return "Token expired: \(reason)"
      case let .encryptionFailed(reason):
        return "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        return "Decryption failed: \(reason)"
      case let .keyGenerationFailed(reason):
        return "Key generation failed: \(reason)"
      case let .hashingFailed(reason):
        return "Hashing failed: \(reason)"
      case let .signatureInvalid(reason):
        return "Signature invalid: \(reason)"
      case let .permissionDenied(reason):
        return "Permission denied: \(reason)"
      case let .certificateInvalid(reason):
        return "Certificate invalid: \(reason)"
      case let .secureChannelFailed(reason):
        return "Secure channel failed: \(reason)"
      case let .securityConfigurationError(reason):
        return "Security configuration error: \(reason)"
      case let .internalError(reason):
        return "Internal security error: \(reason)"
      case let .unknown(reason):
        return "Unknown security error: \(reason)"
    }
  }
}

// MARK: - LocalizedError

extension SecurityError: LocalizedError {
  public var errorDescription: String? {
    description
  }
}

// MARK: - Equatable

extension SecurityError {
  public static func == (lhs: SecurityError, rhs: SecurityError) -> Bool {
    switch (lhs, rhs) {
      case (.domainCoreError(let lhsError), .domainCoreError(let rhsError)):
        return lhsError == rhsError
      case (.domainProtocolError(let lhsError), .domainProtocolError(let rhsError)):
        return lhsError == rhsError
      case (.domainXPCError(let lhsError), .domainXPCError(let rhsError)):
        return lhsError == rhsError
      case (.authenticationFailed(let lhsReason), .authenticationFailed(let rhsReason)):
        return lhsReason == rhsReason
      case (.unauthorizedAccess(let lhsReason), .unauthorizedAccess(let rhsReason)):
        return lhsReason == rhsReason
      case (.invalidCredentials(let lhsReason), .invalidCredentials(let rhsReason)):
        return lhsReason == rhsReason
      case (.sessionExpired(let lhsReason), .sessionExpired(let rhsReason)):
        return lhsReason == rhsReason
      case (.tokenExpired(let lhsReason), .tokenExpired(let rhsReason)):
        return lhsReason == rhsReason
      case (.encryptionFailed(let lhsReason), .encryptionFailed(let rhsReason)):
        return lhsReason == rhsReason
      case (.decryptionFailed(let lhsReason), .decryptionFailed(let rhsReason)):
        return lhsReason == rhsReason
      case (.keyGenerationFailed(let lhsReason), .keyGenerationFailed(let rhsReason)):
        return lhsReason == rhsReason
      case (.hashingFailed(let lhsReason), .hashingFailed(let rhsReason)):
        return lhsReason == rhsReason
      case (.signatureInvalid(let lhsReason), .signatureInvalid(let rhsReason)):
        return lhsReason == rhsReason
      case (.permissionDenied(let lhsReason), .permissionDenied(let rhsReason)):
        return lhsReason == rhsReason
      case (.certificateInvalid(let lhsReason), .certificateInvalid(let rhsReason)):
        return lhsReason == rhsReason
      case (.secureChannelFailed(let lhsReason), .secureChannelFailed(let rhsReason)):
        return lhsReason == rhsReason
      case (.securityConfigurationError(let lhsReason), .securityConfigurationError(let rhsReason)):
        return lhsReason == rhsReason
      case (.internalError(let lhsReason), .internalError(let rhsReason)):
        return lhsReason == rhsReason
      case (.unknown(let lhsReason), .unknown(let rhsReason)):
        return lhsReason == rhsReason
      default:
        return false
    }
  }
}
