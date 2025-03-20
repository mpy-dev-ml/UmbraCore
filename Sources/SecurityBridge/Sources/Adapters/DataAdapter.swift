// DEPRECATED: DataAdapter
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import Foundation
import UmbraCoreTypes

/// DataAdapter provides bidirectional conversion between Foundation Data and SecureBytes.
///
/// This adapter serves as the primary bridge for binary data between Foundation-dependent
/// and Foundation-independent code. It ensures that conversions are efficient and maintain
/// the security properties of SecureBytes when converting to and from Data.
public enum DataAdapter {
    /// Convert Foundation Data to SecureBytes
    /// - Parameter data: Foundation Data instance
    /// - Returns: A new SecureBytes instance containing the same bytes
    public static func secureBytes(from data: Data) -> SecureBytes {
        // Create SecureBytes from Data's bytes
        SecureBytes(bytes: [UInt8](data))
    }

    /// Convert SecureBytes to Foundation Data
    /// - Parameter secureBytes: SecureBytes instance
    /// - Returns: A new Data instance containing the same bytes
    public static func data(from secureBytes: SecureBytes) -> Data {
        // Create Data from SecureBytes' bytes by converting to array first
        var byteArray = [UInt8]()
        secureBytes.withUnsafeBytes { buffer in
            byteArray = Array(buffer)
        }
        return Data(byteArray)
    }

    /// Create SecureBytes from JSON encodable object
    /// - Parameter object: JSON encodable object
    /// - Returns: SecureBytes containing the JSON data, or nil if conversion fails
    public static func secureBytes(from object: some Encodable) -> SecureBytes? {
        guard let data = try? JSONEncoder().encode(object) else {
            return nil
        }
        return secureBytes(from: data)
    }

    /// Convert optional SecureBytes to optional Foundation Data
    /// - Parameter secureBytes: The optional SecureBytes instance to convert
    /// - Returns: An optional Foundation Data instance, or nil if input is nil
    public static func optionalData(from secureBytes: SecureBytes?) -> Data? {
        guard let secureBytes else { return nil }
        return data(from: secureBytes)
    }

    /// Convert optional Foundation Data to optional SecureBytes
    /// - Parameter data: The optional Foundation Data instance to convert
    /// - Returns: An optional SecureBytes instance, or nil if input is nil
    public static func optionalSecureBytes(from data: Data?) -> SecureBytes? {
        guard let data else { return nil }
        return secureBytes(from: data)
    }

    /// Convert an array of SecureBytes to an array of Foundation Data
    /// - Parameter secureBytes: The array of SecureBytes instances to convert
    /// - Returns: An array of Foundation Data instances
    public static func dataArray(from secureBytes: [SecureBytes]) -> [Data] {
        secureBytes.map { data(from: $0) }
    }

    /// Convert an array of Foundation Data to an array of SecureBytes
    /// - Parameter dataArray: The array of Foundation Data instances to convert
    /// - Returns: An array of SecureBytes instances
    public static func secureBytesArray(from dataArray: [Data]) -> [SecureBytes] {
        dataArray.map { secureBytes(from: $0) }
    }
}
