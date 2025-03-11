import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// FoundationConversions provides utilities for converting between Foundation types
/// and foundation-free types when communicating through XPC or with legacy systems.
public enum FoundationConversions {

  // MARK: - Dictionary Conversions

  /// Convert a dictionary of [String: SecureBytes] to [String: Data]
  ///
  /// - Parameter dictionary: Dictionary of strings to SecureBytes
  /// - Returns: Dictionary of strings to Data
  public static func toFoundation(dictionary: [String: UmbraCoreTypes.SecureBytes])
  -> [String: Data] {
    dictionary.mapValues { secureBytes -> Data in
      let bytes=Array(secureBytes)
      let nsData=NSData(bytes: bytes, length: bytes.count)
      return Data(referencing: nsData)
    }
  }

  /// Convert a dictionary of [String: Data] to [String: SecureBytes]
  ///
  /// - Parameter dictionary: Dictionary of strings to Data
  /// - Returns: Dictionary of strings to SecureBytes
  public static func fromFoundation(dictionary: [String: Data])
  -> [String: UmbraCoreTypes.SecureBytes] {
    dictionary.mapValues { data -> UmbraCoreTypes.SecureBytes in
      let bytes=[UInt8](data)
      return UmbraCoreTypes.SecureBytes(bytes: bytes)
    }
  }

  // MARK: - Array Conversions

  /// Convert an array of SecureBytes to an array of Data
  ///
  /// - Parameter array: Array of SecureBytes
  /// - Returns: Array of equivalent Data
  public static func toFoundation(array: [UmbraCoreTypes.SecureBytes]) -> [Data] {
    array.map { secureBytes -> Data in
      let bytes=Array(secureBytes)
      let nsData=NSData(bytes: bytes, length: bytes.count)
      return Data(referencing: nsData)
    }
  }

  /// Convert an array of Data to an array of SecureBytes
  ///
  /// - Parameter array: Array of Data
  /// - Returns: Array of equivalent UmbraCoreTypes.SecureBytes
  public static func fromFoundation(array: [Data]) -> [UmbraCoreTypes.SecureBytes] {
    array.map { data -> UmbraCoreTypes.SecureBytes in
      let bytes=[UInt8](data)
      return UmbraCoreTypes.SecureBytes(bytes: bytes)
    }
  }

  // MARK: - JSON Conversions

  /// Convert SecureBytes to JSON Data
  ///
  /// - Parameter secureBytes: SecureBytes to convert to JSON
  /// - Returns: Data representation of JSON
  /// - Throws: AdapterError if conversion fails
  public static func jsonData(from secureBytes: UmbraCoreTypes.SecureBytes) throws -> Data {
    let bytes=Array(secureBytes)
    let nsData=NSData(bytes: bytes, length: bytes.count)
    let data=Data(referencing: nsData)

    // Verify that the data is valid JSON
    do {
      _=try JSONSerialization.jsonObject(with: data)
      return data
    } catch {
      throw UmbraErrors.Security.Protocols
        .invalidFormat(reason: "Data is not valid JSON: \(error.localizedDescription)")
    }
  }

  /// Convert a JSON-serializable object to UmbraCoreTypes.SecureBytes
  ///
  /// - Parameter jsonObject: Any JSONSerialization-compatible object
  /// - Returns: UmbraCoreTypes.SecureBytes containing the UTF-8 encoded JSON
  /// - Throws: AdapterError if conversion fails
  public static func secureBytes(from object: Any) throws -> UmbraCoreTypes.SecureBytes {
    do {
      let data=try JSONSerialization.data(withJSONObject: object, options: [])
      let bytes=[UInt8](data)
      return UmbraCoreTypes.SecureBytes(bytes: bytes)
    } catch {
      throw UmbraErrors.Security.Protocols
        .invalidFormat(reason: "Could not convert object to JSON: \(error.localizedDescription)")
    }
  }
}
