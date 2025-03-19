import ErrorHandling
import ErrorHandlingDomains
import Foundation

// Removed import SecurityProtocolsCore to break circular dependency
import UmbraCoreTypes

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
        let domain = nsError.domain
        let code = nsError.code

        // Try to create a more specific error based on domain and code
        if domain.contains("auth") {
            return .authenticationFailed(reason: "Error \(code)")
        } else if domain.contains("timeout") {
            return .timeout(after: 30.0) // Default timeout
        } else if domain.contains("crypto") || domain.contains("security") {
            return .cryptographicError(operation: "unknown", details: "Error \(code)")
        } else {
            return .internalError(reason: nsError.localizedDescription)
        }
    }
}

// MARK: - Swift Concurrency Helpers

public extension XPCProtocolMigrationFactory {
    /// Convert a completion handler-based function to an async function
    ///
    /// - Parameters:
    ///   - operation: The operation to perform with a completion handler
    /// - Returns: A Result with the operation result or error
    static func withAsyncErrorHandling<T>(
        _ operation: (@escaping (Result<T, Error>) -> Void) -> Void
    ) async -> Result<T, XPCSecurityError> {
        return await withCheckedContinuation { continuation in
            operation { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: .success(value))
                case .failure(let error):
                    continuation.resume(returning: .failure(convertErrorToXPCSecurityError(error)))
                }
            }
        }
    }

    /// Convert a traditional success/error completion handler to an async function
    ///
    /// - Parameters:
    ///   - operation: The operation with traditional (T?, Error?) completion
    /// - Returns: A Result with the operation result or error
    static func withTraditionalAsyncErrorHandling<T>(
        _ operation: (@escaping (T?, Error?) -> Void) -> Void
    ) async -> Result<T, XPCSecurityError> {
        return await withCheckedContinuation { continuation in
            operation { value, error in
                if let error = error {
                    continuation.resume(returning: .failure(convertErrorToXPCSecurityError(error)))
                } else if let value = value {
                    continuation.resume(returning: .success(value))
                } else {
                    continuation.resume(returning: .failure(.invalidData(reason: "Both value and error were nil")))
                }
            }
        }
    }
}
