import CoreTypes
import Foundation

/// Protocol defining the XPC service interface for key management
@objc public protocol XPCServiceProtocol: NSObjectProtocol, Sendable {
    /// Base method to test connectivity
    @objc func ping() async throws -> Bool

    /// Synchronize keys across processes with Data
    /// - Parameter data: The key data to synchronize
    @objc func synchroniseKeys(_ data: Data) async throws

    /// Reset all security data
    @objc func resetSecurityData() async throws

    /// Get the XPC service version
    @objc func getVersion() async throws -> String

    /// Get the host identifier
    @objc func getHostIdentifier() async throws -> String

    /// Register a client application
    /// - Parameter bundleIdentifier: The bundle identifier of the client application
    @objc func registerClient(bundleIdentifier: String) async throws -> Bool

    /// Request key rotation
    /// - Parameter keyId: The ID of the key to rotate
    @objc func requestKeyRotation(keyId: String) async throws

    /// Notify about a potentially compromised key
    /// - Parameter keyId: The ID of the compromised key
    @objc func notifyKeyCompromise(keyId: String) async throws
}

/// Extension to bridge the two protocol worlds
public extension XPCServiceProtocol {
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol"
    }
}
