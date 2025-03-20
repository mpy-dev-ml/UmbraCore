// DEPRECATED: DataBridge
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import Foundation
import UmbraCoreTypes

/// Extension to the SecurityBridge namespace
public extension SecurityBridge {
    /// A bridge type that encapsulates data without exposing Foundation
    /// but can be converted to Foundation types internally.
    struct DataBridge: Sendable, Equatable {
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
            data = Data(bytes)
        }

        /// Initialize with secure bytes
        /// - Parameter secureBytes: SecureBytes object
        public init(_ secureBytes: SecureBytes) {
            data = DataAdapter.data(from: secureBytes)
        }

        // MARK: - Conversion Methods

        /// Convert to Foundation Data
        /// - Returns: Foundation Data
        public func toFoundationData() -> Data {
            data
        }

        /// Convert to SecureBytes
        /// - Returns: SecureBytes
        public func toSecureBytes() -> SecureBytes {
            SecureBytes(bytes: Array(data))
        }

        /// Get as array of bytes
        /// - Returns: Byte array
        public func toBytes() -> [UInt8] {
            Array(data)
        }

        // MARK: - Equatable

        public static func == (lhs: DataBridge, rhs: DataBridge) -> Bool {
            lhs.data == rhs.data
        }
    }
}
