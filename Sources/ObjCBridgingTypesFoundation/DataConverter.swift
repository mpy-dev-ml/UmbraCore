import Foundation

/// Utility class to handle conversions between byte arrays and Foundation types
public class DataConverter {
    /// Convert a byte array to NSData
    /// - Parameter bytes: Array of bytes to convert
    /// - Returns: An NSData representation of the bytes
    public static func convertToNSData(fromBytes bytes: [UInt8]) -> NSObject {
        return Data(bytes) as NSObject
    }

    /// Convert NSData to a byte array
    /// - Parameter nsData: The NSData object to convert
    /// - Returns: Array of bytes
    public static func convertToBytes(fromNSData nsData: NSObject) -> [UInt8] {
        guard let data = nsData as? NSData else {
            return []
        }
        let convertedData = data as Data
        return [UInt8](convertedData)
    }

    /// Execute a closure with NSData converted to Data
    /// - Parameters:
    ///   - nsData: The NSData to convert
    ///   - block: Closure to execute with the converted Data
    public static func withConvertedData(_ nsData: NSObject, _ block: (Foundation.Data) -> Void) {
        guard let data = nsData as? NSData else {
            return
        }
        block(data as Foundation.Data)
    }
}
