import Foundation

/// Protocol for XPC service that executes Restic commands
@objc
public protocol ResticXPCServiceProtocol: NSObject, HealthCheckable {
    /// Ping the service to check availability
    @objc
    func ping() async -> Bool

    /// Initialize a new repository
    @objc
    func initializeRepository(
        at url: URL,
        username: String,
        password: String
    ) async throws

    /// Create a backup
    @objc
    func backup(
        from source: URL,
        to destination: URL,
        username: String,
        password: String
    ) async throws

    /// List snapshots in repository
    @objc
    func listSnapshots(
        username: String,
        password: String
    ) async throws -> [String]

    /// Restore from backup
    @objc
    func restore(
        from source: URL,
        to destination: URL,
        username: String,
        password: String
    ) async throws
}
