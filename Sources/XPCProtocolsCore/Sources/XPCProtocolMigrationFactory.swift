import CoreErrors
import ErrorHandling
import ErrorHandlingDomains
import SecurityProtocolsCore
import UmbraCoreTypes

// Type alias to disambiguate SecurityError types
typealias SPCSecurityError = UmbraErrors.Security.Protocols

/// Factory class that provides convenience methods for creating protocol adapters
/// during the migration from legacy protocols to the new XPCProtocolsCore protocols.
public enum XPCProtocolMigrationFactory {
    /// Create a standard protocol adapter from a legacy XPC service
    /// This allows using legacy implementations with the new protocol APIs
    ///
    /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
    /// - Returns: An adapter that conforms to XPCServiceProtocolStandard
    public static func createStandardAdapter(from legacyService: Any)
        -> any XPCServiceProtocolStandard
    {
        LegacyXPCServiceAdapter(service: legacyService)
    }

    /// Create a complete protocol adapter from a legacy XPC service
    /// This provides all the functionality of the complete XPC service protocol
    ///
    /// - Parameter legacyService: Any legacy XPC service that implements legacy protocols
    /// - Returns: An adapter that conforms to XPCServiceProtocolComplete
    public static func createCompleteAdapter(from legacyService: Any)
        -> any XPCServiceProtocolComplete
    {
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

    /// Convert from legacy error to XPCSecurityError
    ///
    /// - Parameter error: Legacy error to convert
    /// - Returns: Standardised XPCSecurityError
    public static func convertToStandardError(_ error: Error) -> XPCSecurityError {
        // If the error is already an XPCSecurityError, return it directly
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        }

        // Otherwise create a general error with the original error's description
        return .internalError(reason: error.localizedDescription)
    }

    /// Convert any error to XPCSecurityError
    ///
    /// - Parameter error: Any error
    /// - Returns: XPCSecurityError representation
    public static func anyErrorToXPCError(_ error: Error) -> XPCSecurityError {
        // If the error is already an XPCSecurityError, return it directly
        if let xpcError = error as? XPCSecurityError {
            return xpcError
        }

        // Otherwise create a general error with the original error's description
        return .internalError(reason: error.localizedDescription)
    }
}
