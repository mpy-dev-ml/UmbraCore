import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Resource {
  /// File system specific resource errors
  public enum File: Error, UmbraError, StandardErrorCapabilities {
    // File access errors
    /// File not found
    case fileNotFound(path: String)
    
    /// Directory not found
    case directoryNotFound(path: String)
    
    /// Permission denied for file operation
    case permissionDenied(path: String, operation: String)
    
    /// File already exists
    case fileAlreadyExists(path: String)
    
    /// Directory already exists
    case directoryAlreadyExists(path: String)
    
    // File operation errors
    /// Failed to read from file
    case readFailed(path: String, reason: String)
    
    /// Failed to write to file
    case writeFailed(path: String, reason: String)
    
    /// Failed to delete file
    case deleteFailed(path: String, reason: String)
    
    /// Failed to create directory
    case createDirectoryFailed(path: String, reason: String)
    
    /// Failed to move file
    case moveFailed(sourcePath: String, destinationPath: String, reason: String)
    
    /// Failed to copy file
    case copyFailed(sourcePath: String, destinationPath: String, reason: String)
    
    // File state errors
    /// File is in use by another process
    case fileInUse(path: String, processName: String?)
    
    /// File system is read-only
    case readOnlyFileSystem(path: String)
    
    /// Disk is full
    case diskFull(path: String, requiredBytes: Int64?, availableBytes: Int64?)
    
    /// File is corrupt
    case fileCorrupt(path: String, reason: String)
    
    /// Path is invalid
    case invalidPath(path: String, reason: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for file errors
    public var domain: String {
      "Resource.File"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .fileNotFound:
        return "file_not_found"
      case .directoryNotFound:
        return "directory_not_found"
      case .permissionDenied:
        return "permission_denied"
      case .fileAlreadyExists:
        return "file_already_exists"
      case .directoryAlreadyExists:
        return "directory_already_exists"
      case .readFailed:
        return "read_failed"
      case .writeFailed:
        return "write_failed"
      case .deleteFailed:
        return "delete_failed"
      case .createDirectoryFailed:
        return "create_directory_failed"
      case .moveFailed:
        return "move_failed"
      case .copyFailed:
        return "copy_failed"
      case .fileInUse:
        return "file_in_use"
      case .readOnlyFileSystem:
        return "read_only_file_system"
      case .diskFull:
        return "disk_full"
      case .fileCorrupt:
        return "file_corrupt"
      case .invalidPath:
        return "invalid_path"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .fileNotFound(path):
        return "File not found: \(path)"
      case let .directoryNotFound(path):
        return "Directory not found: \(path)"
      case let .permissionDenied(path, operation):
        return "Permission denied for operation '\(operation)' on path: \(path)"
      case let .fileAlreadyExists(path):
        return "File already exists: \(path)"
      case let .directoryAlreadyExists(path):
        return "Directory already exists: \(path)"
      case let .readFailed(path, reason):
        return "Failed to read from file '\(path)': \(reason)"
      case let .writeFailed(path, reason):
        return "Failed to write to file '\(path)': \(reason)"
      case let .deleteFailed(path, reason):
        return "Failed to delete file '\(path)': \(reason)"
      case let .createDirectoryFailed(path, reason):
        return "Failed to create directory '\(path)': \(reason)"
      case let .moveFailed(sourcePath, destinationPath, reason):
        return "Failed to move file from '\(sourcePath)' to '\(destinationPath)': \(reason)"
      case let .copyFailed(sourcePath, destinationPath, reason):
        return "Failed to copy file from '\(sourcePath)' to '\(destinationPath)': \(reason)"
      case let .fileInUse(path, processName):
        if let process = processName {
          return "File '\(path)' is in use by process: \(process)"
        } else {
          return "File '\(path)' is in use by another process"
        }
      case let .readOnlyFileSystem(path):
        return "File system is read-only for path: \(path)"
      case let .diskFull(path, requiredBytes, availableBytes):
        var message = "Disk is full for path: \(path)"
        if let required = requiredBytes, let available = availableBytes {
          message += " (required: \(required) bytes, available: \(available) bytes)"
        }
        return message
      case let .fileCorrupt(path, reason):
        return "File is corrupt '\(path)': \(reason)"
      case let .invalidPath(path, reason):
        return "Invalid path '\(path)': \(reason)"
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
        operation: "file_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .fileNotFound(path):
        return .fileNotFound(path: path)
      case let .directoryNotFound(path):
        return .directoryNotFound(path: path)
      case let .permissionDenied(path, operation):
        return .permissionDenied(path: path, operation: operation)
      case let .fileAlreadyExists(path):
        return .fileAlreadyExists(path: path)
      case let .directoryAlreadyExists(path):
        return .directoryAlreadyExists(path: path)
      case let .readFailed(path, reason):
        return .readFailed(path: path, reason: reason)
      case let .writeFailed(path, reason):
        return .writeFailed(path: path, reason: reason)
      case let .deleteFailed(path, reason):
        return .deleteFailed(path: path, reason: reason)
      case let .createDirectoryFailed(path, reason):
        return .createDirectoryFailed(path: path, reason: reason)
      case let .moveFailed(sourcePath, destinationPath, reason):
        return .moveFailed(sourcePath: sourcePath, destinationPath: destinationPath, reason: reason)
      case let .copyFailed(sourcePath, destinationPath, reason):
        return .copyFailed(sourcePath: sourcePath, destinationPath: destinationPath, reason: reason)
      case let .fileInUse(path, processName):
        return .fileInUse(path: path, processName: processName)
      case let .readOnlyFileSystem(path):
        return .readOnlyFileSystem(path: path)
      case let .diskFull(path, requiredBytes, availableBytes):
        return .diskFull(path: path, requiredBytes: requiredBytes, availableBytes: availableBytes)
      case let .fileCorrupt(path, reason):
        return .fileCorrupt(path: path, reason: reason)
      case let .invalidPath(path, reason):
        return .invalidPath(path: path, reason: reason)
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

extension UmbraErrors.Resource.File {
  /// Create an error for a file that could not be found
  public static func fileNotFound(
    path: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .fileNotFound(path: path)
  }
  
  /// Create an error for a directory that could not be found
  public static func directoryNotFound(
    path: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .directoryNotFound(path: path)
  }
  
  /// Create an error for a failed file read operation
  public static func readError(
    path: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .readFailed(path: path, reason: reason)
  }
  
  /// Create an error for a failed file write operation
  public static func writeError(
    path: String,
    reason: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .writeFailed(path: path, reason: reason)
  }
  
  /// Create an error for a permission denied scenario
  public static func permissionError(
    path: String,
    operation: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .permissionDenied(path: path, operation: operation)
  }
}
