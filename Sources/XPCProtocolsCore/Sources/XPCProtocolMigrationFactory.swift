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

    /// Creates a wrapper for a legacy XPC service using NSObject-derived protocol
    ///
    /// - Parameter legacyService: The legacy service to wrap
    /// - Returns: A modern XPCServiceProtocolComplete implementation
    public static func createWrapperForLegacyService(
        _: NSObject
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

    /// Convert NSData to SecureBytes
    ///
    /// Useful for migration from legacy code using NSData to modern code using SecureBytes
    ///
    /// - Parameter nsData: The NSData object to convert
    /// - Returns: A SecureBytes instance containing the same data
    public static func convertNSDataToSecureBytes(_ nsData: NSData) -> SecureBytes {
        SecureBytes(bytes: [UInt8](Data(referencing: nsData)))
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
            return .encryptionFailed(reason: reason)
        } else if errorString.contains("key") {
            return .keyGenerationFailed(reason: reason)
        } else if errorString.contains("signature") || errorString.contains("sign") || errorString.contains("verify") {
            return .cryptographicError(operation: "signature", details: reason)
        } else if errorString.contains("storage") || errorString.contains("store") {
            return .invalidState(details: reason)
        } else if errorString.contains("permission") || errorString.contains("access") {
            return .authorizationDenied(operation: "access")
        } else {
            return .internalError(reason: reason)
        }
    }
}

// MARK: - Swift Concurrency Helpers

public extension XPCProtocolMigrationFactory {
    /// Converts a completion handler-based async call to a modern async/await call
    ///
    /// - Parameters:
    ///   - completionHandler: A function that takes a callback closure
    ///   - callback: The callback to be passed to the completion handler
    /// - Returns: A result containing the success value or error
    static func convertToAsync<T>(
        completionHandler: (@escaping (T?, Error?) -> Void) -> Void
    ) async -> Result<T, XPCSecurityError> {
        await withCheckedContinuation { continuation in
            completionHandler { value, error in
                if let error {
                    continuation.resume(returning: .failure(convertToXPCSecurityError(error)))
                } else if let value {
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
    static func convertToCompletion<T>(
        asyncOperation: @escaping () async -> Result<T, XPCSecurityError>,
        completion: @escaping (T?, Error?) -> Void
    ) {
        Task {
            let result = await asyncOperation()
            switch result {
            case let .success(value):
                completion(value, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
}

// MARK: - Data Conversion Helpers

public extension XPCProtocolMigrationFactory {
    /// Convert SecureBytes to Data
    ///
    /// Useful when integrating with APIs that require Data
    ///
    /// - Parameter secureBytes: The SecureBytes to convert
    /// - Returns: A Data instance containing the same bytes
    static func convertSecureBytesToData(_ secureBytes: SecureBytes) -> Data {
        var bytes = [UInt8]()
        bytes.reserveCapacity(secureBytes.count)

        for i in 0 ..< secureBytes.count {
            bytes.append(secureBytes[i])
        }

        return Data(bytes)
    }

    /// Convert Data to SecureBytes
    ///
    /// Useful when receiving Data from external APIs
    ///
    /// - Parameter data: The Data to convert
    /// - Returns: A SecureBytes instance containing the same data
    static func convertDataToSecureBytes(_ data: Data) -> SecureBytes {
        SecureBytes(bytes: [UInt8](data))
    }
}
