import Foundation

/// Represents the current state of a service
@frozen public enum ServiceState: String, Sendable {
    /// Service has not been initialised
    case uninitialized
    /// Service is in the process of initialising
    case initializing
    /// Service is ready for use
    case ready
    /// Service has encountered an error
    case error
    /// Service is in the process of shutting down
    case shuttingDown
    /// Service has been shut down
    case shutdown
}

/// Protocol defining the base requirements for all UmbraCore services
public protocol UmbraService: Actor {
    /// Unique identifier for the service type
    static var serviceIdentifier: String { get }
    
    /// Current state of the service
    var state: ServiceState { get async }
    
    /// Initialise the service
    /// - Throws: ServiceError if initialisation fails
    func initialize() async throws
    
    /// Gracefully shut down the service
    func shutdown() async
    
    /// Check if the service is in a usable state
    /// - Returns: true if the service can be used
    func isUsable() async -> Bool
}

/// Extension providing default implementations for UmbraService
extension UmbraService {
    public func isUsable() async -> Bool {
        await state == .ready
    }
}

/// Errors that can occur during service operations
public enum ServiceError: LocalizedError, Sendable {
    /// Service initialisation failed
    case initialisationFailed(String)
    /// Service is in an invalid state for the requested operation
    case invalidState(String)
    /// Service operation failed
    case operationFailed(String)
    /// Service dependency is missing or invalid
    case dependencyError(String)
    /// Service configuration is invalid
    case configurationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .initialisationFailed(let reason):
            return "Service initialisation failed: \(reason)"
        case .invalidState(let reason):
            return "Invalid service state: \(reason)"
        case .operationFailed(let reason):
            return "Service operation failed: \(reason)"
        case .dependencyError(let reason):
            return "Service dependency error: \(reason)"
        case .configurationError(let reason):
            return "Service configuration error: \(reason)"
        }
    }
}

/// Protocol for services that require cleanup of resources
public protocol CleanupCapable {
    /// Clean up any resources used by the service
    /// - Parameter force: If true, forcefully clean up resources even if in use
    func cleanup(force: Bool) async throws
}

/// Protocol for services that can be reset to their initial state
public protocol Resettable {
    /// Reset the service to its initial state
    /// - Parameter preserveConfig: If true, preserve configuration during reset
    func reset(preserveConfig: Bool) async throws
}

/// Protocol for services that support health checks
public protocol HealthCheckable {
    /// Perform a health check on the service
    /// - Returns: true if the service is healthy
    func checkHealth() async throws -> Bool
    
    /// Get detailed health status information
    /// - Returns: Dictionary containing health status details
    func getHealthStatus() async -> [String: Any]
}
