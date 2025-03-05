// SecurityProtocolsCoreErrorMapping.swift
// IMPORTANT: This file only imports SecurityProtocolsCore to avoid type conflicts

import Foundation
import SecurityProtocolsCore

// MARK: - Type Aliases

/// Type alias for SecurityProtocolsCore's error type - We use the same prefix as in
/// SPCorePackage.swift
public typealias SPCSecurityError=SecurityError

// MARK: - Public Error Mapping Functions

/// Maps an error from SecurityProtocolsCore to a Foundation NSError
///
/// This function translates SecurityProtocolsCore-specific error types into standard
/// NSError objects with appropriate domain, code, and localized description.
///
/// - Parameter error: SecurityProtocolsCore error to map
/// - Returns: NSError representation of the error
public func mapFromSecurityProtocolsCore(_ error: Error) -> NSError {
  if let secError=error as? SPCSecurityError {
    // Map known error types
    switch secError {
      // Encryption and Decryption Errors
      case let .encryptionFailed(reason):
        return NSError(
          domain: "com.umbra.security",
          code: 100,
          userInfo: [
            NSLocalizedDescriptionKey: "Encryption failed: \(reason)"
          ]
        )

      case let .decryptionFailed(reason):
        return NSError(
          domain: "com.umbra.security",
          code: 101,
          userInfo: [
            NSLocalizedDescriptionKey: "Decryption failed: \(reason)"
          ]
        )

      // Key Management Errors
      case let .keyGenerationFailed(reason):
        return NSError(
          domain: "com.umbra.security",
          code: 102,
          userInfo: [
            NSLocalizedDescriptionKey: "Key generation failed: \(reason)"
          ]
        )

      case .invalidKey:
        return NSError(
          domain: "com.umbra.security",
          code: 103,
          userInfo: [
            NSLocalizedDescriptionKey: "Invalid key format or content"
          ]
        )

      // Hash and Verification Errors
      case .hashVerificationFailed:
        return NSError(
          domain: "com.umbra.security",
          code: 104,
          userInfo: [
            NSLocalizedDescriptionKey: "Hash verification failed"
          ]
        )

      case let .randomGenerationFailed(reason):
        return NSError(
          domain: "com.umbra.security",
          code: 105,
          userInfo: [
            NSLocalizedDescriptionKey: "Random generation failed: \(reason)"
          ]
        )

      // Input and Data Errors
      case let .invalidInput(reason):
        return NSError(
          domain: "com.umbra.security",
          code: 106,
          userInfo: [
            NSLocalizedDescriptionKey: "Invalid input: \(reason)"
          ]
        )

      case let .storageOperationFailed(reason):
        return NSError(
          domain: "com.umbra.security",
          code: 107,
          userInfo: [
            NSLocalizedDescriptionKey: "Storage operation failed: \(reason)"
          ]
        )

      // Service and Operational Errors
      case .timeout:
        return NSError(
          domain: "com.umbra.security",
          code: 108,
          userInfo: [
            NSLocalizedDescriptionKey: "Security operation timed out"
          ]
        )

      case let .serviceError(code, reason):
        return NSError(
          domain: "com.umbra.security",
          code: 109,
          userInfo: [
            NSLocalizedDescriptionKey: "Security service error (\(code)): \(reason)"
          ]
        )

      // General Errors
      case let .internalError(message):
        return NSError(
          domain: "com.umbra.security",
          code: 110,
          userInfo: [
            NSLocalizedDescriptionKey: message
          ]
        )

      case .notImplemented:
        return NSError(
          domain: "com.umbra.security",
          code: 111,
          userInfo: [
            NSLocalizedDescriptionKey: "Operation not implemented"
          ]
        )

      // Handle any future cases that might be added in future Swift versions
      @unknown default:
        return NSError(
          domain: "com.umbra.security",
          code: 999,
          userInfo: [
            NSLocalizedDescriptionKey: "Unknown security error: \(secError.localizedDescription)"
          ]
        )
    }
  }

  // Fallback for unknown errors
  return NSError(
    domain: "com.umbra.security",
    code: 999,
    userInfo: [
      NSLocalizedDescriptionKey: "Unknown security error: \(error.localizedDescription)"
    ]
  )
}

/// Maps an NSError back to SecurityProtocolsCore error type
///
/// This function translates standard NSError objects back into
/// SecurityProtocolsCore-specific error types based on error codes.
///
/// - Parameter error: NSError to map
/// - Returns: SecurityProtocolsCore error
public func mapToSecurityProtocolsCore(_ error: NSError) -> SPCSecurityError {
  switch error.code {
    // Encryption and Decryption Errors
    case 100:
      return .encryptionFailed(
        reason: error.userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown encryption failure"
      )

    case 101:
      return .decryptionFailed(
        reason: error.userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown decryption failure"
      )

    // Key Management Errors
    case 102:
      return .keyGenerationFailed(
        reason: error
          .userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown key generation failure"
      )

    case 103:
      return .invalidKey

    // Hash and Verification Errors
    case 104:
      return .hashVerificationFailed

    case 105:
      return .randomGenerationFailed(
        reason: error
          .userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown random generation failure"
      )

    // Input and Data Errors
    case 106:
      return .invalidInput(
        reason: error
          .userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown input validation failure"
      )

    case 107:
      return .storageOperationFailed(
        reason: error.userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown storage failure"
      )

    // Service and Operational Errors
    case 108:
      return .timeout

    case 109:
      let description=error
        .userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown service error"
      return .serviceError(
        code: error.code,
        reason: description
      )

    // General Errors
    case 110:
      return .internalError(
        error
          .userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown reason"
      )

    case 111:
      return .notImplemented

    // Fallback for unexpected errors
    default:
      return .invalidInput(
        reason: "Error with code \(error.code): \(error.localizedDescription)"
      )
  }
}
