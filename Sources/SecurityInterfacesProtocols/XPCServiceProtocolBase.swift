/// Binary data representation without Foundation dependencies
public struct BinaryData: Sendable {
    /// Raw byte array
    public let bytes: [UInt8]

    /// Create a new BinaryData instance from a byte array
    public init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }

    /// Create an empty BinaryData instance
    public init() {
        self.bytes = []
    }
}

/// Custom error for security interfaces that doesn't require Foundation
public enum SecurityProtocolError: Error, Sendable {
    case implementationMissing(String)
}

/// Protocol defining the base XPC service interface without Foundation dependencies
public protocol XPCServiceProtocolBase: Sendable {
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String { get }

    /// Test connectivity
    func ping() async throws -> Bool

    /// Synchronize keys across processes
    /// - Parameter syncData: The key data to synchronize
    func synchroniseKeys(_ syncData: BinaryData) async throws
}

/// Default implementation for XPCServiceProtocolBase
public extension XPCServiceProtocolBase {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.base"
    }
}
