import Foundation
import ErrorHandling
import ErrorHandlingDomains

// Removed import SecurityProtocolsCore to break circular dependency
import UmbraCoreTypes

// Type alias to disambiguate SecurityError types
typealias SPCSecurityError = UmbraErrors.Security.Protocols

/// Factory class that provides convenience methods for creating protocol adapters
/// during the migration from legacy protocols to the new XPCProtocolsCore protocols.
///
/// **Migration Notice:**
/// This factory previously supported creating adapters that wrapped legacy services.
/// In the current implementation, all factory methods create instances of ModernXPCService
/// which directly implements all XPC service protocols by default. If specific test dependencies
/// require a legacy adapter, you can still create one by providing the appropriate service.
///
/// - To transition from LegacyXPCServiceAdapter to ModernXPCService:
///   1. Replace direct instantiation of LegacyXPCServiceAdapter with the appropriate factory method
///   2. Ensure your code is using the protocol interfaces (XPCServiceProtocolBasic, etc.) rather than
///      the concrete implementation types
///   3. If you need specific functionality from the legacy adapter, consider subclassing ModernXPCService
///      or extending the protocol with your custom implementation
public enum XPCProtocolMigrationFactory {
    /// Create a standard protocol adapter
    ///
    /// - Parameter service: Optional legacy service to wrap (for testing and backwards compatibility)
    /// - Returns: An implementation that conforms to XPCServiceProtocolStandard
    public static func createStandardAdapter(
        service: NSObject? = nil
    ) -> any XPCServiceProtocolStandard {
        if let legacyService = service {
            // Warning: This use of LegacyXPCServiceAdapter is deprecated and will be removed in future
            return LegacyXPCServiceAdapter(service: legacyService)
        }
        return ModernXPCService()
    }
    
    /// Create a complete protocol adapter
    ///
    /// - Parameter service: Optional legacy service to wrap (for testing and backwards compatibility)
    /// - Returns: An implementation that conforms to XPCServiceProtocolComplete
    public static func createCompleteAdapter(
        service: NSObject? = nil
    ) -> any XPCServiceProtocolComplete {
        if let legacyService = service {
            // Warning: This use of LegacyXPCServiceAdapter is deprecated and will be removed in future
            return LegacyXPCServiceAdapter(service: legacyService)
        }
        return ModernXPCService()
    }
    
    /// Create a basic protocol adapter
    ///
    /// - Parameter service: Optional legacy service to wrap (for testing and backwards compatibility)
    /// - Returns: An implementation that conforms to XPCServiceProtocolBasic
    public static func createBasicAdapter(
        service: NSObject? = nil
    ) -> any XPCServiceProtocolBasic {
        if let legacyService = service {
            // Warning: This use of LegacyXPCServiceAdapter is deprecated and will be removed in future
            return LegacyXPCServiceAdapter(service: legacyService)
        }
        return ModernXPCService()
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
