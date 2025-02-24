import Foundation

/// Represents the current state of a managed resource
public enum ResourceState: String, Sendable {
    /// Resource is not yet initialised
    case uninitialized
    /// Resource is being initialised
    case initializing
    /// Resource is ready for use
    case ready
    /// Resource is in use
    case inUse
    /// Resource encountered an error
    case error
    /// Resource is being released
    case releasing
    /// Resource has been released
    case released
}

/// Protocol for managed resources that require lifecycle management
public protocol ManagedResource: Actor, Sendable {
    /// Resource type identifier
    static var resourceType: String { get }
    
    /// Current state of the resource
    nonisolated var state: ResourceState { get }
    
    /// Acquire the resource for use
    /// - Throws: ResourceError if acquisition fails
    func acquire() async throws
    
    /// Release the resource back to the pool
    func release() async
    
    /// Clean up any allocated resources
    func cleanup() async
}

/// Errors that can occur during resource operations
public enum ResourceError: LocalizedError, Sendable {
    /// Resource acquisition failed
    case acquisitionFailed(String)
    /// Resource is in an invalid state
    case invalidState(String)
    /// Resource operation timed out
    case timeout(String)
    /// Resource pool is exhausted
    case poolExhausted(String)
    /// Resource cleanup failed
    case cleanupFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .acquisitionFailed(let reason):
            return "Resource acquisition failed: \(reason)"
        case .invalidState(let reason):
            return "Resource is in an invalid state: \(reason)"
        case .timeout(let reason):
            return "Resource operation timed out: \(reason)"
        case .poolExhausted(let reason):
            return "Resource pool is exhausted: \(reason)"
        case .cleanupFailed(let reason):
            return "Resource cleanup failed: \(reason)"
        }
    }
}
