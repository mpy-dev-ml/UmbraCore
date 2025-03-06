import CoreTypesInterfaces
import Foundation

/// Represents various security operations that can be performed
public enum SecurityOperation {
  case encrypt
  case decrypt
  case sign
  case verify
  case hash
  case keyGeneration
  case keyRotation
  case keyDeletion
  case custom(String)

  public var rawValue: String {
    switch self {
      case .encrypt:
        "encrypt"
      case .decrypt:
        "decrypt"
      case .sign:
        "sign"
      case .verify:
        "verify"
      case .hash:
        "hash"
      case .keyGeneration:
        "keyGeneration"
      case .keyRotation:
        "keyRotation"
      case .keyDeletion:
        "keyDeletion"
      case let .custom(value):
        value
    }
  }
}

/// Result of a security operation
public struct SecurityResult {
  /// Whether the operation was successful
  public let success: Bool

  /// Output data from the operation, if any
  public let data: Data?

  /// Additional metadata about the operation
  public let metadata: [String: String]

  public init(success: Bool, data: Data? = nil, metadata: [String: String] = [:]) {
    self.success = success
    self.data = data
    self.metadata = metadata
  }
}

/// Current status of the security system
public struct SecurityStatus {
  /// Whether the security system is active
  public let isActive: Bool

  /// Numeric status code
  public let statusCode: Int

  /// Human-readable status message
  public let statusMessage: String

  public init(isActive: Bool, statusCode: Int, statusMessage: String) {
    self.isActive = isActive
    self.statusCode = statusCode
    self.statusMessage = statusMessage
  }
}
