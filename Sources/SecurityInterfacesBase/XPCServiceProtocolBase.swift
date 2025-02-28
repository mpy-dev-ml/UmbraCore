import SecurityInterfacesProtocols

/// Re-export the protocol from SecurityInterfacesProtocols
public typealias XPCServiceProtocolBase = SecurityInterfacesProtocols.XPCServiceProtocolBase

/// Re-export BinaryData from SecurityInterfacesProtocols
public typealias BinaryData = SecurityInterfacesProtocols.BinaryData

/// Custom error for security interfaces that doesn't require Foundation
public enum XPCServiceProtocolBaseError: Error, Sendable {
    case implementationMissing(String)
}

/// Extension for XPCServiceProtocolBase to provide security-specific functionality
extension SecurityInterfacesProtocols.XPCServiceProtocolBase {
    /// Implementation for synchronising keys with byte array
    func synchroniseKeys(_ syncData: [UInt8]) async throws {
        // Convert bytes to BinaryData
        let binaryData = SecurityInterfacesProtocols.BinaryData(syncData)
        return try await synchroniseKeys(binaryData)
    }

    /// Default implementation of protocol identifier
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.base"
    }

    /// Default implementation of ping
    public func ping() async throws -> Bool {
        return true
    }
}
