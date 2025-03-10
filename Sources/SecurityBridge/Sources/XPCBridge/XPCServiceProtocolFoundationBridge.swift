import CoreErrors
import CoreTypesInterfaces
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol defining Foundation-dependent XPC security service.
/// This protocol is designed for use with Foundation-based security implementations.
@objc
public protocol FoundationXPCSecurityService: NSObjectProtocol, Sendable {
  // MARK: - Crypto Operations
  
  /// Encrypt data using XPC
  /// - Parameters:
  ///   - data: The data to encrypt
  ///   - completion: Completion handler called with encrypted data or error
  func encryptDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void)
  
  /// Decrypt data using XPC
  /// - Parameters:
  ///   - data: The data to decrypt
  ///   - completion: Completion handler called with decrypted data or error
  func decryptDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void)
  
  /// Generate random data using XPC
  /// - Parameters:
  ///   - length: Length of random data to generate
  ///   - completion: Completion handler called with generated data or error
  func generateRandomDataXPC(_ length: Int, completion: @escaping (Data?, NSNumber?, String?) -> Void)
  
  /// Hash data using XPC
  /// - Parameters:
  ///   - data: The data to hash
  ///   - completion: Completion handler called with hash data or error
  func hashDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void)
  
  /// Sign data using XPC
  /// - Parameters:
  ///   - data: The data to sign
  ///   - algorithm: The algorithm to use for signing
  ///   - completion: Completion handler called with signature or error
  func signDataXPC(_ data: Data, algorithm: String, completion: @escaping (Data?, NSNumber?, String?) -> Void)
  
  /// Verify data against signature using XPC
  /// - Parameters:
  ///   - data: The data to verify
  ///   - signature: The signature to verify against
  ///   - algorithm: The algorithm used for signing
  ///   - completion: Completion handler called with verification result
  func verifyDataXPC(_ data: Data, signature: Data, algorithm: String, completion: @escaping (NSNumber?, NSNumber?, String?) -> Void)
  
  // MARK: - Key Management
  
  /// Retrieve a key by ID using XPC
  /// - Parameters:
  ///   - identifier: The key identifier
  ///   - completion: Completion handler called with key data or error
  func retrieveKeyXPC(withIdentifier identifier: String, completion: @escaping (Data?, NSNumber?, String?) -> Void)
  
  /// Store a key with ID using XPC
  /// - Parameters:
  ///   - key: The key data to store
  ///   - identifier: The key identifier
  ///   - completion: Completion handler called with result
  func storeKeyXPC(_ key: Data, withIdentifier identifier: String, completion: @escaping (NSNumber?, String?) -> Void)
  
  /// List all key identifiers using XPC
  /// - Parameter completion: Completion handler called with list of identifiers or error
  func listKeyIdentifiers(completion: @escaping ([String]?, Error?) -> Void)
}

/// Protocol defining Foundation-dependent XPC service interface.
/// This protocol is designed to work with the Objective-C runtime and NSXPCConnection.
@objc
public protocol XPCServiceProtocolFoundationBridge: NSObjectProtocol {
  /// Protocol identifier - used for protocol negotiation
  static var protocolIdentifier: String { get }

  /// Test connectivity with a Foundation-based reply
  /// - Parameter reply: Reply block that is called with result and optional error
  func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void)

  /// Synchronize keys across processes with a Foundation-based reply
  /// - Parameters:
  ///   - syncData: The key data to synchronize
  ///   - reply: Reply block that is called when the operation completes
  func synchroniseKeysFoundation(
    _ syncData: Data,
    withReply reply: @escaping @Sendable (Error?) -> Void
  )

  /// Encrypt data using Foundation types
  /// - Parameters:
  ///   - data: Data to encrypt
  ///   - reply: Reply block with encrypted data and optional error
  func encryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)

  /// Decrypt data using Foundation types
  /// - Parameters:
  ///   - data: Data to decrypt
  ///   - reply: Reply block with decrypted data and optional error
  func decryptFoundation(data: Data, withReply reply: @escaping @Sendable (Data?, Error?) -> Void)

  /// Generate random data using Foundation types
  /// - Parameters:
  ///   - length: Length of random data to generate
  ///   - reply: Reply block with generated data and optional error
  func generateRandomDataFoundation(
    _ length: Int,
    withReply reply: @escaping @Sendable (Data?, Error?) -> Void
  )

  /// Reset security data with a Foundation-based reply
  /// - Parameter reply: Reply block that is called with optional error
  func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void)

  /// Get version with a Foundation-based reply
  /// - Parameter reply: Reply block that is called with version string and optional error
  func getVersionFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void)

  /// Get host identifier with a Foundation-based reply
  /// - Parameter reply: Reply block that is called with identifier string and optional error
  func getHostIdentifierFoundation(withReply reply: @escaping @Sendable (String?, Error?) -> Void)
}

/// Adapter to convert between Core and Foundation XPC service protocols
public final class CoreTypesToFoundationBridgeAdapter: NSObject,
XPCServiceProtocolFoundationBridge, @unchecked Sendable {
  public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.outgoing"

  private let coreService: any ComprehensiveSecurityServiceProtocol

  public init(wrapping coreService: any ComprehensiveSecurityServiceProtocol) {
    self.coreService=coreService
    super.init()
  }

  public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
    Task {
      // Check if the service is available by requesting a version
      let _ = await coreService.getServiceVersion()
      // If we got here without crashing, the service is available
      reply(true, nil)
    }
  }

  public func synchroniseKeysFoundation(
    _ syncData: Data,
    withReply reply: @escaping @Sendable (Error?) -> Void
  ) {
    Task {
      // Convert Data to NSData for processing
      let nsData=syncData as NSData
      
      // Extract bytes from NSData to conform to protocol
      let length = nsData.length
      var bytes = [UInt8](repeating: 0, count: length)
      nsData.getBytes(&bytes, length: length)

      // Use the @objc compatible version that takes NSData
      var errorToReturn: NSError? = nil
      coreService.synchroniseKeys(bytes) { error in
        errorToReturn = error
      }
      
      // Process the result
      reply(errorToReturn)
    }
  }

  public func generateRandomDataFoundation(
    _: Int,
    withReply reply: @escaping @Sendable (Data?, Error?) -> Void
  ) {
    let error=NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Method 'generateRandomData' not available in XPCServiceProtocolBasic"
    ])
    reply(nil, error)
  }

  public func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void) {
    let error=NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Method 'resetSecurityData' not available in XPCServiceProtocolBasic"
    ])
    reply(error)
  }

  public func getVersionFoundation(
    withReply reply: @escaping @Sendable (String?, Error?) -> Void
  ) {
    let error=NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Method 'getVersion' not available in XPCServiceProtocolBasic"
    ])
    reply(nil, error)
  }

  public func getHostIdentifierFoundation(
    withReply reply: @escaping @Sendable (String?, Error?) -> Void
  ) {
    let error=NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Method 'getHostIdentifier' not available in XPCServiceProtocolBasic"
    ])
    reply(nil, error)
  }

  public func encryptFoundation(
    data _: Data,
    withReply reply: @escaping @Sendable (Data?, Error?) -> Void
  ) {
    let error=NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Method 'encrypt' not available in XPCServiceProtocolBasic"
    ])
    reply(nil, error)
  }

  public func decryptFoundation(
    data _: Data,
    withReply reply: @escaping @Sendable (Data?, Error?) -> Void
  ) {
    let error=NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
      NSLocalizedDescriptionKey: "Method 'decrypt' not available in XPCServiceProtocolBasic"
    ])
    reply(nil, error)
  }
}

public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
@unchecked Sendable {
  public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

  private let foundation: any XPCServiceProtocolFoundationBridge

  public init(wrapping foundation: any XPCServiceProtocolFoundationBridge) {
    self.foundation=foundation
    super.init()
  }

  @objc
  public func ping() async -> Bool {
    await withCheckedContinuation { continuation in
      foundation.pingFoundation { success, error in
        continuation.resume(returning: success)
      }
    }
  }
  
  @objc
  public func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
    // Convert [UInt8] to Data
    let data = Data(bytes)
    
    foundation.synchroniseKeysFoundation(data) { error in
      completionHandler(error as NSError?)
    }
  }

  // Swift-friendly ping that returns Result
  public func pingWithResult() async -> Result<Bool, XPCProtocolsCore.SecurityError> {
    let success = await ping()
    return .success(success)
  }

  // Swift-friendly SecureBytes version
  public func synchroniseKeys(_ syncData: SecureBytes) async -> Result<Void, XPCProtocolsCore.SecurityError> {
    return await withCheckedContinuation { continuation in
      // Convert SecureBytes to [UInt8]
      let bytes = [UInt8](syncData)
      
      synchroniseKeys(bytes) { error in
        if let error = error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
        } else {
          continuation.resume(returning: .success(()))
        }
      }
    }
  }

  @objc
  public func resetSecurityData() async -> NSObject? {
    await withCheckedContinuation { continuation in
      foundation.resetSecurityDataFoundation { error in
        if let error {
          continuation.resume(returning: error as NSError)
        } else {
          continuation.resume(returning: NSNull())
        }
      }
    }
  }

  @objc
  public func getServiceVersion() async -> NSObject? {
    await withCheckedContinuation { continuation in
      foundation.getVersionFoundation { versionString, error in
        if let error {
          continuation.resume(returning: error as NSError)
        } else if let versionString {
          continuation.resume(returning: versionString as NSString)
        } else {
          let error=NSError(
            domain: "XPCErrorDomain",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Version not available"]
          )
          continuation.resume(returning: error)
        }
      }
    }
  }

  // Swift-friendly version with Result type
  public func getVersion() async -> Result<String, XPCProtocolsCore.SecurityError> {
    let result=await getServiceVersion()
    if let nsError=result as? NSError {
      return .failure(mapXPCError(nsError))
    } else if let nsString=result as? NSString {
      return .success(nsString as String)
    } else {
      return .failure(XPCProtocolsCore.SecurityError.internalError(reason: "Invalid version format"))
    }
  }

  @objc
  public func getHostIdentifier() async -> NSObject? {
    await withCheckedContinuation { continuation in
      foundation.getHostIdentifierFoundation { hostIdentifier, error in
        if let error {
          continuation.resume(returning: error as NSError)
        } else if let hostIdentifier {
          continuation.resume(returning: hostIdentifier as NSString)
        } else {
          let error=NSError(
            domain: "XPCErrorDomain",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Host identifier not available"]
          )
          continuation.resume(returning: error)
        }
      }
    }
  }

  public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCProtocolsCore.SecurityError> {
    await withCheckedContinuation { continuation in
      self.foundation.generateRandomDataFoundation(length) { data, error in
        if let error {
          continuation.resume(returning: .failure(self.mapXPCError(error)))
        } else if let data {
          continuation.resume(returning: .success(XPCDataAdapter.secureBytes(from: data)))
        } else {
          continuation
            .resume(
              returning: .failure(
                XPCProtocolsCore.SecurityError.internalError(reason: "Random data generation failed")
              )
            )
        }
      }
    }
  }

  // MARK: - Error Handling

  /// Maps any error to the XPCProtocolsCore.SecurityError domain
  ///
  /// This helper method provides a standardised way of handling errors throughout the XPC bridge.
  /// It delegates to the centralised mapper for consistent error handling across the codebase.
  ///
  /// - Parameter error: The error to map
  /// - Returns: A properly mapped XPCProtocolsCore.SecurityError
  private func mapXPCError(_ error: Error) -> XPCProtocolsCore.SecurityError {
    if let securityError = error as? XPCProtocolsCore.SecurityError {
      return securityError
    } else if let securityError = error as? UmbraErrors.Security.Protocols {
      // Convert from UmbraErrors.Security.Protocols to XPCProtocolsCore.SecurityError
      switch securityError {
        case .encryptionFailed:
          return .cryptographicError(operation: "encryption", details: "Encryption operation failed")
        case .decryptionFailed:
          return .cryptographicError(operation: "decryption", details: "Decryption operation failed")
        case .internalError(let message):
          return .internalError(reason: message)
        case .invalidFormat, .invalidInput:
          return .invalidInput(details: "Invalid data format or input")
        case .missingProtocolImplementation, .unsupportedOperation, .notImplemented:
          return .operationNotSupported(name: "The requested operation")
        case .incompatibleVersion, .invalidState, .randomGenerationFailed, .serviceError, .storageOperationFailed:
          return .serviceNotReady(reason: "Service is not in correct state")
        @unknown default:
          return .internalError(reason: error.localizedDescription)
      }
    } else if let xpcSecurityError = error as? XPCSecurityError {
      switch xpcSecurityError {
        case .serviceUnavailable:
          return .serviceUnavailable
        case .connectionInterrupted:
          return .serviceNotReady(reason: "Connection interrupted")
        case .connectionInvalidated(let reason):
          return .serviceNotReady(reason: "Connection invalidated: \(reason)")
        case .invalidState(let details):
          return .serviceNotReady(reason: "Invalid state: \(details)")
        case .invalidKeyType(let expected, let received):
          return .invalidInput(details: "Expected key type \(expected), received \(received)")
        case .keyNotFound(let identifier):
          return .invalidInput(details: "Key not found: \(identifier)")
        case .cryptographicError(let operation, let details):
          return .invalidInput(details: "Cryptographic operation failed: \(operation) - \(details)")
        case .internalError(let reason):
          return .internalError(reason: reason)
        case .operationNotSupported(let name):
          return .operationNotSupported(name: name)
        case .invalidInput(let details):
          return .invalidInput(details: details)
        case .serviceNotReady(let reason):
          return .serviceNotReady(reason: reason)
        case .timeout(let after):
          return .timeout(after: after)
        case .authenticationFailed(let reason):
          return .authenticationFailed(reason: reason)
        case .authorizationDenied(let operation):
          return .authorizationDenied(operation: operation)
        @unknown default:
          return .internalError(reason: "Unknown XPC security error")
      }
    } else {
      // Map generic error to appropriate error
      return .internalError(reason: error.localizedDescription)
    }
  }

  /// Maps a SecurityProtocolError to XPCProtocolsCore.SecurityError domain
  ///
  /// This helper method ensures consistent handling of protocol-specific errors.
  /// It delegates to the centralised mapper for consistent error handling.
  ///
  /// - Parameter error: The protocol error to map
  /// - Returns: A properly mapped XPCProtocolsCore.SecurityError
  private func mapSecurityProtocolError(_ error: Error) -> XPCProtocolsCore.SecurityError {
    // If SecurityProtocolError is unavailable, we use a general mapping approach
    if let xpcError = error as? XPCProtocolsCore.SecurityError {
      return xpcError
    } else {
      return .internalError(reason: error.localizedDescription)
    }
  }
}

// Helper adapter to convert between SecureBytes and Data for XPC
private enum XPCDataAdapter {
  static func data(from secureBytes: SecureBytes) -> Data {
    // Use available properties from SecureBytes
    secureBytes.withUnsafeBytes { Data($0) }
  }

  static func secureBytes(from data: Data) -> SecureBytes {
    data.withUnsafeBytes { bytes -> SecureBytes in
      let bufferPointer=bytes.bindMemory(to: UInt8.self)
      return SecureBytes(bytes: Array(bufferPointer))
    }
  }
}
