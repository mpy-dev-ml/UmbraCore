import Foundation
import UmbraXPC

/// Service for managing security-scoped bookmarks
@MainActor
public final class BookmarkService: NSObject, BookmarkServiceProtocol, NSXPCListenerDelegate {
  /// Set of URLs currently being accessed
  private var activeAccessURLs: Set<URL>=[]

  /// Thread-safe access for connections outside the MainActor
  /// Uses an actor to provide isolation without imposing MainActor requirements
  private actor ConnectionsRegistry {
    private var connections: [UUID: NSXPCConnection] = [:]
    
    func store(_ id: UUID, connection: NSXPCConnection) {
      connections[id] = connection
    }
    
    func retrieve(_ id: UUID) -> NSXPCConnection? {
      let connection = connections[id]
      connections.removeValue(forKey: id)
      return connection
    }
    
    /// Process a connection with a handler while keeping it isolated within the actor
    /// This avoids passing NSXPCConnection across actor boundaries
    func processConnection(_ id: UUID, with handler: @Sendable (NSXPCConnection) -> Void) {
      guard let connection = connections[id] else { return }
      handler(connection)
      connections.removeValue(forKey: id)
    }
  }
  
  // The connections registry provides thread-safe access outside MainActor
  private let connectionsRegistry = ConnectionsRegistry()

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

  public nonisolated func listener(
    _: NSXPCListener,
    shouldAcceptNewConnection newConnection: NSXPCConnection
  ) -> Bool {
    // Create a unique ID to track this connection
    let connectionId = UUID()
    
    // Configure the connection interface before storing it
    // This can be done outside the MainActor
    let exportedInterface = NSXPCInterface(with: BookmarkServiceProtocol.self)
    newConnection.exportedInterface = exportedInterface
    
    // Create a detached task to handle the connection safely
    Task.detached {
      // First store the connection in our thread-safe registry
      await self.connectionsRegistry.store(connectionId, connection: newConnection)
      
      // Then notify the MainActor that a connection is ready to be set up
      // Using a separate method call avoids sending the NSXPCConnection directly
      await MainActor.run {
        // This is a synchronous call on the MainActor
        self.prepareToSetupConnection(withId: connectionId)
      }
    }
    
    return true
  }
  
  // Initial setup method that runs on the MainActor but doesn't await anything
  @MainActor
  private func prepareToSetupConnection(withId id: UUID) {
    // Create a task to handle the async part
    Task {
      await finaliseConnectionSetup(withId: id)
    }
  }
  
  // Final setup method that can use async/await
  @MainActor
  private func finaliseConnectionSetup(withId id: UUID) async {
    // Use the actor to process the connection directly without crossing actor boundaries
    await connectionsRegistry.processConnection(id) { connection in
      // These operations happen within the actor's context via the closure
      // The NSXPCConnection doesn't cross actor boundaries
      connection.exportedObject = self
      connection.resume()
    }
  }
}
