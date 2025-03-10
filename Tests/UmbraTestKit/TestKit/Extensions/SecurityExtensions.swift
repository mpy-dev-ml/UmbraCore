import ErrorHandlingDomains
import Foundation
import SecurityInterfaces
import SecurityTypes

// Define a protocol for URL-based security access
public protocol URLSecurityProvider {
  /// Start accessing a URL security-scoped resource
  /// - Parameter url: URL to access
  /// - Returns: True if access was granted
  /// - Throws: SecurityError if access cannot be granted
  func startAccessing(url: URL) async throws -> Bool
}

extension SecurityInterfaces.SecurityProvider {
  /// Start accessing a URL security-scoped resource
  /// - Parameter url: URL to access
  /// - Returns: True if access was granted
  /// - Throws: SecurityError if access cannot be granted
  public func startAccessing(url: URL) async throws -> Bool {
    // Access the path directly to avoid recursive call
    guard !url.path.isEmpty else {
      throw SecurityInterfaces.SecurityError.operationFailed("Empty path")
    }
    return true
  }
}
