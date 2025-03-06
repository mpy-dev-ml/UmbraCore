// Only import SecurityProtocolsCore in this file to isolate namespace conflicts
import SecurityProtocolsCore

/// Direct access to the SecurityError type in the SecurityProtocolsCore module
/// This approach avoids the namespace conflict with the enum named SecurityProtocolsCore
public typealias SPCSecurityError=SecurityProtocolsCore.SecurityError

/// Protocol to convert between SecurityProtocolsCore error types and other error types
public protocol SecurityProtocolsCoreErrorConvertible {
  /// Convert to SecurityProtocolsCore.SecurityError
  func toSPCSecurityError() -> SPCSecurityError

  /// Create from SecurityProtocolsCore.SecurityError
  static func fromSPCSecurityError(_ error: SPCSecurityError) -> Self
}

/// Helper functions for error conversion
extension SPCSecurityError {
  /// Convert to a string representation
  public func detailedDescription() -> String {
    String(describing: self)
  }
}
