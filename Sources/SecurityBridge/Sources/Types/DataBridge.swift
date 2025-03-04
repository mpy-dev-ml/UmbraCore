// DataBridge.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import UmbraCoreTypes
/// Extension to the SecurityBridge namespace
extension SecurityBridge {
    /// A bridge type that encapsulates data without exposing Foundation
    /// but can be converted to Foundation types internally.
    public struct DataBridge: Sendable, Equatable {
        // MARK: - Properties
        
        /// The internal Foundation Data
        private let data: Data
        
        // MARK: - Initialization
        
        /// Initialize with Foundation Data
        /// - Parameter data: Foundation Data object
        public init(_ data: Data) {
            self.data = data
        }
        
        /// Initialize with raw bytes
        /// - Parameter bytes: Array of bytes
        public init(_ bytes: [UInt8]) {
            self.data = Data(bytes)
        }
        
        /// Initialize with secure bytes
        /// - Parameter secureBytes: SecureBytes object
        public init(_ secureBytes: SecureBytes) {
            self.data = Data(secureBytes.unsafeBytes)
        }
        
        // MARK: - Conversion Methods
        
        /// Convert to Foundation Data
        /// - Returns: Foundation Data
        public func toFoundationData() -> Data {
            return data
        }
        
        /// Convert to SecureBytes
        /// - Returns: SecureBytes
        public func toSecureBytes() -> SecureBytes {
            return SecureBytes(Array(data))
        }
        
        /// Get as array of bytes
        /// - Returns: Byte array
        public func toBytes() -> [UInt8] {
            return Array(data)
        }
        
        // MARK: - Equatable
        
        public static func == (lhs: DataBridge, rhs: DataBridge) -> Bool {
            return lhs.data == rhs.data
        }
    }
}
