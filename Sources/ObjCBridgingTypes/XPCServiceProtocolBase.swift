import CoreTypes

/// Base protocol for XPC service communication - minimal version without Foundation dependencies
public protocol XPCServiceProtocolBase {
    /// Base method to test connectivity
    func ping(completion: @escaping (Bool, Error?) -> Void)

    /// Reset all security data
    func resetSecurityData(completion: @escaping (Error?) -> Void)
}

/// Extension providing shared functionality for XPC service protocols
public extension XPCServiceProtocolBase {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.xpc.service.protocol.base"
    }
}
