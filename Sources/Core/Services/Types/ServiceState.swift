import Foundation

/// Represents the current state of a service
@frozen
public enum ServiceState: String, Sendable, Codable {
    /// Service is not yet initialized
    case uninitialized
    /// Service is initializing
    case initializing
    /// Service is running normally
    case running
    /// Service is ready for use
    case ready
    /// Service is shutting down
    case shuttingDown
    /// Service has encountered an error
    case error
    /// Service has been suspended
    case suspended
    /// Service has been shut down
    case shutdown
}

/// Legacy service state enum for backward compatibility
@available(*, deprecated, message: "Use ServiceState directly")
public enum LegacyServiceState: Int, Sendable {
    /// Service has not been initialized yet
    case uninitialized = 0
    
    /// Service is in the process of initializing
    case initializing = 1
    
    /// Service is ready for use
    case ready = 2
    
    /// Service is in the process of shutting down
    case shuttingDown = 3
    
    /// Service has been shut down and is no longer available
    case shutdown = 4
    
    /// Service has encountered an error and is in an undefined state
    case error = 5
}

/// Extension for LegacyServiceState to convert to standard service state
@available(*, deprecated, message: "Use ServiceState directly")
public extension LegacyServiceState {
    /// Convert to standard service state
    var standardServiceState: ServiceState {
        switch self {
        case .uninitialized: return .uninitialized
        case .initializing: return .initializing
        case .ready: return .ready
        case .shuttingDown: return .shuttingDown
        case .shutdown: return .shutdown
        case .error: return .error
        }
    }
}
