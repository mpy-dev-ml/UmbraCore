import CoreErrors
import Foundation
import SecurityProtocolsCore

/// Error types that can be thrown by the SecurityBridge module
extension SecurityBridge {
  /// Error types specific to the bridge layer
  public enum SecurityBridgeError: Error, Sendable {
    /// Bookmark resolution failed
    case bookmarkResolutionFailed
    /// Implementation is missing
    case implementationMissing(String)
  }
}

/// Mapper to convert between SecurityError and SecurityBridgeError
public enum SecurityBridgeErrorMapper {
  /// Maps any error to a Bridge-specific error representation
  ///
  /// This method delegates the core error mapping to the centralised mapper,
  /// then converts the standardised error to a bridge-specific representation.
  ///
  /// - Parameter error: The error to map
  /// - Returns: A SecurityBridgeError representation
  public static func mapToBridgeError(_ error: Error) -> Error {
    // First, ensure we have a consistent SecurityProtocolsCore.SecurityError
    let securityError=CoreErrors.SecurityErrorMapper.mapToSPCError(error)

    // Convert to a bridge-specific error with appropriate message
    let message=String(describing: securityError)
    return SecurityBridge.SecurityBridgeError.implementationMissing(message)
  }

  /// Maps a bridge error to a SecurityError
  ///
  /// This method converts bridge-specific errors to the standardised SecurityError type
  /// using the centralised mapper.
  ///
  /// - Parameter error: The bridge error to map
  /// - Returns: A SecurityError
  public static func mapToSecurityError(_ error: Error) -> Error {
    // If it's already a SecurityBridgeError, create a basic error message
    if let bridgeError=error as? SecurityBridge.SecurityBridgeError {
      let message: String=switch bridgeError {
        case .bookmarkResolutionFailed:
          "Bookmark resolution failed"
        case let .implementationMissing(details):
          details
      }
      // Create a basic SecurityError with the message
      return SecurityProtocolsCore.SecurityError.internalError(message)
    }

    // For all other error types, use our canonical mapper
    return CoreErrors.SecurityErrorMapper.mapToSPCError(error)
  }
}
