import Foundation

/// Custom error for Foundation bridging that doesn't require direct NSError use
public enum FoundationBridgingError: Error, Sendable {
    case implementationMissing(String)
}

/// Protocol for XPC services in ObjCBridgingTypesFoundation that depends on Foundation
/// This is a standalone protocol that doesn't try to bridge to CoreTypes directly
@objc public protocol XPCServiceProtocolBaseFoundation: NSObjectProtocol {
    /// Protocol identifier - used for protocol negotiation
    @objc static var protocolIdentifier: String { get }

    /// Base method to test connectivity
    @objc func ping(withReply reply: @escaping (Bool, Error?) -> Void)

    /// Raw method for synchronising keys with Foundation.Data
    @objc optional func synchroniseKeys(_ data: Any, withReply reply: @escaping (Error?) -> Void)
}

/// Default implementation for XPCServiceProtocolBaseFoundation
public extension XPCServiceProtocolBaseFoundation {
    /// Default protocol identifier - must be implemented by concrete types
    static var protocolIdentifierDefault: String {
        return "com.umbra.xpc.service.protocol.base.foundation"
    }

    /// Raw implementation for synchronising keys
    var synchroniseKeysRaw: ((Any, @escaping (Error?) -> Void) -> Void)? {
        return self.synchroniseKeys(_:withReply:)
    }

    /// Async ping implementation
    func ping() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            ping { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    /// Async implementation for synchronising keys with byte array
    func synchroniseKeys(_ bytes: [UInt8]) async throws {
        let data = Data(bytes) as NSData

        return try await withCheckedThrowingContinuation { continuation in
            guard let synchroniseKeysRaw = self.synchroniseKeysRaw else {
                continuation.resume(throwing: FoundationBridgingError.implementationMissing("synchroniseKeys not implemented"))
                return
            }

            synchroniseKeysRaw(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
