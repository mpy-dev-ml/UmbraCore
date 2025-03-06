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
    bytes
  }

  /// The number of bytes in the array
  public var count: Int {
    bytes.count
  }

  /// Creates a ByteArray from a slice of another ByteArray
  public init(slice: ArraySlice<UInt8>) {
    bytes = Array(slice)
  }

  /// Implement Equatable
  public static func == (lhs: ByteArray, rhs: ByteArray) -> Bool {
    lhs.bytes == rhs.bytes
  }

  /// Implement Hashable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(bytes)
  }
}
