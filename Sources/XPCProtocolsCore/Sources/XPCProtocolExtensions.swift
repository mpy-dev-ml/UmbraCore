/**
 # XPC Protocol Extensions
 
 This file contains extensions to the XPC protocol types that provide utility functions
 and shared implementations across protocol hierarchies. These extensions help ensure
 consistency across protocol implementations and reduce code duplication.
 
 ## Features
 
 * Protocol bridging utilities between different protocol levels
 * Data conversion helpers for working with different data representations
 * Common implementation patterns for protocol requirements
 * Extension methods for working with NSObject-based protocols
 
 These extensions are designed to simplify the implementation of XPC services
 by providing reusable functionality.
 */

import Foundation
import UmbraCoreTypes

/// Extension methods for easier implementation of XPC service protocols
public extension XPCServiceProtocolBasic {
  /// Convert UInt8 array to Data
  /// - Parameter bytes: Byte array to convert
  /// - Returns: Data object containing the bytes
  func convertBytesToData(_ bytes: [UInt8]) -> Data {
    Data(bytes)
  }
  
  /// Convert Data to UInt8 array
  /// - Parameter data: Data to convert
  /// - Returns: Array of bytes
  func convertDataToBytes(_ data: Data) -> [UInt8] {
    [UInt8](data)
  }
  
  /// Convert NSData to Data
  /// - Parameter nsData: NSData to convert
  /// - Returns: Swift Data equivalent
  func convertNSDataToData(_ nsData: NSData) -> Data {
    Data(referencing: nsData)
  }
  
  /// Convert Data to NSData
  /// - Parameter data: Data to convert
  /// - Returns: NSData equivalent
  func convertDataToNSData(_ data: Data) -> NSData {
    data as NSData
  }
  
  /// Convert SecureBytes to NSData for Objective-C interfaces
  /// - Parameter secureBytes: SecureBytes to convert
  /// - Returns: NSData representation
  func convertSecureBytesToNSData(_ secureBytes: SecureBytes) -> NSData {
    secureBytes.withUnsafeBytes { bytes in
      Data(bytes) as NSData
    }
  }
  
  /// Convert NSData to SecureBytes for secure storage
  /// - Parameter nsData: NSData to convert
  /// - Returns: SecureBytes representation
  func convertNSDataToSecureBytes(_ nsData: NSData) -> SecureBytes {
    SecureBytes(bytes: [UInt8](Data(referencing: nsData)))
  }
}

/// Extension methods for standardising error handling in XPC protocols
public extension XPCServiceProtocolStandard {
  /// Create an NSError with domain and code for XPC communication
  /// - Parameters:
  ///   - message: Error message
  ///   - code: Error code
  /// - Returns: Formatted NSError
  func createXPCError(message: String, code: Int) -> NSError {
    NSError(
      domain: "com.umbra.xpc.error",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }
  
  /// Convert a Result to an optional NSObject for Objective-C interfaces
  /// - Parameter result: Result to convert
  /// - Returns: NSObject or nil
  func convertResultToNSObject<T>(_ result: Result<T, Error>) -> NSObject? where T: NSObject {
    switch result {
    case let .success(value):
      return value
    case .failure:
      return nil
    }
  }
  
  /// Convert a Result<Bool, Error> to an optional NSNumber for Objective-C interfaces
  /// - Parameter result: Result to convert
  /// - Returns: NSNumber or nil
  func convertBoolResultToNSNumber(_ result: Result<Bool, Error>) -> NSNumber? {
    switch result {
    case let .success(value):
      return NSNumber(value: value)
    case .failure:
      return nil
    }
  }
}

/// Extension methods for bridging between complete and standard protocols
public extension XPCServiceProtocolComplete {
  /// Bridge encryptData from standard protocol to complete protocol
  /// - Parameters:
  ///   - data: NSData to encrypt
  ///   - keyIdentifier: Optional key identifier
  /// - Returns: Encrypted NSData or nil
  func encryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    let secureBytes = convertNSDataToSecureBytes(data)
    let result = await encrypt(data: secureBytes)
    
    switch result {
    case let .success(encryptedData):
      return convertSecureBytesToNSData(encryptedData)
    case .failure:
      return nil
    }
  }
  
  /// Bridge decryptData from standard protocol to complete protocol
  /// - Parameters:
  ///   - data: NSData to decrypt
  ///   - keyIdentifier: Optional key identifier
  /// - Returns: Decrypted NSData or nil
  func decryptData(_ data: NSData, keyIdentifier: String?) async -> NSObject? {
    let secureBytes = convertNSDataToSecureBytes(data)
    let result = await decrypt(data: secureBytes)
    
    switch result {
    case let .success(decryptedData):
      return convertSecureBytesToNSData(decryptedData)
    case .failure:
      return nil
    }
  }
  
  /// Bridge hashData from standard protocol to complete protocol
  /// - Parameter data: NSData to hash
  /// - Returns: Hash NSData or nil
  func hashData(_ data: NSData) async -> NSObject? {
    let secureBytes = convertNSDataToSecureBytes(data)
    let result = await hash(data: secureBytes)
    
    switch result {
    case let .success(hashData):
      return convertSecureBytesToNSData(hashData)
    case .failure:
      return nil
    }
  }
  
  /// Bridge getServiceStatus from standard protocol to complete protocol
  /// - Returns: Status dictionary or nil
  func getServiceStatus() async -> NSDictionary? {
    let result = await getStatus()
    
    switch result {
    case let .success(status):
      return [
        "status": status.rawValue,
        "protocolVersion": Self.protocolIdentifier
      ] as NSDictionary
    case .failure:
      return nil
    }
  }
}
