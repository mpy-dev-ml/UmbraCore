// Base protocol for XPC services without Foundation dependencies
// This protocol defines the basic requirements without using Foundation types

/// Protocol defining the base XPC service interface without Foundation dependencies
public protocol XPCServiceProtocolBase: Sendable {
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String { get }

    /// Base method to test connectivity
    func ping() async throws -> Bool

    /// Synchronize keys across processes
    /// - Parameter data: The key data to synchronize (can be any kind of data)
    func synchroniseKeys(_ data: Any) async throws
}

/// Protocol extension with default implementation
public extension XPCServiceProtocolBase {
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.base"
    }
}
