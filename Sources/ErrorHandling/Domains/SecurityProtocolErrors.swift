import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Security {
  /// Protocol implementation errors in the security domain
  public enum Protocols: Error, UmbraError, StandardErrorCapabilities {
    /// A required protocol implementation is missing
    case missingProtocolImplementation(protocolName: String)

    /// Data is in an invalid format for the protocol
    case invalidFormat(reason: String)

    /// The requested operation is not supported by this protocol
    case unsupportedOperation(name: String)

    /// The protocol version is incompatible
    case incompatibleVersion(version: String)

    /// The protocol is in an invalid state for the requested operation
    case invalidState(state: String, expectedState: String)

    /// An unspecified internal error occurred within the protocol implementation
    case internalError(String)

    // MARK: - UmbraError Protocol

    /// Domain identifier for security protocol errors
    public var domain: String {
      "Security.Protocols"
    }

    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
        case .missingProtocolImplementation:
          "missing_protocol_implementation"
        case .invalidFormat:
          "invalid_format"
        case .unsupportedOperation:
          "unsupported_operation"
        case .incompatibleVersion:
          "incompatible_version"
        case .invalidState:
          "invalid_state"
        case .internalError:
          "internal_error"
      }
    }

    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
        case let .missingProtocolImplementation(protocolName):
          "Missing protocol implementation: \(protocolName)"
        case let .invalidFormat(reason):
          "Invalid data format for protocol: \(reason)"
        case let .unsupportedOperation(name):
          "Operation not supported by protocol: \(name)"
        case let .incompatibleVersion(version):
          "Incompatible protocol version: \(version)"
        case let .invalidState(state, expectedState):
          "Invalid protocol state: current '\(state)', expected '\(expectedState)'"
        case let .internalError(message):
          "Internal protocol error: \(message)"
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
        operation: "protocol_operation",
        details: errorDescription
      )
    }

    /// Creates a new instance of the error with additional context
    public func with(context _: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
        case let .missingProtocolImplementation(protocolName):
          .missingProtocolImplementation(protocolName: protocolName)
        case let .invalidFormat(reason):
          .invalidFormat(reason: reason)
        case let .unsupportedOperation(name):
          .unsupportedOperation(name: name)
        case let .incompatibleVersion(version):
          .incompatibleVersion(version: version)
        case let .invalidState(state, expectedState):
          .invalidState(state: state, expectedState: expectedState)
        case let .internalError(message):
          .internalError(message)
      }
      // In a real implementation, we would attach the context
    }

    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError _: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }

    /// Creates a new instance of the error with source information
    public func with(source _: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
  }
}

// MARK: - Factory Methods

extension UmbraErrors.Security.Protocols {
  /// Create a missing protocol implementation error
  public static func makeMissingImplementation(
    protocolName: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .missingProtocolImplementation(protocolName: protocolName)
  }

  /// Create an invalid format error
  public static func makeInvalidFormat(
    reason: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .invalidFormat(reason: reason)
  }

  /// Create an unsupported operation error
  public static func makeUnsupportedOperation(
    name: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .unsupportedOperation(name: name)
  }

  /// Create an invalid state error
  public static func makeInvalidState(
    state: String,
    expectedState: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .invalidState(state: state, expectedState: expectedState)
  }

  /// Create an incompatible version error
  public static func makeIncompatibleVersion(
    version: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .incompatibleVersion(version: version)
  }

  /// Create an internal error
  public static func makeInternalError(
    message: String,
    file _: String=#file,
    line _: Int=#line,
    function _: String=#function
  ) -> Self {
    .internalError(message)
  }
}
