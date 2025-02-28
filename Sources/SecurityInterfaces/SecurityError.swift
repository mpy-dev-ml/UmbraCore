import SecurityInterfacesBase

/// Errors that can occur during security operations
public enum SecurityInterfacesError: Error, Sendable {
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
    /// Wrapped SecurityInterfacesBase.SecurityError
    case wrapped(SecurityInterfacesBase.SecurityError)

    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let path):
            return "Failed to create security bookmark for path: \(path)"
        case .bookmarkResolutionFailed:
            return "Failed to resolve security bookmark"
        case .bookmarkStale(let path):
            return "Security bookmark is stale for path: \(path)"
        case .bookmarkNotFound(let path):
            return "Security bookmark not found for path: \(path)"
        case .resourceAccessFailed(let path):
            return "Failed to access security-scoped resource: \(path)"
        case .randomGenerationFailed:
            return "Failed to generate random data"
        case .hashingFailed:
            return "Failed to perform hashing operation"
        case .itemNotFound:
            return "Security item not found"
        case .operationFailed(let message):
            return "Security operation failed: \(message)"
        case .bookmarkError(let message):
            return "Security bookmark error: \(message)"
        case .accessError(let message):
            return "Security access error: \(message)"
        case .wrapped(let error):
            return "Wrapped security error: \(error.localizedDescription)"
        }
    }

    public init(from baseError: SecurityInterfacesBase.SecurityError) {
        self = .wrapped(baseError)
    }

    public func toBaseError() -> SecurityInterfacesBase.SecurityError? {
        switch self {
        case .wrapped(let baseError):
            return baseError
        default:
            return nil
        }
    }
}

// Add LocalizedError conformance in a separate extension
// This allows us to maintain compatibility without importing Foundation directly
extension SecurityInterfacesError {
    public var localizedDescription: String {
        return errorDescription ?? "Unknown security error"
    }
}

// For backward compatibility
public typealias SecurityError = SecurityInterfacesError
