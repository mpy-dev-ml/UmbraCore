import CoreTypes
import FoundationBridgeTypes

/// Custom error for security interfaces that doesn't require Foundation
public enum XPCServiceProtocolCoreAdapterError: Error, Sendable {
    case implementationMissing(String)
}

/// Core protocol for XPC service without Foundation dependencies
public protocol XPCServiceProtocolCore: Sendable {
    /// Protocol identifier for the XPC service
    static var protocolIdentifier: String { get }

    /// Ping the XPC service
    /// - Returns: Whether the ping was successful
    func ping() async throws -> Bool

    /// Synchronise keys with the XPC service
    /// - Parameter syncData: Data to synchronise
    func synchroniseKeys(_ syncData: [UInt8]) async throws

    /// Get the current key from the XPC service
    /// - Returns: Current key
    func getCurrentKey() async throws -> [UInt8]

    /// Get the security provider from the XPC service
    /// - Returns: Security provider identifier
    func getSecurityProvider() async throws -> String
}

/// Core protocol for XPC client without Foundation dependencies
public protocol XPCClientProtocolCore: Sendable {
    /// Protocol identifier for the XPC client
    static var protocolIdentifier: String { get }

    /// Connect to the XPC service
    /// - Returns: Whether the connection was successful
    func connect() async throws -> Bool

    /// Disconnect from the XPC service
    func disconnect() async

    /// Get the security provider from the XPC client
    /// - Returns: Security provider identifier
    func getSecurityProvider() async throws -> String
}
