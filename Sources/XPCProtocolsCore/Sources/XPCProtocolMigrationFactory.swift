import CoreErrors
import SecurityProtocolsCore
import UmbraCoreTypes

/// Factory class that provides convenience methods for creating protocol adapters
/// during the migration from legacy protocols to the new XPCProtocolsCore protocols.
public enum XPCProtocolMigrationFactory {

  /// Create a standard protocol adapter from a legacy XPC service
  /// This allows using legacy implementations with the new protocol APIs
  ///
  /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
  /// - Returns: An adapter that conforms to XPCServiceProtocolStandard
  public static func createStandardAdapter(from legacyService: Any)
  -> any XPCServiceProtocolStandard {
    LegacyXPCServiceAdapter(service: legacyService)
  }

  /// Create a complete protocol adapter from a legacy XPC service
  /// This provides all the functionality of the complete XPC service protocol
  ///
  /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
  /// - Returns: An adapter that conforms to XPCServiceProtocolComplete
  public static func createCompleteAdapter(from legacyService: Any)
  -> any XPCServiceProtocolComplete {
    LegacyXPCServiceAdapter(service: legacyService)
  }

  /// Create a basic protocol adapter from a legacy XPC service
  /// This provides the minimal functionality of the basic XPC service protocol
  ///
  /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
  /// - Returns: An adapter that conforms to XPCServiceProtocolBasic
  public static func createBasicAdapter(from legacyService: Any) -> any XPCServiceProtocolBasic {
    LegacyXPCServiceAdapter(service: legacyService)
  }

  /// Convert from XPCSecurityError to legacy SecurityError
  ///
  /// - Parameter error: XPCSecurityError to convert
  /// - Returns: Legacy SecurityError
  @available(*, deprecated, message: "Use XPCSecurityError instead")
  public static func convertToLegacyError(_ error: XPCSecurityError) -> SecurityError {
    // Use the centralised mapper for consistent error handling
    CoreErrors.SecurityErrorMapper.mapToSPCError(error)
  }

  /// Convert from legacy error to XPCSecurityError
  ///
  /// - Parameter error: Legacy error to convert
  /// - Returns: Standardised XPCSecurityError
  public static func convertToStandardError(_ error: Error) -> XPCSecurityError {
    // Use the centralised mapper for consistent error handling
    CoreErrors.SecurityErrorMapper.mapToXPCError(error)
  }

  /// Convert from SecurityProtocolsCore.SecurityError to XPCSecurityError
  ///
  /// - Parameter error: Security error from the SecurityProtocolsCore module
  /// - Returns: Equivalent XPCSecurityError
  public static func convertSecurityCoreError(
    _ error: SecurityProtocolsCore.SecurityError
  ) -> XPCSecurityError {
    // Use the centralised mapper for consistent error handling
    CoreErrors.SecurityErrorMapper.mapToXPCError(error)
  }

  /// Convert from XPCSecurityError to SecurityProtocolsCore.SecurityError
  ///
  /// - Parameter error: XPC error
  /// - Returns: Equivalent SecurityProtocolsCore.SecurityError
  public static func convertToSecurityCoreError(_ error: XPCSecurityError) -> SecurityProtocolsCore
  .SecurityError {
    // Use the centralised mapper for consistent error handling
    CoreErrors.SecurityErrorMapper.mapToSPCError(error)
  }

  /// Convert any error to XPCSecurityError
  ///
  /// - Parameter error: Any error
  /// - Returns: XPCSecurityError representation
  public static func anyErrorToXPCError(_ error: Error) -> XPCSecurityError {
    // Use the centralised mapper for consistent error handling
    CoreErrors.SecurityErrorMapper.mapToXPCError(error)
  }
}
