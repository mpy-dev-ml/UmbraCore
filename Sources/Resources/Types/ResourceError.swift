import Foundation

/// Errors that can occur during resource operations
public enum ResourceError: LocalizedError, Sendable {
    /// Resource acquisition failed
    case acquisitionFailed(String)

    /// Resource is in an invalid state for the requested operation
    case invalidState(String)

    /// Resource pool is exhausted (no more resources available)
    case poolExhausted

    /// Resource not found in pool
    case resourceNotFound(String)

    /// Resource operation failed
    case operationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .acquisitionFailed(let message):
            return "Resource acquisition failed: \(message)"
        case .invalidState(let message):
            return "Resource in invalid state: \(message)"
        case .poolExhausted:
            return "Resource pool exhausted: no more resources available"
        case .resourceNotFound(let id):
            return "Resource not found: \(id)"
        case .operationFailed(let message):
            return "Resource operation failed: \(message)"
        }
    }
}
