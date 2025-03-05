import FeaturesLoggingErrors
import FeaturesLoggingModels
import FeaturesLoggingProtocols
import Foundation
import SecurityTypes
import SwiftyBeaver

/// A logging service implementation using SwiftyBeaver
public actor SwiftyBeaverLoggingService: LoggingProtocol {
  private let logger=SwiftyBeaver.self
  private var isInitialized=false
  private var logFileDestination: FileDestination?

  /// Initialize the SwiftyBeaver logging service
  /// - Parameter path: Path to the log file
  public func initialize(with path: String) async throws {
    guard !isInitialized else { return }

    // Create log directory if it doesn't exist
    let directoryPath=(path as NSString).deletingLastPathComponent
    do {
      try FileManager.default.createDirectory(
        atPath: directoryPath,
        withIntermediateDirectories: true,
        attributes: nil
      )
    } catch {
      throw LoggingError.directoryCreationFailed(path: directoryPath)
    }

    // Configure file destination
    let destination=FileDestination()
    destination.logFileURL=URL(fileURLWithPath: path)

    // Add destination to logger
    logger.addDestination(destination)
    logFileDestination=destination
    isInitialized=true
  }

  public func log(_ entry: LogEntry) async throws {
    guard isInitialized else {
      throw LoggingError.initializationFailed(reason: "Logging service not initialized")
    }

    guard !entry.message.isEmpty else {
      throw LoggingError.writeError(reason: "Log message cannot be empty")
    }

    let message=entry.metadata?.isEmpty == false ? "\(entry.message) | \(entry.metadata!)" : entry
      .message

    switch entry.level {
      case .debug:
        logger.debug(message)
      case .info:
        logger.info(message)
      case .warning:
        logger.warning(message)
      case .error:
        logger.error(message)
    }
  }

  public func stop() async {
    guard let destination=logFileDestination else { return }
    logger.removeDestination(destination)
    isInitialized=false
    logFileDestination=nil
  }
}
