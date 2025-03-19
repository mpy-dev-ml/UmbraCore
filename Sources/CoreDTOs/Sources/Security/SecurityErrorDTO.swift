import UmbraCoreTypes

/// FoundationIndependent representation of a security error.
/// This data transfer object encapsulates security error information
/// without using any Foundation types.
public struct SecurityErrorDTO: Error, Sendable, Equatable, CustomStringConvertible {
    // MARK: - Properties

    /// Error code value
    public let code: Int32

    /// Error domain identifier
    public let domain: String

    /// Human-readable error message
    public let message: String

    /// Additional error details
    public let details: [String: String]

    // MARK: - Initializers

    /// Create a security error
    /// - Parameters:
    ///   - code: Error code
    ///   - domain: Error domain
    ///   - message: Error message
    ///   - details: Additional details
    public init(
        code: Int32,
        domain: String = "security",
        message: String,
        details: [String: String] = [:]
    ) {
        self.code = code
        self.domain = domain
        self.message = message
        self.details = details
    }

    // MARK: - CustomStringConvertible

    /// Human-readable description
    public var description: String {
        "[\(domain):\(code)] \(message)"
    }

    // MARK: - Factory Methods

    /// Create an encryption error
    /// - Parameters:
    ///   - message: Error message
    ///   - details: Additional details
    /// - Returns: A SecurityErrorDTO
    public static func encryptionError(
        message: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 1_001,
            message: message,
            details: details
        )
    }

    /// Create a decryption error
    /// - Parameters:
    ///   - message: Error message
    ///   - details: Additional details
    /// - Returns: A SecurityErrorDTO
    public static func decryptionError(
        message: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 1_002,
            message: message,
            details: details
        )
    }

    /// Create a key error
    /// - Parameters:
    ///   - message: Error message
    ///   - details: Additional details
    /// - Returns: A SecurityErrorDTO
    public static func keyError(
        message: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 1_003,
            message: message,
            details: details
        )
    }

    /// Create a storage error
    /// - Parameters:
    ///   - message: Error message
    ///   - details: Additional details
    /// - Returns: A SecurityErrorDTO
    public static func storageError(
        message: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 1_004,
            message: message,
            details: details
        )
    }

    /// Create an access error
    /// - Parameters:
    ///   - message: Error message
    ///   - details: Additional details
    /// - Returns: A SecurityErrorDTO
    public static func accessError(
        message: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 1_005,
            message: message,
            details: details
        )
    }
}
