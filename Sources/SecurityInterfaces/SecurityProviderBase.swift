import SecurityInterfacesBase

/// Base protocol defining core security operations that don't require Foundation
public protocol SecurityProviderBase {
    /// Reset all security data
    func resetSecurityData() async throws

    /// Get the host identifier
    func getHostIdentifier() async throws -> String

    /// Register a client application
    /// - Parameter bundleIdentifier: The bundle identifier of the client application
    func registerClient(bundleIdentifier: String) async throws -> Bool

    /// Request key rotation
    /// - Parameter keyId: The ID of the key to rotate
    func requestKeyRotation(keyId: String) async throws

    /// Notify about a potentially compromised key
    /// - Parameter keyId: The ID of the compromised key
    func notifyKeyCompromise(keyId: String) async throws
}
