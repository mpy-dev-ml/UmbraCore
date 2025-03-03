import Foundation
import SecurityProtocolsCore
import SecureBytes
import CoreTypes
import XPCProtocolsCore

/// Protocol defining Foundation-dependent XPC service interface.
/// This protocol is designed to work with the Objective-C runtime and NSXPCConnection.
extension SecurityBridge {
    /// A protocol that NSXPCConnection uses must inherit from NSObjectProtocol.
    /// We can't mark it as Sendable directly since it wouldn't be compatible with ObjC.
    @objc public protocol XPCServiceProtocolFoundationBridge: NSObjectProtocol {
        /// Protocol identifier - used for protocol negotiation
        static var protocolIdentifier: String { get }
        
        /// Test connectivity with a Foundation-based reply
        /// - Parameter reply: Reply block that is called with result and optional error
        func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void)
        
        /// Synchronize keys across processes with a Foundation-based reply
        /// - Parameters:
        ///   - syncData: The key data to synchronize
        ///   - reply: Reply block that is called when the operation completes
        func synchroniseKeysFoundation(_ syncData: Data, withReply reply: @escaping @Sendable (Error?) -> Void)
        
        /// Encrypt data using Foundation types
        /// - Parameters:
        ///   - data: Data to encrypt
        ///   - reply: Reply block with encrypted data and optional error
        func encryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)
        
        /// Decrypt data using Foundation types
        /// - Parameters:
        ///   - data: Data to decrypt
        ///   - reply: Reply block with decrypted data and optional error
        func decryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)
        
        /// Generate random data using Foundation types
        /// - Parameters:
        ///   - length: Length of random data to generate
        ///   - reply: Reply block with generated data and optional error
        func generateRandomDataFoundation(_ length: Int, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)
        
        /// Reset security data with a Foundation-based reply
        /// - Parameter reply: Reply block that is called with optional error
        func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void)
        
        /// Get version with a Foundation-based reply
        /// - Parameter reply: Reply block that is called with version string and optional error
        func getVersionFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void)
        
        /// Get host identifier with a Foundation-based reply
        /// - Parameter reply: Reply block that is called with identifier string and optional error
        func getHostIdentifierFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void)
    }
}

/// Adapter to convert between Core and Foundation XPC service protocols
extension SecurityBridge {
    public final class CoreTypesToFoundationBridgeAdapter: NSObject, XPCServiceProtocolFoundationBridge, @unchecked Sendable {
        public static var protocolIdentifier: String = "com.umbra.xpc.service.adapter.coretypes.bridge"
        
        private let coreService: any XPCServiceProtocolBasic
        
        public init(wrapping coreService: any XPCServiceProtocolBasic) {
            self.coreService = coreService
            super.init()
        }
        
        public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
            Task {
                do {
                    let result = try await coreService.ping()
                    reply(result, nil)
                } catch {
                    reply(false, error)
                }
            }
        }
        
        public func synchroniseKeysFoundation(_ syncData: Data, withReply reply: @escaping @Sendable (Error?) -> Void) {
            Task {
                do {
                    // Convert from Foundation Data to SecureBytes
                    let bytes = [UInt8](syncData)
                    let secureBytes = SecureBytes(bytes)
                    
                    try await coreService.synchroniseKeys(secureBytes)
                    reply(nil)
                } catch {
                    reply(error)
                }
            }
        }
        
        // The basic protocol doesn't have these methods, so we'll return appropriate errors
        
        public func generateRandomDataFoundation(_ length: Int, withReply reply: @escaping @Sendable (Data?, Error?) -> Void) {
            let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Method 'generateRandomData' not available in XPCServiceProtocolBasic"
            ])
            reply(nil, error)
        }
        
        public func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void) {
            let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Method 'resetSecurityData' not available in XPCServiceProtocolBasic"
            ])
            reply(error)
        }
        
        public func getVersionFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void) {
            let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Method 'getVersion' not available in XPCServiceProtocolBasic"
            ])
            reply(nil, error)
        }
        
        public func getHostIdentifierFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void) {
            let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Method 'getHostIdentifier' not available in XPCServiceProtocolBasic"
            ])
            reply(nil, error)
        }
        
        public func encryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void) {
            let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Method 'encrypt' not available in XPCServiceProtocolBasic"
            ])
            reply(nil, error)
        }
        
        public func decryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void) {
            let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Method 'decrypt' not available in XPCServiceProtocolBasic"
            ])
            reply(nil, error)
        }
    }
    
    public final class FoundationToCoreTypesBridgeAdapter: XPCServiceProtocolBasic, @unchecked Sendable {
        public static var protocolIdentifier: String = "com.umbra.xpc.service.adapter.foundation.bridge"
        
        private let foundation: any XPCServiceProtocolFoundationBridge
        
        public init(wrapping foundation: any XPCServiceProtocolFoundationBridge) {
            self.foundation = foundation
        }
        
        public func ping() async throws -> Bool {
            return try await withCheckedThrowingContinuation { continuation in
                foundation.pingFoundation { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        }
        
        public func synchroniseKeys(_ syncData: SecureBytes) async throws {
            let data = Data(syncData.bytes())
            
            return try await withCheckedThrowingContinuation { continuation in
                foundation.synchroniseKeysFoundation(data) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
        }
        
        public func resetSecurityData() async throws {
            return try await withCheckedThrowingContinuation { continuation in
                foundation.resetSecurityDataFoundation { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
        }
        
        public func getVersion() async throws -> String {
            return try await withCheckedThrowingContinuation { continuation in
                foundation.getVersionFoundation { versionString, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let versionString = versionString {
                        continuation.resume(returning: versionString)
                    } else {
                        continuation.resume(throwing: SecurityProtocolError.implementationMissing("Version not available"))
                    }
                }
            }
        }
        
        public func getHostIdentifier() async throws -> String {
            return try await withCheckedThrowingContinuation { continuation in
                foundation.getHostIdentifierFoundation { hostIdentifier, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let hostIdentifier = hostIdentifier {
                        continuation.resume(returning: hostIdentifier)
                    } else {
                        continuation.resume(throwing: SecurityProtocolError.implementationMissing("Host identifier not available"))
                    }
                }
            }
        }
        
        public func generateRandomData(length: Int) async throws -> BinaryData {
            return try await withCheckedThrowingContinuation { continuation in
                foundation.generateRandomDataFoundation(length) { data, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data {
                        let bytes = [UInt8](data)
                        continuation.resume(returning: BinaryData(bytes))
                    } else {
                        continuation.resume(throwing: SecurityProtocolError.implementationMissing("Random data generation failed"))
                    }
                }
            }
        }
    }
}
