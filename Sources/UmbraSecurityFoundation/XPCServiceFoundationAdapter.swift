import Foundation
import FoundationBridgeTypes
@preconcurrency import ObjCBridgingTypesFoundation
import SecurityInterfaces
import SecurityInterfacesBase
import SecurityInterfacesFoundation
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import SecurityInterfacesProtocols
@preconcurrency import SecurityInterfacesXPC

/// Adapter that bridges from SecurityInterfaces.XPCServiceProtocol to ObjCBridgingTypesFoundation.XPCServiceProtocolDefinitionBaseFoundation
@objc public final class SecurityToFoundationAdapter: NSObject, @preconcurrency SecurityInterfacesXPC.XPCServiceProtocolDefinition {
    private let service: any SecurityInterfaces.XPCServiceProtocol

    /// Create a new adapter wrapping a SecurityInterfaces implementation
    public init(wrapping service: any SecurityInterfaces.XPCServiceProtocol) {
        self.service = service
        super.init()
    }

    /// Protocol identifier from the wrapped service
    @objc public static var protocolIdentifier: String {
        return "com.umbra.xpc.service.adapter.security"
    }

    // MARK: - XPCServiceProtocolDefinitionBaseFoundation Implementation

    /// Test connectivity
    @MainActor @objc public func ping(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        let callback = CallbackStore.store(reply)
        // Capture service reference to avoid capturing self in the task
        let serviceRef = self.service

        Task {
            do {
                let result = try await serviceRef.ping()
                CallbackStore.callPingCallback(id: callback, result: result, error: nil)
            } catch {
                CallbackStore.callPingCallback(id: callback, result: false, error: error)
            }
        }
    }

    /// Reset security data
    @objc public func resetSecurityData(withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Since XPCServiceProtocol doesn't have resetSecurityData, just return success
        reply(nil)
    }

    // MARK: - XPCServiceProtocolDefinition Implementation

    /// Synchronize keys across processes
    @MainActor @objc public func synchroniseKeys(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Convert NSData to bytes before passing to Task to avoid capturing non-Sendable types
        let bytes = [UInt8](Data(referencing: data))
        let callback = CallbackStore.store(reply)
        // Capture service reference to avoid capturing self in the task
        let serviceRef = self.service

        Task {
            do {
                // Convert bytes to BinaryData
                let binaryData = SecurityInterfacesProtocols.BinaryData(bytes)
                // Call the CoreTypes implementation
                try await serviceRef.synchroniseKeys(binaryData)
                CallbackStore.callErrorCallback(id: callback, error: nil)
            } catch {
                CallbackStore.callErrorCallback(id: callback, error: error)
            }
        }
    }

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
public final class FoundationToSecurityAdapter: SecurityInterfaces.XPCServiceProtocol {
    // Use a class to wrap the non-Sendable protocol
    private final class FoundationWrapper: @unchecked Sendable {
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
    public func ping() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            // Capture wrapper locally to avoid capturing self
            let localWrapper = self.foundationWrapper

            localWrapper.foundation.ping { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    /// Synchronize keys across processes
    public func synchroniseKeys(_ data: SecurityInterfacesProtocols.BinaryData) async throws {
        // Convert BinaryData directly to NSData
        let nsObject = NSData(bytes: data.bytes, length: data.bytes.count)

        return try await withCheckedThrowingContinuation { continuation in
            // Capture wrapper locally to avoid capturing self
            let localWrapper = self.foundationWrapper

            localWrapper.foundation.synchroniseKeys(nsObject) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    /// Encrypt data using the service
    public func encrypt(data: SecurityInterfacesBase.BinaryData) async throws -> SecurityInterfacesBase.BinaryData {
        // This is just a placeholder implementation
        // In a real implementation, you would implement actual encryption
        return data
    }

    /// Decrypt data using the service
    public func decrypt(data: SecurityInterfacesBase.BinaryData) async throws -> SecurityInterfacesBase.BinaryData {
        // This is just a placeholder implementation
        // In a real implementation, you would implement actual decryption
        return data
    }
}

/// Helper class to safely store and call callbacks from async contexts
@MainActor final class CallbackStore {
    private static var pingCallbacks: [UUID: @Sendable (Bool, Error?) -> Void] = [:]
    private static var errorCallbacks: [UUID: @Sendable (Error?) -> Void] = [:]

    /// Store a ping callback and return its ID
    static func store(_ callback: @escaping @Sendable (Bool, Error?) -> Void) -> UUID {
        let id = UUID()
        pingCallbacks[id] = callback
        return id
    }

    /// Store an error callback and return its ID
    static func store(_ callback: @escaping @Sendable (Error?) -> Void) -> UUID {
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
