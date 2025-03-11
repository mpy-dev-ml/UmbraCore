import CoreErrors
import CoreServicesSecurityTypeAliases
import CoreServicesTypeAliases
import CoreServicesTypes
import KeyManagementTypes
import CoreTypesInterfaces
import Foundation
import ObjCBridgingTypesFoundation
import UmbraCoreTypes
import XPCProtocolsCore

/**
 # Core Service Container

 The service container manages all services in the CoreServices module. It provides
 a central registry for registering, initialising, and resolving services, as well
 as managing dependencies between services.

 Services can be registered with dependencies on other services, and the container
 ensures that dependencies are initialised before dependent services. It also provides
 mechanisms for initialising all registered services, shutting them down, and monitoring
 their states.
 */
public actor ServiceContainer {
  /// Shared instance of the service container
  public static let shared=ServiceContainer()

  /// XPC service for inter-process communication
  public private(set) var xpcService: (any XPCServiceProtocol)?

  /// Registered services keyed by their identifiers.
  private var services: [String: any UmbraService]

  /// Map of service identifiers to their dependencies
  private var dependencyGraph: [String: Set<String>]

  /// Map of service identifiers to their states
  private var serviceStates: [String: CoreServicesTypes.ServiceState]

  /// Initialise a new service container
  public init() {
    services=[:]
    dependencyGraph=[:]
    serviceStates=[:]
    xpcService=nil
  }

  /// Set the XPC service for inter-process communication
  /// - Parameter service: The XPC service to use
  public func setXPCService(_ service: any XPCServiceProtocol) {
    xpcService=service
  }

  /// Register a service with the container
  /// - Parameters:
  ///   - service: Service to register
  ///   - dependencies: Optional array of service identifiers that this service depends on
  /// - Throws: ServiceError if registration fails.
  public func register<T: UmbraService>(_ service: T, dependencies: [String]=[]) async throws {
    let identifier=T.serviceIdentifier

    guard services[identifier] == nil else {
      throw ServiceError
        .configurationError("Service with identifier \(identifier) already registered")
    }

    // Store the service and its dependencies
    services[identifier]=service
    dependencyGraph[identifier]=Set(dependencies)

    // Set initial state
    updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.uninitialized)
  }

  /// Resolve a service by type
  /// - Returns: The requested service instance.
  /// - Throws: ServiceError if service not found or unusable.
  public func resolve<T: UmbraService>(_: T.Type) async throws -> T {
    let identifier=T.serviceIdentifier

    guard let service=services[identifier] else {
      throw ServiceError.initialisationFailed("Service \(identifier) not found")
    }

    guard let typedService=service as? T else {
      throw ServiceError.invalidState("Service \(identifier) is not of the requested type")
    }

    guard await service.isUsable() else {
      throw ServiceError.invalidState("Service \(identifier) is not in a usable state")
    }

    return typedService
  }

  /// Resolve a service by identifier
  /// - Parameter identifier: Unique identifier of the service
  /// - Returns: The requested service
  /// - Throws: ServiceError if service not found or unusable
  public func resolveById(_ identifier: String) async throws -> any UmbraService {
    guard let service=services[identifier] else {
      throw ServiceError.initialisationFailed("Service \(identifier) not found")
    }

    guard await service.isUsable() else {
      throw ServiceError.invalidState("Service \(identifier) is not in a usable state")
    }

    return service
  }

  /// Initialise all registered services in dependency order
  /// - Throws: ServiceError if initialisation fails
  public func initialiseAll() async throws {
    // Get services in initialization order
    let serviceIds=try sortServicesByDependency()

    // Initialise services in order
    for serviceId in serviceIds {
      guard let service=services[serviceId] else { continue }
      guard await service.state == CoreServicesTypes.ServiceState.uninitialized else { continue }

      let initializer: () async throws -> Void={ [weak self] in
        do {
          await self?.updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.initializing)
          try await service.initialize()
          await self?.updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.ready)
        } catch {
          await self?.updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.error)
          throw ServiceError
            .initialisationFailed(
              "Failed to initialize \(serviceId): \(error.localizedDescription)"
            )
        }
      }

      try await initializer()
    }
  }

  /// Initialise a specific service and its dependencies
  /// - Parameter identifier: Unique identifier of the service to initialise
  /// - Throws: ServiceError if initialisation fails
  public func initialiseService(_ identifier: String) async throws {
    guard let service=services[identifier] else {
      throw ServiceError.initialisationFailed("Service \(identifier) not found")
    }

    // Don't initialise if already initialised
    guard await service.state == CoreServicesTypes.ServiceState.uninitialized else {
      return
    }

    // Initialise dependencies first
    let deps=dependencyGraph[identifier] ?? []
    for depId in deps {
      try await initialiseService(depId)
    }

    // Initialise the service
    await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.initializing)
    do {
      try await service.initialize()
      await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.ready)
    } catch {
      await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.error)
      throw ServiceError
        .initialisationFailed("Failed to initialize \(identifier): \(error.localizedDescription)")
    }
  }

  /// Shut down all services in reverse dependency order
  public func shutdownAll() async {
    // Get services in reverse dependency order
    let serviceIds=(try? sortServicesByDependency().reversed()) ?? Array(services.keys)

    // Shut down services in reverse order
    for serviceId in serviceIds {
      guard let service=services[serviceId] else { continue }

      updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.shuttingDown)
      await service.shutdown()
      updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.shutdown)
    }
  }

  /// Sort services by their dependencies
  /// - Returns: Array of service identifiers in dependency order
  /// - Throws: ServiceError if circular dependency detected
  private func sortServicesByDependency() throws -> [String] {
    var visited=Set<String>()
    var visiting=Set<String>()
    var sorted: [String]=[]

    for serviceId in services.keys {
      try visit(serviceId, visited: &visited, visiting: &visiting, sorted: &sorted)
    }

    return sorted
  }

  /// Visit service and its dependencies in topological order
  /// - Parameters:
  ///   - serviceId: Current service identifier
  ///   - visited: Set of already visited services
  ///   - visiting: Set of services being visited in current recursion
  ///   - sorted: Output array with topological order
  /// - Throws: ServiceError if circular dependency detected
  private func visit(
    _ serviceId: String,
    visited: inout Set<String>,
    visiting: inout Set<String>,
    sorted: inout [String]
  ) throws {
    if visited.contains(serviceId) {
      return
    }

    if visiting.contains(serviceId) {
      throw ServiceError
        .dependencyError("Circular dependency detected involving service \(serviceId)")
    }

    visiting.insert(serviceId)

    let deps=dependencyGraph[serviceId] ?? []
    for depId in deps {
      if !services.keys.contains(depId) {
        throw ServiceError
          .dependencyError("Service \(serviceId) depends on \(depId) which is not registered")
      }
      try visit(depId, visited: &visited, visiting: &visiting, sorted: &sorted)
    }

    visiting.remove(serviceId)
    visited.insert(serviceId)
    sorted.append(serviceId)
  }

  /// Update the state of a service
  /// - Parameters:
  ///   - serviceId: Identifier of the service to update.
  ///   - newState: New state to set.
  private func updateServiceState(_ serviceId: String, newState: CoreServicesTypes.ServiceState) {
    serviceStates[serviceId]=newState
  }
}
