import Foundation

/// A thread-safe pool for managing reusable resources
public actor ResourcePool<Resource: ManagedResource> {
    /// Configuration for the resource pool
    public struct Configuration {
        /// Maximum number of resources in the pool
        public let maxSize: Int
        /// Timeout for resource acquisition (in seconds)
        public let acquisitionTimeout: TimeInterval
        /// Whether to create resources lazily
        public let lazyInitialization: Bool
        
        public init(
            maxSize: Int = 10,
            acquisitionTimeout: TimeInterval = 30,
            lazyInitialization: Bool = true
        ) {
            self.maxSize = maxSize
            self.acquisitionTimeout = acquisitionTimeout
            self.lazyInitialization = lazyInitialization
        }
    }
    
    /// Available resources in the pool
    private var available: [Resource]
    
    /// Resources currently in use
    private var inUse: [Resource]
    
    /// Factory for creating new resources
    private let factory: () async throws -> Resource
    
    /// Pool configuration
    private let configuration: Configuration
    
    /// Create a new resource pool
    /// - Parameters:
    ///   - factory: Factory function for creating new resources
    ///   - configuration: Pool configuration
    public init(
        factory: @escaping () async throws -> Resource,
        configuration: Configuration = Configuration()
    ) {
        self.factory = factory
        self.configuration = configuration
        self.available = []
        self.inUse = []
    }
    
    /// Acquire a resource from the pool
    /// - Returns: An available resource
    /// - Throws: ResourceError if no resources are available
    public func acquire() async throws -> Resource {
        // First try to get an available resource
        if let resource = available.first {
            available.removeFirst()
            inUse.append(resource)
            return resource
        }
        
        // If we can create a new resource, do so
        if inUse.count < configuration.maxSize {
            let resource = try await factory()
            try await resource.acquire()
            inUse.append(resource)
            return resource
        }
        
        // Wait for a resource to become available
        let deadline = Date().addingTimeInterval(configuration.acquisitionTimeout)
        while Date() < deadline {
            if let resource = available.first {
                available.removeFirst()
                inUse.append(resource)
                return resource
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
        
        throw ResourceError.poolExhausted("No resources available after \(configuration.acquisitionTimeout) seconds")
    }
    
    /// Release a resource back to the pool
    /// - Parameter resource: Resource to release
    public func release(_ resource: Resource) async {
        if let index = inUse.firstIndex(where: { $0 === (resource as AnyObject) }) {
            inUse.remove(at: index)
            await resource.release()
            available.append(resource)
        }
    }
    
    /// Clean up all resources in the pool
    public func cleanup() async {
        // Clean up in-use resources
        for resource in inUse {
            await resource.cleanup()
        }
        inUse.removeAll()
        
        // Clean up available resources
        for resource in available {
            await resource.cleanup()
        }
        available.removeAll()
    }
    
    /// Get the current number of available resources
    public var availableCount: Int {
        available.count
    }
    
    /// Get the current number of in-use resources
    public var inUseCount: Int {
        inUse.count
    }
}
