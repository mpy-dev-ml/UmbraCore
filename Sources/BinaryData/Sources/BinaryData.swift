// BinaryData.swift - Foundation-free implementation
// Part of UmbraCore project
// Created on 2025-02-28

/// A Foundation-free alternative to Data that can be used across thread boundaries.
@frozen
public struct BinaryData: Sendable, Equatable, Hashable {
    // MARK: - Properties
    
    /// The underlying storage for the binary data
    private let storage: [UInt8]
    
    /// The number of bytes in the binary data
    public var count: Int {
        return storage.count
    }
    
    /// Whether the binary data is empty
    public var isEmpty: Bool {
        return storage.isEmpty
    }
    
    // MARK: - Initialisation
    
    /// Creates an empty instance
    public init() {
        self.storage = []
    }
    
    /// Creates a new instance from a byte array
    /// - Parameter bytes: The bytes to store
    public init(bytes: [UInt8]) {
        self.storage = bytes
    }
    
    /// Creates a new instance from a static byte array
    /// - Parameter staticBytes: The static bytes to store
    public init<T>(staticBytes: T) where T: Collection, T.Element == UInt8 {
        self.storage = Array(staticBytes)
    }
    
    /// Creates a new instance with the specified number of zeroed bytes
    /// - Parameter count: The number of zeroed bytes
    public init(count: Int) {
        self.storage = Array(repeating: 0, count: count)
    }
    
    // MARK: - Collection Interface
    
    /// Access individual bytes
    public subscript(index: Int) -> UInt8 {
        get {
            precondition(index >= 0 && index < count, "Index out of bounds")
            return storage[index]
        }
    }
    
    /// Access a range of bytes
    public subscript(range: Range<Int>) -> BinaryData {
        get {
            precondition(range.lowerBound >= 0 && range.upperBound <= count, "Range out of bounds")
            return BinaryData(bytes: Array(storage[range]))
        }
    }
    
    // MARK: - Methods
    
    /// Returns the bytes as an array
    public func bytes() -> [UInt8] {
        return storage
    }
    
    /// Appends another BinaryData to this instance
    /// - Parameter other: The BinaryData to append
    /// - Returns: A new BinaryData with the combined content
    public func appending(_ other: BinaryData) -> BinaryData {
        var result = storage
        result.append(contentsOf: other.storage)
        return BinaryData(bytes: result)
    }
    
    /// Appends a byte to this instance
    /// - Parameter byte: The byte to append
    /// - Returns: A new BinaryData with the appended byte
    public func appending(byte: UInt8) -> BinaryData {
        var result = storage
        result.append(byte)
        return BinaryData(bytes: result)
    }
    
    /// Creates a hexadecimal string representation of the binary data
    /// - Returns: A hex string representation of the data
    public func hexEncodedString() -> String {
        let hexDigits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        var hexString = ""
        for byte in storage {
            let value = Int(byte)
            hexString.append(hexDigits[(value >> 4) & 0xF])
            hexString.append(hexDigits[value & 0xF])
        }
        return hexString
    }
}

// MARK: - ExpressibleByArrayLiteral

extension BinaryData: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = UInt8
    
    public init(arrayLiteral elements: UInt8...) {
        self.init(bytes: elements)
    }
}

// MARK: - Conversion

extension BinaryData {
    /// Creates a binary data instance from a hex string
    /// - Parameter hexString: A string containing hexadecimal characters
    /// - Returns: A new BinaryData instance, or nil if the string contains invalid characters
    public static func fromHexEncodedString(_ hexString: String) -> BinaryData? {
        let chars = Array(hexString)
        guard chars.count % 2 == 0 else { return nil }
        
        var bytes: [UInt8] = []
        bytes.reserveCapacity(chars.count / 2)
        
        for i in stride(from: 0, to: chars.count, by: 2) {
            guard let high = hexValue(for: chars[i]),
                  let low = hexValue(for: chars[i + 1]) else {
                return nil
            }
            
            bytes.append(UInt8(high * 16 + low))
        }
        
        return BinaryData(bytes: bytes)
    }
    
    /// Helper function to convert a character to its hexadecimal value
    private static func hexValue(for char: Character) -> Int? {
        switch char {
        case "0"..."9": return Int(char.asciiValue! - Character("0").asciiValue!)
        case "a"..."f": return Int(char.asciiValue! - Character("a").asciiValue! + 10)
        case "A"..."F": return Int(char.asciiValue! - Character("A").asciiValue! + 10)
        default: return nil
        }
    }
}
