import CoreTypesInterfaces
import UmbraCoreTypes

/// Extension providing conversion between SecureBytes and BinaryData (SecureData)
/// for use in the SecurityInterfaces module
extension SecureBytes {
    /// Convert to BinaryData type for use with DTOs
    /// - Returns: A BinaryData representation of this SecureBytes instance
    public func toBinaryData() -> BinaryData {
        // Since BinaryData is a typealias for SecureData,
        // we need to convert our SecureBytes to SecureData
        // Create a buffer of bytes from the SecureBytes
        var bytes = [UInt8]()
        for i in 0..<self.count {
            bytes.append(self[i])
        }
        return BinaryData(bytes: bytes)
    }
}
