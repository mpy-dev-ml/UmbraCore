// SecurityErrorBase.swift
// Provides base definitions for security error types and conversion utilities

import CoreErrors
import Foundation
import UmbraCoreTypes

// Standard module imports using the isolation pattern
// Each file that would have a namespace conflict is isolated in its own file
// where it can safely import the modules needed
import SecurityProtocolsCoreIsolation
import XPCProtocolsCoreIsolation

/// Typealias for CoreErrors.SecurityError in UmbraCoreTypes module
public typealias CoreSecurityError = CoreErrors.SecurityError

/// Typealias for SecurityError in SecurityProtocolsCore module 
/// Re-exporting from our isolation file
public typealias SPCoreSecurityError = SPCSecurityError

/// Typealias for XPCSecurityError in XPCProtocolsCore module
/// Re-exporting from our isolation file
public typealias XPCoreSecurityError = XPCSecurityError

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
    let coreError = mapSPCToCoreError(error)
    return mapCoreToXPCError(coreError)
}

/// Map an XPCProtocolsCore.XPCSecurityError to a SecurityProtocolsCore.SecurityError
public func mapXPCToSPCError(_ error: XPCoreSecurityError) -> SPCoreSecurityError {
    // Use our isolated conversion functions
    let coreError = mapXPCToCoreError(error)
    return mapCoreToSPCError(coreError)
}

/// Map any error to CoreSecurityError
public func mapToCoreError(_ error: Error) -> CoreSecurityError {
    if let spcError = error as? SPCoreSecurityError {
        return mapSPCToCoreError(spcError)
    } else if let xpcError = error as? XPCoreSecurityError {
        return mapXPCToCoreError(xpcError)
    } else if let coreError = error as? CoreSecurityError {
        return coreError
    } else {
        return .internalError(reason: "Unknown error: \(error)")
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
    case (.accessDenied(let l), .accessDenied(let r)):
      return l == r
    case (.authenticationFailed, .authenticationFailed):
      return true
    case (.encryptionFailed(let l), .encryptionFailed(let r)):
      return l == r
    case (.encryptionNotSupported, .encryptionNotSupported):
      return true
    case (.decryptionFailed(let l), .decryptionFailed(let r)):
      return l == r
    case (.dataCorrupted, .dataCorrupted):
      return true
    case (.dataNotFound, .dataNotFound):
      return true
    case (.hashingFailed, .hashingFailed):
      return true
    case (.invalidCredential, .invalidCredential):
      return true
    case (.invalidData, .invalidData):
      return true
    case (.connectionFailed, .connectionFailed):
      return true
    case (.networkError(let l), .networkError(let r)):
      return l == r
    case (.notAuthorized, .notAuthorized):
      return true
    case (.operationCancelled, .operationCancelled):
      return true
    case (.operationTimeout, .operationTimeout):
      return true
    case (.unexpectedData, .unexpectedData):
      return true
    case (.unsupportedAlgorithm(let l), .unsupportedAlgorithm(let r)):
      return l == r
    case (.unknown(let l), .unknown(let r)):
      return l == r
    default:
      return false
    }
  }
}

extension SecurityErrorBase: CustomStringConvertible {
  public var description: String {
    switch self {
    case .accessDenied(let reason):
      return "Access denied: \(reason)"
    case .authenticationFailed:
      return "Authentication failed"
    case .encryptionFailed(let reason):
      return "Encryption failed: \(reason)"
    case .encryptionNotSupported:
      return "Encryption not supported"
    case .decryptionFailed(let reason):
      return "Decryption failed: \(reason)"
    case .dataCorrupted:
      return "Data corrupted"
    case .dataNotFound:
      return "Data not found"
    case .hashingFailed:
      return "Hashing failed"
    case .invalidCredential:
      return "Invalid credential"
    case .invalidData:
      return "Invalid data"
    case .connectionFailed:
      return "Connection failed"
    case .networkError(let code):
      return "Network error: \(code)"
    case .notAuthorized:
      return "Not authorised"
    case .operationCancelled:
      return "Operation cancelled"
    case .operationTimeout:
      return "Operation timed out"
    case .unexpectedData:
      return "Unexpected data"
    case .unsupportedAlgorithm(let name):
      return "Unsupported algorithm: \(name)"
    case .unknown(let message):
      return "Unknown error: \(message)"
    }
  }
}

// MARK: - Error Type Mapping

/// Extension to map SecurityProtocolsCore's SecurityError to SecurityErrorBase
extension SPCoreSecurityError: SecurityErrorConvertible {
  public func toBaseError() -> SecurityErrorBase {
    switch self {
    case .encryptionFailed(let reason):
      return .encryptionFailed(reason: reason)
    case .decryptionFailed(let reason):
      return .decryptionFailed(reason: reason)
    case .keyGenerationFailed(let reason):
      return .unknown(message: "Key generation failed: \(reason)")
    case .invalidKey:
      return .invalidCredential
    case .hashVerificationFailed:
      return .hashingFailed
    case .randomGenerationFailed(let reason):
      return .unknown(message: "Random generation failed: \(reason)")
    case .invalidInput(let reason):
      return .invalidData
    case .storageError(let reason):
      return .unknown(message: "Storage error: \(reason)")
    case .serviceNotAvailable:
      return .connectionFailed
    case .operationNotSupported:
      return .encryptionNotSupported
    case .invalidIVLength, .invalidSaltLength, .invalidIterationCount, .invalidCredentialIdentifier:
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
    case .accessDenied(let reason):
      return .invalidInput(reason: "Access denied: \(reason)")
    case .authenticationFailed:
      return .authenticationFailed
    case .encryptionFailed(let reason):
      return .encryptionFailed(reason: reason)
    case .encryptionNotSupported:
      return .operationNotSupported
    case .decryptionFailed(let reason):
      return .decryptionFailed(reason: reason)
    case .dataCorrupted:
      return .invalidInput(reason: "Data corrupted")
    case .dataNotFound:
      return .keyNotFound
    case .hashingFailed:
      return .hashVerificationFailed
    case .invalidCredential:
      return .invalidKey
    case .invalidData:
      return .invalidInput(reason: "Invalid data")
    case .connectionFailed:
      return .serviceNotAvailable
    case .networkError(let code):
      return .serviceNotAvailable
    case .notAuthorized:
      return .invalidInput(reason: "Not authorized")
    case .operationCancelled:
      return .invalidInput(reason: "Operation cancelled")
    case .operationTimeout:
      return .serviceNotAvailable
    case .unexpectedData:
      return .invalidInput(reason: "Unexpected data format")
    case .unsupportedAlgorithm(let name):
      return .operationNotSupported
    case .unknown(let message):
      return .invalidInput(reason: message)
    }
  }
}

/// Extension to map CoreErrors.CryptoError to SecurityErrorBase
extension CoreSecurityError: SecurityErrorConvertible {
  public func toBaseError() -> SecurityErrorBase {
    switch self {
    case .encryptionFailed(let reason):
      return .encryptionFailed(reason: reason)
    case .decryptionFailed(let reason):
      return .decryptionFailed(reason: reason)
    case .keyGenerationFailed:
      return .unknown(message: "Key generation failed")
    case .invalidKey, .invalidKeySize, .invalidKeyFormat, .invalidKeyLength,
      .invalidIVLength, .invalidSaltLength, .invalidIterationCount, .invalidCredentialIdentifier:
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
    case .general(let message):
      return .general(message: message)
    case .bookmarkError, .bookmarkCreationFailed, .bookmarkResolutionFailed: // Added missing cases
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
