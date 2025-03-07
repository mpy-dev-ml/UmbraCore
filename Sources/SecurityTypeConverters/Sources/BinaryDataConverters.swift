import CoreTypesInterfaces
import FoundationBridgeTypes
import UmbraCoreTypes

// MARK: - BinaryData Extensions

public extension CoreTypesInterfaces.BinaryData {
    /// Convert to SecureBytes for use in security operations
    /// - Returns: SecureBytes representation of this data
    func toSecureBytes() -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: self.rawBytes)
    }
    
    /// Convert to DataBridge for cross-module compatibility
    /// - Returns: DataBridge representation of this data
    func toDataBridge() -> DataBridge {
        DataBridge(self.rawBytes)
    }
    
    /// Create from SecureBytes 
    /// - Parameter secureBytes: The SecureBytes to convert
    /// - Returns: BinaryData representation
    static func from(secureBytes: UmbraCoreTypes.SecureBytes) -> CoreTypesInterfaces.BinaryData {
        // Access each byte in the secure bytes and create a new array
        var bytes = [UInt8]()
        for i in 0..<secureBytes.count {
            bytes.append(secureBytes[i])
        }
        return CoreTypesInterfaces.BinaryData(bytes: bytes)
    }
    
    /// Create from DataBridge
    /// - Parameter bridge: The DataBridge to convert
    /// - Returns: BinaryData representation
    static func from(bridge: DataBridge) -> CoreTypesInterfaces.BinaryData {
        CoreTypesInterfaces.BinaryData(bytes: bridge.bytes)
    }
}

// MARK: - SecureBytes Extensions

public extension UmbraCoreTypes.SecureBytes {
    /// Convert to BinaryData
    /// - Returns: BinaryData representation of these bytes
    func toBinaryData() -> CoreTypesInterfaces.BinaryData {
        // Access each byte in the secure bytes and create a new array
        var bytes = [UInt8]()
        for i in 0..<self.count {
            bytes.append(self[i])
        }
        return CoreTypesInterfaces.BinaryData(bytes: bytes)
    }
    
    /// Convert to DataBridge for cross-module compatibility
    /// - Returns: DataBridge representation of these bytes
    func toDataBridge() -> DataBridge {
        // Access each byte in the secure bytes and create a new array
        var bytes = [UInt8]()
        for i in 0..<self.count {
            bytes.append(self[i])
        }
        return DataBridge(bytes)
    }
}

// MARK: - DataBridge Extensions

public extension DataBridge {
    /// Convert to BinaryData
    /// - Returns: BinaryData representation of this bridge
    func toBinaryData() -> CoreTypesInterfaces.BinaryData {
        CoreTypesInterfaces.BinaryData(bytes: self.bytes)
    }
    
    /// Convert to SecureBytes
    /// - Returns: SecureBytes representation of this bridge
    func toSecureBytes() -> UmbraCoreTypes.SecureBytes {
        UmbraCoreTypes.SecureBytes(bytes: self.bytes)
    }
}
