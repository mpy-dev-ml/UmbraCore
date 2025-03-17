import Foundation
import UmbraCoreTypes

// Default implementations for XPCDataHandlingProtocol
public extension XPCDataHandlingProtocol {
    /// Convert NSData to SecureBytes
    func convertNSDataToSecureBytes(_ data: NSData) -> SecureBytes {
        let dataBytes = [UInt8](Data(referencing: data))
        return SecureBytes(bytes: dataBytes)
    }
    
    /// Convert SecureBytes to NSData
    func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
        var dataBytes = [UInt8]()
        
        // Access the bytes using withUnsafeBytes since there's no direct bytes property
        secureBytes.withUnsafeBytes { rawBuffer in
            dataBytes = Array(rawBuffer)
        }
        
        return NSData(bytes: dataBytes, length: dataBytes.count)
    }
    
    /// Convert Data to SecureBytes
    func convertDataToSecureBytes(_ data: Data) -> SecureBytes {
        let dataBytes = [UInt8](data)
        return SecureBytes(bytes: dataBytes)
    }
    
    /// Convert SecureBytes to Data
    func convertSecureBytesToData(_ secureBytes: SecureBytes) -> Data {
        var data = Data()
        
        // Access the bytes using withUnsafeBytes since there's no direct bytes property
        secureBytes.withUnsafeBytes { rawBuffer in
            data = Data(rawBuffer)
        }
        
        return data
    }
    
    /// Convert byte array to SecureBytes
    func convertBytesToSecureBytes(_ bytes: [UInt8]) -> SecureBytes {
        return SecureBytes(bytes: bytes)
    }
    
    /// Convert SecureBytes to byte array
    func convertSecureBytesToBytes(_ secureBytes: SecureBytes) -> [UInt8] {
        var bytes = [UInt8]()
        
        // Access the bytes using withUnsafeBytes since there's no direct bytes property
        secureBytes.withUnsafeBytes { rawBuffer in
            bytes = Array(rawBuffer)
        }
        
        return bytes
    }
    
    /// Convert byte array to Data
    func convertBytesToData(_ bytes: [UInt8]) -> Data {
        return Data(bytes)
    }
    
    /// Convert Data to byte array
    func convertDataToBytes(_ data: Data) -> [UInt8] {
        return [UInt8](data)
    }
    
    /// Convert NSData to Data
    func convertNSDataToData(_ nsData: NSData) -> Data {
        return Data(referencing: nsData)
    }
    
    /// Convert Data to NSData
    func convertDataToNSData(_ data: Data) -> NSData {
        return data as NSData
    }
}
