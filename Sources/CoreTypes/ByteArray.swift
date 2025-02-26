// Foundation-free byte array representation
// Used to avoid Foundation dependencies in base protocols

/// A simple Foundation-free representation of a byte array
public struct ByteArray: Sendable, Equatable, Hashable {
    /// The raw bytes
    private let bytes: [UInt8]

    /// Initialize with raw bytes
    /// - Parameter bytes: Array of bytes
    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    /// Access the raw bytes
    public var rawBytes: [UInt8] {
        return bytes
    }

    /// The number of bytes in the array
    public var count: Int {
        return bytes.count
    }

    /// Creates a ByteArray from a slice of another ByteArray
    public init(slice: ArraySlice<UInt8>) {
        self.bytes = Array(slice)
    }

    /// Implement Equatable
    public static func == (lhs: ByteArray, rhs: ByteArray) -> Bool {
        return lhs.bytes == rhs.bytes
    }

    /// Implement Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bytes)
    }
}
