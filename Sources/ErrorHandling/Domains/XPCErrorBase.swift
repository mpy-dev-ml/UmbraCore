import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors {
  /// XPC communication error domain
  public enum XPC {
    // This namespace contains the various XPC error types
    // Implementation in separate files:
    // - XPCCoreErrors.swift - Core XPC communication errors
    // - XPCProtocolErrors.swift - XPC protocol-specific errors
  }
}
