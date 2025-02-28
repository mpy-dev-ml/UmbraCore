import CoreTypes
import Foundation

/// Utility class for converting between different data representations
/// This class is designed to be used without importing ObjCBridgingTypesFoundation
public enum DataConverter {
    /// Convert bytes to NSData
    /// - Parameter bytes: Array of bytes
    /// - Returns: NSData object
    public static func convertToNSData(fromBytes bytes: [UInt8]) -> NSData {
        return NSData(bytes: bytes, length: bytes.count)
    }
    
    /// Convert NSData to bytes
    /// - Parameter nsData: NSData object
    /// - Returns: Array of bytes
    public static func convertToBytes(fromNSData nsData: NSData) -> [UInt8] {
        return [UInt8](Data(referencing: nsData))
    }
    
    /// Convert BinaryData to NSData
    /// - Parameter data: BinaryData object
    /// - Returns: NSData object
    public static func convertToNSData(fromBinaryData data: CoreTypes.BinaryData) -> NSData {
        return data.bytes.withUnsafeBytes { bytes in
            NSData(bytes: bytes.baseAddress!, length: bytes.count)
        }
    }
    
    /// Convert NSData to BinaryData
    /// - Parameter nsData: NSData object
    /// - Returns: BinaryData object
    public static func convertToBinaryData(fromNSData nsData: NSData) -> CoreTypes.BinaryData {
        let bytes = [UInt8](Data(referencing: nsData))
        return CoreTypes.BinaryData(bytes)
    }
}
