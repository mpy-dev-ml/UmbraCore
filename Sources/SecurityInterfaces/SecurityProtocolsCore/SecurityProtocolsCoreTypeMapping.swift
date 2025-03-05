// SecurityProtocolsCoreTypeMapping.swift
// IMPORTANT: This file only imports SecurityProtocolsCore to avoid type conflicts

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

// MARK: - Error Definitions

/// Errors that can occur during type mapping operations
public enum MappingError: Error, LocalizedError {
  /// Indicates that the operation name provided could not be mapped to a valid operation
  case unknownOperation(String)

  public var errorDescription: String? {
    switch self {
      case let .unknownOperation(name):
        "Unknown security operation: \(name)"
    }
  }
}

// MARK: - Operation Mapping

/// Maps a string operation identifier to a SecurityOperation
///
/// - Parameter operation: String identifier of the operation
/// - Returns: Corresponding SecurityOperation
/// - Throws: MappingError.unknownOperation if the operation cannot be mapped
public func mapToSecurityProtocolsCoreOperation(_ operation: String) throws -> SecurityOperation {
  // First try to directly map from the raw value
  if let mappedOperation=SecurityOperation(rawValue: operation) {
    return mappedOperation
  }

  // If that fails, provide custom mapping for any special cases
  switch operation {
    case "encrypt":
      return .symmetricEncryption
    case "decrypt":
      return .symmetricDecryption
    case "hash":
      return .hashing
    case "sign":
      return .signatureGeneration
    case "verify":
      return .signatureVerification
    default:
      // Throw an error for unknown operations instead of using a default value
      throw MappingError.unknownOperation(operation)
  }
}

// MARK: - Configuration Mapping

/// Creates a SecurityConfigDTO from a dictionary of parameters
///
/// - Parameter params: Dictionary of configuration parameters
/// - Returns: SecurityProtocolsCore configuration object
public func createSecurityProtocolsCoreConfig(from params: [String: Any]) -> SecurityConfigDTO {
  // Extract common parameters with sensible defaults
  let algorithm=params["algorithm"] as? String ?? "AES"
  let keySize=params["keySize"] as? Int ?? 256
  let keyId=params["keyId"] as? String

  // Handle optional data parameters
  var inputData: SecureBytes?
  if let data=params["data"] as? Data {
    inputData=SecureBytes([UInt8](data))
  } else if let string=params["data"] as? String {
    if let data=string.data(using: .utf8) {
      inputData=SecureBytes([UInt8](data))
    }
  }

  // Handle optional key data
  var key: SecureBytes?
  if let keyData=params["key"] as? Data {
    key=SecureBytes([UInt8](keyData))
  } else if let keyString=params["key"] as? String {
    if let keyData=Data(base64Encoded: keyString) {
      key=SecureBytes([UInt8](keyData))
    }
  }

  // Create options dictionary
  var options: [String: String]=[:]
  if let mode=params["mode"] as? String {
    options["mode"]=mode
  }
  if let padding=params["padding"] as? String {
    options["padding"]=padding
  }

  // Create the configuration
  return SecurityConfigDTO(
    algorithm: algorithm,
    keySizeInBits: keySize,
    initializationVector: nil,
    additionalAuthenticatedData: nil,
    iterations: params["iterations"] as? Int,
    options: options,
    keyIdentifier: keyId,
    inputData: inputData,
    key: key,
    additionalData: params["additionalData"] as? SecureBytes
  )
}

// MARK: - Result Mapping

/// Maps a SecurityResultDTO to a dictionary of results
///
/// - Parameter result: SecurityProtocolsCore result
/// - Returns: Dictionary representation of the result
public func mapSecurityProtocolsCoreResult(_ result: SecurityResultDTO) -> [String: Any] {
  var resultDict: [String: Any]=[
    "success": result.success
  ]

  // Add any error information
  if let error=result.error {
    resultDict["error"]=error.localizedDescription
  }

  // Add output data if available
  if let data=result.data {
    resultDict["data"]=data
  }

  // Convert SecureBytes to Base64 if available
  if let secureBytes=result.data {
    let data=Data(secureBytes.unsafeBytes)
    resultDict["secureData"]=data.base64EncodedString()
  }

  return resultDict
}
