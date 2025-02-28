import CoreTypes

/// Protocol defining the base XPC service interface with completion handlers - minimal version without Foundation dependencies
public protocol XPCServiceProtocolDefinitionBase {
    /// Base method to test connectivity
    func ping(completion: @escaping (Bool, Error?) -> Void)

    /// Reset all security data
    func resetSecurityData(completion: @escaping (Error?) -> Void)
}
