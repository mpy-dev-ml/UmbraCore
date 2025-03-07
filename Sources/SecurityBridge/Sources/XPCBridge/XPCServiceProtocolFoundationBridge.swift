import CoreTypesInterfaces
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore
import CoreErrors

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
    public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.coretypes.bridge"

    private let coreService: any XPCServiceProtocolBasic

    public init(wrapping coreService: any XPCServiceProtocolBasic) {
      self.coreService=coreService
      super.init()
    }

    public func pingFoundation(withReply reply: @escaping @Sendable (Bool, Error?) -> Void) {
      Task {
        do {
          // Handle Result type properly
          let result=await coreService.ping()
          switch result {
            case let .success(value):
              reply(value, nil)
            case let .failure(error):
              reply(false, error)
          }
        } catch {
          reply(false, error)
        }
      }
    }

    public func synchroniseKeysFoundation(
      _ syncData: Data,
      withReply reply: @escaping @Sendable (Error?) -> Void
    ) {
      Task {
        // Convert from Foundation Data to SecureBytes
        let bytes=[UInt8](syncData)
        let secureBytes=SecureBytes(bytes: bytes)

        let result=await coreService.synchroniseKeys(secureBytes)
        switch result {
          case .success:
            reply(nil)
          case let .failure(error):
            reply(error)
        }
      }
    }

    // The basic protocol doesn't have these methods, so we'll return appropriate errors

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

  public final class FoundationToCoreTypesBridgeAdapter: XPCServiceProtocolBasic,
  @unchecked Sendable {
    public static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

    private let foundation: any XPCServiceProtocolFoundationBridge

    public init(wrapping foundation: any XPCServiceProtocolFoundationBridge) {
      self.foundation=foundation
    }

    public func ping() async -> Result<Bool, XPCSecurityError> {
      await withCheckedContinuation { continuation in
        foundation.pingFoundation { success, error in
          if let error {
            continuation.resume(returning: .failure(self.mapXPCError(error)))
          } else {
            continuation.resume(returning: .success(success))
          }
        }
      }
    }

    public func synchroniseKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
      // Convert SecureBytes to Data using DataAdapter
      let data=DataAdapter.data(from: syncData)

      do {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<
          Void,
          Error
        >) in
          foundation.synchroniseKeysFoundation(data) { error in
            if let error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume(returning: ())
            }
          }
        }
        return .success(())
      } catch {
        return .failure(mapXPCError(error))
      }
    }

    public func resetSecurityData() async -> Result<Void, XPCSecurityError> {
      await withCheckedContinuation { continuation in
        foundation.resetSecurityDataFoundation { error in
          if let error {
            continuation.resume(returning: .failure(self.mapXPCError(error)))
          } else {
            continuation.resume(returning: .success(()))
          }
        }
      }
    }

    public func getVersion() async -> Result<String, XPCSecurityError> {
      await withCheckedContinuation { continuation in
        foundation.getVersionFoundation { versionString, error in
          if let error {
            continuation.resume(returning: .failure(self.mapXPCError(error)))
          } else if let versionString {
            continuation.resume(returning: .success(versionString))
          } else {
            continuation
              .resume(
                returning: .failure(
                  mapSecurityProtocolError(
                    SecurityProtocolError.implementationMissing("Version not available")
                  )
                )
              )
          }
        }
      }
    }

    public func getHostIdentifier() async -> Result<String, XPCSecurityError> {
      await withCheckedContinuation { continuation in
        foundation.getHostIdentifierFoundation { hostIdentifier, error in
          if let error {
            continuation.resume(returning: .failure(self.mapXPCError(error)))
          } else if let hostIdentifier {
            continuation.resume(returning: .success(hostIdentifier))
          } else {
            continuation
              .resume(
                returning: .failure(
                  mapSecurityProtocolError(
                    SecurityProtocolError.implementationMissing("Host identifier not available")
                  )
                )
              )
          }
        }
      }
    }

    public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityError> {
      await withCheckedContinuation { continuation in
        foundation.generateRandomDataFoundation(length) { data, error in
          if let error {
            continuation.resume(returning: .failure(self.mapXPCError(error)))
          } else if let data {
            continuation.resume(returning: .success(DataAdapter.secureBytes(from: data)))
          } else {
            continuation
              .resume(
                returning: .failure(
                  mapSecurityProtocolError(
                    SecurityProtocolError.implementationMissing("Random data generation failed")
                  )
                )
              )
          }
        }
      }
    }

    // Helper to map Foundation errors to XPCSecurityError domain
    private func mapXPCError(_ error: Error) -> XPCSecurityError {
      // If it's already a XPCSecurityError, just return it
      if let xpcError = error as? XPCSecurityError {
        return xpcError
      }
      
      // If it's a regular SecurityError, convert to XPC domain
      if let securityError = error as? SecurityError {
        return securityError.toXPC() as! XPCSecurityError
      }
      
      // If it's a namespaced CoreErrors.SecurityError, convert to XPC domain
      if let ceError = error as? CoreErrors.SecurityError {
        return XPCErrors.SecurityError(ceError) as! XPCSecurityError
      }
      
      return .general("XPC error: \(error.localizedDescription)")
    }
    
    // Map SecurityProtocolError to XPCSecurityError
    private func mapSecurityProtocolError(_ error: SecurityProtocolError) -> XPCSecurityError {
      switch error {
      case .implementationMissing(let message):
        return .general("Implementation missing: \(message)")
      }
    }
  }
}

// Helper adapter to convert between SecureBytes and Data
private enum DataAdapter {
  static func data(from secureBytes: SecureBytes) -> Data {
    // Use available properties from SecureBytes 
    secureBytes.withUnsafeBytes { Data($0) }
  }

  static func secureBytes(from data: Data) -> SecureBytes {
    data.withUnsafeBytes { bytes -> SecureBytes in
      let bufferPointer = bytes.bindMemory(to: UInt8.self)
      return SecureBytes(Array(bufferPointer))
    }
  }
}
