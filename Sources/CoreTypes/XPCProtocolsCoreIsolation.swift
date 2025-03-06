import CoreErrors
import Foundation
import UmbraCoreTypes

// Only import XPCProtocolsCore in this file to isolate namespace conflicts
import XPCProtocolsCore

/// Direct access to the XPCSecurityError type in the XPCProtocolsCore module
/// This approach avoids the namespace conflict with the enum named XPCProtocolsCore
public typealias XPCSecurityError=XPCProtocolsCore.XPCSecurityError

/// Map from XPCProtocolsCore.XPCSecurityError to CoreErrors.SecurityError
/// This provides a clean conversion between error domains
public func mapXPCToCoreError(_ error: XPCSecurityError) -> CoreErrors.SecurityError {
  switch error {
    case let .encryptionError(reason):
      .encryptionError(reason: reason)
    case let .decryptionError(reason):
      .decryptionError(reason: reason)
    case let .keyError(reason):
      .keyManagementError(reason: reason)
    case .invalidKey:
      .invalidKey
    case let .authenticationError(reason):
      .authenticationError(reason: reason)
    case let .invalidInput(reason):
      .invalidInput(reason: reason)
    case .serviceNotAvailable:
      .serviceUnavailable(reason: "XPC service not available")
    case .operationNotSupported:
      .operationNotSupported
    case let .internalError(reason):
      .internalError(reason: reason)
    default:
      .internalError(reason: "Unknown XPC error: \(error)")
  }
}

/// Map from CoreErrors.SecurityError to XPCProtocolsCore.XPCSecurityError
/// This provides the reverse conversion for round-trip support
public func mapCoreToXPCError(_ error: CoreErrors.SecurityError) -> XPCSecurityError {
  switch error {
    case let .encryptionError(reason):
      .encryptionError(reason: reason)
    case let .decryptionError(reason):
      .decryptionError(reason: reason)
    case let .keyManagementError(reason):
      .keyError(reason: reason)
    case .invalidKey:
      .invalidKey
    case let .authenticationError(reason):
      .authenticationError(reason: reason)
    case let .invalidInput(reason):
      .invalidInput(reason: reason)
    case .serviceUnavailable:
      .serviceNotAvailable
    case .operationNotSupported:
      .operationNotSupported
    case let .internalError(reason):
      .internalError(reason: reason)
    default:
      .internalError(reason: "Unmapped core error: \(error)")
  }
}

/// Provide consistent factory methods for common XPC security operations
public enum XPCSecurityOperations {
  /// Create a standard encryption error
  public static func createEncryptionError(reason: String) -> XPCSecurityError {
    .encryptionError(reason: reason)
  }

  /// Create a standard decryption error
  public static func createDecryptionError(reason: String) -> XPCSecurityError {
    .decryptionError(reason: reason)
  }

  /// Create a standard key error
  public static func createKeyError(reason: String) -> XPCSecurityError {
    .keyError(reason: reason)
  }
}
