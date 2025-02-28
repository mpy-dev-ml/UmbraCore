import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesProtocols

/// Adapter that bridges from SecurityInterfacesProtocols.XPCServiceProtocolBase to XPCServiceProtocolCore
public final class CoreTypesToNoFoundationAdapter: XPCServiceProtocolCore {
    private let core: any SecurityInterfacesProtocols.XPCServiceProtocolBase

    /// Create a new adapter wrapping a CoreTypes implementation
    public init(wrapping core: any SecurityInterfacesProtocols.XPCServiceProtocolBase) {
        self.core = core
    }

    /// Protocol identifier from the CoreTypes implementation
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.core"
    }

    /// Ping the XPC service
    public func ping() async throws -> Bool {
        try await core.ping()
    }

    /// Synchronise keys with the XPC service
    public func synchroniseKeys(_ syncData: [UInt8]) async throws {
        // Convert to BinaryData first
        let binaryData = SecurityInterfacesProtocols.BinaryData(syncData)
        try await core.synchroniseKeys(binaryData)
    }

    /// Get the current key from the XPC service
    public func getCurrentKey() async throws -> [UInt8] {
        // This method isn't available in the base protocol, so we'll provide a default implementation
        return []
    }

    /// Get the security provider from the XPC service
    public func getSecurityProvider() async throws -> String {
        // This method isn't available in the base protocol, so we'll provide a default implementation
        return "default.security.provider"
    }
}

/// Adapter that bridges from XPCServiceProtocolCore to SecurityInterfacesProtocols.XPCServiceProtocolBase
public final class NoFoundationToCoreTypesAdapter: SecurityInterfacesProtocols.XPCServiceProtocolBase {
    private let foundation: any XPCServiceProtocolCore

    /// Create a new adapter wrapping a Foundation implementation
    public init(wrapping foundation: any XPCServiceProtocolCore) {
        self.foundation = foundation
    }

    /// Protocol identifier from the Foundation implementation
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.base"
    }

    /// Ping the XPC service
    public func ping() async throws -> Bool {
        try await foundation.ping()
    }

    /// Synchronise keys with the XPC service
    public func synchroniseKeys(_ syncData: SecurityInterfacesProtocols.BinaryData) async throws {
        try await foundation.synchroniseKeys(syncData.bytes)
    }
}
