import Foundation
@preconcurrency import ObjCBridgingTypesFoundation
import SecurityBridge
@preconcurrency import SecurityInterfacesXPC
import SecurityProtocolsCore
import SecureBytes

/// Adapter that bridges from SecurityInterfaces.XPCServiceProtocol to ObjCBridgingTypesFoundation.XPCServiceProtocolDefinitionBaseFoundation
@objc public final class SecurityToFoundationAdapter: NSObject, SecurityInterfacesXPC.XPCServiceProtocolDefinition {
    private let service: any XPCServiceProtocolCore
    
    /// Create a new adapter wrapping a SecurityInterfaces implementation
    public init(wrapping service: any XPCServiceProtocolCore) {
        self.service = service
        super.init()
    }
    
    /// Protocol identifier from the wrapped service
    @objc public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.security"
    }
    
    /// Ping the service
    @objc public func ping(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Capture service in a local variable to avoid capturing self
        let serviceRef = service
        
        // Use Task.detached to avoid capturing self
        Task.detached { @Sendable in
            // First store the callback on the main actor
            let callback = await MainActor.run {
                return CallbackStore.store(reply)
            }
            
            // Call the service's ping method
            let result = await serviceRef.ping()
            
            // Process the result back on the main actor
            await MainActor.run {
                switch result {
                case .success(let isReachable):
                    CallbackStore.callPingCallback(id: callback, result: isReachable, error: nil)
                case .failure(let error):
                    CallbackStore.callPingCallback(id: callback, result: false, error: error)
                }
            }
        }
    }
    
    /// Synchronize keys
    @objc public func synchroniseKeys(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Convert NSData to bytes before passing to Task to avoid capturing non-Sendable types
        let bytes = ObjCBridgingTypesFoundation.DataConverter.convertToBytes(fromNSData: data)
        
        // Capture service in a local variable to avoid capturing self
        let serviceRef = service
        
        // Use Task.detached to avoid capturing self
        Task.detached { @Sendable in
            // Create SecureBytes from bytes
            let binaryData = SecureBytes(bytes)
            
            // First store the callback on the main actor
            let callback = await MainActor.run {
                return CallbackStore.store(reply)
            }
            
            // Call the service's synchronizeKeys method
            let result = await serviceRef.synchronizeKeys(binaryData)
            
            // Process the result back on the main actor
            await MainActor.run {
                switch result {
                case .success:
                    CallbackStore.callErrorCallback(id: callback, error: nil)
                case .failure(let error):
                    CallbackStore.callErrorCallback(id: callback, error: error)
                }
            }
        }
    }
    
    /// Reset security data
    @objc public func resetSecurityData(withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have resetSecurityData, just return success
        reply(nil)
    }
    
    // MARK: - XPCServiceProtocolDefinition Implementation
    
    /// Get the XPC service version
    @objc public func getVersion(withReply reply: @escaping @Sendable (NSString?, Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have getVersion, return a default version
        reply("1.0.0" as NSString, nil)
    }
    
    /// Get the host identifier
    @objc public func getHostIdentifier(withReply reply: @escaping @Sendable (NSString?, Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have getHostIdentifier, return a default host ID
        reply("host-id" as NSString, nil)
    }
    
    /// Register a client application
    @objc public func registerClient(clientId: NSString, withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have registerClient, return success
        reply(true, nil)
    }
    
    /// Deregister a client application
    @objc public func deregisterClient(clientId: NSString, withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have deregisterClient, return success
        reply(true, nil)
    }
    
    /// Check if a client is registered
    @objc public func isClientRegistered(clientId: NSString, withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have isClientRegistered, return true
        reply(true, nil)
    }
}

/// Adapter that bridges from SecurityInterfacesXPC.XPCServiceProtocolDefinition to SecurityInterfaces.XPCServiceProtocol
public final class FoundationToSecurityAdapter: XPCServiceProtocolCore {
    // Use a class to wrap the non-Sendable protocol
    private final class FoundationWrapper: Sendable {
        let foundation: any SecurityInterfacesXPC.XPCServiceProtocolDefinition
        
        init(foundation: any SecurityInterfacesXPC.XPCServiceProtocolDefinition) {
            self.foundation = foundation
        }
    }
    
    private let foundationWrapper: FoundationWrapper
    
    /// Create a new adapter wrapping a Foundation implementation
    public init(wrapping foundation: any SecurityInterfacesXPC.XPCServiceProtocolDefinition) {
        self.foundationWrapper = FoundationWrapper(foundation: foundation)
    }
    
    // MARK: - XPCServiceProtocolBase Implementation
    
    /// Protocol identifier - required for XPCServiceProtocolBase conformance
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.foundation"
    }
    
    /// Test connectivity
    public func ping() async throws -> Result<Bool, Error> {
        return try await withCheckedThrowingContinuation { continuation in
            foundationWrapper.foundation.ping { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: .success(result))
                }
            }
        }
    }
    
    /// Synchronize keys across processes
    public func synchronizeKeys(_ data: SecureBytes) async throws -> Result<Void, Error> {
        // Convert BinaryData to NSData
        let nsData = ObjCBridgingTypesFoundation.DataConverter.convertToNSData(fromBytes: data.unsafeBytes)
        
        return try await withCheckedThrowingContinuation { continuation in
            foundationWrapper.foundation.synchroniseKeys(nsData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: .success(()))
                }
            }
        }
    }
    
    // MARK: - XPCServiceProtocol Implementation
    
    /// Encrypt data using the service
    public func encrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // This is just a placeholder implementation
        // In a real implementation, you would implement actual encryption
        return .success(data)
    }
    
    /// Decrypt data using the service
    public func decrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        // This is just a placeholder implementation
        // In a real implementation, you would implement actual decryption
        return .success(data)
    }
}

/// Helper class to safely store and call callbacks from async contexts
@MainActor final class CallbackStore {
    private static var pingCallbacks: [UUID: (Bool, Error?) -> Void] = [:]
    private static var errorCallbacks: [UUID: (Error?) -> Void] = [:]
    
    /// Store a ping callback and return its ID
    static func store(_ callback: @escaping (Bool, Error?) -> Void) -> UUID {
        let id = UUID()
        pingCallbacks[id] = callback
        return id
    }
    
    /// Store an error callback and return its ID
    static func store(_ callback: @escaping (Error?) -> Void) -> UUID {
        let id = UUID()
        errorCallbacks[id] = callback
        return id
    }
    
    /// Call a ping callback by its ID
    static func callPingCallback(id: UUID, result: Bool, error: Error?) {
        if let callback = pingCallbacks.removeValue(forKey: id) {
            callback(result, error)
        }
    }
    
    /// Call an error callback by its ID
    static func callErrorCallback(id: UUID, error: Error?) {
        if let callback = errorCallbacks.removeValue(forKey: id) {
            callback(error)
        }
    }
}
