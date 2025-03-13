import CoreTypesInterfaces
import Foundation
import UmbraCoreTypes

/// Extension providing conversion between SecureData and Foundation's Data
public extension SecureData {
    /// Initialize from Foundation Data
    /// - Parameter data: Foundation Data instance
    init(data: Data) {
        self.init(bytes: [UInt8](data))
    }

    /// Convert to Foundation Data
    /// - Returns: Data representation
    func toData() -> Data {
        Data(rawBytes)
    }

    /// Initialize from UmbraCoreTypes's SecureBytes
    /// - Parameter secureBytes: SecureBytes instance
    init(secureBytes: UmbraCoreTypes.SecureBytes) {
        // Convert SecureBytes to [UInt8] array using iteration and subscript access
        var bytes = [UInt8]()
        for i in 0 ..< secureBytes.count {
            bytes.append(secureBytes[i])
        }
        self.init(bytes: bytes)
    }

    /// Convert to UmbraCoreTypes's SecureBytes
    /// - Returns: SecureBytes representation
    func toSecureBytes() -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: rawBytes)
    }
}

/// Extension providing conversion to/from SecureData for Foundation's Data
public extension Data {
    /// Convert to SecureData
    /// - Returns: SecureData representation
    func toSecureData() -> SecureData {
        SecureData(data: self)
    }
}

/// Extension providing conversion to/from SecureData for UmbraCoreTypes's SecureBytes
public extension UmbraCoreTypes.SecureBytes {
    /// Convert to SecureData
    /// - Returns: SecureData representation
    func toSecureData() -> SecureData {
        SecureData(secureBytes: self)
    }

    /// Convert from SecureData
    /// - Parameter secureData: SecureData to convert
    /// - Returns: SecureBytes instance
    static func from(secureData: SecureData) -> UmbraCoreTypes.SecureBytes {
        secureData.toSecureBytes()
    }
}
