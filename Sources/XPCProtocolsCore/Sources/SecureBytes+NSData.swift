import Foundation
import UmbraCoreTypes

/// Extensions for SecureBytes to work with NSData
public extension SecureBytes {
    /// Create SecureBytes from NSData
    /// - Parameter nsData: NSData to convert
    /// - Returns: SecureBytes instance
    init(nsData: NSData) {
        let bytes = nsData.bytes.bindMemory(to: UInt8.self, capacity: nsData.length)
        let buffer = UnsafeBufferPointer(start: bytes, count: nsData.length)
        self.init(bytes: Array(buffer))
    }

    /// Convert SecureBytes to NSData
    var nsData: NSData {
        // Use withUnsafeBytes to safely access the raw bytes
        withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }
    }
}
