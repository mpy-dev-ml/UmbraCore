import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Bookmark {
  /// Core bookmark errors related to bookmark creation, resolution, and access
  public enum Core: Error, UmbraError, StandardErrorCapabilities {
    // Bookmark creation and resolution errors
    /// Failed to create bookmark data for URL
    case creationFailed(url: URL, reason: String?)
    
    /// Failed to resolve bookmark data to URL
    case resolutionFailed(reason: String?, underlyingError: Error?)
    
    /// Bookmark data is stale and needs to be recreated
    case staleBookmark(url: URL)
    
    /// Invalid bookmark data format
    case invalidBookmarkData(reason: String?)
    
    // Security and access errors
    /// Security-scoped resource access was denied
    case accessDenied(url: URL, reason: String?)
    
    /// Failed to start security-scoped resource access
    case startAccessFailed(url: URL, reason: String?)
    
    /// Failed to stop security-scoped resource access
    case stopAccessFailed(url: URL, reason: String?)
    
    // Resource errors
    /// File does not exist at URL
    case fileNotFound(url: URL)
    
    /// File is not accessible due to permissions
    case permissionDenied(url: URL)
    
    /// File moved or renamed
    case fileRelocated(originalURL: URL, currentURL: URL?)
    
    /// File type is not supported for bookmarking
    case unsupportedFileType(url: URL, fileType: String)
    
    /// Failed to serialise bookmark data
    case serialisationFailed(reason: String?)
    
    /// Failed to deserialise bookmark data
    case deserialisationFailed(reason: String?)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for bookmark core errors
    public var domain: String {
      "Bookmark.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .creationFailed:
        return "creation_failed"
      case .resolutionFailed:
        return "resolution_failed"
      case .staleBookmark:
        return "stale_bookmark"
      case .invalidBookmarkData:
        return "invalid_bookmark_data"
      case .accessDenied:
        return "access_denied"
      case .startAccessFailed:
        return "start_access_failed"
      case .stopAccessFailed:
        return "stop_access_failed"
      case .fileNotFound:
        return "file_not_found"
      case .permissionDenied:
        return "permission_denied"
      case .fileRelocated:
        return "file_relocated"
      case .unsupportedFileType:
        return "unsupported_file_type"
      case .serialisationFailed:
        return "serialisation_failed"
      case .deserialisationFailed:
        return "deserialisation_failed"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .creationFailed(url, reason):
        let baseMessage = "Failed to create bookmark for file at \(url.path)"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      case let .resolutionFailed(reason, underlyingError):
        var baseMessage = "Failed to resolve bookmark"
        if let reason = reason {
          baseMessage += ": \(reason)"
        }
        if let error = underlyingError {
          baseMessage += " (\(error.localizedDescription))"
        }
        return baseMessage
      case let .staleBookmark(url):
        return "Bookmark is stale for file at \(url.path)"
      case let .invalidBookmarkData(reason):
        let baseMessage = "Invalid bookmark data format"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      case let .accessDenied(url, reason):
        let baseMessage = "Access denied to file at \(url.path)"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      case let .startAccessFailed(url, reason):
        let baseMessage = "Failed to start security-scoped access for \(url.path)"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      case let .stopAccessFailed(url, reason):
        let baseMessage = "Failed to stop security-scoped access for \(url.path)"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      case let .fileNotFound(url):
        return "File does not exist at \(url.path)"
      case let .permissionDenied(url):
        return "Permission denied for file at \(url.path)"
      case let .fileRelocated(originalURL, currentURL):
        let baseMessage = "File relocated from \(originalURL.path)"
        return currentURL.map { "\(baseMessage) to \($0.path)" } ?? baseMessage
      case let .unsupportedFileType(url, fileType):
        return "Unsupported file type '\(fileType)' for bookmarking at \(url.path)"
      case let .serialisationFailed(reason):
        let baseMessage = "Failed to serialise bookmark data"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      case let .deserialisationFailed(reason):
        let baseMessage = "Failed to deserialise bookmark data"
        return reason.map { "\(baseMessage): \($0)" } ?? baseMessage
      }
    }
    
    /// Source information about where the error occurred
    public var source: ErrorHandlingInterfaces.ErrorSource? {
      nil // Source is typically set when the error is created with context
    }
    
    /// The underlying error, if any
    public var underlyingError: Error? {
      if case let .resolutionFailed(_, error) = self {
        return error
      }
      return nil // Underlying error is typically set when the error is created with context
    }
    
    /// Additional context for the error
    public var context: ErrorHandlingInterfaces.ErrorContext {
      ErrorHandlingInterfaces.ErrorContext(
        source: domain,
        operation: "bookmark_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .creationFailed(url, reason):
        return .creationFailed(url: url, reason: reason)
      case let .resolutionFailed(reason, underlyingError):
        return .resolutionFailed(reason: reason, underlyingError: underlyingError)
      case let .staleBookmark(url):
        return .staleBookmark(url: url)
      case let .invalidBookmarkData(reason):
        return .invalidBookmarkData(reason: reason)
      case let .accessDenied(url, reason):
        return .accessDenied(url: url, reason: reason)
      case let .startAccessFailed(url, reason):
        return .startAccessFailed(url: url, reason: reason)
      case let .stopAccessFailed(url, reason):
        return .stopAccessFailed(url: url, reason: reason)
      case let .fileNotFound(url):
        return .fileNotFound(url: url)
      case let .permissionDenied(url):
        return .permissionDenied(url: url)
      case let .fileRelocated(originalURL, currentURL):
        return .fileRelocated(originalURL: originalURL, currentURL: currentURL)
      case let .unsupportedFileType(url, fileType):
        return .unsupportedFileType(url: url, fileType: fileType)
      case let .serialisationFailed(reason):
        return .serialisationFailed(reason: reason)
      case let .deserialisationFailed(reason):
        return .deserialisationFailed(reason: reason)
      }
      // In a real implementation, we would attach the context
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
      // Since only resolutionFailed supports an underlying error directly
      if case let .resolutionFailed(reason, _) = self {
        return .resolutionFailed(reason: reason, underlyingError: underlyingError)
      }
      // For other cases, we would need a more complex implementation to store the error
      return self
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Bookmark.Core {
  /// Create an error for a failed bookmark creation
  public static func creationFailed(
    url: URL,
    reason: String? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .creationFailed(url: url, reason: reason)
  }
  
  /// Create an error for a failed bookmark resolution
  public static func resolutionFailed(
    reason: String? = nil,
    underlyingError: Error? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .resolutionFailed(reason: reason, underlyingError: underlyingError)
  }
  
  /// Create an error for a stale bookmark
  public static func stale(
    url: URL,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .staleBookmark(url: url)
  }
  
  /// Create an error for a file not found
  public static func fileNotFound(
    url: URL,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .fileNotFound(url: url)
  }
  
  /// Create an error for access denied
  public static func accessDenied(
    url: URL,
    reason: String? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> Self {
    .accessDenied(url: url, reason: reason)
  }
}
