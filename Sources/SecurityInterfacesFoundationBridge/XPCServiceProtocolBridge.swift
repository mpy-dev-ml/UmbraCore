import Foundation
@preconcurrency import ObjCBridgingTypesFoundation
import SecurityInterfacesProtocols

/// Custom error for security interfaces that doesn't require SecurityInterfaces
public enum SecurityBridgeError: Error, Sendable {
    case implementationMissing(String)
}

/// Bridge protocol to break circular dependencies between Foundation and SecurityInterfaces
@objc public protocol XPCServiceProtocolFoundationBridge: NSObjectProtocol {
    /// Protocol identifier
    @objc static var protocolIdentifier: String { get }
    
    /// Test connectivity with Foundation types
    @objc func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void)
    
    /// Synchronize keys across processes with Foundation types
    @objc func synchroniseKeysFoundation(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void)
    
    /// Encrypt data using the service with Foundation types
    @objc func encryptFoundation(data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void)
    
    /// Decrypt data using the service with Foundation types
    @objc func decryptFoundation(data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void)
}

/// Adapter that bridges from SecurityInterfacesProtocols.XPCServiceProtocolBase to Foundation
@objc public final class CoreTypesToFoundationBridgeAdapter: NSObject, XPCServiceProtocolFoundationBridge, @unchecked Sendable {
    private let core: any SecurityInterfacesProtocols.XPCServiceProtocolBase
    private let queue = DispatchQueue(label: "com.umbra.security.bridge", qos: .userInitiated)
    
    /// Create a new adapter wrapping a CoreTypes implementation
    public init(wrapping core: any SecurityInterfacesProtocols.XPCServiceProtocolBase) {
        self.core = core
        super.init()
    }
    
    /// Protocol identifier from the CoreTypes implementation
    @objc public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.coretypes.bridge"
    }
    
    /// Implement ping using the CoreTypes implementation
    @objc public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Capture the core reference and queue to avoid capturing self
        let coreRef = self.core
        let queue = self.queue
        
        Task.detached { @Sendable in
            do {
                let result = try await coreRef.ping()
                queue.async { reply(result, nil) }
            } catch {
                queue.async { reply(false, error) }
            }
        }
    }
    
    /// Implement synchroniseKeys using the CoreTypes implementation
    @objc public func synchroniseKeysFoundation(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Convert NSData to bytes first to avoid capturing it in the task
        let bytes = ObjCBridgingTypesFoundation.DataConverter.convertToBytes(fromNSData: data)
        
        // Capture the core reference and queue to avoid capturing self
        let coreRef = self.core
        let queue = self.queue
        
        Task.detached { @Sendable in
            do {
                // Convert bytes to BinaryData
                let binaryData = SecurityInterfacesProtocols.BinaryData(bytes)
                // Call the CoreTypes implementation
                try await coreRef.synchroniseKeys(binaryData)
                queue.async { reply(nil) }
            } catch {
                queue.async { reply(error) }
            }
        }
    }
    
    /// Implement encrypt using the CoreTypes implementation
    @objc public func encryptFoundation(data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // This is a placeholder implementation
        reply(data, nil)
    }
    
    /// Implement decrypt using the CoreTypes implementation
    @objc public func decryptFoundation(data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // This is a placeholder implementation
        reply(data, nil)
    }
}

/// Adapter that bridges from Foundation to SecurityInterfacesProtocols.XPCServiceProtocolBase
public final class FoundationToCoreTypesBridgeAdapter: SecurityInterfacesProtocols.XPCServiceProtocolBase {
    private class FoundationWrapper: @unchecked Sendable {
        let foundation: any XPCServiceProtocolFoundationBridge
        
        init(foundation: any XPCServiceProtocolFoundationBridge) {
            self.foundation = foundation
        }
    }
    
    private let foundationWrapper: FoundationWrapper
    
    /// Create a new adapter wrapping a Foundation implementation
    public init(wrapping foundation: any XPCServiceProtocolFoundationBridge) {
        self.foundationWrapper = FoundationWrapper(foundation: foundation)
    }
    
    /// Protocol identifier from the Foundation implementation
    public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.foundation.bridge"
    }
    
    /// Implement ping using the Foundation implementation
    public func ping() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            foundationWrapper.foundation.pingFoundation { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    /// Implement synchroniseKeys using the Foundation implementation
    public func synchroniseKeys(_ data: SecurityInterfacesProtocols.BinaryData) async throws {
        // Convert BinaryData to NSData
        let nsData = ObjCBridgingTypesFoundation.DataConverter.convertToNSData(fromBytes: data.bytes)
        
        return try await withCheckedThrowingContinuation { continuation in
            foundationWrapper.foundation.synchroniseKeysFoundation(nsData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
