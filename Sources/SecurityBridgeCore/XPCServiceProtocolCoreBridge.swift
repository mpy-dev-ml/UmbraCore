/// Core XPC service protocol that doesn't depend on Foundation
/// This protocol is used to break circular dependencies between Foundation and SecurityInterfaces
public protocol XPCServiceProtocolCoreBridge: AnyObject, Sendable {
    /// Ping the service to check if it's alive
    /// - Parameter reply: Reply handler with boolean result and optional error
    func pingCore(withReply reply: @escaping @Sendable (Bool, Error?) -> Void)

    /// Synchronize keys with the service
    /// - Parameters:
    ///   - data: The data to synchronize as bytes
    ///   - reply: Reply handler with optional error
    func synchroniseKeysCore(_ data: [UInt8], withReply reply: @escaping @Sendable (Error?) -> Void)

    /// Get encryption keys from the service
    /// - Parameter reply: Reply handler with bytes result and optional error
    func getEncryptionKeysCore(withReply reply: @escaping @Sendable ([UInt8]?, Error?) -> Void)

    /// Encrypt data using the service
    /// - Parameters:
    ///   - data: The data to encrypt as bytes
    ///   - reply: Reply handler with encrypted bytes and optional error
    func encryptDataCore(_ data: [UInt8], withReply reply: @escaping @Sendable ([UInt8]?, Error?) -> Void)

    /// Decrypt data using the service
    /// - Parameters:
    ///   - data: The data to decrypt as bytes
    ///   - reply: Reply handler with decrypted bytes and optional error
    func decryptDataCore(_ data: [UInt8], withReply reply: @escaping @Sendable ([UInt8]?, Error?) -> Void)
}

/// Async extension for XPCServiceProtocolCoreBridge
public extension XPCServiceProtocolCoreBridge {
    /// Async version of pingCore
    func pingCore() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            pingCore { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    /// Async version of synchroniseKeysCore
    func synchroniseKeysCore(_ data: [UInt8]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            synchroniseKeysCore(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    /// Async version of getEncryptionKeysCore
    func getEncryptionKeysCore() async throws -> [UInt8]? {
        return try await withCheckedThrowingContinuation { continuation in
            getEncryptionKeysCore { bytes, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: bytes)
                }
            }
        }
    }

    /// Async version of encryptDataCore
    func encryptDataCore(_ data: [UInt8]) async throws -> [UInt8]? {
        return try await withCheckedThrowingContinuation { continuation in
            encryptDataCore(data) { encryptedBytes, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: encryptedBytes)
                }
            }
        }
    }

    /// Async version of decryptDataCore
    func decryptDataCore(_ data: [UInt8]) async throws -> [UInt8]? {
        return try await withCheckedThrowingContinuation { continuation in
            decryptDataCore(data) { decryptedBytes, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: decryptedBytes)
                }
            }
        }
    }
}
