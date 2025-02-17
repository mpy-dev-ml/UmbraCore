import Foundation

/// Errors that can occur during XPC operations
@frozen public enum XPCError: LocalizedError, Sendable {
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
    case operationCancelled(reason: String)
    case timeout(operation: String)
    case securityValidationFailed(reason: String)
    case serviceUnavailable(name: String)

    /// Whether this error is potentially recoverable
    public var isRecoverable: Bool {
        switch self {
        case .serviceError(let category, _, _):
            switch category {
            case .connection:
                return true
            default:
                return false
            }
        case .connectionError, .timeout, .serviceUnavailable:
            return true
        case .invalidRequest, .operationCancelled, .securityValidationFailed:
            return false
        }
    }

    public var errorDescription: String? {
        switch self {
        case .serviceError(let category, let error, let message):
            return "[\(category.rawValue.capitalized)] \(message): \(error.localizedDescription)"
        case .connectionError(let message):
            return "[Connection] \(message)"
        case .invalidRequest(let message):
            return "[Invalid Request] \(message)"
        case .operationCancelled(let reason):
            return "[Cancelled] \(reason)"
        case .timeout(let operation):
            return "[Timeout] Operation timed out: \(operation)"
        case .securityValidationFailed(let reason):
            return "[Security] Validation failed: \(reason)"
        case .serviceUnavailable(let name):
            return "[Service] \(name) is unavailable"
        }
    }

    public var localizedDescription: String {
        switch self {
        case .serviceError(let category, let error, let message):
            return "[\(category.rawValue.capitalized)] \(message): \(error.localizedDescription)"
        case .connectionError(let message):
            return "[Connection] \(message)"
        case .invalidRequest(let message):
            return "[Invalid Request] \(message)"
        case .operationCancelled(let reason):
            return "[Cancelled] \(reason)"
        case .timeout(let operation):
            return "[Timeout] Operation timed out: \(operation)"
        case .securityValidationFailed(let reason):
            return "[Security] Validation failed: \(reason)"
        case .serviceUnavailable(let name):
            return "[Service] \(name) is unavailable"
        }
    }
}
