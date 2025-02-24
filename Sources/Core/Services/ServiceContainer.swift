import Foundation

/// Thread-safe container for managing service instances and their dependencies
public actor ServiceContainer {
    /// Registered services keyed by their identifiers
    private var services: [String: any UmbraService]
    
    /// Service initialisation queue
    private let initializationQueue: OperationQueue
    
    /// Tracks service dependencies to prevent circular references
    private var dependencyGraph: [String: Set<String>]
    
    /// Create a new service container
    public init() {
        self.services = [:]
        self.dependencyGraph = [:]
        self.initializationQueue = OperationQueue()
        self.initializationQueue.name = "com.umbracore.service-container"
        self.initializationQueue.maxConcurrentOperationCount = 1
    }
    
    /// Register a service with the container
    /// - Parameters:
    ///   - service: The service to register
    ///   - dependencies: Optional list of service identifiers this service depends on
    /// - Throws: ServiceError if registration fails
    public func register<T: UmbraService>(_ service: T, dependencies: [String] = []) async throws {
        let identifier = T.serviceIdentifier
        
        // Check for existing service
        guard services[identifier] == nil else {
            throw ServiceError.configurationError("Service \(identifier) is already registered")
        }
        
        // Validate dependencies
        for dependency in dependencies {
            guard services[dependency] != nil else {
                throw ServiceError.dependencyError("Required dependency \(dependency) not found")
            }
            
            // Update dependency graph
            if dependencyGraph[identifier] == nil {
                dependencyGraph[identifier] = Set()
            }
            dependencyGraph[identifier]?.insert(dependency)
            
            // Check for circular dependencies
            if hasCircularDependency(from: identifier) {
                dependencyGraph[identifier]?.remove(dependency)
                throw ServiceError.dependencyError("Circular dependency detected for \(identifier)")
            }
        }
        
        // Register the service
        services[identifier] = service
    }
    
    /// Resolve a service of the specified type
    /// - Returns: The requested service instance
    /// - Throws: ServiceError if service not found or unusable
    public func resolve<T: UmbraService>(_ type: T.Type) async throws -> T {
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
    
    /// Initialise all registered services in dependency order
    /// - Throws: ServiceError if initialisation fails
    public func initialiseAll() async throws {
        let sortedServices = try sortServicesByDependency()
        
        for identifier in sortedServices {
            guard let service = services[identifier] else { continue }
            
            do {
                try await service.initialize()
            } catch {
                throw ServiceError.initialisationFailed("Failed to initialise \(identifier): \(error.localizedDescription)")
            }
        }
    }
    
    /// Shut down all services in reverse dependency order
    public func shutdownAll() async {
        let sortedServices = (try? sortServicesByDependency().reversed()) ?? Array(services.keys)
        
        for identifier in sortedServices {
            guard let service = services[identifier] else { continue }
            await service.shutdown()
        }
    }
    
    /// Remove all registered services
    public func removeAll() {
        services.removeAll()
        dependencyGraph.removeAll()
    }
    
    // MARK: - Private Methods
    
    /// Check if adding a dependency would create a circular reference
    private func hasCircularDependency(from identifier: String, visited: Set<String> = []) -> Bool {
        guard let dependencies = dependencyGraph[identifier] else { return false }
        
        var visited = visited
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
    
    /// Sort services by dependency order
    private func sortServicesByDependency() throws -> [String] {
        var sorted: [String] = []
        var visited: Set<String> = []
        var temporary: Set<String> = []
        
        func visit(_ identifier: String) throws {
            if visited.contains(identifier) { return }
            if temporary.contains(identifier) {
                throw ServiceError.dependencyError("Circular dependency detected")
            }
            
            temporary.insert(identifier)
            
            if let dependencies = dependencyGraph[identifier] {
                for dependency in dependencies {
                    try visit(dependency)
                }
            }
            
            temporary.remove(identifier)
            visited.insert(identifier)
            sorted.append(identifier)
        }
        
        for identifier in services.keys {
            try visit(identifier)
        }
        
        return sorted
    }
}
