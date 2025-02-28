import SecurityInterfacesProtocols

/// Base errors that can occur during security operations
/// This is a Foundation-free version of SecurityError
public enum SecurityError: Error, Sendable {
    /// Bookmark operation failed
    case bookmarkFailed(String)
    /// Resource access failed
    case accessFailed(String)
    /// Random data generation failed
    case randomGenerationFailed
    /// Hashing operation failed
    case hashingFailed
    /// Item not found
    case itemNotFound
    /// General operation failed
    case operationFailed(String)
    /// Wrapped protocol error
    case wrapped(SecurityProtocolError)

    /// Get a description of the error
    public var localizedDescription: String {
        switch self {
        case .bookmarkFailed(let message):
            return "Bookmark operation failed: \(message)"
        case .accessFailed(let message):
            return "Resource access failed: \(message)"
        case .randomGenerationFailed:
            return "Failed to generate random data"
        case .hashingFailed:
            return "Failed to perform hashing operation"
        case .itemNotFound:
            return "Security item not found"
        case .operationFailed(let message):
            return "Security operation failed: \(message)"
        case .wrapped(let error):
            switch error {
            case .implementationMissing(let name):
                return "Implementation missing: \(name)"
            }
        }
    }

    /// Initialize from a protocol error
    public init(from protocolError: SecurityProtocolError) {
        self = .wrapped(protocolError)
    }

    /// Convert to a protocol error if possible
    public func toProtocolError() -> SecurityProtocolError? {
        switch self {
        case .wrapped(let protocolError):
            return protocolError
        default:
            return nil
        }
    }
}
