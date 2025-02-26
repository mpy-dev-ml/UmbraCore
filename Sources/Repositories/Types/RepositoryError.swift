// Standard modules
import Foundation

/// Errors that can occur during repository operations.
public enum RepositoryError: LocalizedError, Equatable, Sendable, Codable {
    /// The repository was not found at the specified location.
    case notFound(identifier: String)

    /// The repository was not found during an operation.
    case repositoryNotFound(_ message: String)

    /// The repository is locked and cannot be accessed.
    case locked(reason: String)

    /// The repository cannot be accessed due to permissions or other issues.
    case notAccessible(reason: String)

    /// The repository configuration is invalid.
    case invalidConfiguration(reason: String)

    /// An operation on the repository failed.
    case operationFailed(reason: String)

    /// Repository maintenance operation failed.
    case maintenanceFailed(reason: String)

    /// Repository validation failed.
    case validationFailed(reason: String)

    /// Repository health check failed.
    case healthCheckFailed(reason: String)

    /// The error description.
    public var errorDescription: String? {
        switch self {
        case .notFound(let identifier):
            return "Repository not found: \(identifier)"
        case .repositoryNotFound(let message):
            return message
        case .locked(let reason):
            return "Repository is locked: \(reason)"
        case .notAccessible(let reason):
            return "Repository is not accessible: \(reason)"
        case .invalidConfiguration(let reason):
            return "Invalid repository configuration: \(reason)"
        case .operationFailed(let reason):
            return "Repository operation failed: \(reason)"
        case .maintenanceFailed(let reason):
            return "Repository maintenance failed: \(reason)"
        case .validationFailed(let reason):
            return "Repository validation failed: \(reason)"
        case .healthCheckFailed(let reason):
            return "Repository health check failed: \(reason)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .locked(let reason),
             .notAccessible(let reason),
             .invalidConfiguration(let reason),
             .operationFailed(let reason),
             .maintenanceFailed(let reason),
             .validationFailed(let reason),
             .healthCheckFailed(let reason):
            return reason
        case .notFound(let identifier):
            return identifier
        case .repositoryNotFound(let message):
            return message
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "Check the repository identifier and try again"
        case .repositoryNotFound:
            return "Check the repository identifier and try again"
        case .locked:
            return "Wait for other operations to complete or force unlock if necessary"
        case .notAccessible:
            return "Check repository permissions and network connectivity"
        case .invalidConfiguration:
            return "Check repository configuration settings"
        case .operationFailed:
            return "Retry the operation or check logs for more details"
        case .maintenanceFailed:
            return "Retry the maintenance operation or check logs for more details"
        case .validationFailed:
            return "Check repository configuration and data for errors"
        case .healthCheckFailed:
            return "Check repository configuration and data for errors"
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case identifier
        case message
        case reason
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notFound(let identifier):
            try container.encode("notFound", forKey: .type)
            try container.encode(identifier, forKey: .identifier)
        case .repositoryNotFound(let message):
            try container.encode("repositoryNotFound", forKey: .type)
            try container.encode(message, forKey: .message)
        case .locked(let reason):
            try container.encode("locked", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .notAccessible(let reason):
            try container.encode("notAccessible", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .invalidConfiguration(let reason):
            try container.encode("invalidConfiguration", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .operationFailed(let reason):
            try container.encode("operationFailed", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .maintenanceFailed(let reason):
            try container.encode("maintenanceFailed", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .validationFailed(let reason):
            try container.encode("validationFailed", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .healthCheckFailed(let reason):
            try container.encode("healthCheckFailed", forKey: .type)
            try container.encode(reason, forKey: .reason)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "notFound":
            let identifier = try container.decode(String.self, forKey: .identifier)
            self = .notFound(identifier: identifier)
        case "repositoryNotFound":
            let message = try container.decode(String.self, forKey: .message)
            self = .repositoryNotFound(message)
        case "locked":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .locked(reason: reason)
        case "notAccessible":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .notAccessible(reason: reason)
        case "invalidConfiguration":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .invalidConfiguration(reason: reason)
        case "operationFailed":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .operationFailed(reason: reason)
        case "maintenanceFailed":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .maintenanceFailed(reason: reason)
        case "validationFailed":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .validationFailed(reason: reason)
        case "healthCheckFailed":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .healthCheckFailed(reason: reason)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid repository error type: \(type)"
            )
        }
    }
}
