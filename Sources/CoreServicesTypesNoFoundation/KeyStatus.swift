// Foundation-free version of KeyStatus

/// Represents the current status of a cryptographic key
@frozen
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StatusType.self, forKey: .type)

        switch type {
        case .active:
            self = .active
        case .compromised:
            self = .compromised
        case .retired:
            self = .retired
        case .pendingDeletion:
            let timestamp = try container.decode(Int64.self, forKey: .deletionTimestamp)
            self = .pendingDeletion(timestamp)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .active:
            try container.encode(StatusType.active, forKey: .type)
        case .compromised:
            try container.encode(StatusType.compromised, forKey: .type)
        case .retired:
            try container.encode(StatusType.retired, forKey: .type)
        case .pendingDeletion(let timestamp):
            try container.encode(StatusType.pendingDeletion, forKey: .type)
            try container.encode(timestamp, forKey: .deletionTimestamp)
        }
    }
}
