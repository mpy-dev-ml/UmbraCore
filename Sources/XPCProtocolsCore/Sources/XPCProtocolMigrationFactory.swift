import ErrorHandling
import ErrorHandlingDomains
import Foundation

// Type alias to disambiguate SecurityError types
typealias SPCSecurityError = UmbraErrors.Security.Protocols

/// Factory class that provides convenience methods for creating protocol adapters
/// during the migration from legacy protocols to the new XPCProtocolsCore protocols.
///
/// **Migration Notice:**
/// This factory now exclusively creates ModernXPCService instances which implement
/// all XPC service protocols. Legacy adapters have been removed as part of the
/// modernization effort.
///
/// The factory methods remain to ensure API compatibility, but all return
/// ModernXPCService implementations.
public enum XPCProtocolMigrationFactory {
    /// Create a standard protocol adapter
    ///
    /// - Returns: An implementation that conforms to XPCServiceProtocolStandard
    public static func createStandardAdapter() -> any XPCServiceProtocolStandard {
        ModernXPCService()
    }

    /// Create a complete protocol adapter
    ///
    /// - Returns: An implementation that conforms to XPCServiceProtocolComplete
    public static func createCompleteAdapter() -> any XPCServiceProtocolComplete {
        ModernXPCService()
    }

    /// Create a basic protocol adapter
    ///
    /// - Returns: An implementation that conforms to XPCServiceProtocolBasic
    public static func createBasicAdapter() -> any XPCServiceProtocolBasic {
        ModernXPCService()
    }

    /// Convert from legacy error to XPCSecurityError
    ///
    /// - Parameter error: Error to convert
    /// - Returns: XPCSecurityError representation
    public static func convertLegacyError(_ error: Error) -> XPCSecurityError {
        // First check if it's already the right type
        if let securityError = error as? XPCSecurityError {
            return securityError
        }
        
        // Convert to XPCSecurityError with appropriate mapping
        let nsError = error as NSError
        
        // Try to create a more specific error based on domain and code
        return .internalError(reason: nsError.localizedDescription)
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

    /// Map any NSError to an XPCSecurityError
    /// - Parameter error: The error to map
    /// - Returns: An XPCSecurityError representing the given error
    public static func mapError(_ error: Error) -> XPCSecurityError {
        // NSError properties
        let nsError = error as NSError
        let domain = nsError.domain
        
        // Map specific error domains
        if domain == NSURLErrorDomain {
            return .connectionInterrupted
        } else {
            return .internalError(reason: nsError.localizedDescription)
        }
    }

    // MARK: - Migration Helper Methods

    /// Creates a wrapper for a legacy XPC service
    ///
    /// - Parameter legacyService: The legacy service to wrap
    /// - Returns: A modern XPCServiceProtocolComplete implementation
    public static func createWrapperForLegacyService(
        _: Any
    ) -> any XPCServiceProtocolComplete {
        createCompleteAdapter()
    }

    /// Creates a mock service implementation for testing purposes
    ///
    /// - Parameter mockResponses: Dictionary of method names to mock responses
    /// - Returns: A mock XPCServiceProtocolComplete implementation
    public static func createMockService(
        mockResponses _: [String: Any] = [:]
    ) -> any XPCServiceProtocolComplete {
        // This could be expanded in the future to provide a more sophisticated mock
        ModernXPCService()
    }

    /// Convert Data to SecureBytes
    ///
    /// Useful for migration from legacy code using Data to modern code using SecureBytes
    ///
    /// - Parameter data: The Data object to convert
    /// - Returns: A SecureBytes instance containing the same data
    public static func convertDataToSecureBytes(_ data: Data) -> SecureBytes {
        SecureBytes(bytes: [UInt8](data))
    }

    /// Convert SecureBytes to Data
    ///
    /// Useful for interoperability with APIs that require Data
    ///
    /// - Parameter secureBytes: The SecureBytes to convert
    /// - Returns: A Data instance containing the same bytes
    public static func convertSecureBytesToData(_ secureBytes: SecureBytes) -> Data {
        Data(secureBytes)
    }

    /// Convert a generic Error to XPCSecurityError
    ///
    /// - Parameter error: The error to convert
    /// - Returns: Equivalent XPCSecurityError
    public static func convertErrorToXPCSecurityError(
        _ error: Error
    ) -> XPCSecurityError {
        // If it's already an XPCSecurityError, return it
        if let securityError = error as? XPCSecurityError {
            return securityError
        }

        // Convert to XPCSecurityError with appropriate mapping
        let nsError = error as NSError
        
        // Try to create a more specific error based on domain and code
        return .internalError(reason: nsError.localizedDescription)
    }

// MARK: - Swift Concurrency Helpers
}
