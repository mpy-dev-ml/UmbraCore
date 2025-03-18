import CoreErrors
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
public extension UmbraService {
    func isUsable() async -> Bool {
        state == CoreServicesTypes.ServiceState.ready || state == CoreServicesTypes.ServiceState.running
    }
}

/// Errors that can occur during service operations
/// @deprecated This will be replaced by CoreErrors.ServiceError in a future version.
/// New code should use CoreErrors.ServiceError directly.
@available(
    *,
    deprecated,
    message: "This will be replaced by CoreErrors.ServiceError in a future version. Use CoreErrors.ServiceError directly."
)
public typealias ServiceError = CoreErrors.ServiceError

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

// Extension to add more details to CoreErrors.ServiceError
extension CoreErrors.ServiceError {
    /// Add a detailed message to the error
    /// - Parameter message: The detailed error message
    /// - Returns: A corresponding CoreErrors.ServiceError with the message
    public static func withMessage(_ message: String) -> CoreErrors.ServiceError {
        switch self {
        case .initialisationFailed:
            // We can't modify the enum case, but we can provide guidance on how to handle the message
            print("Service initialisation failed: \(message)")
            return .initialisationFailed
        case .invalidState:
            print("Invalid service state: \(message)")
            return .invalidState
        case .configurationError:
            print("Service configuration error: \(message)")
            return .configurationError
        case .dependencyError:
            print("Service dependency error: \(message)")
            return .dependencyError
        case .operationFailed:
            print("Operation failed: \(message)")
            return .operationFailed
        }
    }
}
