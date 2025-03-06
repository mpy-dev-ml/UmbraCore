import CoreErrors
import Foundation
import UmbraCoreTypes

// Only import SecurityProtocolsCore in this file to isolate namespace conflicts
import SecurityProtocolsCore

/// Direct access to the SecurityError type in the SecurityProtocolsCore module
/// This approach avoids the namespace conflict with the enum named SecurityProtocolsCore
public typealias SPCSecurityError=SecurityProtocolsCore.SecurityError

/// Map from SecurityProtocolsCore.SecurityError to CoreErrors.SecurityError
/// This provides a clean conversion between error domains
public func mapSPCToCoreError(_ error: SPCSecurityError) -> CoreErrors.SecurityError {
  switch error {
    case let .encryptionFailed(reason):
      .encryptionError(reason: reason)
    case let .decryptionFailed(reason):
      .decryptionError(reason: reason)
    case let .keyGenerationFailed(reason):
      .keyManagementError(reason: reason)
    case .invalidKey:
      .invalidKey
    case .hashVerificationFailed:
      .verificationFailure(reason: "Hash verification failed")
    case let .randomGenerationFailed(reason):
      .randomGenerationError(reason: reason)
    case let .invalidInput(reason):
      .invalidInput(reason: reason)
    case let .storageOperationFailed(reason):
      .storageError(reason: reason)
    case .timeout:
      .timeout
    case let .serviceError(code, reason):
      .serviceUnavailable(reason: "Code \(code): \(reason)")
    case let .internalError(message):
      .internalError(reason: message)
    case .notImplemented:
      .operationNotSupported
    default:
      .internalError(reason: "Unknown SPC error: \(error)")
  }
}

/// Map from CoreErrors.SecurityError to SecurityProtocolsCore.SecurityError
/// This provides the reverse conversion for round-trip support
public func mapCoreToSPCError(_ error: CoreErrors.SecurityError) -> SPCSecurityError {
  switch error {
    case let .encryptionError(reason):
      .encryptionFailed(reason: reason)
    case let .decryptionError(reason):
      .decryptionFailed(reason: reason)
    case let .keyManagementError(reason):
      .keyGenerationFailed(reason: reason)
    case .invalidKey:
      .invalidKey
    case let .verificationFailure(reason):
      .hashVerificationFailed
    case let .randomGenerationError(reason):
      .randomGenerationFailed(reason: reason)
    case let .invalidInput(reason):
      .invalidInput(reason: reason)
    case let .storageError(reason):
      .storageOperationFailed(reason: reason)
    case .timeout:
      .timeout
    case let .serviceUnavailable(reason):
      .serviceError(code: -1, reason: reason)
    case let .internalError(reason):
      .internalError(reason)
    case .operationNotSupported:
      .notImplemented
    default:
      .internalError("Unmapped core error: \(error)")
  }
}
