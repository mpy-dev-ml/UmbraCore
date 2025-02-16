/// Represents errors that can occur during security operations
public enum SecurityError: Error {
    // MARK: - Bookmark Errors
    
    /// Failed to create a security-scoped bookmark
    case bookmarkCreationFailed(path: String, description: String)
    
    /// Failed to resolve a security-scoped bookmark
    case bookmarkResolutionFailed(description: String)
    
    /// Bookmark data is invalid or corrupted
    case invalidBookmarkData(identifier: String?)
    
    /// Bookmark has become stale and needs to be recreated
    case staleBookmark(path: String)
    
    // MARK: - Access Control Errors
    
    /// Access to a security-scoped resource was denied
    case accessDenied(path: String)
    
    /// Failed to start accessing a security-scoped resource
    case accessStartFailed(path: String, reason: String)
    
    /// Resource is already being accessed
    case resourceAlreadyAccessed(path: String)
    
    /// Maximum number of concurrent resource accesses exceeded
    case tooManyResourceAccesses(current: Int, maximum: Int)
    
    // MARK: - Persistence Errors
    
    /// Failed to save bookmark to persistent storage
    case bookmarkSaveFailed(identifier: String, reason: String)
    
    /// Failed to load bookmark from persistent storage
    case bookmarkLoadFailed(identifier: String, reason: String)
    
    /// Failed to delete bookmark from persistent storage
    case bookmarkDeleteFailed(identifier: String, reason: String)
    
    /// Bookmark with specified identifier not found
    case bookmarkNotFound(identifier: String)
    
    // MARK: - State Errors
    
    /// Operation attempted on an invalid path
    case invalidPath(path: String, reason: String)
    
    /// Security provider is in an invalid state
    case invalidProviderState(reason: String)
    
    /// Operation timeout
    case operationTimeout(operation: String, seconds: Int)
    
    // MARK: - System Errors
    
    /// System-level security error occurred
    case systemError(code: Int, description: String)
    
    /// Required security entitlement is missing
    case missingEntitlement(name: String)
    
    /// Security framework API error
    case securityFrameworkError(status: Int, description: String)
}

// MARK: - Error Description

extension SecurityError {
    public var errorDescription: String? {
        switch self {
        // Bookmark Errors
        case .bookmarkCreationFailed(let path, let description):
            return "Failed to create bookmark for '\(path)': \(description)"
        case .bookmarkResolutionFailed(let description):
            return "Failed to resolve bookmark: \(description)"
        case .invalidBookmarkData(let identifier):
            return "Invalid bookmark data\(identifier.map { " for '\($0)'" } ?? "")"
        case .staleBookmark(let path):
            return "Bookmark for '\(path)' has become stale and needs to be recreated"
            
        // Access Control Errors
        case .accessDenied(let path):
            return "Access denied to '\(path)'"
        case .accessStartFailed(let path, let reason):
            return "Failed to start accessing '\(path)': \(reason)"
        case .resourceAlreadyAccessed(let path):
            return "Resource '\(path)' is already being accessed"
        case .tooManyResourceAccesses(let current, let maximum):
            return "Too many concurrent resource accesses (current: \(current), maximum: \(maximum))"
            
        // Persistence Errors
        case .bookmarkSaveFailed(let identifier, let reason):
            return "Failed to save bookmark '\(identifier)': \(reason)"
        case .bookmarkLoadFailed(let identifier, let reason):
            return "Failed to load bookmark '\(identifier)': \(reason)"
        case .bookmarkDeleteFailed(let identifier, let reason):
            return "Failed to delete bookmark '\(identifier)': \(reason)"
        case .bookmarkNotFound(let identifier):
            return "Bookmark '\(identifier)' not found"
            
        // State Errors
        case .invalidPath(let path, let reason):
            return "Invalid path '\(path)': \(reason)"
        case .invalidProviderState(let reason):
            return "Security provider is in an invalid state: \(reason)"
        case .operationTimeout(let operation, let seconds):
            return "Operation '\(operation)' timed out after \(seconds)s"
            
        // System Errors
        case .systemError(let code, let description):
            return "System security error (\(code)): \(description)"
        case .missingEntitlement(let name):
            return "Missing required security entitlement: \(name)"
        case .securityFrameworkError(let status, let description):
            return "Security framework error (\(status)): \(description)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .staleBookmark:
            return "The security-scoped bookmark is no longer valid"
        case .invalidBookmarkData:
            return "The bookmark data is corrupted or in an invalid format"
        case .accessDenied:
            return "The application does not have permission to access this resource"
        case .tooManyResourceAccesses:
            return "The maximum number of concurrent resource accesses has been exceeded"
        case .missingEntitlement:
            return "The application lacks the required security entitlement"
        default:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .staleBookmark:
            return "Request the user to reselect the resource to create a new bookmark"
        case .invalidBookmarkData:
            return "Delete the invalid bookmark and create a new one"
        case .accessDenied:
            return "Request permission from the user to access this resource"
        case .tooManyResourceAccesses:
            return "Stop accessing some resources before attempting to access new ones"
        case .missingEntitlement:
            return "Add the required entitlement to your app's entitlements file"
        default:
            return nil
        }
    }
}

// MARK: - Error Classification

extension SecurityError {
    /// Indicates whether the error is potentially recoverable
    public var isRecoverable: Bool {
        switch self {
        case .staleBookmark,
             .invalidBookmarkData,
             .accessDenied,
             .tooManyResourceAccesses,
             .operationTimeout:
            return true
        default:
            return false
        }
    }
    
    /// Indicates whether the error requires user intervention to resolve
    public var requiresUserIntervention: Bool {
        switch self {
        case .staleBookmark,
             .accessDenied,
             .missingEntitlement:
            return true
        default:
            return false
        }
    }
    
    /// Indicates whether the error should be reported to the developer
    public var shouldReportToDeveloper: Bool {
        switch self {
        case .systemError,
             .securityFrameworkError,
             .missingEntitlement,
             .invalidProviderState:
            return true
        default:
            return false
        }
    }
}
