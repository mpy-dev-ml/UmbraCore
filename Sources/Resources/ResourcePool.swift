import Foundation
import ResourcesProtocols
import ResourcesTypes

/// A thread-safe pool for managing reusable resources.
///
/// `ResourcePool` provides a way to maintain and reuse a fixed number of resources,
/// ensuring thread-safe access through the actor model. It handles resource
/// lifecycle management including acquisition, release, and cleanup.
///
/// Example:
/// ```swift
/// let pool = ResourcePool<DatabaseConnection>(maxSize: 5)
/// 
/// // Add resources to the pool
/// try await pool.add(DatabaseConnection())
/// 
/// // Acquire and use a resource
/// let connection = try await pool.acquire()
/// defer { Task { await pool.release(connection) } }
/// 
/// // Use connection...
/// ```
public actor ResourcePool<Resource: BasicManagedResource> {
    /// Available resources in the pool.
    ///
    /// This array contains all resources managed by the pool, whether they
    /// are currently in use or available. The state of each resource
    /// determines its availability.
    private var resources: [Resource]

    /// Maximum number of resources allowed in the pool.
    ///
    /// This limit helps prevent resource exhaustion by maintaining
    /// a fixed upper bound on the number of resources that can
    /// be created.
    private let maxSize: Int

    /// Creates a new resource pool with a maximum size.
    ///
    /// - Parameter maxSize: Maximum number of resources allowed in the pool.
    ///                     This limit cannot be changed after initialisation.
    /// - Precondition: maxSize > 0
    public init(maxSize: Int) {
        precondition(maxSize > 0, "Pool size must be greater than zero")
        self.maxSize = maxSize
        self.resources = []
    }

    /// Adds a resource to the pool.
    ///
    /// The resource is initialised and tested before being added to ensure
    /// it is in a valid state. If the resource cannot be initialised or
    /// the pool is full, an error is thrown.
    ///
    /// - Parameter resource: Resource to add to the pool.
    /// - Throws: `ResourcesTypes.ResourceError.poolExhausted` if the pool is at capacity,
    ///          or any error thrown by the resource during acquisition.
    public func add(_ resource: Resource) async throws {
        guard resources.count < maxSize else {
            throw ResourcesTypes.ResourceError.poolExhausted
        }

        // Test the resource by acquiring and releasing it
        try await resource.acquire()
        try await resource.release()
        resources.append(resource)
    }

    /// Acquires an available resource from the pool.
    ///
    /// This method attempts to find and return a resource in the `ready`
    /// state. If no resources are available, it throws an error.
    ///
    /// - Returns: An available resource from the pool.
    /// - Throws: `ResourcesTypes.ResourceError.acquisitionFailed` if no resources are available,
    ///          or if the resource cannot be acquired.
    public func acquire() async throws -> Resource {
        guard let index = resources.firstIndex(where: { $0.state == .ready }) else {
            throw ResourcesTypes.ResourceError.acquisitionFailed(
                "No available resources (pool size: \(resources.count), max: \(maxSize))"
            )
        }

        let resource = resources[index]
        try await resource.acquire()
        return resource
    }

    /// Releases a resource back to the pool.
    ///
    /// - Parameter resource: The resource to release.
    public func release(_ resource: Resource) async {
        if let index = resources.firstIndex(where: { $0.id == resource.id }) {
            let resource = resources[index]
            do {
                try await resource.release()
            } catch {
                // Log the error but continue
                print("Error releasing resource \(resource.id): \(error)")
            }
        }
    }

    /// Cleans up all resources in the pool.
    ///
    /// This method should be called when the pool is no longer needed.
    /// It attempts to clean up all resources, ignoring errors.
    public func cleanup() async {
        for resource in resources {
            do {
                try await resource.cleanup()
            } catch {
                // Log the error but continue
                print("Error cleaning up resource \(resource.id): \(error)")
            }
        }
        resources.removeAll()
    }
}
