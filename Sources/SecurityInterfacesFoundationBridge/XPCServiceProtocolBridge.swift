import Foundation
import SecurityBridgeCore
import SecurityObjCProtocols

/// Bridge protocol to break circular dependencies between Foundation and SecurityInterfaces
@objc public protocol XPCServiceProtocolFoundationBridge: NSObjectProtocol {
    /// Protocol identifier
    @objc static var protocolIdentifier: String { get }

    /// Ping the service to check if it's alive
    /// - Parameter reply: Callback with result and error
    @objc func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void)

    /// Synchronize keys
    /// - Parameters:
    ///   - data: Key data
    ///   - reply: Callback with error
    @objc func synchroniseKeysFoundation(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void)

    /// Get encryption keys from the service
    /// - Parameter reply: Reply handler with data result and optional error
    @objc func getEncryptionKeysFoundation(withReply reply: @escaping @Sendable (NSData?, Error?) -> Void)

    /// Encrypt data using the service
    /// - Parameters:
    ///   - data: The data to encrypt
    ///   - reply: Reply handler with encrypted data and optional error
    @objc func encryptDataFoundation(_ data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void)

    /// Decrypt data using the service
    /// - Parameters:
    ///   - data: The data to decrypt
    ///   - reply: Reply handler with decrypted data and optional error
    @objc func decryptDataFoundation(_ data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void)
}

/// Adapter that bridges from SecurityBridgeCore to XPCServiceProtocolFoundationBridge
@objc public final class CoreTypesToFoundationBridgeAdapter: NSObject, XPCServiceProtocolFoundationBridge, @unchecked Sendable {
    private let core: any SecurityBridgeCore.XPCServiceProtocolCoreBridge

    public init(wrapping core: any SecurityBridgeCore.XPCServiceProtocolCoreBridge) {
        self.core = core
        super.init()
    }

    @objc public static var protocolIdentifier: String {
        return "com.umbra.security.xpc.foundation"
    }

    @objc public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        // Capture core reference outside the task to avoid capturing self
        let coreRef = self.core

        Task {
            do {
                let result = try await coreRef.pingCore()
                reply(result, nil)
            } catch {
                reply(false, error)
            }
        }
    }

    @objc public func synchroniseKeysFoundation(_ data: NSData, withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Capture data reference and convert to bytes outside the task to avoid capturing non-sendable types
        let coreRef = self.core
        let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: data)

        Task {
            do {
                try await coreRef.synchroniseKeysCore(bytes)
                reply(nil)
            } catch {
                reply(error)
            }
        }
    }

    @objc public func getEncryptionKeysFoundation(withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // Capture core reference outside the task to avoid capturing self
        let coreRef = self.core

        Task {
            do {
                let bytes = try await coreRef.getEncryptionKeysCore()
                if let bytes = bytes {
                    // Convert bytes back to NSData
                    let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: bytes)
                    reply(nsData, nil)
                } else {
                    reply(nil, nil)
                }
            } catch {
                reply(nil, error)
            }
        }
    }

    @objc public func encryptDataFoundation(_ data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // Capture data reference and convert to bytes outside the task to avoid capturing non-sendable types
        let coreRef = self.core
        let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: data)

        Task {
            do {
                let encryptedBytes = try await coreRef.encryptDataCore(bytes)
                if let encryptedBytes = encryptedBytes {
                    // Convert bytes back to NSData
                    let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: encryptedBytes)
                    reply(nsData, nil)
                } else {
                    reply(nil, nil)
                }
            } catch {
                reply(nil, error)
            }
        }
    }

    @objc public func decryptDataFoundation(_ data: NSData, withReply reply: @escaping @Sendable (NSData?, Error?) -> Void) {
        // Capture data reference and convert to bytes outside the task to avoid capturing non-sendable types
        let coreRef = self.core
        let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: data)

        Task {
            do {
                let decryptedBytes = try await coreRef.decryptDataCore(bytes)
                if let decryptedBytes = decryptedBytes {
                    // Convert bytes back to NSData
                    let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: decryptedBytes)
                    reply(nsData, nil)
                } else {
                    reply(nil, nil)
                }
            } catch {
                reply(nil, error)
            }
        }
    }
}

/// Adapter that bridges from XPCServiceProtocolFoundationBridge to SecurityBridgeCore
public final class FoundationToCoreTypesBridgeAdapter: SecurityBridgeCore.XPCServiceProtocolCoreBridge, @unchecked Sendable {
    private let wrapper: XPCServiceProtocolWrapper

    public static var protocolIdentifier: String {
        return "com.umbra.security.xpc.core"
    }

    public init(foundation: any XPCServiceProtocolFoundationBridge) {
        self.wrapper = XPCServiceProtocolWrapper(foundation: foundation)
    }

    // MARK: - Protocol Methods

    public func pingCore(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
        wrapper.foundation.pingFoundation(withReply: reply)
    }

    public func synchroniseKeysCore(_ data: [UInt8], withReply reply: @escaping @Sendable (Error?) -> Void) {
        // Convert bytes to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data)

        // Call the foundation implementation
        wrapper.foundation.synchroniseKeysFoundation(nsData, withReply: reply)
    }

    public func getEncryptionKeysCore(withReply reply: @escaping @Sendable ([UInt8]?, Error?) -> Void) {
        wrapper.foundation.getEncryptionKeysFoundation { data, error in
            if let error = error {
                reply(nil, error)
            } else if let data = data {
                let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: data)
                reply(bytes, nil)
            } else {
                reply(nil, NSError(domain: "com.umbra.security", code: 1_001, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"]))
            }
        }
    }

    public func encryptDataCore(_ data: [UInt8], withReply reply: @escaping @Sendable ([UInt8]?, Error?) -> Void) {
        // Convert bytes to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data)

        // Call the foundation implementation
        wrapper.foundation.encryptDataFoundation(nsData) { nsData, error in
            if let error = error {
                reply(nil, error)
            } else if let nsData = nsData {
                let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: nsData)
                reply(bytes, nil)
            } else {
                reply(nil, NSError(domain: "com.umbra.security", code: 1_001, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"]))
            }
        }
    }

    public func decryptDataCore(_ data: [UInt8], withReply reply: @escaping @Sendable ([UInt8]?, Error?) -> Void) {
        // Convert bytes to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data)

        // Call the foundation implementation
        wrapper.foundation.decryptDataFoundation(nsData) { nsData, error in
            if let error = error {
                reply(nil, error)
            } else if let nsData = nsData {
                let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: nsData)
                reply(bytes, nil)
            } else {
                reply(nil, NSError(domain: "com.umbra.security", code: 1_001, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"]))
            }
        }
    }

    // Async versions for convenience

    public func pingCore() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            wrapper.foundation.pingFoundation { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    public func synchroniseKeysCore(_ data: [UInt8]) async throws {
        // Convert bytes to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data)

        // Call the foundation implementation
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            wrapper.foundation.synchroniseKeysFoundation(nsData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func getEncryptionKeysCore() async throws -> [UInt8]? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[UInt8]?, Error>) in
            wrapper.foundation.getEncryptionKeysFoundation { nsData, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let nsData = nsData {
                    // Convert NSData to bytes
                    let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: nsData)
                    continuation.resume(returning: bytes)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    public func encryptDataCore(_ data: [UInt8]) async throws -> [UInt8]? {
        // Convert bytes to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data)

        // Call the foundation implementation
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[UInt8]?, Error>) in
            wrapper.foundation.encryptDataFoundation(nsData) { nsData, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let nsData = nsData {
                    // Convert NSData to bytes
                    let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: nsData)
                    continuation.resume(returning: bytes)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    public func decryptDataCore(_ data: [UInt8]) async throws -> [UInt8]? {
        // Convert bytes to NSData
        let nsData = SecurityBridgeCore.DataConverter.convertToNSData(fromBytes: data)

        // Call the foundation implementation
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[UInt8]?, Error>) in
            wrapper.foundation.decryptDataFoundation(nsData) { nsData, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let nsData = nsData {
                    // Convert NSData to bytes
                    let bytes = SecurityBridgeCore.DataConverter.convertToBytes(fromNSData: nsData)
                    continuation.resume(returning: bytes)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

/// Wrapper to hold a reference to the foundation protocol
/// This is used to avoid capturing self in async contexts
public struct XPCServiceProtocolWrapper {
    public let foundation: any XPCServiceProtocolFoundationBridge

    public init(foundation: any XPCServiceProtocolFoundationBridge) {
        self.foundation = foundation
    }
}
