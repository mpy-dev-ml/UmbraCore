/**
 # XPC Protocol Extensions

 This file contains extensions to the XPC protocol types that provide utility functions
 and shared implementations across protocol hierarchies. These extensions help ensure
 consistency across protocol implementations and reduce code duplication.

 ## Features

 * Protocol bridging utilities between different protocol levels
 * Data conversion helpers for working with different data representations
 * Common implementation patterns for protocol requirements
 * Extension methods for Swift-native protocols

 These extensions are designed to simplify the implementation of XPC services
 by providing reusable functionality.
 */

import Foundation
import UmbraCoreTypes

/// Extension methods for easier implementation of XPC service protocols
public extension XPCServiceProtocolBasic {
    /// Convert UInt8 array to Data
    /// - Parameter bytes: Byte array to convert
    /// - Returns: Data object containing the bytes
    func convertBytesToData(_ bytes: [UInt8]) -> Data {
        Data(bytes)
    }

    /// Convert Data to UInt8 array
    /// - Parameter data: Data to convert
    /// - Returns: Array of bytes
    func convertDataToBytes(_ data: Data) -> [UInt8] {
        [UInt8](data)
    }

    /// Convert Data to SecureBytes
    /// - Parameter data: Data to convert
    /// - Returns: SecureBytes safely containing the data
    func convertDataToSecureBytes(_ data: Data) -> SecureBytes {
        SecureBytes(bytes: [UInt8](data))
    }

    /// Convert SecureBytes to Data
    /// - Parameter secureBytes: SecureBytes to convert
    /// - Returns: Data representation
    func convertSecureBytesToData(_ secureBytes: SecureBytes) -> Data {
        var data = Data()
        secureBytes.withUnsafeBytes { rawBuffer in
            data = Data(rawBuffer)
        }
        return data
    }

    /// Convert UInt8 array to SecureBytes
    /// - Parameter bytes: Byte array to convert
    /// - Returns: SecureBytes safely containing the bytes
    func convertBytesToSecureBytes(_ bytes: [UInt8]) -> SecureBytes {
        SecureBytes(bytes: bytes)
    }

    /// Convert SecureBytes to bytes
    /// - Parameter secureBytes: SecureBytes to convert
    /// - Returns: A byte array containing the bytes
    func convertSecureBytesToBytes(_ secureBytes: SecureBytes) -> [UInt8] {
        var bytes = [UInt8]()
        secureBytes.withUnsafeBytes { rawBuffer in
            bytes = Array(rawBuffer)
        }
        return bytes
    }
}

/// Extension methods for standard protocol implementations
public extension XPCServiceProtocolStandard {
    /// Convenience method to get service status
    /// - Returns: Dictionary with status information
    func getStatus() -> [String: Any] {
        [
            "timestamp": Date().timeIntervalSince1970,
            "protocol": Self.protocolIdentifier,
            "isActive": true
        ]
    }

    /// Default implementation for generating random data
    /// - Parameter length: Length in bytes
    /// - Returns: SecureBytes containing random data
    func generateRandomSecureBytes(length: Int) -> SecureBytes {
        let bytes = (0 ..< length).map { _ in UInt8.random(in: 0 ... 255) }
        return SecureBytes(bytes: bytes)
    }
}

/// Extension methods for complete protocol implementations
public extension XPCServiceProtocolComplete {
    /// Bridge encryption from standard protocol to complete protocol
    /// - Parameters:
    ///   - data: SecureBytes to encrypt
    ///   - keyIdentifier: Optional key identifier
    /// - Returns: Result with encrypted data or error
    func bridgeEncryption(
        data: SecureBytes,
        keyIdentifier: String?
    ) async -> Result<SecureBytes, XPCSecurityError> {
        await encryptSecureData(data, keyIdentifier: keyIdentifier)
    }

    /// Bridge decryption from standard protocol to complete protocol
    /// - Parameters:
    ///   - data: SecureBytes to decrypt
    ///   - keyIdentifier: Optional key identifier
    /// - Returns: Result with decrypted data or error
    func bridgeDecryption(
        data: SecureBytes,
        keyIdentifier: String?
    ) async -> Result<SecureBytes, XPCSecurityError> {
        await decryptSecureData(data, keyIdentifier: keyIdentifier)
    }
}
