// SecurityResultDTO.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import SecureBytes

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

    // MARK: - Initializers

    /// Initialize a successful result with data
    /// - Parameter data: The operation result data
    public init(data: SecureBytes) {
        self.success = true
        self.data = data
        self.errorCode = nil
        self.errorMessage = nil
    }

    /// Initialize a successful result without data
    public init() {
        self.success = true
        self.data = nil
        self.errorCode = nil
        self.errorMessage = nil
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
}
