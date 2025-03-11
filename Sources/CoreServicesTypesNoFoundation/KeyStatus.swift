import Foundation
import KeyManagementTypes

/// Represents the current status of a cryptographic key
///
/// - Important: This type is deprecated. Please use `KeyManagementTypes.KeyStatus` instead.
///
/// The canonical implementation is available in the KeyManagementTypes module and provides
/// a standardised representation used across the UmbraCore framework.
@frozen
@available(*, deprecated, message: "Please use KeyManagementTypes.KeyStatus instead")
public enum KeyStatus: Sendable, Equatable, Codable {
  /// Key is active and can be used
  case active
  /// Key has been compromised and should not be used
  case compromised
  /// Key has been retired and should not be used
  case retired
  /// Key is scheduled for deletion at the specified time (Unix timestamp)
  case pendingDeletion(Int64)

  // Custom Codable implementation to handle the associated value
  private enum CodingKeys: String, CodingKey {
    case type
    case deletionTimestamp
  }

  private enum StatusType: String, Codable {
    case active
    case compromised
    case retired
    case pendingDeletion
  }

  @preconcurrency
  @available(*, deprecated, message: "Will need to be refactored for Swift 6")
  public init(from decoder: Decoder) throws {
    let container=try decoder.container(keyedBy: CodingKeys.self)
    let type=try container.decode(StatusType.self, forKey: .type)

    switch type {
      case .active:
        self = .active
      case .compromised:
        self = .compromised
      case .retired:
        self = .retired
      case .pendingDeletion:
        let timestamp=try container.decode(Int64.self, forKey: .deletionTimestamp)
        self = .pendingDeletion(timestamp)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container=encoder.container(keyedBy: CodingKeys.self)

    switch self {
      case .active:
        try container.encode(StatusType.active, forKey: .type)
      case .compromised:
        try container.encode(StatusType.compromised, forKey: .type)
      case .retired:
        try container.encode(StatusType.retired, forKey: .type)
      case let .pendingDeletion(timestamp):
        try container.encode(StatusType.pendingDeletion, forKey: .type)
        try container.encode(timestamp, forKey: .deletionTimestamp)
    }
  }

  /// Convert to the canonical KeyStatus type
  /// - Returns: The equivalent canonical KeyStatus
  public func toCanonical() -> KeyManagementTypes.KeyStatus {
    switch self {
      case .active:
        .active
      case .compromised:
        .compromised
      case .retired:
        .retired
      case let .pendingDeletion(timestamp):
        KeyManagementTypes.KeyStatus.pendingDeletionWithTimestamp(timestamp)
    }
  }

  /// Create from the canonical KeyStatus type
  /// - Parameter canonical: The canonical KeyStatus to convert from
  /// - Returns: The equivalent legacy KeyStatus
  public static func from(canonical: KeyManagementTypes.KeyStatus) -> KeyStatus {
    switch canonical {
      case .active:
        .active
      case .compromised:
        .compromised
      case .retired:
        .retired
      case .pendingDeletion:
        if let timestamp=canonical.getDeletionTimestamp() {
          .pendingDeletion(timestamp)
        } else {
          // This shouldn't happen with valid data, but as a fallback we use current time
          .pendingDeletion(Int64(Date().timeIntervalSince1970))
        }
    }
  }
}
