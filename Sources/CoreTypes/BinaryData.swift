// This file is just a re-export of BinaryData from SecurityInterfacesProtocols
@_exported import SecurityInterfacesProtocols

// Add extension methods to maintain backward compatibility
extension SecurityInterfacesProtocols.BinaryData {
    /// Get a slice of the data
    public func slice(from: Int, length: Int) -> SecurityInterfacesProtocols.BinaryData {
        let end = Swift.min(from + length, bytes.count)
        let slice = bytes[from..<end]
        return SecurityInterfacesProtocols.BinaryData(Array(slice))
    }

    /// Access a specific byte by index
    public subscript(index: Int) -> UInt8 {
        return bytes[index]
    }

    /// The number of bytes in the data
    public var count: Int {
        return bytes.count
    }
}
