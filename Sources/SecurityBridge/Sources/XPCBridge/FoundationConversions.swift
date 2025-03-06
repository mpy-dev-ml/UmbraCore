import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// FoundationConversions provides utilities for converting between Foundation types
/// and foundation-free types when communicating through XPC or with legacy systems.
public enum FoundationConversions {

  // MARK: - Dictionary Conversions

  /// Convert a Dictionary with String keys and UmbraCoreTypes.SecureBytes values to a Dictionary
  /// with Data values
  /// - Parameter dictionary: Dictionary with UmbraCoreTypes.SecureBytes values
  /// - Returns: Dictionary with equivalent Data values
  public static func toFoundation(dictionary: [String: UmbraCoreTypes.SecureBytes])
  -> [String: Data] {
    dictionary.mapValues { DataAdapter.data(from: $0) }
  }

  /// Convert a Dictionary with String keys and Data values to a Dictionary with
  /// UmbraCoreTypes.SecureBytes values
  /// - Parameter dictionary: Dictionary with Data values
  /// - Returns: Dictionary with equivalent UmbraCoreTypes.SecureBytes values
  public static func fromFoundation(dictionary: [String: Data])
  -> [String: UmbraCoreTypes.SecureBytes] {
    dictionary.mapValues { DataAdapter.secureBytes(from: $0) }
  }

  // MARK: - Array Conversions

  /// Convert an Array of UmbraCoreTypes.SecureBytes to an Array of Data
  /// - Parameter array: Array of UmbraCoreTypes.SecureBytes
  /// - Returns: Array of equivalent Data
  public static func toFoundation(array: [UmbraCoreTypes.SecureBytes]) -> [Data] {
    array.map { DataAdapter.data(from: $0) }
  }

  /// Convert an Array of Data to an Array of UmbraCoreTypes.SecureBytes
  /// - Parameter array: Array of Data
  /// - Returns: Array of equivalent UmbraCoreTypes.SecureBytes
  public static func fromFoundation(array: [Data]) -> [UmbraCoreTypes.SecureBytes] {
    array.map { DataAdapter.secureBytes(from: $0) }
  }

  // MARK: - JSON Conversions

  /// Convert UmbraCoreTypes.SecureBytes to Data suitable for JSON processing
  /// - Parameter secureBytes: UmbraCoreTypes.SecureBytes to convert
  /// - Returns: A Foundation JSONSerialization-compatible Data object
  /// - Throws: AdapterError if conversion fails
  public static func jsonData(from secureBytes: UmbraCoreTypes.SecureBytes) throws -> Data {
    let data = DataAdapter.data(from: secureBytes)

    // Verify that the data is valid JSON
    do {
      _ = try JSONSerialization.jsonObject(with: data, options: [])
      return data
    } catch {
      throw AdapterError
        .invalidDataConversion("Data is not valid JSON: \(error.localizedDescription)")
    }
  }

  /// Convert a JSON-serializable object to UmbraCoreTypes.SecureBytes
  /// - Parameter jsonObject: Any JSONSerialization-compatible object
  /// - Returns: UmbraCoreTypes.SecureBytes containing the UTF-8 encoded JSON
  /// - Throws: AdapterError if conversion fails
  public static func secureBytes(from jsonObject: Any) throws -> UmbraCoreTypes.SecureBytes {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      return DataAdapter.secureBytes(from: data)
    } catch {
      throw AdapterError
        .invalidDataConversion("Could not convert object to JSON: \(error.localizedDescription)")
    }
  }
}
