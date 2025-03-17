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
    
    // MARK: - Migration Helper Methods
    
    /// Creates a wrapper for a legacy XPC service using NSObject-derived protocol
    ///
    /// - Parameter legacyService: The legacy service to wrap
    /// - Returns: A modern XPCServiceProtocolComplete implementation
    public static func createWrapperForLegacyService(
        _ legacyService: NSObject
    ) -> any XPCServiceProtocolComplete {
        return createCompleteAdapter(service: legacyService)
    }
    
    /// Creates a mock service implementation for testing purposes
    ///
    /// - Parameter mockResponses: Dictionary of method names to mock responses
    /// - Returns: A mock XPCServiceProtocolComplete implementation
    public static func createMockService(
        mockResponses: [String: Any] = [:]
    ) -> any XPCServiceProtocolComplete {
        // This could be expanded in the future to provide a more sophisticated mock
        return ModernXPCService()
    }
    
    /// Convert NSData to SecureBytes
    ///
    /// Useful for migration from legacy code using NSData to modern code using SecureBytes
    ///
    /// - Parameter nsData: The NSData object to convert
    /// - Returns: A SecureBytes instance containing the same data
    public static func convertNSDataToSecureBytes(_ nsData: NSData) -> SecureBytes {
        return SecureBytes(data: nsData as Data)
    }
    
    /// Convert Error to XPCSecurityError
    ///
    /// Useful for mapping general errors to the specific XPCSecurityError type
    ///
    /// - Parameters:
    ///   - error: The error to convert
    ///   - context: Additional context about where the error occurred
    /// - Returns: An appropriate XPCSecurityError
    public static func convertToXPCSecurityError(
        _ error: Error,
        context: String? = nil
    ) -> XPCSecurityError {
        // If it's already an XPCSecurityError, return it
        if let securityError = error as? XPCSecurityError {
            return securityError
        }
        
        // Add context if provided
        let errorDescription = error.localizedDescription
        let contextPrefix = context != nil ? "\(context!): " : ""
        let reason = "\(contextPrefix)\(errorDescription)"
        
        // Try to infer the error type from the error domain or description
        let errorString = String(describing: error)
        
        if errorString.contains("encrypt") || errorString.contains("decrypt") {
            return .encryptionError(reason: reason)
        } else if errorString.contains("key") {
            return .keyError(reason: reason)
        } else if errorString.contains("signature") || errorString.contains("sign") || errorString.contains("verify") {
            return .signatureError(reason: reason)
        } else if errorString.contains("storage") || errorString.contains("store") {
            return .storageError(reason: reason)
        } else if errorString.contains("permission") || errorString.contains("access") {
            return .permissionError(reason: reason)
        } else {
            return .internalError(reason: reason)
        }
    }
}

// MARK: - Swift Concurrency Helpers

extension XPCProtocolMigrationFactory {
    /// Converts a completion handler-based async call to a modern async/await call
    ///
    /// - Parameters:
    ///   - completionHandler: A function that takes a callback closure
    ///   - callback: The callback to be passed to the completion handler
    /// - Returns: A result containing the success value or error
    public static func convertToAsync<T>(
        completionHandler: (@escaping (T?, Error?) -> Void) -> Void
    ) async -> Result<T, XPCSecurityError> {
        return await withCheckedContinuation { continuation in
            completionHandler { value, error in
                if let error = error {
                    continuation.resume(returning: .failure(convertToXPCSecurityError(error)))
                } else if let value = value {
                    continuation.resume(returning: .success(value))
                } else {
                    continuation.resume(returning: .failure(.internalError(reason: "No value or error returned")))
                }
            }
        }
    }
    
    /// Converts a modern async call to a completion handler-based call
    ///
    /// - Parameters:
    ///   - asyncOperation: The async operation to perform
    ///   - completion: The completion handler to call with the result
    public static func convertToCompletion<T>(
        asyncOperation: @escaping () async -> Result<T, XPCSecurityError>,
        completion: @escaping (T?, Error?) -> Void
    ) {
        Task {
            let result = await asyncOperation()
            switch result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

// MARK: - Data Conversion Helpers

extension XPCProtocolMigrationFactory {
    /// Convert SecureBytes to Data
    ///
    /// Useful when integrating with APIs that require Data
    ///
    /// - Parameter secureBytes: The SecureBytes to convert
    /// - Returns: A Data instance containing the same bytes
    public static func convertSecureBytesToData(_ secureBytes: SecureBytes) -> Data {
        return secureBytes.data
    }
    
    /// Convert Data to SecureBytes
    ///
    /// Useful when receiving Data from external APIs
    ///
    /// - Parameter data: The Data to convert
    /// - Returns: A SecureBytes instance containing the same data
    public static func convertDataToSecureBytes(_ data: Data) -> SecureBytes {
        return SecureBytes(data: data)
    }
}
