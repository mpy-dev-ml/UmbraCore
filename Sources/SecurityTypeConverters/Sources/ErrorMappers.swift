import CoreErrors
import SecurityProtocolsCore
import XPCProtocolsCore

/// Provides standardised error mapping between different security error types
public enum SecurityErrorMapper {
  /// Map any error to SecurityError from SecurityProtocolsCore
  /// - Parameter error: The error to map
  /// - Returns: A SecurityError representation of the error from SecurityProtocolsCore
  public static func toSecurityError(_ error: Error) -> SecurityProtocolsCore.SecurityError {
    // Delegate to the canonical implementation in CoreErrors and cast the result
    // The force cast is safe because mapToSPCError is designed to be used in this context
    CoreErrors.SecurityErrorMapper.mapToSPCError(error) as! SecurityProtocolsCore.SecurityError
  }

  /// Map any error to CoreErrors.SecurityError
  /// - Parameter error: The error to map
  /// - Returns: A CoreErrors.SecurityError representation of the error
  public static func toCoreError(_ error: Error) -> CoreErrors.SecurityError {
    // Delegate to the canonical implementation in CoreErrors
    CoreErrors.SecurityErrorMapper.mapToCoreError(error)
  }

  /// Map any error to XPC security error type
  /// - Parameter error: The error to map
  /// - Returns: An CoreErrors.XPCErrors.SecurityError representation
  public static func toXPCError(_ error: Error) -> CoreErrors.XPCErrors.SecurityError {
    // Delegate to the canonical implementation in CoreErrors
    CoreErrors.SecurityErrorMapper.mapToXPCError(error)
  }
}
