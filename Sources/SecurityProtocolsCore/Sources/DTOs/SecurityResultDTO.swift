// SecurityResultDTO.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import UmbraCoreTypes
/// FoundationIndependent representation of a security operation result.
/// This data transfer object encapsulates the outcome of security-related operations
/// including success with data or failure with error information.
public struct SecurityResultDTO: Sendable, Equatable {

    // MARK: - Properties

    /// Success or failure status
    public let success: Bool

    /// Operation result data, if successful
    public let data: SecureBytes?

    /// Error code if operation failed
    public let errorCode: Int?

    /// Error message if operation failed
    public let errorMessage: String?

    /// Security error type
    public let error: SecurityError?

    // MARK: - Initializers

    /// Initialize a successful result with data
    /// - Parameter data: The operation result data
    public init(data: SecureBytes) {
        self.success = true
        self.data = data
        self.errorCode = nil
        self.errorMessage = nil
        self.error = nil
    }

    /// Initialize a successful result without data
    public init() {
        self.success = true
        self.data = nil
        self.errorCode = nil
        self.errorMessage = nil
        self.error = nil
    }

    /// Initialize with success flag and optional data
    /// - Parameters:
    ///   - success: Whether the operation succeeded
    ///   - data: Optional result data
    public init(success: Bool, data: SecureBytes? = nil) {
        self.success = success
        self.data = data
        self.errorCode = nil
        self.errorMessage = nil
        self.error = nil
    }

    /// Initialize with success flag and error
    /// - Parameters:
    ///   - success: Whether the operation succeeded
    ///   - error: Optional error type
    ///   - errorDetails: Optional detailed error message
    public init(success: Bool, error: SecurityError? = nil, errorDetails: String? = nil) {
        self.success = success
        self.data = nil
        self.error = error

        // Derive error code based on error type
        if let error = error {
            switch error {
            case .encryptionFailed:
                self.errorCode = 1_001
            case .decryptionFailed:
                self.errorCode = 1_002
            case .keyGenerationFailed:
                self.errorCode = 1_003
            case .invalidKey:
                self.errorCode = 1_004
            case .hashVerificationFailed:
                self.errorCode = 1_005
            case .randomGenerationFailed:
                self.errorCode = 1_006
            case .invalidInput:
                self.errorCode = 1_007
            case .storageOperationFailed:
                self.errorCode = 1_008
            case .timeout:
                self.errorCode = 1_009
            case .serviceError(let code, _):
                self.errorCode = code
            case .internalError:
                self.errorCode = 1_010
            case .notImplemented:
                self.errorCode = 1_011
            }

            // Use error description if no specific details provided
            self.errorMessage = errorDetails ?? error.description
        } else {
            self.errorCode = nil
            self.errorMessage = errorDetails
        }
    }

    /// Initialize a failure result with error details
    /// - Parameters:
    ///   - errorCode: Numeric error code
    ///   - errorMessage: Human-readable error message
    public init(errorCode: Int, errorMessage: String) {
        self.success = false
        self.data = nil
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.error = .serviceError(code: errorCode, reason: errorMessage)
    }

    // MARK: - Utility Methods

    /// Create a successful result with the given data
    /// - Parameter data: Result data
    /// - Returns: A success result DTO
    public static func success(data: SecureBytes) -> SecurityResultDTO {
        return SecurityResultDTO(data: data)
    }

    /// Create a successful result with no data
    /// - Returns: A success result DTO
    public static func success() -> SecurityResultDTO {
        return SecurityResultDTO()
    }

    /// Create a failure result with the given error information
    /// - Parameters:
    ///   - code: Error code
    ///   - message: Error message
    /// - Returns: A failure result DTO
    public static func failure(code: Int, message: String) -> SecurityResultDTO {
        return SecurityResultDTO(errorCode: code, errorMessage: message)
    }

    /// Create a failure result with a SecurityError
    /// - Parameters:
    ///   - error: The security error that occurred
    ///   - details: Optional additional details
    /// - Returns: A failure result DTO
    public static func failure(error: SecurityError, details: String? = nil) -> SecurityResultDTO {
        return SecurityResultDTO(success: false, error: error, errorDetails: details)
    }
}
