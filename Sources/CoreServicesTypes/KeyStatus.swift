import Foundation

/// Represents the current status of a cryptographic key
@frozen
public enum KeyStatus: Sendable, Equatable, Codable {
  /// Key is active and can be used
  case active
  /// Key has been compromised and should not be used
  case compromised
  /// Key has been retired and should not be used
  case retired
  /// Key is scheduled for deletion at the specified time
  case pendingDeletion(Date)

  // Custom Codable implementation to handle the associated value
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
