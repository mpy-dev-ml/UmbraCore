import CoreErrors
import CoreTypesInterfaces
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

/// Protocol defining Foundation-dependent XPC service interface.
/// This protocol is designed to work with the Objective-C runtime and NSXPCConnection.
extension SecurityBridge {
  /// A protocol that NSXPCConnection uses must inherit from NSObjectProtocol.
  /// We can't mark it as Sendable directly since it wouldn't be compatible with ObjC.
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
}

/// Adapter to convert between Core and Foundation XPC service protocols
extension SecurityBridge {
  public final class CoreTypesToFoundationBridgeAdapter: NSObject,
  XPCServiceProtocolFoundationBridge, @unchecked Sendable {
    public static var protocolIdentifier: String = "com.umbra.xpc.service.adapter.foundation.outgoing"

    private let coreService: any ComprehensiveSecurityServiceProtocol

    public init(wrapping coreService: any ComprehensiveSecurityServiceProtocol) {
      self.coreService = coreService
      super.init()
    }

    public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
      Task {
        let pingResult = await coreService.getServiceVersion()
        
        switch pingResult {
        case .success:
          reply(true, nil)
        case .failure(let error):
          reply(false, error as NSError)
        }
      }
    }

    public func synchroniseKeysFoundation(
      _ syncData: Data,
      withReply reply: @escaping @Sendable (Error?) -> Void
    ) {
      Task {
        // Convert Data to NSData for processing
        let nsData = syncData as NSData
        
        // Use the @objc compatible version that takes NSData
        let result = await coreService.synchroniseKeys(nsData)
        
        // Process the result
        if let error = result as? NSError {
          reply(error)
        } else {
          reply(nil)
        }
      }
    }

    public func generateRandomDataFoundation(
      _: Int,
      withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
      let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Method 'generateRandomData' not available in XPCServiceProtocolBasic"
      ])
      reply(nil, error)
    }

    public func resetSecurityDataFoundation(withReply reply: @escaping @Sendable (Error?) -> Void) {
      let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Method 'resetSecurityData' not available in XPCServiceProtocolBasic"
      ])
      reply(error)
    }

    public func getVersionFoundation(
      withReply reply: @escaping @Sendable (String?, Error?) -> Void
    ) {
      let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Method 'getVersion' not available in XPCServiceProtocolBasic"
      ])
      reply(nil, error)
    }

    public func getHostIdentifierFoundation(
      withReply reply: @escaping @Sendable (String?, Error?) -> Void
    ) {
      let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Method 'getHostIdentifier' not available in XPCServiceProtocolBasic"
      ])
      reply(nil, error)
    }

    public func encryptFoundation(
      data _: Data,
      withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
      let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Method 'encrypt' not available in XPCServiceProtocolBasic"
      ])
      reply(nil, error)
    }

    public func decryptFoundation(
      data _: Data,
      withReply reply: @escaping @Sendable (Data?, Error?) -> Void
    ) {
      let error = NSError(domain: "com.umbra.xpc.service", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Method 'decrypt' not available in XPCServiceProtocolBasic"
      ])
      reply(nil, error)
    }
  }

  public final class FoundationToCoreTypesBridgeAdapter: NSObject, XPCServiceProtocolBasic,
  @unchecked Sendable {
    public static var protocolIdentifier: String = "com.umbra.xpc.service.adapter.foundation.bridge"

    private let foundation: any XPCServiceProtocolFoundationBridge

    public init(wrapping foundation: any XPCServiceProtocolFoundationBridge) {
      self.foundation = foundation
      super.init()
    }

    @objc
    public func ping() async -> NSObject? {
      await withCheckedContinuation { continuation in
        foundation.pingFoundation { success, error in
          if let error {
            continuation.resume(returning: error as NSError)
          } else {
            continuation.resume(returning: NSNumber(value: success))
          }
        }
      }
    }
    
    // Swift-friendly ping that returns Result
    public func pingWithResult() async -> Result<Bool, XPCSecurityError> {
      let result = await ping()
      if let nsError = result as? NSError {
        return .failure(mapXPCError(nsError))
      } else if let nsNumber = result as? NSNumber {
        return .success(nsNumber.boolValue)
      } else {
        return .failure(CoreErrors.SecurityError.general("Unknown result type"))
      }
    }

    @objc
    public func synchroniseKeys(_ syncData: NSData) async -> NSObject? {
      // Convert NSData to Data
      let data = Data(referencing: syncData)
      
      return await withCheckedContinuation { continuation in
        foundation.synchroniseKeysFoundation(data) { error in
          if let error {
            continuation.resume(returning: error as NSError)
          } else {
            continuation.resume(returning: NSNull())
          }
        }
      }
    }
    
    // Swift-friendly SecureBytes version
    public func synchroniseKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
      // Convert SecureBytes to Data
      let data = XPCDataAdapter.data(from: syncData)
      // Convert Data to NSData for the @objc method
      let nsData = data as NSData
      
      let result = await synchroniseKeys(nsData)
      if let nsError = result as? NSError {
        return .failure(mapXPCError(nsError))
      } else {
        return .success(())
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
            let error = NSError(
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
    public func getVersion() async -> Result<String, XPCSecurityError> {
      let result = await getServiceVersion()
      if let nsError = result as? NSError {
        return .failure(mapXPCError(nsError))
      } else if let nsString = result as? NSString {
        return .success(nsString as String)
      } else {
        return .failure(CoreErrors.SecurityError.general("Invalid version format"))
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
            let error = NSError(
              domain: "XPCErrorDomain",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Host identifier not available"]
            )
            continuation.resume(returning: error)
          }
        }
      }
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
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
                    self.mapSecurityProtocolError(
                      SecurityProtocolError.implementationMissing("Random data generation failed")
                    )
                  )
                )
          }
        }
      }
    }

    // MARK: - Error Handling

    /// Maps any error to the XPCSecurityError domain
    ///
    /// This helper method provides a standardised way of handling errors throughout the XPC bridge.
    /// It delegates to the centralised mapper for consistent error handling across the codebase.
    ///
    /// - Parameter error: The error to map
    /// - Returns: A properly mapped XPCSecurityError
    private func mapXPCError(_ error: Error) -> XPCSecurityError {
      if let securityError = error as? XPCSecurityError {
        return securityError
      } else if let securityError = error as? SecurityProtocolsCore.SecurityError {
        // Convert from SecurityProtocolsCore.SecurityError to XPCSecurityError (CoreErrors.SecurityError)
        switch securityError {
        case .encryptionFailed:
          return CoreErrors.SecurityError.encryptionFailed
        case .decryptionFailed:
          return CoreErrors.SecurityError.decryptionFailed
        case .keyGenerationFailed:
          return CoreErrors.SecurityError.keyGenerationFailed
        case .invalidKey, .invalidInput:
          return CoreErrors.SecurityError.invalidData
        case .hashVerificationFailed, .randomGenerationFailed:
          return CoreErrors.SecurityError.hashingFailed
        case .storageOperationFailed:
          return CoreErrors.SecurityError.serviceFailed
        case .timeout, .serviceError:
          return CoreErrors.SecurityError.serviceFailed
        case .internalError:
          return CoreErrors.SecurityError.general(error.localizedDescription)
        case .notImplemented:
          return CoreErrors.SecurityError.notImplemented
        @unknown default:
          return CoreErrors.SecurityError.general(error.localizedDescription)
        }
      } else {
        // Map generic error to appropriate error
        return CoreErrors.SecurityError.general(error.localizedDescription)
      }
    }

    /// Maps a SecurityProtocolError to XPCSecurityError domain
    ///
    /// This helper method ensures consistent handling of protocol-specific errors.
    /// It delegates to the centralised mapper for consistent error handling.
    ///
    /// - Parameter error: The protocol error to map
    /// - Returns: A properly mapped XPCSecurityError
    private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
      CoreErrors.SecurityErrorMapper.mapToXPCError(error)
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
      let bufferPointer = bytes.bindMemory(to: UInt8.self)
      return SecureBytes(bytes: Array(bufferPointer))
    }
  }
}
