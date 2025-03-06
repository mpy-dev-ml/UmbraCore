import CoreTypes

/// Protocol that defines the minimal interface needed for Foundation.Data operations
/// This allows us to break circular dependencies between Foundation and other modules
public protocol DataBridgeProtocol {
  /// Get the bytes representation of the data
  var bytes: [UInt8] { get }

  /// Initialize with bytes
  init(_ bytes: [UInt8])

  /// Get the length of the data
  var count: Int { get }

  /// Get a subset of the data
  func subdata(in range: Range<Int>) -> Self
}

/// Type-erased wrapper for Foundation.Data
/// This allows modules to reference data without directly depending on Foundation
public struct DataBridge: Sendable {
  /// The underlying bytes
  public let bytes: [UInt8]

  /// Initialize with bytes
  public init(_ bytes: [UInt8]) {
    self.bytes = bytes
  }

  /// Initialize with BinaryData (SecureBytes)
  public init(_ binaryData: CoreTypes.BinaryData) {
    var tempBytes = [UInt8]()
    binaryData.withUnsafeBytes { buffer in
      tempBytes = Array(buffer)
    }
    bytes = tempBytes
  }

  /// Convert to BinaryData (SecureBytes)
  public func toBinaryData() -> CoreTypes.BinaryData {
    CoreTypes.BinaryData(bytes: bytes)
  }
}

/// Extension to provide additional functionality
extension DataBridge {
  /// Get the length of the data
  public var count: Int {
    bytes.count
  }

  /// Get a subset of the data
  public func subdata(in range: Range<Int>) -> DataBridge {
    let subBytes = Array(bytes[range])
    return DataBridge(subBytes)
  }
}
