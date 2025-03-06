// This file is now a re-export of SecureBytes from SecurityProtocolsCore
@_exported import SecurityProtocolsCore
import UmbraCoreTypes

// Define a typealias to support legacy code
public typealias BinaryData = SecureBytes

// Note: We don't need to extend SecureBytes with the same methods it already has.
// The slice method is the only one that needs to be added for backward compatibility.
extension SecureBytes {
  /// Get a slice of the data
  public func slice(from: Int, length: Int) -> SecureBytes {
    let end = Swift.min(from + length, count)
    return self[from..<end]
  }

  // The following methods are already provided by SecureBytes:
  // - subscript(index: Int)
  // - count property
}
