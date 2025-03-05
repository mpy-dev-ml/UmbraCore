import CoreErrors
import CoreServicesSecurityTypeAliases
import CoreServicesTypeAliases
import CoreServicesTypes
import CoreTypes
import Foundation
import ObjCBridgingTypes
import UmbraCoreTypes
import XPCProtocolsCore

/// Thread-safe container for managing service instances and their dependencies.
public actor ServiceContainer {
  /// Shared instance of the service container
  public static let shared = ServiceContainer()

  /// XPC service for inter-process communication
  public private(set) var xpcService: (any XPCServiceProtocol)?

  /// Registered services keyed by their identifiers.
  private var services: [String: any UmbraService]

  /// Tracks service dependencies to prevent circular references.
  private var dependencyGraph: [String: Set<String>]

  /// Tracks service states for lifecycle management.
  private var serviceStates: [String: ServiceState]

  /// Create a new service container.
  public init() {
    services = [:]
    dependencyGraph = [:]
    serviceStates = [:]
    xpcService = nil
  }

  /// Set the XPC service for inter-process communication
  /// - Parameter service: The XPC service to use
  public func setXPCService(_ service: any XPCServiceProtocol) {
    xpcService = service
  }

  // MARK: - Service Registration

  /// Register a service with the container.
  /// - Parameters:
  ///   - service: The service to register.
  ///   - dependencies: Optional list of service identifiers this service depends on.
  /// - Throws: ServiceError if registration fails.
  public func register<T: UmbraService>(_ service: T, dependencies: [String] = []) async throws {
    let identifier = T.serviceIdentifier

    guard services[identifier] == nil else {
      throw ServiceError.configurationError("Service \(identifier) is already registered")
    }

    try validateDependencies(identifier: identifier, dependencies: dependencies)

    // Register the service
    services[identifier] = service
    serviceStates[identifier] = .uninitialized
  }

  // MARK: - Service Resolution

  /// Resolve a service of the specified type.
  /// - Returns: The requested service instance.
  /// - Throws: ServiceError if service not found or unusable.
  public func resolve<T: UmbraService>(_: T.Type) async throws -> T {
    let identifier = T.serviceIdentifier

    guard let service = services[identifier] else {
      throw ServiceError.dependencyError("Service \(identifier) not found")
    }

    guard let typedService = service as? T else {
      throw ServiceError.dependencyError("Service \(identifier) is of incorrect type")
    }

    guard await typedService.isUsable() else {
      throw ServiceError.invalidState("Service \(identifier) is not in a usable state")
    }

    return typedService
  }

  // MARK: - Service Lifecycle

  /// Initialise all registered services in dependency order.
  /// - Parameter timeout: Maximum time to wait for initialisation (in seconds).
  /// - Throws: ServiceError if initialisation fails.
  public func initialiseAll(timeout: TimeInterval = 30) async throws {
    let sortedServices = try sortServicesByDependency()
    try await initializeServices(sortedServices, timeout: timeout)
  }

  /// Shut down all services in reverse dependency order.
  public func shutdownAll() async {
    let sortedServices = (try? sortServicesByDependency().reversed()) ?? Array(services.keys)
    await shutdownServices(sortedServices)
  }

  // MARK: - Private Helper Methods

  /// Initialize services in the specified order.
  /// - Parameters:
  ///   - serviceIds: Ordered list of service identifiers to initialize.
  ///   - timeout: Maximum time to wait for each service initialization.
  /// - Throws: ServiceError if initialization fails.
  private func initializeServices(_ serviceIds: [String], timeout: TimeInterval) async throws {
    for serviceId in serviceIds {
      guard let service = services[serviceId] else { continue }
      guard await service.state == .uninitialized else { continue }

      let initializer: () async throws -> Void = { [weak self] in
        guard let self else { return }
        await updateServiceState(serviceId, newState: .initializing)
        try await service.initialize()
        await updateServiceState(serviceId, newState: .ready)
      }

      do {
        try await withTimeout(timeout) {
          try await initializer()
        }
      } catch {
        await updateServiceState(serviceId, newState: .failed)
        throw ServiceError
          .initializationError("Failed to initialize \(serviceId): \(error.localizedDescription)")
      }
    }
  }

  /// Shut down services in the specified order.
  /// - Parameter serviceIds: Ordered list of service identifiers to shut down.
  private func shutdownServices(_ serviceIds: [String]) async {
    for serviceId in serviceIds {
      guard
        let service = services[serviceId],
        await service.state == .ready
      else { continue }

      await updateServiceState(serviceId, newState: .shuttingDown)
      await service.shutdown()
      await updateServiceState(serviceId, newState: .uninitialized)
    }
  }

  /// Update the state of a service.
  /// - Parameters:
  ///   - serviceId: Identifier of the service to update.
  ///   - newState: New state to set.
  private func updateServiceState(_ serviceId: String, newState: ServiceState) {
    serviceStates[serviceId] = newState
  }

  /// Sort services by dependency order.
  /// - Returns: List of service identifiers in dependency order.
  /// - Throws: ServiceError if circular dependencies are detected.
  private func sortServicesByDependency() throws -> [String] {
    var visited: Set<String> = []
    var sorted: [String] = []
    var temp: Set<String> = []

    func visit(_ id: String) throws {
      if temp.contains(id) {
        throw ServiceError.circularDependency("Circular dependency detected involving \(id)")
      }

      if !visited.contains(id) {
        temp.insert(id)
        for dep in dependencyGraph[id] ?? [] {
          try visit(dep)
        }
        temp.remove(id)
        visited.insert(id)
        sorted.append(id)
      }
    }

    for id in services.keys {
      if !visited.contains(id) {
        try visit(id)
      }
    }

    return sorted
  }

  /// Validate dependencies of a service.
  /// - Parameters:
  ///   - identifier: Identifier of the service being registered.
  ///   - dependencies: List of service identifiers this service depends on.
  /// - Throws: ServiceError if dependencies are invalid.
  private func validateDependencies(identifier: String, dependencies: [String]) throws {
    for dependency in dependencies {
      guard services[dependency] != nil else {
        throw ServiceError.dependencyError("Required dependency \(dependency) not found")
      }
    }

    dependencyGraph[identifier] = Set(dependencies)

    // Verify no circular dependencies
    _ = try sortServicesByDependency()
  }

  /// Execute an operation with a timeout.
  /// - Parameters:
  ///   - seconds: Timeout in seconds.
  ///   - operation: Operation to execute.
  /// - Throws: ServiceError if the operation times out.
  private func withTimeout<T>(
    _ seconds: TimeInterval,
    operation: @escaping () async throws -> T
  ) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      Task {
        let task = Task {
          do {
            let result = try await operation()
            continuation.resume(returning: result)
          } catch {
            continuation.resume(throwing: error)
          }
        }

        Task {
          try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
          task.cancel()
          continuation
            .resume(throwing: ServiceError.timeout("Operation timed out after \(seconds) seconds"))
        }
      }
    }
  }
}

/// Error types for service operations
public enum ServiceError: Error, Sendable {
  /// Error due to invalid configuration
  case configurationError(String)
  /// Error due to dependency issues
  case dependencyError(String)
  /// Error during service initialization
  case initializationError(String)
  /// Error due to invalid service state
  case invalidState(String)
  /// Error due to circular dependency
  case circularDependency(String)
  /// Error due to operation timeout
  case timeout(String)
}

/// Protocol for services that can be registered with the container
public protocol UmbraService: AnyObject, Sendable {
  /// Unique identifier for the service type
  static var serviceIdentifier: String { get }
  /// Current state of the service
  var state: ServiceState { get }
  /// Initialize the service
  func initialize() async throws
  /// Shut down the service
  func shutdown() async
  /// Check if the service is in a usable state
  func isUsable() async -> Bool
}

/// Default implementations for UmbraService
extension UmbraService {
  /// Default implementation to check if service is usable
  public func isUsable() async -> Bool {
    state == .ready
  }
}
