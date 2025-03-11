import CoreErrors
import ErrorHandlingDomains
import Foundation
import SecurityInterfaces
import UmbraCoreTypes
import XPCProtocolsCore
import SecurityTypesProtocols
import SecurityInterfacesFoundation

/// Service for managing log files with security-scoped bookmarks
@available(macOS 14.0, *)
public actor LoggingService {
  /// Shared instance with default security service
  public static let shared=LoggingService(securityProvider: DefaultSecurityProvider())

  /// The security service to use for file operations
  private let securityProvider: any SecurityInterfaces.SecurityProviderFoundation

  /// Initialize a new logging service
  /// - Parameter securityProvider: The security provider to use for file operations
  public init(securityProvider: any SecurityInterfaces.SecurityProviderFoundation) {
    self.securityProvider=securityProvider
  }

  /// Create a bookmark for a log file
  /// - Parameter path: Path to the log file
  /// - Returns: The bookmark data
  /// - Throws: SecurityError if bookmark creation fails
  public func createLogBookmark(path: String) async -> Result<[UInt8], XPCSecurityError> {
    let url=URL(fileURLWithPath: path)
    let data=try await securityProvider.createBookmark(for: url)
    return Array(data)
  }

  /// Resolve a bookmark to a log file
  /// - Parameter bookmarkData: The bookmark data
  /// - Returns: The path to the log file and whether the bookmark is stale
  /// - Throws: SecurityError if bookmark resolution fails
  public func resolveLogBookmark(_ bookmarkData: [UInt8]) async throws
  -> (path: String, isStale: Bool) {
    let result=try await securityProvider.resolveBookmark(Data(bookmarkData))
    return (result.url.path, result.isStale)
  }

  /// Start accessing a log file
  /// - Parameter path: Path to the log file
  /// - Returns: True if access was granted
  public func startAccessingLog(path: String) async -> Result<Bool, XPCSecurityError> {
    try await securityProvider.startAccessing(url: URL(fileURLWithPath: path))
  }

  /// Stop accessing a log file
  /// - Parameter path: Path to the log file
  public func stopAccessingLog(path: String) async {
    // Using isolated call to avoid data race
    let provider=securityProvider
    await provider.stopAccessing(url: URL(fileURLWithPath: path))
  }

  /// Stop accessing all log files
  public func stopAccessingAllLogs() async {
    // Using isolated call to avoid data race
    let provider=securityProvider
    await provider.stopAccessingAllResources()
  }

  /// Check if a log file is being accessed
  /// - Parameter path: Path to the log file
  /// - Returns: True if the log file is being accessed
  public func isAccessingLog(path: String) async -> Bool {
    // Using isolated call to avoid data race
    let provider=securityProvider
    return await provider.isAccessing(url: URL(fileURLWithPath: path))
  }

  /// Get all log files being accessed
  /// - Returns: Set of paths to log files being accessed
  public func getAccessedLogPaths() async -> Set<String> {
    // Using isolated call to avoid data race
    let provider=securityProvider
    let urls=await provider.getAccessedUrls()
    return Set(urls.map(\.path))
  }

  /// Perform an operation with security-scoped access to a log file
  /// - Parameters:
  ///   - path: Path to the log file
  ///   - operation: Operation to perform
  /// - Returns: The result of the operation
  /// - Throws: Any error that occurs during the operation
  public func withLogAccess<T: Sendable>(
    to path: String,
    perform operation: @Sendable () async throws -> T
  ) async throws -> T {
    // Check if we're already accessing the path
    let wasAlreadyAccessing=await isAccessingLog(path: path)

    // Start accessing if needed
    if !wasAlreadyAccessing {
      _=try await startAccessingLog(path: path)
    }

    // Perform the operation
    do {
      let result=try await operation()

      // Stop accessing if we weren't already accessing
      if !wasAlreadyAccessing {
        await stopAccessingLog(path: path)
      }

      return result
    } catch {
      // Stop accessing if we weren't already accessing
      if !wasAlreadyAccessing {
        await stopAccessingLog(path: path)
      }
      throw error
    }
  }
}
