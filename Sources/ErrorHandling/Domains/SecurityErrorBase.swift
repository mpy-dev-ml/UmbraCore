import ErrorHandlingInterfaces
import Foundation

/// Security-specific errors extension
extension UmbraErrors {
  /// Security error domain
  public enum Security {
    // This namespace contains the various security error types
    // Implementation in separate files:
    // - SecurityCoreErrors.swift - Core security errors (already created)
    // - SecurityProtocolErrors.swift - Protocol implementation errors
    // - SecurityXPCErrors.swift - XPC communication errors
  }
}
