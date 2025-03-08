import CoreErrors
import Foundation
import SecurityInterfaces
import SecurityUtilsProtocols
import UmbraCoreTypesimport SecurityTypesProtocols
import XPCProtocolsCoreimport SecurityTypes

/// Service for managing security-scoped bookmarks
public actor SecurityBookmarkService {
  private let urlProvider: URLProvider
  private var activeResources: Set<URL>

  /// Initialize a new security bookmark service
  /// - Parameter urlProvider: Provider for URL operations
  public init(urlProvider: URLProvider=PathURLProvider()) {
    self.urlProvider=urlProvider
    activeResources=[]
  }

  /// Create a security-scoped bookmark for a URL
  /// - Parameter url: URL to create bookmark for
  /// - Returns: Bookmark data
  /// - Throws: SecurityError if bookmark creation fails
  public func createBookmark(for url: URL) async -> Result<Data, XPCSecurityError> {
    // Ensure we have a file URL
    let fileURL=url.isFileURL ? url : URL(fileURLWithPath: url.path)

    // Start accessing the resource before creating bookmark
    guard fileURL.startAccessingSecurityScopedResource() else {
      throw SecurityInterfaces.SecurityError.resourceAccessFailed(path: url.path)
    }
    defer { fileURL.stopAccessingSecurityScopedResource() }

    // Create bookmark
    let bookmarkData=try fileURL.bookmarkData(
      options: .withSecurityScope,
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    )
    return bookmarkData
  }

  /// Resolve a security-scoped bookmark to a URL
  /// - Parameter bookmarkData: Bookmark data
  /// - Returns: Resolved URL
  /// - Throws: SecurityError if bookmark resolution fails
  public func resolveBookmark(_ bookmarkData: Data) async -> Result<URL, XPCSecurityError> {
    var isStale=false
    let options: NSURL.BookmarkResolutionOptions=[.withSecurityScope, .withoutUI]

    do {
      let url=try URL(
        resolvingBookmarkData: bookmarkData,
        options: options,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      if isStale {
        // Log warning but continue with the stale bookmark
        print("Warning: Bookmark is stale for \(url.path)")
      }

      return url
    } catch {
      throw SecurityInterfaces.SecurityError.bookmarkResolutionFailed
    }
  }

  /// Perform an operation with security-scoped access to a URL
  /// - Parameters:
  ///   - url: URL to access
  ///   - operation: Operation to perform while URL is accessible
  /// - Returns: Result of the operation
  /// - Throws: SecurityError if access fails
  public func withSecurityScopedAccess<T: Sendable>(
    to url: URL,
    operation: @Sendable () async throws -> T
  ) async throws -> T {
    // Ensure we have a file URL
    let fileURL=url.isFileURL ? url : URL(fileURLWithPath: url.path)

    // Start accessing the resource
    guard fileURL.startAccessingSecurityScopedResource() else {
      throw SecurityInterfaces.SecurityError.resourceAccessFailed(path: url.path)
    }

    // Track the active resource
    activeResources.insert(fileURL)

    defer {
      fileURL.stopAccessingSecurityScopedResource()
      activeResources.remove(fileURL)
    }

    return try await operation()
  }

  /// Stop accessing all security-scoped resources
  public func stopAccessingAllResources() {
    for url in activeResources {
      url.stopAccessingSecurityScopedResource()
    }
    activeResources.removeAll()
  }
}
