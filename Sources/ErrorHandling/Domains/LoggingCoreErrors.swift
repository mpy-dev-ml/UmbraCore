import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Logging {
  /// Core logging errors related to logging operations and management
  public enum Core: Error, UmbraError, StandardErrorCapabilities {
    // Initialisation errors
    /// Failed to initialise logging system
    case initialisationFailed(reason: String)
    
    /// Failed to initialise log file
    case logFileInitialisationFailed(filePath: String, reason: String)
    
    /// Failed to initialise log destination
    case destinationInitialisationFailed(destination: String, reason: String)
    
    // Operation errors
    /// Failed to write log entry
    case writeFailed(reason: String)
    
    /// Failed to flush log buffer
    case flushFailed(reason: String)
    
    /// Failed to rotate log file
    case rotationFailed(filePath: String, reason: String)
    
    /// Log entry exceeded maximum size
    case entrySizeLimitExceeded(entrySize: Int, maxSize: Int)
    
    /// Log formatter error
    case formatterError(reason: String)
    
    // Configuration errors
    /// Invalid log configuration
    case invalidConfiguration(reason: String)
    
    /// Invalid log level
    case invalidLogLevel(providedLevel: String, validLevels: [String])
    
    /// Unsupported log destination
    case unsupportedDestination(destination: String)
    
    /// Destination not available
    case destinationUnavailable(destination: String, reason: String)
    
    // Resource errors
    /// Insufficient disk space for logging
    case insufficientDiskSpace(requireBytes: Int64, availableBytes: Int64)
    
    /// Log file permission error
    case permissionDenied(filePath: String, operation: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for logging core errors
    public var domain: String {
      "Logging.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .initialisationFailed:
        return "initialisation_failed"
      case .logFileInitialisationFailed:
        return "log_file_initialisation_failed"
      case .destinationInitialisationFailed:
        return "destination_initialisation_failed"
      case .writeFailed:
        return "write_failed"
      case .flushFailed:
        return "flush_failed"
      case .rotationFailed:
        return "rotation_failed"
      case .entrySizeLimitExceeded:
        return "entry_size_limit_exceeded"
      case .formatterError:
        return "formatter_error"
      case .invalidConfiguration:
        return "invalid_configuration"
      case .invalidLogLevel:
        return "invalid_log_level"
      case .unsupportedDestination:
        return "unsupported_destination"
      case .destinationUnavailable:
        return "destination_unavailable"
      case .insufficientDiskSpace:
        return "insufficient_disk_space"
      case .permissionDenied:
        return "permission_denied"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .initialisationFailed(reason):
        return "Failed to initialise logging system: \(reason)"
      case let .logFileInitialisationFailed(filePath, reason):
        return "Failed to initialise log file '\(filePath)': \(reason)"
      case let .destinationInitialisationFailed(destination, reason):
        return "Failed to initialise log destination '\(destination)': \(reason)"
      case let .writeFailed(reason):
        return "Failed to write log entry: \(reason)"
      case let .flushFailed(reason):
        return "Failed to flush log buffer: \(reason)"
      case let .rotationFailed(filePath, reason):
        return "Failed to rotate log file '\(filePath)': \(reason)"
      case let .entrySizeLimitExceeded(entrySize, maxSize):
        return "Log entry size (\(entrySize) bytes) exceeds maximum size (\(maxSize) bytes)"
      case let .formatterError(reason):
        return "Log formatter error: \(reason)"
      case let .invalidConfiguration(reason):
        return "Invalid log configuration: \(reason)"
      case let .invalidLogLevel(providedLevel, validLevels):
        return "Invalid log level '\(providedLevel)'. Valid levels: \(validLevels.joined(separator: ", "))"
      case let .unsupportedDestination(destination):
        return "Unsupported log destination: '\(destination)'"
      case let .destinationUnavailable(destination, reason):
        return "Log destination '\(destination)' is unavailable: \(reason)"
      case let .insufficientDiskSpace(requireBytes, availableBytes):
        return "Insufficient disk space for logging: required \(requireBytes) bytes, available \(availableBytes) bytes"
      case let .permissionDenied(filePath, operation):
        return "Permission denied for operation '\(operation)' on log file '\(filePath)'"
      }
    }
    
    /// Source information about where the error occurred
    public var source: ErrorHandlingInterfaces.ErrorSource? {
      nil // Source is typically set when the error is created with context
    }
    
    /// The underlying error, if any
    public var underlyingError: Error? {
      nil // Underlying error is typically set when the error is created with context
    }
    
    /// Additional context for the error
    public var context: ErrorHandlingInterfaces.ErrorContext {
      ErrorHandlingInterfaces.ErrorContext(
        source: domain,
        operation: "logging_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .initialisationFailed(reason):
        return .initialisationFailed(reason: reason)
      case let .logFileInitialisationFailed(filePath, reason):
        return .logFileInitialisationFailed(filePath: filePath, reason: reason)
      case let .destinationInitialisationFailed(destination, reason):
        return .destinationInitialisationFailed(destination: destination, reason: reason)
      case let .writeFailed(reason):
        return .writeFailed(reason: reason)
      case let .flushFailed(reason):
        return .flushFailed(reason: reason)
      case let .rotationFailed(filePath, reason):
        return .rotationFailed(filePath: filePath, reason: reason)
      case let .entrySizeLimitExceeded(entrySize, maxSize):
        return .entrySizeLimitExceeded(entrySize: entrySize, maxSize: maxSize)
      case let .formatterError(reason):
        return .formatterError(reason: reason)
      case let .invalidConfiguration(reason):
        return .invalidConfiguration(reason: reason)
      case let .invalidLogLevel(providedLevel, validLevels):
        return .invalidLogLevel(providedLevel: providedLevel, validLevels: validLevels)
      case let .unsupportedDestination(destination):
        return .unsupportedDestination(destination: destination)
      case let .destinationUnavailable(destination, reason):
        return .destinationUnavailable(destination: destination, reason: reason)
      case let .insufficientDiskSpace(requireBytes, availableBytes):
        return .insufficientDiskSpace(requireBytes: requireBytes, availableBytes: availableBytes)
      case let .permissionDenied(filePath, operation):
        return .permissionDenied(filePath: filePath, operation: operation)
      }
      // In a real implementation, we would attach the context
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Logging.Core {
  /// Create an error for a failed logging system initialisation
  public static func initialisationFailed(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .initialisationFailed(reason: reason)
  }
  
  /// Create an error for a failed log write operation
  public static func writeFailed(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .writeFailed(reason: reason)
  }
  
  /// Create an error for an invalid configuration
  public static func invalidConfig(
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .invalidConfiguration(reason: reason)
  }
  
  /// Create an error for a failed log rotation
  public static func rotationFailed(
    filePath: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .rotationFailed(filePath: filePath, reason: reason)
  }
}
