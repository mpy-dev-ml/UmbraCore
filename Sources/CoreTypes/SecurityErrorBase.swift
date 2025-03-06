import CoreErrors
import Foundation
import UmbraCoreTypes

// Standard module imports using the isolation pattern
// Each file that would have a namespace conflict is isolated in its own file
// where it can safely import the modules needed
import SecurityProtocolsCoreIsolation
import XPCProtocolsCoreIsolation

/// Typealias for CoreErrors.SecurityError in UmbraCoreTypes module
public typealias CoreSecurityError=CoreErrors.SecurityError

/// Typealias for SecurityError in SecurityProtocolsCore module
/// Re-exporting from our isolation file
public typealias SPCoreSecurityError=SPCSecurityError

/// Typealias for XPCSecurityError in XPCProtocolsCore module
/// Re-exporting from our isolation file
public typealias XPCoreSecurityError=XPCSecurityError

/// Protocol for error types that can be converted to SecurityErrorBase
public protocol SecurityErrorConvertible {
  /// Convert this error to a CoreSecurityError
  func toCoreSecurityError() -> CoreSecurityError

  /// Create this error type from a CoreSecurityError
  static func fromCoreSecurityError(_ error: CoreSecurityError) -> Self
}

// MARK: - Error Mapping Functions

/// Map a SecurityProtocolsCore.SecurityError to an XPCProtocolsCore.XPCSecurityError
public func mapSPCToXPCError(_ error: SPCoreSecurityError) -> XPCoreSecurityError {
  // Use our isolated conversion functions
  let coreError=mapSPCToCoreError(error)
  return mapCoreToXPCError(coreError)
}

/// Map an XPCProtocolsCore.XPCSecurityError to a SecurityProtocolsCore.SecurityError
public func mapXPCToSPCError(_ error: XPCoreSecurityError) -> SPCoreSecurityError {
  // Use our isolated conversion functions
  let coreError=mapXPCToCoreError(error)
  return mapCoreToSPCError(coreError)
}

/// Map any error to CoreSecurityError
public func mapToCoreError(_ error: Error) -> CoreSecurityError {
  if let spcError=error as? SPCoreSecurityError {
    mapSPCToCoreError(spcError)
  } else if let xpcError=error as? XPCoreSecurityError {
    mapXPCToCoreError(xpcError)
  } else if let coreError=error as? CoreSecurityError {
    coreError
  } else {
    .internalError(reason: "Unknown error: \(error)")
  }
}

/// Base error type for security operations
/// This type provides a common foundation across security modules
public enum SecurityErrorBase: Error, Sendable {
  case accessDenied(reason: String)
  case authenticationFailed
  case encryptionFailed(reason: String)
  case encryptionNotSupported
  case decryptionFailed(reason: String)
  case dataCorrupted
  case dataNotFound
  case hashingFailed
  case invalidCredential
  case invalidData
  case connectionFailed
  case networkError(code: Int)
  case notAuthorized
  case operationCancelled
  case operationTimeout
  case unexpectedData
  case unsupportedAlgorithm(name: String)
  case unknown(message: String) // Changed from Error to String to support Equatable

  /// Common error for general failures
  public static func general(message: String) -> SecurityErrorBase {
    .unknown(message: message)
  }
}

// MARK: - Equatable Implementation

extension SecurityErrorBase: Equatable {
  public static func == (lhs: SecurityErrorBase, rhs: SecurityErrorBase) -> Bool {
    switch (lhs, rhs) {
      case let (.accessDenied(l), .accessDenied(r)):
        l == r
      case (.authenticationFailed, .authenticationFailed):
        true
      case let (.encryptionFailed(l), .encryptionFailed(r)):
        l == r
      case (.encryptionNotSupported, .encryptionNotSupported):
        true
      case let (.decryptionFailed(l), .decryptionFailed(r)):
        l == r
      case (.dataCorrupted, .dataCorrupted):
        true
      case (.dataNotFound, .dataNotFound):
        true
      case (.hashingFailed, .hashingFailed):
        true
      case (.invalidCredential, .invalidCredential):
        true
      case (.invalidData, .invalidData):
        true
      case (.connectionFailed, .connectionFailed):
        true
      case let (.networkError(l), .networkError(r)):
        l == r
      case (.notAuthorized, .notAuthorized):
        true
      case (.operationCancelled, .operationCancelled):
        true
      case (.operationTimeout, .operationTimeout):
        true
      case (.unexpectedData, .unexpectedData):
        true
      case let (.unsupportedAlgorithm(l), .unsupportedAlgorithm(r)):
        l == r
      case let (.unknown(l), .unknown(r)):
        l == r
      default:
        false
    }
  }
}

extension SecurityErrorBase: CustomStringConvertible {
  public var description: String {
    switch self {
      case let .accessDenied(reason):
        "Access denied: \(reason)"
      case .authenticationFailed:
        "Authentication failed"
      case let .encryptionFailed(reason):
        "Encryption failed: \(reason)"
      case .encryptionNotSupported:
        "Encryption not supported"
      case let .decryptionFailed(reason):
        "Decryption failed: \(reason)"
      case .dataCorrupted:
        "Data corrupted"
      case .dataNotFound:
        "Data not found"
      case .hashingFailed:
        "Hashing failed"
      case .invalidCredential:
        "Invalid credential"
      case .invalidData:
        "Invalid data"
      case .connectionFailed:
        "Connection failed"
      case let .networkError(code):
        "Network error: \(code)"
      case .notAuthorized:
        "Not authorised"
      case .operationCancelled:
        "Operation cancelled"
      case .operationTimeout:
        "Operation timed out"
      case .unexpectedData:
        "Unexpected data"
      case let .unsupportedAlgorithm(name):
        "Unsupported algorithm: \(name)"
      case let .unknown(message):
        "Unknown error: \(message)"
    }
  }
}

// MARK: - Error Type Mapping

/// Extension to map SecurityProtocolsCore's SecurityError to SecurityErrorBase
extension SPCoreSecurityError: SecurityErrorConvertible {
  public func toBaseError() -> SecurityErrorBase {
    switch self {
      case let .encryptionFailed(reason):
        return .encryptionFailed(reason: reason)
      case let .decryptionFailed(reason):
        return .decryptionFailed(reason: reason)
      case let .keyGenerationFailed(reason):
        return .unknown(message: "Key generation failed: \(reason)")
      case .invalidKey:
        return .invalidCredential
      case .hashVerificationFailed:
        return .hashingFailed
      case let .randomGenerationFailed(reason):
        return .unknown(message: "Random generation failed: \(reason)")
      case let .invalidInput(reason):
        return .invalidData
      case let .storageError(reason):
        return .unknown(message: "Storage error: \(reason)")
      case .serviceNotAvailable:
        return .connectionFailed
      case .operationNotSupported:
        return .encryptionNotSupported
      case .invalidIVLength, .invalidSaltLength, .invalidIterationCount,
           .invalidCredentialIdentifier:
        return .invalidData
      case .ivGenerationFailed, .tagGenerationFailed, .keyDerivationFailed, .randomGenerationFailed:
        return .unknown(message: "Crypto generation error")
      case .authenticationFailed:
        return .authenticationFailed
      case .keyNotFound:
        return .dataNotFound
      case .keyExists:
        return .unknown(message: "Key already exists")
      case .keychainError:
        return .unknown(message: "Keychain error")
      @unknown default:
        return .unknown(message: "Unknown security protocol error")
    }
  }
}

/// Extension to map from SecurityErrorBase to SecurityProtocolsCore's SecurityError
extension SecurityErrorBase {
  public func toSecurityError() -> SPCoreSecurityError {
    switch self {
      case let .accessDenied(reason):
        .invalidInput(reason: "Access denied: \(reason)")
      case .authenticationFailed:
        .authenticationFailed
      case let .encryptionFailed(reason):
        .encryptionFailed(reason: reason)
      case .encryptionNotSupported:
        .operationNotSupported
      case let .decryptionFailed(reason):
        .decryptionFailed(reason: reason)
      case .dataCorrupted:
        .invalidInput(reason: "Data corrupted")
      case .dataNotFound:
        .keyNotFound
      case .hashingFailed:
        .hashVerificationFailed
      case .invalidCredential:
        .invalidKey
      case .invalidData:
        .invalidInput(reason: "Invalid data")
      case .connectionFailed:
        .serviceNotAvailable
      case let .networkError(code):
        .serviceNotAvailable
      case .notAuthorized:
        .invalidInput(reason: "Not authorized")
      case .operationCancelled:
        .invalidInput(reason: "Operation cancelled")
      case .operationTimeout:
        .serviceNotAvailable
      case .unexpectedData:
        .invalidInput(reason: "Unexpected data format")
      case let .unsupportedAlgorithm(name):
        .operationNotSupported
      case let .unknown(message):
        .invalidInput(reason: message)
    }
  }
}

/// Extension to map CoreErrors.CryptoError to SecurityErrorBase
extension CoreSecurityError: SecurityErrorConvertible {
  public func toBaseError() -> SecurityErrorBase {
    switch self {
      case let .encryptionFailed(reason):
        return .encryptionFailed(reason: reason)
      case let .decryptionFailed(reason):
        return .decryptionFailed(reason: reason)
      case .keyGenerationFailed:
        return .unknown(message: "Key generation failed")
      case .invalidKey, .invalidKeySize, .invalidKeyFormat, .invalidKeyLength,
           .invalidIVLength, .invalidSaltLength, .invalidIterationCount,
           .invalidCredentialIdentifier:
        return .invalidData
      case .ivGenerationFailed, .tagGenerationFailed, .keyDerivationFailed, .randomGenerationFailed:
        return .unknown(message: "Crypto generation error")
      case .authenticationFailed:
        return .authenticationFailed
      case .keyNotFound:
        return .dataNotFound
      case .keyExists:
        return .unknown(message: "Key already exists")
      case .keychainError:
        return .unknown(message: "Keychain error")
      @unknown default:
        return .unknown(message: "Unknown crypto error")
    }
  }
}

/// Extension to map XPCSecurityError to SecurityErrorBase
extension XPCoreSecurityError: SecurityErrorConvertible {
  public func toBaseError() -> SecurityErrorBase {
    switch self {
      case .accessError:
        return .accessDenied(reason: "XPC access error")
      case .cryptoError:
        return .unknown(message: "XPC crypto error")
      case .encryptionFailed:
        return .encryptionFailed(reason: "XPC encryption failed")
      case .decryptionFailed:
        return .decryptionFailed(reason: "XPC decryption failed")
      case .keyGenerationFailed:
        return .unknown(message: "XPC key generation failed")
      case .hashingFailed:
        return .hashingFailed
      case .invalidData:
        return .invalidData
      case .serviceFailed:
        return .connectionFailed
      case .notImplemented:
        return .unknown(message: "Not implemented")
      case let .general(message):
        return .general(message: message)
      case .bookmarkError, .bookmarkCreationFailed,
           .bookmarkResolutionFailed: // Added missing cases
        return .unknown(message: "Bookmark error")
      @unknown default:
        return .unknown(message: "Unknown XPC error")
    }
  }
}

// MARK: - Helpers for Converting Between Error Types

/// Map XPC Security Error to Base Error
/// This function is used throughout the XPC adapter implementation
/// to maintain type safety when converting error types
public func mapXPCError(_ error: XPCoreSecurityError) -> SecurityErrorBase {
  error.toBaseError()
}

/// Map Core Security Error to Base Error
/// This function is used for converting Core module errors to the base type
public func mapCoreError(_ error: CoreSecurityError) -> SecurityErrorBase {
  error.toBaseError()
}

/// Map Security Protocol Error to Base Error
/// This function is used for converting SecurityProtocolsCore errors to the base type
public func mapSecurityProtocolError(_ error: SPCoreSecurityError) -> SecurityErrorBase {
  error.toBaseError()
}
