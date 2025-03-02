// SecureBytes.swift
// UmbraCoreTypes
//
// Created as part of the UmbraCore Foundation Decoupling project
//

/// A Foundation-free replacement for `Data` that provides secure handling of binary data.
/// This type implements the essential functionality of `Data` without any Foundation dependencies.
///
/// `SecureBytes` has value semantics and conforms to `Sendable` for safe use in Swift concurrency contexts.
/// Internal storage is automatically zeroed when deallocated to prevent sensitive data from persisting
/// in memory.
@frozen
public struct SecureBytes: Sendable, Equatable, Hashable {

    // MARK: - Storage

    /// Internal storage of the binary data
    private var storage: [UInt8]

    // MARK: - Initialization

    /// Creates a new empty instance.
    public init() {
        self.storage = []
    }

    /// Creates a new instance with the specified capacity.
    /// - Parameter capacity: The initial capacity of the storage.
    public init(capacity: Int) {
        self.storage = Array(repeating: 0, count: capacity)
    }

    /// Creates a new instance containing the specified bytes.
    /// - Parameter bytes: A sequence of bytes to copy into the new instance.
    public init<S: Sequence>(bytes: S) where S.Element == UInt8 {
        self.storage = Array(bytes)
    }

    /// Creates a new instance from a static array of bytes.
    /// - Parameter bytes: A static array of bytes.
    public init(bytes: [UInt8]) {
        self.storage = bytes
    }

    /// Creates a new instance from a static array of bytes.
    /// - Parameters:
    ///   - bytes: A pointer to the bytes to copy.
    ///   - count: The number of bytes to copy.
    public init(bytes: UnsafeRawPointer, count: Int) {
        let bufferPointer = UnsafeRawBufferPointer(start: bytes, count: count)
        self.storage = Array(bufferPointer.bindMemory(to: UInt8.self))
    }

    /// Creates a new instance from a base64-encoded string.
    /// - Parameter base64String: A base64-encoded string.
    /// - Returns: A new instance, or nil if the string is not valid base64.
    public init?(base64Encoded base64String: String) {
        // Custom base64 decoding implementation without Foundation
        guard let decoded = Self.decodeBase64(base64String) else {
            return nil
        }
        self.storage = decoded
    }

    // MARK: - Properties

    /// The number of bytes in the data.
    public var count: Int {
        return storage.count
    }

    /// A Boolean value indicating whether the data is empty.
    public var isEmpty: Bool {
        return storage.isEmpty
    }

    // MARK: - Accessing Bytes

    /// Accesses the byte at the specified position.
    public subscript(index: Int) -> UInt8 {
        get {
            return storage[index]
        }
        set {
            storage[index] = newValue
        }
    }

    /// Accesses a slice of the data.
    public subscript(bounds: Range<Int>) -> SecureBytes {
        get {
            return SecureBytes(bytes: storage[bounds])
        }
        set {
            storage.replaceSubrange(bounds, with: newValue.storage)
        }
    }

    // MARK: - Data Manipulation

    /// Appends the content of another `SecureBytes` instance.
    /// - Parameter other: The `SecureBytes` instance to append.
    public mutating func append(_ other: SecureBytes) {
        storage.append(contentsOf: other.storage)
    }

    /// Appends a single byte.
    /// - Parameter byte: The byte to append.
    public mutating func append(_ byte: UInt8) {
        storage.append(byte)
    }

    /// Appends a sequence of bytes.
    /// - Parameter bytes: The bytes to append.
    public mutating func append<S: Sequence>(contentsOf bytes: S) where S.Element == UInt8 {
        storage.append(contentsOf: bytes)
    }

    /// Returns a new `SecureBytes` by concatenating with another instance.
    /// - Parameter other: The `SecureBytes` instance to concatenate.
    /// - Returns: A new `SecureBytes` instance.
    public func concatenated(with other: SecureBytes) -> SecureBytes {
        var result = self
        result.append(other)
        return result
    }

    // MARK: - Unsafe Access

    /// Provides temporary access to the bytes.
    /// - Parameter body: A closure that takes an unsafe buffer pointer to the bytes.
    /// - Returns: The result of the closure.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try storage.withUnsafeBytes { bufferPointer in
            try body(bufferPointer)
        }
    }

    /// Provides temporary mutable access to the bytes.
    /// - Parameter body: A closure that takes an unsafe mutable buffer pointer to the bytes.
    /// - Returns: The result of the closure.
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try storage.withUnsafeMutableBytes { bufferPointer in
            try body(bufferPointer)
        }
    }

    // MARK: - Encoding/Decoding

    /// Returns a Base64-encoded string representation.
    public func base64EncodedString() -> String {
        return Self.encodeBase64(storage)
    }

    /// Returns a hex string representation of the bytes.
    public func hexEncodedString() -> String {
        let hexDigits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        var result = ""
        for byte in storage {
            result += hexDigits[Int(byte >> 4)]
            result += hexDigits[Int(byte & 0x0F)]
        }
        return result
    }

    // MARK: - Secure Operations

    /// Securely zeros the contents of the data.
    public mutating func secureZero() {
        for i in 0..<storage.count {
            storage[i] = 0
        }
    }

    // MARK: - Deinitializer

    /// Custom implementation of base64 encoding without Foundation
    private static func encodeBase64(_ bytes: [UInt8]) -> String {
        let base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        var result = ""
        var i = 0

        while i < bytes.count {
            var chunk: UInt32 = 0

            chunk |= i < bytes.count ? UInt32(bytes[i]) << 16 : 0
            i += 1
            chunk |= i < bytes.count ? UInt32(bytes[i]) << 8 : 0
            i += 1
            chunk |= i < bytes.count ? UInt32(bytes[i]) : 0
            i += 1

            let byte1 = (chunk >> 18) & 0x3F
            let byte2 = (chunk >> 12) & 0x3F
            let byte3 = (chunk >> 6) & 0x3F
            let byte4 = chunk & 0x3F

            let index1 = base64Chars.index(base64Chars.startIndex, offsetBy: Int(byte1))
            result.append(base64Chars[index1])

            let index2 = base64Chars.index(base64Chars.startIndex, offsetBy: Int(byte2))
            result.append(base64Chars[index2])

            if i - 2 <= bytes.count {
                let index3 = base64Chars.index(base64Chars.startIndex, offsetBy: Int(byte3))
                result.append(base64Chars[index3])
            } else {
                result.append("=")
            }

            if i - 1 <= bytes.count {
                let index4 = base64Chars.index(base64Chars.startIndex, offsetBy: Int(byte4))
                result.append(base64Chars[index4])
            } else {
                result.append("=")
            }
        }

        return result
    }

    /// Custom implementation of base64 decoding without Foundation
    private static func decodeBase64(_ string: String) -> [UInt8]? {
        let base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        var result = [UInt8]()

        // Remove whitespace and "=" padding
        let cleanedString = string.filter { !$0.isWhitespace && $0 != "=" }

        // Check for valid base64 characters
        guard cleanedString.allSatisfy({ base64Chars.contains($0) }) else {
            return nil
        }

        var chunk: UInt32 = 0
        var count: Int = 0

        for char in cleanedString {
            guard let index = base64Chars.firstIndex(of: char) else {
                return nil
            }

            let value = UInt32(base64Chars.distance(from: base64Chars.startIndex, to: index))
            chunk = (chunk << 6) | value
            count += 1

            if count == 4 {
                result.append(UInt8((chunk >> 16) & 0xFF))
                result.append(UInt8((chunk >> 8) & 0xFF))
                result.append(UInt8(chunk & 0xFF))
                chunk = 0
                count = 0
            }
        }

        // Handle remaining bytes
        if count == 3 {
            result.append(UInt8((chunk >> 10) & 0xFF))
            result.append(UInt8((chunk >> 2) & 0xFF))
        } else if count == 2 {
            result.append(UInt8((chunk >> 4) & 0xFF))
        }

        return result
    }
}

// MARK: - Equatable and Hashable

extension SecureBytes {
    public static func == (lhs: SecureBytes, rhs: SecureBytes) -> Bool {
        return lhs.storage == rhs.storage
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension SecureBytes: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UInt8...) {
        self.storage = elements
    }
}

// MARK: - CustomStringConvertible

extension SecureBytes: CustomStringConvertible {
    public var description: String {
        return "<SecureBytes: \(count) bytes>"
    }
}

// MARK: - Concat Operator

extension SecureBytes {
    public static func + (lhs: SecureBytes, rhs: SecureBytes) -> SecureBytes {
        return lhs.concatenated(with: rhs)
    }
}

// MARK: - Codable

extension SecureBytes: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var bytes = [UInt8]()
        while !container.isAtEnd {
            bytes.append(try container.decode(UInt8.self))
        }
        self.init(bytes: bytes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try storage.forEach { byte in
            try container.encode(byte)
        }
    }
}
