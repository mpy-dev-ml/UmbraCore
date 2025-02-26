import CoreTypes
import Foundation

/// Errors that can occur during security operations
public enum SecurityError: LocalizedError, Sendable {
    /// Bookmark creation failed
    case bookmarkCreationFailed(path: String)
    /// Bookmark resolution failed
    case bookmarkResolutionFailed
    /// Bookmark is stale and needs to be recreated
    case bookmarkStale(path: String)
    /// Bookmark not found
    case bookmarkNotFound(path: String)
    /// Security-scoped resource access failed
    case resourceAccessFailed(path: String)
    /// Random data generation failed
    case randomGenerationFailed
    /// Hashing operation failed
    case hashingFailed
    /// Credential or secure item not found
    case itemNotFound
    /// General security operation failed
    case operationFailed(String)
    /// Custom bookmark error with message
    case bookmarkError(String)
    /// Custom access error with message
    case accessError(String)
    /// Wrapped CoreTypes.SecurityErrorBase
    case wrapped(CoreTypes.SecurityErrorBase)

    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let path):
            return "Failed to create bookmark for \(path)"
        case .bookmarkResolutionFailed:
            return "Failed to resolve bookmark"
        case .bookmarkStale(let path):
            return "Bookmark for \(path) is stale and needs to be recreated"
        case .bookmarkNotFound(let path):
            return "Bookmark not found for \(path)"
        case .resourceAccessFailed(let path):
            return "Failed to access security-scoped resource at \(path)"
        case .randomGenerationFailed:
            return "Failed to generate random data"
        case .hashingFailed:
            return "Failed to hash data"
        case .itemNotFound:
            return "Credential or secure item not found"
        case .operationFailed(let message):
            return "Security operation failed: \(message)"
        case .bookmarkError(let message):
            return "Bookmark error: \(message)"
        case .accessError(let message):
            return "Access error: \(message)"
        case .wrapped(let baseError):
            switch baseError {
            case .accessDenied(let reason):
                return "Access denied: \(reason)"
            case .itemNotFound:
                return "Item not found"
            case .bookmarkError(let message):
                return "Bookmark error: \(message)"
            case .randomGenerationFailed:
                return "Random generation failed"
            case .generalError(let message):
                return "General security error: \(message)"
            }
        }
    }

    public init(from baseError: CoreTypes.SecurityErrorBase) {
        self = .wrapped(baseError)
    }

    public func toBaseError() -> CoreTypes.SecurityErrorBase? {
        switch self {
        case .wrapped(let baseError):
            return baseError
        default:
            return nil
        }
    }
}
