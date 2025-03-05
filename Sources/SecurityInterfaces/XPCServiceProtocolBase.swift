import CoreTypes

/// Protocol defining the core XPC service interface without Foundation dependencies
public protocol XPCServiceProtocolBase: Sendable {
  /// Base method to test connectivity
  func ping() async -> Result<Bool
, XPCSecurityError>
  /// Reset all security data
  func resetSecurityData() async throws

  /// Get the XPC service version
  func getVersion() async -> Result<String
, XPCSecurityError>
  /// Get the host identifier
  func getHostIdentifier() async -> Result<String
, XPCSecurityError>
  /// Synchronize keys between services
  /// - Parameter syncData: The key synchronization data as bytes
  func synchroniseKeys(_ syncData: [UInt8]) async throws
}
