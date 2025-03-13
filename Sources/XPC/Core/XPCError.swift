import Foundation

/// Errors that can occur during XPC operations
@frozen
public enum XPCError: LocalizedError, Sendable {
    public enum Category: String, Sendable {
        case crypto
        case credentials
        case security
        case connection
        case invalidRequest
    }

    case serviceError(category: Category, underlying: Error, message: String)
    case connectionError(message: String)
    case invalidRequest(message: String)
    case operationCanceled(reason: String)
    case timeout(operation: String)
    case securityValidationFailed(reason: String)
    case serviceUnavailable(name: String)

    /// Whether this error is potentially recoverable
    public var isRecoverable: Bool {
        switch self {
        case let .serviceError(category, _, _):
            switch category {
            case .connection:
                true
            default:
                false
            }
        case .connectionError, .timeout, .serviceUnavailable:
            true
        case .invalidRequest, .operationCanceled, .securityValidationFailed:
            false
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .serviceError(category, error, message):
            "[\(category.rawValue.capitalized)] \(message): \(error.localizedDescription)"
        case let .connectionError(message):
            "[Connection] \(message)"
        case let .invalidRequest(message):
            "[Invalid Request] \(message)"
        case let .operationCanceled(reason):
            "[Canceled] \(reason)"
        case let .timeout(operation):
            "[Timeout] Operation timed out: \(operation)"
        case let .securityValidationFailed(reason):
            "[Security] Validation failed: \(reason)"
        case let .serviceUnavailable(name):
            "[Service] \(name) is unavailable"
        }
    }

    public var localizedDescription: String {
        switch self {
        case let .serviceError(category, error, message):
            "[\(category.rawValue.capitalized)] \(message): \(error.localizedDescription)"
        case let .connectionError(message):
            "[Connection] \(message)"
        case let .invalidRequest(message):
            "[Invalid Request] \(message)"
        case let .operationCanceled(reason):
            "[Canceled] \(reason)"
        case let .timeout(operation):
            "[Timeout] Operation timed out: \(operation)"
        case let .securityValidationFailed(reason):
            "[Security] Validation failed: \(reason)"
        case let .serviceUnavailable(name):
            "[Service] \(name) is unavailable"
        }
    }
}
