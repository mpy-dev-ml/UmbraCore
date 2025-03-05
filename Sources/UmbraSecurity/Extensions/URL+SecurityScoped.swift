import Foundation
import SecurityInterfaces
import SecurityTypes

/// Extension to URL for security-scoped bookmark operations
extension URL {
  /// Create a security-scoped bookmark for this URL
  /// - Returns: Bookmark data
  /// - Throws: SecurityError if bookmark creation fails
  public func us_createSecurityScopedBookmark() async throws -> Data {
    let path=path
    do {
      return try bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
    } catch {
      throw SecurityInterfaces.SecurityError.bookmarkError("Failed to create bookmark for: \(path)")
    }
  }

  /// Resolve a security-scoped bookmark
  /// - Parameter bookmarkData: Bookmark data to resolve
  /// - Returns: Tuple containing resolved URL and whether bookmark is stale
  /// - Throws: SecurityError if bookmark resolution fails
  public static func us_resolveSecurityScopedBookmark(_ bookmarkData: Data) async throws
  -> (URL, Bool) {
    do {
      var isStale=false
      let url=try URL(
        resolvingBookmarkData: bookmarkData,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      return (url, isStale)
    } catch {
      throw SecurityInterfaces.SecurityError.bookmarkError("Failed to resolve bookmark")
    }
  }

  /// Check if this URL is a security-scoped bookmark
  /// - Returns: True if URL is a security-scoped bookmark
  public var us_isSecurityScoped: Bool {
    startAccessingSecurityScopedResource()
  }

  /// Perform an operation with security-scoped access to this URL
  /// - Parameter operation: Operation to perform with access
  /// - Returns: Result of the operation
  /// - Throws: SecurityError if access fails, or any error thrown by the operation
  public func us_withSecurityScopedAccess<T>(perform operation: () async throws -> T) async throws
  -> T {
    guard us_startAccessingSecurityScopedResource() else {
      throw SecurityInterfaces.SecurityError.accessError("Failed to access: \(path)")
    }
    defer { us_stopAccessingSecurityScopedResource() }

    return try await operation()
  }

  /// Start accessing security-scoped resource
  /// - Returns: True if access was granted
  public func us_startAccessingSecurityScopedResource() -> Bool {
    startAccessingSecurityScopedResource()
  }

  /// Stop accessing security-scoped resource
  public func us_stopAccessingSecurityScopedResource() {
    stopAccessingSecurityScopedResource()
  }
}
