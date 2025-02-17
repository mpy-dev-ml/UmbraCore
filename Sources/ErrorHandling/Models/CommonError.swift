import Foundation
import SwiftyBeaver
import UmbraLogging

/// Common error types used across the UmbraCore framework
public enum CommonError: LocalizedError, Equatable {
    /// A required service dependency is not available
    case dependencyUnavailable(String)

    /// An operation failed due to invalid state
    case invalidState(String)

    /// A required resource is not available
    case resourceUnavailable(String)

    /// An operation failed due to system constraints
    case systemConstraint(String)

    /// An operation failed due to security restrictions
    case securityViolation(String)

    /// An operation timed out
    case timeout(String)

    public var errorDescription: String? {
        switch self {
        case .dependencyUnavailable(let details):
            return "Required dependency unavailable: \(details)"
        case .invalidState(let details):
            return "Invalid state: \(details)"
        case .resourceUnavailable(let details):
            return "Resource unavailable: \(details)"
        case .systemConstraint(let details):
            return "System constraint: \(details)"
        case .securityViolation(let details):
            return "Security violation: \(details)"
        case .timeout(let details):
            return "Operation timed out: \(details)"
        }
    }
}
