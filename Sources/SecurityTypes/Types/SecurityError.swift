/// Errors that can occur during security operations
public enum SecurityError: Error {
    /// Failed to create a security-scoped bookmark
    case bookmarkCreationFailed(path: String, description: String)
    
    /// Failed to resolve a security-scoped bookmark
    case bookmarkResolutionFailed(description: String)
    
    /// Access to a security-scoped resource was denied
    case accessDenied(path: String)
}

extension SecurityError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .bookmarkCreationFailed(let path, let description):
            return "Failed to create bookmark for \(path): \(description)"
        case .bookmarkResolutionFailed(let description):
            return "Failed to resolve bookmark: \(description)"
        case .accessDenied(let path):
            return "Access denied to \(path)"
        }
    }
}
