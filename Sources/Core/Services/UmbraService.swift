import CoreServicesTypes
import Foundation

/// Protocol defining the base requirements for all UmbraCore services
public protocol UmbraService: Actor {
    /// Unique identifier for the service type
    static var serviceIdentifier: String { get }

    /// Current state of the service
    nonisolated var state: CoreServicesTypes.ServiceState { get }

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
        state == .ready || state == .running
    }
}

/// Errors that can occur during service operations
public enum ServiceError: LocalizedError, Sendable {
    /// Service initialisation failed
    case initialisationFailed(String)
    /// Service is in an invalid state for the requested operation
    case invalidState(String)
    /// Service configuration error
    case configurationError(String)
    /// Service dependency error
    case dependencyError(String)
    /// Operation failed
    case operationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .initialisationFailed(let message):
            return "Service initialisation failed: \(message)"
        case .invalidState(let message):
            return "Invalid service state: \(message)"
        case .configurationError(let message):
            return "Service configuration error: \(message)"
        case .dependencyError(let message):
            return "Service dependency error: \(message)"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
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
