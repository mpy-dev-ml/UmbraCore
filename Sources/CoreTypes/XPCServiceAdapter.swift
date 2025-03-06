// Foundation-free adapter for XPC services
// Provides a bridge between Foundation-dependent and Foundation-free implementations
import CoreErrors
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// Use our isolation files instead of direct imports
// This prevents namespace conflicts with enum types that share module names
public typealias SecureBytes=UmbraCoreTypes.SecureBytes
public typealias SecureValue=UmbraCoreTypes.SecureValue
public typealias XPCSecurityError=CoreErrors.SecurityError

/// Protocol for Foundation-based XPC service implementations
/// This is implemented by the concrete service classes
public protocol FoundationBasedXPCService {
  func processRequest(_ requestData: Data) async -> Result<Data, Error>
  func callSecureFunction(_ name: String, parameters: [String: Any]) async
    -> Result<[String: Any], Error>
  func validateCredential(_ credential: Data) async -> Result<Bool, Error>
  func getSystemInfo() async -> Result<[String: String], Error>
}

/// XPC Service adapter that wraps XPC communication with type safety
public final class XPCServiceAdapter: XPCServiceProtocolStandard {
  private let service: any FoundationBasedXPCService

  /// Create a new adapter wrapping a Foundation-based service implementation
  public init(wrapping service: any FoundationBasedXPCService) {
    self.service=service
  }

  /// Convert an NSDictionary to a secure dictionary format
  /// - Parameter dict: Original NSDictionary from XPC
  /// - Returns: Dictionary with SecureValue values
  private func convertToSecureDict(_ dict: NSDictionary) -> [String: SecureValue] {
    var secureDict=[String: SecureValue]()

    for (key, value) in dict {
      guard let key=key as? String else { continue }

      if let stringValue=value as? String {
        secureDict[key] = .string(stringValue)
      } else if let intValue=value as? Int {
        secureDict[key] = .integer(intValue)
      } else if let boolValue=value as? Bool {
        secureDict[key] = .boolean(boolValue)
      } else if let dataValue=value as? Data {
        secureDict[key] = .data(SecureBytes(data: dataValue))
      } else if value is NSNull {
        secureDict[key] = .null
      }
      // Array and dictionary cases would need more conversion
    }

    return secureDict
  }

  /// Map from any error to XPCSecurityError
  private func mapError(_ error: Error) -> XPCSecurityError {
    // If we already have a SecurityError, return it
    if let securityError=error as? XPCSecurityError {
      return securityError
    }

    // Handle SecurityProtocolsCore's SecurityError types
    if let securityError=error as? SPCoreSecurityError {
      switch securityError {
        case .encryptionFailed:
          return .encryptionError(reason: "Encryption failed")
        case .decryptionFailed:
          return .decryptionError(reason: "Decryption failed")
        case .keyGenerationFailed:
          return .keyGenerationError(reason: "Key generation failed")
        case .hashVerificationFailed:
          return .hashingError(reason: "Hash verification failed")
        case .randomGenerationFailed:
          return .cryptoError(reason: "Crypto operation failed")
        case .invalidInput:
          return .invalidData(reason: "Invalid data")
        case .storageError:
          return .storageError(reason: "Storage operation failed")
        case .serviceNotAvailable:
          return .serviceUnavailable(reason: "Service not available")
        case .operationNotSupported:
          return .notImplemented(reason: "Operation not supported")
        // Handle other specific cases
        default:
          return .unknownError(reason: "Unknown error")
      }
    }

    // Handle general Error types
    let nsError=error as NSError
    switch nsError.domain {
      case NSURLErrorDomain:
        return .networkError(reason: "Network error")
      case "CoreCryptoErrorDomain":
        return .cryptoError(reason: "Crypto operation failed")
      case "CoreSecurityErrorDomain":
        return .securityError(reason: "Security error")
      default:
        return .unknownError(reason: "Unknown error")
    }
  }

  // MARK: - XPCServiceProtocolStandard Implementation

  public func processRequest(_ requestData: SecureBytes) async
  -> Result<SecureBytes, XPCSecurityError> {
    let dataResult=await service.processRequest(Data(requestData.bytes))

    switch dataResult {
      case let .success(responseData):
        return .success(SecureBytes(bytes: [UInt8](responseData)))
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func callSecureFunction(
    _ name: String,
    parameters: [String: SecureValue]
  ) async -> Result<[String: SecureValue], XPCSecurityError> {
    // Convert SecureValue dictionary to [String: Any]
    var jsonParameters: [String: Any]=[:]

    for (key, value) in parameters {
      switch value {
        case let .string(stringValue):
          jsonParameters[key]=stringValue
        case let .number(numberValue):
          jsonParameters[key]=numberValue
        case let .boolean(boolValue):
          jsonParameters[key]=boolValue
        case let .data(bytes):
          jsonParameters[key]=Data(bytes.bytes)
        case .null:
          jsonParameters[key]=NSNull()
        case let .array(array):
          // Simplified - would need recursive conversion in practice
          jsonParameters[key]=array
        case let .dictionary(dict):
          // Simplified - would need recursive conversion in practice
          jsonParameters[key]=dict
      }
    }

    let result=await service.callSecureFunction(name, parameters: jsonParameters)

    switch result {
      case let .success(resultDict):
        // Convert back to SecureValue dictionary
        var secureDict: [String: SecureValue]=[:]

        for (key, value) in resultDict {
          if let stringValue=value as? String {
            secureDict[key] = .string(stringValue)
          } else if let numberValue=value as? Double {
            secureDict[key] = .number(numberValue)
          } else if let boolValue=value as? Bool {
            secureDict[key] = .boolean(boolValue)
          } else if let dataValue=value as? Data {
            secureDict[key] = .data(SecureBytes(bytes: [UInt8](dataValue)))
          } else if value is NSNull {
            secureDict[key] = .null
          }
          // Array and dictionary cases would need more conversion
        }

        return .success(secureDict)
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func validateCredential(_ credential: SecureBytes) async
  -> Result<Bool, XPCSecurityError> {
    let result=await service.validateCredential(Data(credential.bytes))

    switch result {
      case let .success(isValid):
        return .success(isValid)
      case let .failure(error):
        return .failure(mapError(error))
    }
  }

  public func getSystemInfo() async -> Result<[String: String], XPCSecurityError> {
    let result=await service.getSystemInfo()

    switch result {
      case let .success(info):
        return .success(info)
      case let .failure(error):
        return .failure(mapError(error))
    }
  }
}
