/// Binary data representation without Foundation dependencies
/// @deprecated Use SecureBytes from UmbraCoreTypes instead
@available(*, deprecated, message: "Use SecureBytes from UmbraCoreTypes instead")
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
/// @deprecated Use SecurityProtocolError from XPCProtocolsCore instead
@available(*, deprecated, message: "Use SecurityProtocolError from XPCProtocolsCore instead")
public enum SecurityProtocolError: Error, Sendable {
    case implementationMissing(String)
}

/// Protocol defining the base XPC service interface without Foundation dependencies
/// 
/// @deprecated As part of the UmbraCore XPC Protocol Consolidation, this protocol
/// is being superseded by XPCServiceProtocolBasic in the XPCProtocolsCore module.
/// Please migrate to the new protocol hierarchy. See XPC_PROTOCOLS_MIGRATION_GUIDE.md
/// in the XPCProtocolsCore module for migration instructions.
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
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
@available(*, deprecated, message: "Use XPCServiceProtocolBasic from XPCProtocolsCore instead")
public extension XPCServiceProtocolBase {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.base"
    }
}
