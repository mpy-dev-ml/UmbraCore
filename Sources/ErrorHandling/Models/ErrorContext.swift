import Foundation

/// Context information for an error
public struct ErrorContext: Sendable, Equatable {
  /// Source of the error (e.g. service name)
  public let source: String

  /// Error code if available
  public let code: String?

  /// Error message
  public let message: String

  /// Additional metadata about the error
  public var metadata: [String: Any]
  
  /// Creates a new ErrorContext instance
  /// - Parameters:
  ///   - source: Source of the error (e.g. service name)
  ///   - code: Error code if available
  ///   - message: Error message
  ///   - metadata: Additional metadata about the error
  public init(
    source: String,
    code: String? = nil,
    message: String,
    metadata: [String: Any] = [:]
  ) {
    self.source = source
    self.code = code
    self.message = message
    self.metadata = metadata
  }

  /// A human-readable description of the error context
  public var description: String {
    var result = "[\(source)]"

    if let code {
      result += " [\(code)]"
    }

    result += ": \(message)"

    if !metadata.isEmpty {
      result += "\nMetadata:"
      for (key, value) in metadata.keys.sorted().map({ ($0, metadata[$0]!) }) {
        result += "\n  \(key): \(String(describing: value))"
      }
    }

    return result
  }
  
  /// Gets a value from the context using the specified key
  /// - Parameter key: The key to look up
  /// - Returns: The value if found, or nil if the key doesn't exist
  public func value(for key: String) -> Any? {
    return metadata[key]
  }
  
  /// Gets a strongly typed value from the context
  /// - Parameters:
  ///   - key: The key to look up
  ///   - type: The expected type of the value
  /// - Returns: The value cast to the specified type, or nil if not found or wrong type
  public func typedValue<T>(for key: String, as type: T.Type = T.self) -> T? {
    return metadata[key] as? T
  }
  
  /// Creates a new context with the specified key-value pair added
  /// - Parameters:
  ///   - key: The key to add
  ///   - value: The value to associate with the key
  /// - Returns: A new ErrorContext instance with the added key-value pair
  public func adding(key: String, value: Any) -> ErrorContext {
    var newMetadata = metadata
    newMetadata[key] = value
    return ErrorContext(
      source: source,
      code: code,
      message: message,
      metadata: newMetadata
    )
  }
  
  /// Creates a new context with multiple key-value pairs added
  /// - Parameter additionalMetadata: Dictionary of key-value pairs to add
  /// - Returns: A new ErrorContext instance with the added key-value pairs
  public func adding(metadata additionalMetadata: [String: Any]) -> ErrorContext {
    var newMetadata = metadata
    for (key, value) in additionalMetadata {
      newMetadata[key] = value
    }
    return ErrorContext(
      source: source,
      code: code,
      message: message,
      metadata: newMetadata
    )
  }
  
  /// Creates a new context by merging with another context
  /// - Parameter other: Another ErrorContext to merge with
  /// - Returns: A new ErrorContext with values from both contexts (the other context takes precedence)
  public func merging(with other: ErrorContext) -> ErrorContext {
    // For a merged context, we keep our source/code/message unless the other one has non-nil values
    let mergedSource = other.source.isEmpty ? source : other.source
    let mergedCode = other.code ?? code
    let mergedMessage = other.message.isEmpty ? message : other.message
    
    return ErrorContext(
      source: mergedSource,
      code: mergedCode,
      message: mergedMessage,
      metadata: adding(metadata: other.metadata).metadata
    )
  }
  
  /// Checks if two ErrorContext instances are equal
  public static func == (lhs: ErrorContext, rhs: ErrorContext) -> Bool {
    guard lhs.source == rhs.source &&
          lhs.code == rhs.code &&
          lhs.message == rhs.message &&
          lhs.metadata.keys.sorted() == rhs.metadata.keys.sorted() else {
      return false
    }
    
    // Compare string representations of metadata values
    for key in lhs.metadata.keys {
      if String(describing: lhs.metadata[key]!) != String(describing: rhs.metadata[key]!) {
        return false
      }
    }
    
    return true
  }
}

/// Extension to add conveniences for common context values
public extension ErrorContext {
  /// Creates a context with a message
  /// - Parameter message: The message to include
  /// - Returns: A new ErrorContext with the message
  static func withMessage(_ message: String) -> ErrorContext {
    return ErrorContext(source: "UmbraCore", message: message)
  }
  
  /// Creates a context with detailed error information
  /// - Parameters:
  ///   - message: A descriptive message
  ///   - source: Source of the error
  ///   - code: Optional error code
  ///   - file: Source file
  ///   - line: Line number
  ///   - function: Function name
  /// - Returns: A new ErrorContext with error details
  static func withDetails(
    message: String,
    source: String = "UmbraCore",
    code: String? = nil,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) -> ErrorContext {
    return ErrorContext(
      source: source,
      code: code,
      message: message,
      metadata: [
        "file": file,
        "line": line,
        "function": function
      ]
    )
  }
}
