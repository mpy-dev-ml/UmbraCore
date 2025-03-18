import UmbraCoreTypes

/// FoundationIndependent representation of an operation result.
/// This data transfer object encapsulates the outcome of an operation
/// without using any Foundation types.
public struct OperationResultDTO<T>: Sendable, Equatable where T: Sendable, T: Equatable {
    // MARK: - Types

    /// Represents the status of an operation
    public enum Status: String, Sendable, Equatable {
        /// Operation completed successfully
        case success
        /// Operation failed with an error
        case failure
        /// Operation was cancelled
        case cancelled
        
        /// Whether this status represents a success
        public var isSuccess: Bool {
            self == .success
        }
        
        /// Whether this status represents a failure
        public var isFailure: Bool {
            self == .failure || self == .cancelled
        }
    }

    // MARK: - Properties

    /// Current status of the operation
    public let status: Status

    /// Result value if the operation was successful
    public let value: T?

    /// Error code if the operation failed
    public let errorCode: Int?

    /// Error message if the operation failed
    public let errorMessage: String?

    /// Additional details about the operation
    public let details: [String: String]

    // MARK: - Initializers

    /// Full initializer with all result information
    /// - Parameters:
    ///   - status: Current status of the operation
    ///   - value: Result value if the operation was successful
    ///   - errorCode: Error code if the operation failed
    ///   - errorMessage: Error message if the operation failed
    ///   - details: Additional details about the operation
    public init(
        status: Status,
        value: T? = nil,
        errorCode: Int? = nil,
        errorMessage: String? = nil,
        details: [String: String] = [:]
    ) {
        self.status = status
        self.value = value
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.details = details
    }

    // MARK: - Factory Methods

    /// Create a successful operation result
    /// - Parameters:
    ///   - value: The successful result value
    ///   - details: Additional details about the operation
    /// - Returns: An OperationResultDTO indicating success
    public static func success(_ value: T, details: [String: String] = [:]) -> OperationResultDTO<T> {
        OperationResultDTO(
            status: .success,
            value: value,
            details: details
        )
    }

    /// Create a failure operation result
    /// - Parameters:
    ///   - errorCode: Error code for the failure
    ///   - errorMessage: Error message describing the failure
    ///   - details: Additional details about the operation
    /// - Returns: An OperationResultDTO indicating failure
    public static func failure(
        errorCode: Int,
        errorMessage: String,
        details: [String: String] = [:]
    ) -> OperationResultDTO<T> {
        OperationResultDTO(
            status: .failure,
            errorCode: errorCode,
            errorMessage: errorMessage,
            details: details
        )
    }

    /// Create a cancelled operation result
    /// - Parameters:
    ///   - message: Optional message explaining why the operation was cancelled
    ///   - details: Additional details about the operation
    /// - Returns: An OperationResultDTO indicating cancellation
    public static func cancelled(
        message: String? = "Operation cancelled by user",
        details: [String: String] = [:]
    ) -> OperationResultDTO<T> {
        OperationResultDTO(
            status: .cancelled,
            errorCode: -1,
            errorMessage: message,
            details: details
        )
    }

    // MARK: - Computed Properties

    /// Whether the operation was successful
    public var isSuccess: Bool {
        status.isSuccess
    }

    /// Whether the operation failed
    public var isFailure: Bool {
        status.isFailure
    }

    // MARK: - Methods

    /// Get the value or throw an error if the operation failed
    /// - Returns: The operation value
    /// - Throws: A CoreErrors.OperationError if the operation failed
    public func valueOrThrow() throws -> T {
        guard let value = value, status == .success else {
            throw UmbraCoreTypes.CoreErrors.Operation.operationFailed(
                message: errorMessage ?? "Unknown error",
                code: errorCode ?? -1
            )
        }
        return value
    }

    /// Apply a transform function to the successful value
    /// - Parameter transform: A function to transform the value
    /// - Returns: A new OperationResultDTO with the transformed value, or the original error
    public func map<U>(_ transform: (T) -> U) -> OperationResultDTO<U> where U: Sendable, U: Equatable {
        switch status {
        case .success:
            guard let value = value else {
                return OperationResultDTO<U>(
                    status: .failure,
                    errorCode: -1,
                    errorMessage: "Value is nil but status is success",
                    details: details
                )
            }
            return OperationResultDTO<U>(
                status: .success,
                value: transform(value),
                details: details
            )
        case .failure, .cancelled:
            return OperationResultDTO<U>(
                status: status,
                errorCode: errorCode,
                errorMessage: errorMessage,
                details: details
            )
        }
    }

    /// Apply a transform function that may fail to the successful value
    /// - Parameter transform: A function that returns a Result
    /// - Returns: A new OperationResultDTO with the transformed value, or a new error
    public func flatMap<U>(_ transform: (T) -> OperationResultDTO<U>) -> OperationResultDTO<U> where U: Sendable, U: Equatable {
        switch status {
        case .success:
            guard let value = value else {
                return OperationResultDTO<U>(
                    status: .failure,
                    errorCode: -1,
                    errorMessage: "Value is nil but status is success",
                    details: details
                )
            }
            return transform(value)
        case .failure, .cancelled:
            return OperationResultDTO<U>(
                status: status,
                errorCode: errorCode,
                errorMessage: errorMessage,
                details: details
            )
        }
    }

    /// Add additional details to the result
    /// - Parameter additionalDetails: The details to add
    /// - Returns: A new OperationResultDTO with updated details
    public func withDetails(_ additionalDetails: [String: String]) -> OperationResultDTO<T> {
        var newDetails = self.details
        for (key, value) in additionalDetails {
            newDetails[key] = value
        }
        
        return OperationResultDTO(
            status: status,
            value: value,
            errorCode: errorCode,
            errorMessage: errorMessage,
            details: newDetails
        )
    }
}
