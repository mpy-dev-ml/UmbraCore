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
        // DEPRECATED: let domain = nsError.domain
        let code = nsError.code

        // Try to create a more specific error based on domain and code
        // DEPRECATED: if domain.contains("auth") {
            return .authenticationFailed(reason: "Error \(code)")
        // DEPRECATED: } else if domain.contains("timeout") {
            return .timeout(after: 30.0) // Default timeout
        // DEPRECATED: } else if domain.contains("crypto") || domain.contains("security") {
            return .cryptographicError(operation: "unknown", details: "Error \(code)")
        } else {
            return .internalError(reason: nsError.localizedDescription)
        }

// MARK: - Swift Concurrency Helpers

// DEPRECATED: public extension XPCProtocolMigrationFactory {
// DEPRECATED:     /// Convert a completion handler-based function to an async function
// DEPRECATED:     ///
// DEPRECATED:     /// - Parameters:
// DEPRECATED:     ///   - operation: The operation to perform with a completion handler
// DEPRECATED:     /// - Returns: A Result with the operation result or error
// DEPRECATED:     static func withAsyncErrorHandling<T>(
// DEPRECATED:         _ operation: (@escaping (Result<T, Error>) -> Void) -> Void
// DEPRECATED:     ) async -> Result<T, XPCSecurityError> {
// DEPRECATED:         await withCheckedContinuation { continuation in
// DEPRECATED:             operation { result in
// DEPRECATED:                 switch result {
// DEPRECATED:                 case let .success(value):
// DEPRECATED:                     continuation.resume(returning: .success(value))
// DEPRECATED:                 case let .failure(error):
// DEPRECATED:                     continuation.resume(returning: .failure(convertErrorToXPCSecurityError(error)))
// DEPRECATED:                 }
// DEPRECATED:             }
// DEPRECATED:         }
// DEPRECATED:     }

// DEPRECATED:     /// Convert a traditional success/error completion handler to an async function
// DEPRECATED:     ///
// DEPRECATED:     /// - Parameters:
// DEPRECATED:     ///   - operation: The operation with traditional (T?, Error?) completion
// DEPRECATED:     /// - Returns: A Result with the operation result or error
// DEPRECATED:     static func withTraditionalAsyncErrorHandling<T>(
// DEPRECATED:         _ operation: (@escaping (T?, Error?) -> Void) -> Void
// DEPRECATED:     ) async -> Result<T, XPCSecurityError> {
// DEPRECATED:         await withCheckedContinuation { continuation in
// DEPRECATED:             operation { value, error in
// DEPRECATED:                 if let error {
// DEPRECATED:                     continuation.resume(returning: .failure(convertErrorToXPCSecurityError(error)))
// DEPRECATED:                 } else if let value {
// DEPRECATED:                     continuation.resume(returning: .success(value))
// DEPRECATED:                 } else {
// DEPRECATED:                     continuation.resume(returning: .failure(.invalidData(reason: "Both value and error were nil")))
// DEPRECATED:                 }
// DEPRECATED:             }
// DEPRECATED:         }
// DEPRECATED:     }
// DEPRECATED: }
