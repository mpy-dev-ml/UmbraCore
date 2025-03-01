// DataAdapter.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecureBytes

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
        return SecureBytes([UInt8](data))
    }
    
    /// Convert SecureBytes to Foundation Data
    /// - Parameter secureBytes: SecureBytes instance
    /// - Returns: A new Data instance containing the same bytes
    public static func data(from secureBytes: SecureBytes) -> Data {
        // Create Data from SecureBytes' bytes
        return Data(secureBytes.unsafeBytes)
    }
    
    /// Create SecureBytes from JSON encodable object
    /// - Parameter object: JSON encodable object
    /// - Returns: SecureBytes containing the JSON data, or nil if conversion fails
    public static func secureBytes<T: Encodable>(from object: T) -> SecureBytes? {
        guard let data = try? JSONEncoder().encode(object) else {
            return nil
        }
        return secureBytes(from: data)
    }
}
