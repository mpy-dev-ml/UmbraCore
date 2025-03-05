import Foundation
import UmbraXPC

/// Service for managing security-scoped bookmarks
@MainActor
public final class BookmarkService: NSObject, BookmarkServiceProtocol {
  /// Set of URLs currently being accessed
  private var activeAccessURLs: Set<URL>=[]

  public override init() {
    super.init()
  }

  public func createBookmark(
    for url: URL,
    options: URL.BookmarkCreationOptions=[.withSecurityScope]
  ) async throws -> Data {
    guard url.isFileURL else {
      throw BookmarkError.invalidBookmarkData
    }

    guard FileManager.default.fileExists(atPath: url.path) else {
      throw BookmarkError.fileNotFound(url: url)
    }

    do {
      let bookmarkData=try url.bookmarkData(
        options: options,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      return bookmarkData
    } catch {
      throw BookmarkError.bookmarkCreationFailed(url: url)
    }
  }

  public func resolveBookmark(
    _ bookmarkData: Data,
    options: URL.BookmarkResolutionOptions=[.withSecurityScope]
  ) async throws -> (URL, Bool) {
    do {
      var isStale=false
      let url=try URL(
        resolvingBookmarkData: bookmarkData,
        options: options,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      // Ensure it's a file URL
      guard url.isFileURL else {
        throw BookmarkError.invalidBookmarkData
      }

      return (url, isStale)
    } catch let error as NSError {
      throw BookmarkError.bookmarkResolutionFailed(error)
    }
  }

  public func startAccessing(_ url: URL) async throws {
    guard url.isFileURL else {
      throw BookmarkError.invalidBookmarkData
    }

    if await isAccessing(url) { return }

    guard url.startAccessingSecurityScopedResource() else {
      throw BookmarkError.startAccessFailed(url: url)
    }

    activeAccessURLs.insert(url)
  }

  public func stopAccessing(_ url: URL) async {
    guard url.isFileURL else { return }

    if await isAccessing(url) {
      url.stopAccessingSecurityScopedResource()
      activeAccessURLs.remove(url)
    }
  }

  public func isAccessing(_ url: URL) async -> Bool {
    activeAccessURLs.contains(url)
  }
}

// MARK: - XPC Support

extension BookmarkService: NSXPCListenerDelegate {
  public nonisolated func listener(
    _: NSXPCListener,
    shouldAcceptNewConnection newConnection: NSXPCConnection
  ) -> Bool {
    // Configure the connection on this thread
    let exportedInterface=NSXPCInterface(with: BookmarkServiceProtocol.self)
    newConnection.exportedInterface=exportedInterface

    // Create a weak reference to avoid potential retain cycles
    weak var weakSelf=self

    // Use MainActor.run to properly handle actor isolation
    Task {
      // Safely access self on the main actor
      await MainActor.run {
        if let strongSelf=weakSelf {
          newConnection.exportedObject=strongSelf
          newConnection.resume()
        }
      }
    }

    return true
  }
}
