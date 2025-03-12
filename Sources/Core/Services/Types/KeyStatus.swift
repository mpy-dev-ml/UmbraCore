import Foundation
import KeyManagementTypes

/// Represents the current status of a cryptographic key
///
/// - Important: This type is deprecated. Please use the canonical `KeyStatus` instead.
///
/// The canonical implementation is available in the KeyManagementTypes module and provides
/// a standardised representation used across the UmbraCore framework.
@available(*, deprecated, message: "Please use the canonical KeyStatus instead")
public enum KeyStatus: Sendable, Equatable {
  /// Key is active and can be used
  case active
  /// Key has been compromised and should not be used
  case compromised
  /// Key has been retired and should not be used
  case retired
  /// Key is scheduled for deletion at the specified time
  case pendingDeletion(Date)
}

extension KeyStatus {
  public static func == (lhs: KeyStatus, rhs: KeyStatus) -> Bool {
    switch (lhs, rhs) {
      case (.active, .active),
           (.compromised, .compromised),
           (.retired, .retired):
        true
      case let (.pendingDeletion(lhsDate), .pendingDeletion(rhsDate)):
        lhsDate == rhsDate
      default:
        false
    }
  }
}

extension KeyStatus: Codable {
  private enum CodingKeys: String, CodingKey {
    case type
    case deletionDate
  }

  private enum StatusType: String, Codable {
    case active
    case compromised
    case retired
    case pendingDeletion
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
      case let .pendingDeletion(date):
        try container.encode(StatusType.pendingDeletion, forKey: .type)
        try container.encode(date, forKey: .deletionDate)
    }
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
        let date=try container.decode(Date.self, forKey: .deletionDate)
        self = .pendingDeletion(date)
    }
  }
}

// MARK: - Raw Conversion Extension (for KeyManagementTypes)

/// Extension to provide conversion to/from the raw representation
/// This will be used by KeyManagementTypes module through type extension
extension KeyStatus {
  /// The raw representation that matches the canonical type's raw status
  public enum RawRepresentation: Equatable {
    case active
    case compromised
    case retired
    case pendingDeletion(Date)
    case pendingDeletionWithTimestamp(Int64)

    public static func == (lhs: RawRepresentation, rhs: RawRepresentation) -> Bool {
      switch (lhs, rhs) {
        case (.active, .active),
             (.compromised, .compromised),
             (.retired, .retired):
          true
        case let (.pendingDeletion(lhsDate), .pendingDeletion(rhsDate)):
          lhsDate == rhsDate
        case let (
        .pendingDeletionWithTimestamp(lhsTimestamp),
        .pendingDeletionWithTimestamp(rhsTimestamp)
      ):
          lhsTimestamp == rhsTimestamp
        case let (.pendingDeletion(lhsDate), .pendingDeletionWithTimestamp(rhsTimestamp)):
          Int64(lhsDate.timeIntervalSince1970) == rhsTimestamp
        case let (.pendingDeletionWithTimestamp(lhsTimestamp), .pendingDeletion(rhsDate)):
          lhsTimestamp == Int64(rhsDate.timeIntervalSince1970)
        default:
          false
      }
    }
  }

  /// Convert to a raw representation that can be used by KeyManagementTypes
  /// - Returns: The raw representation
  public func toRawRepresentation() -> RawRepresentation {
    switch self {
      case .active: .active
      case .compromised: .compromised
      case .retired: .retired
      case let .pendingDeletion(date): .pendingDeletion(date)
    }
  }

  /// Convert to a raw representation with timestamp that can be used by KeyManagementTypes
  /// - Returns: The raw representation with timestamp for date values
  public func toRawRepresentationWithTimestamp() -> RawRepresentation {
    switch self {
      case .active: .active
      case .compromised: .compromised
      case .retired: .retired
      case let .pendingDeletion(date):
        .pendingDeletionWithTimestamp(Int64(date.timeIntervalSince1970))
    }
  }

  /// Create from a raw representation coming from KeyManagementTypes
  /// - Parameter rawRepresentation: The raw representation to convert from
  /// - Returns: The equivalent canonical KeyStatus
  public static func from(rawRepresentation: RawRepresentation) -> KeyManagementTypes.KeyStatus {
    switch rawRepresentation {
      case .active: KeyManagementTypes.KeyStatus.active
      case .compromised: KeyManagementTypes.KeyStatus.compromised
      case .retired: KeyManagementTypes.KeyStatus.retired
      case let .pendingDeletion(date): KeyManagementTypes.KeyStatus.pendingDeletion(date)
      case let .pendingDeletionWithTimestamp(timestamp):
        KeyManagementTypes.KeyStatus
          .pendingDeletion(Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
  }
}
