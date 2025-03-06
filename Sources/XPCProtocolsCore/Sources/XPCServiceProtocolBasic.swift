import UmbraCoreTypes

/// Custom error for security interfaces that doesn't require Foundation
public enum SecurityProtocolError: Error, Sendable, Equatable {
  case implementationMissing(String)

  /// Equatable implementation
  public static func == (lhs: SecurityProtocolError, rhs: SecurityProtocolError) -> Bool {
    switch (lhs, rhs) {
      case let (.implementationMissing(lhsName), .implementationMissing(rhsName)):
        lhsName == rhsName
    }
  }
}

/// Protocol defining the base XPC service interface without Foundation dependencies
public protocol XPCServiceProtocolBasic: Sendable {
  /// Protocol identifier - used for protocol negotiation
  static var protocolIdentifier: String { get }

  /// Test connectivity
  func ping() async -> Result<Bool, XPCSecurityError>

  /// Synchronize keys across processes
  /// - Parameter syncData: The key data to synchronize
  /// - Returns: Result with void success or error
  func synchroniseKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError>
}

// MARK: - Extensions

extension XPCServiceProtocolBasic {
  /// Default implementation of protocol identifier
  public static var protocolIdentifier: String {
    "com.umbra.xpc.service.base"
  }

  /// Default implementation of ping - can be overridden by conforming types
  public func ping() async -> Result<Bool, XPCSecurityError> {
    .success(true)
  }

  /// Implementation for synchronising keys with byte array (for legacy compatibility)
  public func synchroniseKeys(_ bytes: [UInt8]) async -> Result<Void, XPCSecurityError> {
    let secureBytes = SecureBytes(bytes: bytes)
    return await synchroniseKeys(secureBytes)
  }
}
