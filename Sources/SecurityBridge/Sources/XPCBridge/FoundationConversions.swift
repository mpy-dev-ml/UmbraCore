// FoundationConversions.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
// We need UmbraCoreTypes for SecureBytes
import SecurityProtocolsCore
import UmbraCoreTypes

/// FoundationConversions provides utilities for converting between Foundation types
/// and foundation-free types when communicating through XPC or with legacy systems.
public enum FoundationConversions {

    // MARK: - Dictionary Conversions

    /// Convert a dictionary of SecureBytes values to a dictionary of Foundation Data values
    /// - Parameter dictionary: Dictionary with SecureBytes values
    /// - Returns: Dictionary with equivalent Data values
    public static func toFoundation(dictionary: [String: UmbraCoreTypes.SecureBytes]) -> [String: Data] {
        return dictionary.mapValues { DataAdapter.data(from: $0) }
    }

    /// Convert a dictionary of Foundation Data values to a dictionary of SecureBytes values
    /// - Parameter dictionary: Dictionary with Data values
    /// - Returns: Dictionary with equivalent SecureBytes values
    public static func fromFoundation(dictionary: [String: Data]) -> [String: UmbraCoreTypes.SecureBytes] {
        return dictionary.mapValues { DataAdapter.secureBytes(from: $0) }
    }

    // MARK: - Array Conversions

    /// Convert an Array of SecureBytes to an Array of Data
    /// - Parameter array: Array of SecureBytes
    /// - Returns: Array of equivalent Data
    public static func toFoundation(array: [UmbraCoreTypes.SecureBytes]) -> [Data] {
        return array.map { DataAdapter.data(from: $0) }
    }

    /// Convert an Array of Data to an Array of SecureBytes
    /// - Parameter array: Array of Data
    /// - Returns: Array of equivalent SecureBytes
    public static func fromFoundation(array: [Data]) -> [UmbraCoreTypes.SecureBytes] {
        return array.map { DataAdapter.secureBytes(from: $0) }
    }

    // MARK: - JSON Conversions

    /// Convert JSON data in SecureBytes format back to a Foundation JSON object
    /// - Parameter secureBytes: SecureBytes containing JSON data
    /// - Returns: Foundation-compatible JSON object
    /// - Throws: AdapterError if JSON conversion fails
    public static func jsonData(from secureBytes: UmbraCoreTypes.SecureBytes) throws -> Data {
        let data = DataAdapter.data(from: secureBytes)

        // Verify that the data is valid JSON
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return data
        } catch {
            throw AdapterError.invalidDataConversion("Not valid JSON data: \(error.localizedDescription)")
        }
    }

    /// Convert JSON data in SecureBytes format back to a Foundation JSON object
    /// - Parameter secureBytes: SecureBytes containing JSON data
    /// - Returns: Foundation-compatible JSON object
    /// - Throws: AdapterError if JSON conversion fails
    public static func jsonObject(from secureBytes: UmbraCoreTypes.SecureBytes) throws -> Any {
        let data = try jsonData(from: secureBytes)

        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            throw AdapterError.invalidDataConversion("JSON deserialization failed: \(error.localizedDescription)")
        }
    }

    /// Convert a Foundation JSON object to SecureBytes containing JSON data
    /// - Parameter jsonObject: Foundation JSON object
    /// - Returns: SecureBytes containing the JSON data
    /// - Throws: AdapterError if the conversion fails
    public static func secureBytes(from jsonObject: Any) throws -> UmbraCoreTypes.SecureBytes {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            return DataAdapter.secureBytes(from: data)
        } catch {
            throw AdapterError.invalidDataConversion("Could not convert object to JSON: \(error.localizedDescription)")
        }
    }
}
