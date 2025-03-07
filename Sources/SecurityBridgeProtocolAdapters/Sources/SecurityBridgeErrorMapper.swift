import SecurityInterfacesProtocols
import SecurityProtocolsCore
import XPCProtocolsCore
import CoreErrors
import SecurityTypeConverters

/// Error type specific to the security bridge layer
public enum SecurityBridgeError: Error {
  case invalidInputType
  case mappingFailed
  case unsupportedErrorType
  case invalidConfiguration
}

/// Maps between different security error types to provide
/// a consistent error handling interface across security modules
public enum SecurityBridgeErrorMapper {

  /// Maps any error to a SecurityError
  /// - Parameter error: The error to map
  /// - Returns: A SecurityProtocolsCore.SecurityError representation of the error
  public static func mapToSecurityError(_ error: Error) -> SecurityProtocolsCore.SecurityError {
    // Use the standardised error mapper from SecurityTypeConverters
    return SecurityErrorMapper.toSecurityError(error)
  }

  /// Maps a security error to an XPC error type for transmission over XPC
  /// - Parameter error: The error to map
  /// - Returns: An CoreErrors.XPCErrors.SecurityError representation of the error
  public static func mapToXPCError(_ error: Error) -> CoreErrors.XPCErrors.SecurityError {
    // Use the standardised error mapper from SecurityTypeConverters
    return SecurityErrorMapper.toXPCError(error)
  }
}
