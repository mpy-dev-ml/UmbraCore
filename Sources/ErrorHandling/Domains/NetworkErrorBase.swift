import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors {
  /// Network error domain
  public enum Network {
    // This namespace contains the various network error types
    // Implementation in separate files:
    // - NetworkCoreErrors.swift - Core network errors
    // - NetworkHTTPErrors.swift - HTTP-specific errors
    // - NetworkSocketErrors.swift - Socket communication errors
  }
}
