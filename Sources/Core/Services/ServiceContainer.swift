import CoreServicesSecurityTypeAliases
import CoreServicesTypeAliases
import CoreServicesTypes
import CoreTypes
import Foundation
import ObjCBridgingTypes
import ObjCBridgingTypesFoundation

/// Thread-safe container for managing service instances and their dependencies.
public actor ServiceContainer {
  /// Shared instance of the service container
  public static let shared=ServiceContainer()

  /// XPC connection for inter-process communication
  public private(set) var xpcConnection: ObjCBridgingTypesFoundation
    .XPCServiceProtocolBaseFoundation?

  /// Registered services keyed by their identifiers.
  private var services: [String: any UmbraService]

  /// Tracks service dependencies to prevent circular references.
  private var dependencyGraph: [String: Set<String>]

  /// Tracks service states for lifecycle management.
  private var serviceStates: [String: ServiceState]

  /// Create a new service container.
  public init() {
    services=[:]
    dependencyGraph=[:]
    serviceStates=[:]
    xpcConnection=nil
  }

  /// Set the XPC connection
  /// - Parameter connection: The XPC connection to use
  public func setXPCConnection(
    _ connection: ObjCBridgingTypesFoundation
      .XPCServiceProtocolBaseFoundation
  ) {
    xpcConnection=connection
  }

  // MARK: - Service Registration

  /// Register a service with the container.
  /// - Parameters:
  ///   - service: The service to register.
  ///   - dependencies: Optional list of service identifiers this service depends on.
  /// - Throws: ServiceError if registration fails.
  public func register<T: UmbraService>(_ service: T, dependencies: [String]=[]) async throws {
    let identifier=T.serviceIdentifier

    guard services[identifier] == nil else {
      throw ServiceError.configurationError("Service \(identifier) is already registered")
    }

    try validateDependencies(identifier: identifier, dependencies: dependencies)

    // Register the service
    services[identifier]=service
    serviceStates[identifier] = .uninitialized
  }

  // MARK: - Service Resolution

  /// Resolve a service of the specified type.
  /// - Returns: The requested service instance.
  /// - Throws: ServiceError if service not found or unusable.
  public func resolve<T: UmbraService>(_: T.Type) async throws -> T {
    let identifier=T.serviceIdentifier

    guard let service=services[identifier] else {
      throw ServiceError.dependencyError("Service \(identifier) not found")
    }

    guard let typedService=service as? T else {
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
  public func initialiseAll(timeout: TimeInterval=30) async throws {
    let sortedServices=try sortServicesByDependency()
    try await initializeServices(sortedServices, timeout: timeout)
  }

  /// Shut down all services in reverse dependency order.
  public func shutdownAll() async {
    let sortedServices=(try? sortServicesByDependency().reversed()) ?? Array(services.keys)
    await shutdownServices(sortedServices)
  }

  // MARK: - Service State Management

  /// Get the current state of a service.
  /// - Parameter identifier: Service identifier.
  /// - Returns: Current service state.
  public func getServiceState(_ identifier: String) -> ServiceState? {
    serviceStates[identifier]
  }

  /// Check if all services are in a ready state.
  /// - Returns: true if all services are ready.
  public func areAllServicesReady() async -> Bool {
    for (identifier, service) in services {
      guard await service.isUsable() else {
        return false
      }
      guard serviceStates[identifier] == .ready || serviceStates[identifier] == .running else {
        return false
      }
    }
    return true
  }

  /// Reset services to uninitialized state.
  /// - Parameter preserveRegistration: If true, keeps services registered but uninitialised.
  public func reset(preserveRegistration: Bool=false) async {
    if preserveRegistration {
      // Reset states but keep registrations
      for identifier in services.keys {
        serviceStates[identifier] = .uninitialized
      }
    } else {
      // Clear everything
      services.removeAll()
      dependencyGraph.removeAll()
      serviceStates.removeAll()
    }
  }

  // MARK: - Private Helpers

  /// Validate service dependencies and update dependency graph.
  /// - Parameters:
  ///   - identifier: Service identifier.
  ///   - dependencies: List of dependencies to validate.
  /// - Throws: ServiceError if validation fails.
  private func validateDependencies(identifier: String, dependencies: [String]) throws {
    for dependency in dependencies {
      guard services[dependency] != nil else {
        throw ServiceError.dependencyError("Required dependency \(dependency) not found")
      }

      if dependencyGraph[identifier] == nil {
        dependencyGraph[identifier]=Set()
      }
      dependencyGraph[identifier]?.insert(dependency)

      if hasCircularDependency(from: identifier) {
        dependencyGraph[identifier]?.remove(dependency)
        throw ServiceError.dependencyError("Circular dependency detected for \(identifier)")
      }
    }
  }

  /// Initialize services in the specified order with timeout.
  /// - Parameters:
  ///   - services: Ordered list of service identifiers.
  ///   - timeout: Maximum time to wait for initialisation.
  /// - Throws: ServiceError if initialisation fails.
  private func initializeServices(_ services: [String], timeout: TimeInterval) async throws {
    try await withThrowingTaskGroup(of: Void.self) { [self] group in
      // Start the timeout task
      group.addTask {
        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        throw ServiceError.operationFailed("Operation timed out after \(timeout) seconds")
      }

      // Start service initialization tasks
      for identifier in services {
        guard let service=self.services[identifier] else { continue }

        group.addTask { [self] in
          await updateServiceState(identifier, to: .initializing)

          do {
            try await service.initialize()
            await updateServiceState(identifier, to: .ready)
          } catch {
            await updateServiceState(identifier, to: .error)
            let errorMessage=[
              "Failed to initialise \(identifier): ",
              error.localizedDescription
            ].joined()
            throw ServiceError.initialisationFailed(errorMessage)
          }
        }
      }

      // Wait for either timeout or completion
      try await group.next()
      group.cancelAll()
    }
  }

  /// Shutdown services in the specified order.
  /// - Parameter services: Ordered list of service identifiers.
  private func shutdownServices(_ services: [String]) async {
    await withTaskGroup(of: Void.self) { [self] group in
      for identifier in services {
        guard let service=self.services[identifier] else { continue }

        group.addTask { [self] in
          await updateServiceState(identifier, to: .shuttingDown)
          await service.shutdown()
          await updateServiceState(identifier, to: .shutdown)
        }
      }

      await group.waitForAll()
    }
  }

  /// Sort services by dependency order.
  /// - Returns: Ordered list of service identifiers.
  /// - Throws: ServiceError if circular dependency detected.
  private func sortServicesByDependency() throws -> [String] {
    var sorted: [String]=[]
    var visited: Set<String>=[]
    var temporary: Set<String>=[]

    func visit(_ identifier: String) throws {
      if temporary.contains(identifier) {
        throw ServiceError.dependencyError("Circular dependency detected")
      }

      if !visited.contains(identifier) {
        temporary.insert(identifier)

        if let dependencies=dependencyGraph[identifier] {
          for dependency in dependencies {
            try visit(dependency)
          }
        }

        visited.insert(identifier)
        temporary.remove(identifier)
        sorted.append(identifier)
      }
    }

    for identifier in services.keys {
      try visit(identifier)
    }

    return sorted
  }

  /// Check if a service has a circular dependency.
  /// - Parameter identifier: Service identifier.
  /// - Returns: true if circular dependency detected.
  private func hasCircularDependency(from identifier: String, visited: Set<String>=[]) -> Bool {
    guard let dependencies=dependencyGraph[identifier] else {
      return false
    }

    var visited=visited
    visited.insert(identifier)

    for dependency in dependencies {
      if visited.contains(dependency) {
        return true
      }
      if hasCircularDependency(from: dependency, visited: visited) {
        return true
      }
    }

    return false
  }

  /// Update the state of a service.
  /// - Parameters:
  ///   - identifier: Service identifier.
  ///   - state: New state.
  private func updateServiceState(_ identifier: String, to state: ServiceState) {
    serviceStates[identifier]=state
  }
}
