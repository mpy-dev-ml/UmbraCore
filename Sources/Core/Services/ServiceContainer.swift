import CoreErrors
import CoreServicesSecurityTypeAliases
import CoreServicesTypeAliases
import CoreServicesTypes
import CoreTypesInterfaces
import Foundation
import KeyManagementTypes
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
    public static let shared = ServiceContainer()

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

    /// Register a service with the container
    /// - Parameters:
    ///   - service: Service to register
    ///   - dependencies: Optional array of service identifiers that this service depends on
    /// - Throws: ServiceError if registration fails.
    public func register<T: UmbraService>(_ service: T, dependencies: [String] = []) async throws {
        let identifier = T.serviceIdentifier

        guard services[identifier] == nil else {
            throw CoreErrors.ServiceError.configurationError
        }

        // Store the service and its dependencies
        services[identifier] = service
        dependencyGraph[identifier] = Set(dependencies)

        // Set initial state
        await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.uninitialized)
    }

    /// Resolve a service by type
    /// - Returns: The requested service instance.
    /// - Throws: ServiceError if service not found or unusable.
    public func resolve<T: UmbraService>(_: T.Type) async throws -> T {
        let identifier = T.serviceIdentifier

        guard let service = services[identifier] else {
            throw CoreErrors.ServiceError.initialisationFailed
        }

        guard let typedService = service as? T else {
            throw CoreErrors.ServiceError.invalidState
        }

        guard await service.isUsable() else {
            throw CoreErrors.ServiceError.invalidState
        }

        return typedService
    }

    /// Resolve a service by identifier
    /// - Parameter identifier: Unique identifier of the service
    /// - Returns: The requested service
    /// - Throws: ServiceError if service not found or unusable
    public func resolveById(_ identifier: String) async throws -> any UmbraService {
        guard let service = services[identifier] else {
            throw CoreErrors.ServiceError.initialisationFailed
        }

        guard await service.isUsable() else {
            throw CoreErrors.ServiceError.invalidState
        }

        return service
    }

    /// Initialise all registered services.
    /// - Throws: ServiceError if any service fails to initialise.
    public func initialiseAllServices() async throws {
        let serviceIds = try topologicalSort()

        // Initialise services in order
        for serviceId in serviceIds {
            guard let service = services[serviceId] else { continue }
            guard service.state == CoreServicesTypes.ServiceState.uninitialized else { continue }

            let initializer: () async throws -> Void = { [weak self] in
                do {
                    await self?.updateServiceState(
                        serviceId,
                        newState: CoreServicesTypes.ServiceState.initializing
                    )
                    try await service.initialize()
                    await self?.updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.ready)
                } catch {
                    await self?.updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.error)
                    throw CoreErrors.ServiceError.initialisationFailed
                }
            }

            try await initializer()
        }
    }

    /// Initialise a specific service by identifier
    /// - Parameter identifier: Service identifier
    /// - Throws: ServiceError if initialisation fails
    public func initialiseService(_ identifier: String) async throws {
        guard let service = services[identifier] else {
            throw CoreErrors.ServiceError.initialisationFailed
        }

        // Don't initialise if already initialised
        guard service.state == CoreServicesTypes.ServiceState.uninitialized else {
            return
        }

        // Initialise dependencies first
        for depId in dependencyGraph[identifier] ?? [] {
            try await initialiseService(depId)
        }

        // Initialise the service
        await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.initializing)
        do {
            try await service.initialize()
            await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.ready)
        } catch {
            await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.error)
            throw CoreErrors.ServiceError.initialisationFailed
        }
    }

    /// Shut down all registered services
    public func shutdownAllServices() async {
        // Shut down in reverse topological order (dependencies last)
        let serviceIds = (try? topologicalSort().reversed()) ?? Array(services.keys)

        for serviceId in serviceIds {
            guard let service = services[serviceId] else { continue }

            await updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.shuttingDown)
            await service.shutdown()
            await updateServiceState(serviceId, newState: CoreServicesTypes.ServiceState.shutdown)
        }
    }

    /// Shut down a specific service by identifier
    /// - Parameter identifier: Service identifier
    public func shutdownService(_ identifier: String) async {
        guard let service = services[identifier] else { return }

        // Shut down service
        await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.shuttingDown)
        await service.shutdown()
        await updateServiceState(identifier, newState: CoreServicesTypes.ServiceState.shutdown)
    }

    /// Update the state of a service and notify any observers
    /// - Parameters:
    ///   - identifier: Service identifier
    ///   - newState: New service state
    public func updateServiceState(_ identifier: String, newState: CoreServicesTypes.ServiceState) async {
        guard services[identifier] != nil else { return }

        // Update the state
        serviceStates[identifier] = newState

        // Notify XPC service if available
        if let xpcService = xpcService {
            await xpcService.notifyServiceStateChanged(identifier: identifier, state: newState)
        }
    }

    // MARK: - Private Methods

    /// Sort services in topological order (dependencies first)
    /// - Returns: Array of service identifiers in dependency order
    /// - Throws: ServiceError if circular dependency detected
    private func topologicalSort() throws -> [String] {
        var visited = Set<String>()
        var visiting = Set<String>()
        var sorted = [String]()

        // Visit each service node in the dependency graph
        for serviceId in services.keys {
            if !visited.contains(serviceId) {
                try visit(serviceId, visited: &visited, visiting: &visiting, sorted: &sorted)
            }
        }

        return sorted
    }

    /// Visit a node in the dependency graph for topological sorting
    /// - Parameters:
    ///   - serviceId: Service identifier to visit
    ///   - visited: Set of visited nodes
    ///   - visiting: Set of nodes currently being visited (to detect cycles)
    ///   - sorted: Array of sorted nodes
    /// - Throws: ServiceError if circular dependency detected
    private func visit(
        _ serviceId: String,
        visited: inout Set<String>,
        visiting: inout Set<String>,
        sorted: inout [String]
    ) throws {
        // Skip if already visited
        if visited.contains(serviceId) {
            return
        }

        if visiting.contains(serviceId) {
            throw CoreErrors.ServiceError.dependencyError
        }

        visiting.insert(serviceId)

        let deps = dependencyGraph[serviceId] ?? []
        for depId in deps {
            if !services.keys.contains(depId) {
                throw CoreErrors.ServiceError.dependencyError
            }
            try visit(depId, visited: &visited, visiting: &visiting, sorted: &sorted)
        }

        visiting.remove(serviceId)
        visited.insert(serviceId)
        sorted.append(serviceId)
    }
}
