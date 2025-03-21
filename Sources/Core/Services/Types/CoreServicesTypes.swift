import Foundation

/// Core service types namespace
/// This file contains common type definitions used in service implementations
public enum CoreServicesTypes {
    /// Represents the current state of a service
    public enum ServiceState: Equatable, Sendable {
        /// Service is running and healthy
        case healthy
        /// Service is running but experiencing performance issues
        case degraded(reason: String)
        /// Service is not available
        case unavailable(reason: String)
        /// Service is starting up
        case starting
        /// Service is shutting down
        case shuttingDown
        /// Service is in maintenance mode
        case maintenance
    }
}

// Add extensions for Codable, CustomStringConvertible, etc.
extension CoreServicesTypes.ServiceState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .healthy:
            return "Healthy"
        case .degraded(let reason):
            return "Degraded: \(reason)"
        case .unavailable(let reason):
            return "Unavailable: \(reason)"
        case .starting:
            return "Starting"
        case .shuttingDown:
            return "Shutting Down"
        case .maintenance:
            return "Maintenance"
        }
    }
}

extension CoreServicesTypes.ServiceState: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case reason
    }
    
    private enum StateType: String, Codable {
        case healthy
        case degraded
        case unavailable
        case starting
        case shuttingDown
        case maintenance
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .healthy:
            try container.encode(StateType.healthy, forKey: .type)
        case .degraded(let reason):
            try container.encode(StateType.degraded, forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .unavailable(let reason):
            try container.encode(StateType.unavailable, forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .starting:
            try container.encode(StateType.starting, forKey: .type)
        case .shuttingDown:
            try container.encode(StateType.shuttingDown, forKey: .type)
        case .maintenance:
            try container.encode(StateType.maintenance, forKey: .type)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StateType.self, forKey: .type)
        
        switch type {
        case .healthy:
            self = .healthy
        case .degraded:
            let reason = try container.decode(String.self, forKey: .reason)
            self = .degraded(reason: reason)
        case .unavailable:
            let reason = try container.decode(String.self, forKey: .reason)
            self = .unavailable(reason: reason)
        case .starting:
            self = .starting
        case .shuttingDown:
            self = .shuttingDown
        case .maintenance:
            self = .maintenance
        }
    }
}
