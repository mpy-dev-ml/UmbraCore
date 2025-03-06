import Foundation
import SwiftyBeaver
import UmbraLogging

/// Adapter for converting between UmbraLogging and SwiftyBeaver types
public enum SwiftyBeaverAdapter {
  /// Convert UmbraLogLevel to SwiftyBeaver.Level
  /// - Parameter level: The UmbraLogLevel to convert
  /// - Returns: The equivalent SwiftyBeaver.Level
  public static func convertLevel(_ level: UmbraLogLevel) -> SwiftyBeaver.Level {
    switch level {
      case .verbose:
        .verbose
      case .debug:
        .debug
      case .info:
        .info
      case .warning:
        .warning
      case .error, .critical, .fault:
        .error // SwiftyBeaver doesn't have critical/fault levels
    }
  }

  /// Create a SwiftyBeaver console destination with default formatting
  /// - Returns: A configured console destination
  public static func createConsoleDestination() -> ConsoleDestination {
    let console=ConsoleDestination()
    console.format="$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    return console
  }

  /// Create a SwiftyBeaver file destination
  /// - Parameter path: Path to the log file
  /// - Returns: A configured file destination
  public static func createFileDestination(path: String) -> FileDestination {
    let file=FileDestination()
    file.logFileURL=URL(fileURLWithPath: path)
    return file
  }
}
