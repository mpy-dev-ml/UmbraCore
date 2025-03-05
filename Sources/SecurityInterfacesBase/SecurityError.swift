import SecurityInterfacesProtocols

/// Base errors that can occur during security operations
/// This is a Foundation-free version of SecurityError
public enum SecurityError: Error, Sendable {
  /// Bookmark operation failed
  case bookmarkFailed(String)
  /// Resource access failed
  case accessFailed(String)
  /// Random data generation failed
  case randomGenerationFailed
  /// Hashing operation failed
  case hashingFailed
  /// Item not found
  case itemNotFound
  /// General operation failed
  case operationFailed(String)
  /// Wrapped protocol error
  case wrapped(SecurityProtocolError)

  /// Get a description of the error
  public var localizedDescription: String {
    switch self {
      case let .bookmarkFailed(message):
        "Bookmark operation failed: \(message)"
      case let .accessFailed(message):
        "Resource access failed: \(message)"
      case .randomGenerationFailed:
        "Failed to generate random data"
      case .hashingFailed:
        "Failed to perform hashing operation"
      case .itemNotFound:
        "Security item not found"
      case let .operationFailed(message):
        "Security operation failed: \(message)"
      case let .wrapped(error):
        switch error {
          case let .implementationMissing(name):
            "Implementation missing: \(name)"
        }
    }
  }

  /// Initialize from a protocol error
  public init(from protocolError: SecurityProtocolError) {
    self = .wrapped(protocolError)
  }

  /// Convert to a protocol error if possible
  public func toProtocolError() -> SecurityProtocolError? {
    switch self {
      case let .wrapped(protocolError):
        protocolError
      default:
        nil
    }
  }
}
