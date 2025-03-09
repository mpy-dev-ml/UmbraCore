import FeaturesLoggingErrors
import FeaturesLoggingModels
import FeaturesLoggingProtocols
import Foundation
import SecurityTypes
import LoggingWrapper

/// A logging service implementation using LoggingWrapper
public actor LoggingWrapperService: LoggingProtocol {
  private var isInitialized = false
  private var logFilePath: String?

  /// Initialize the logging service
  /// - Parameter path: Path to the log file
  public func initialize(with path: String) async throws {
    guard !isInitialized else { return }

    // Create log directory if it doesn't exist
    let directoryPath = (path as NSString).deletingLastPathComponent
    do {
      try FileManager.default.createDirectory(
        atPath: directoryPath,
        withIntermediateDirectories: true,
        attributes: nil
      )
    } catch {
      throw LoggingError.directoryCreationFailed(path: directoryPath)
    }

    // Configure logger (LoggingWrapper handles destinations internally)
    Logger.configure()
    
    // Store the path for reference
    logFilePath = path
    isInitialized = true
  }

  public func log(_ entry: LogEntry) async throws {
    guard isInitialized else {
      throw LoggingError.initializationFailed(reason: "Logging service not initialized")
    }

    guard !entry.message.isEmpty else {
      throw LoggingError.writeError(reason: "Log message cannot be empty")
    }

    let message = entry.metadata?.isEmpty == false ? "\(entry.message) | \(entry.metadata!)" : entry.message

    switch entry.level {
      case .debug:
        Logger.debug(message)
      case .info:
        Logger.info(message)
      case .warning:
        Logger.warning(message)
      case .error:
        Logger.error(message)
    }
  }

  public func stop() async {
    // LoggingWrapper doesn't need explicit shutdown
    isInitialized = false
    logFilePath = nil
  }
}
