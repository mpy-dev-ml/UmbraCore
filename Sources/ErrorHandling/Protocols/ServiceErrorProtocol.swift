import ErrorHandling_Common
import Foundation

/// Protocol for service-specific errors
public protocol ServiceErrorProtocol: LocalizedError, Sendable, CustomStringConvertible {
    /// The type of error that occurred
    var errorType: ServiceErrorType { get }

    /// Additional context information about the error
    var contextInfo: [String: String] { get }

    /// Severity level of the error
    var severity: ErrorSeverity { get }

    /// Whether the error can be recovered from
    var isRecoverable: Bool { get }
}

// MARK: - ServiceErrorProtocol Extensions

extension ServiceErrorProtocol {
    /// Default severity level
    public var severity: ErrorSeverity {
        .error
    }

    /// Default recoverable state
    public var isRecoverable: Bool {
        false
    }

    public var description: String {
        var description = "[\(errorType)] \(localizedDescription)"
        if !contextInfo.isEmpty {
            description += "\nContext: \(contextInfo)"
        }
        return description
    }

    public var localizedDescription: String {
        errorType.description
    }

    /// Category of the error based on its type
    var category: String {
        errorType.rawValue
    }

    /// String representation of the error
    var detailedDescription: String {
        var desc = "[\(category)] \(localizedDescription)"

        if !contextInfo.isEmpty {
            desc += "\nContext:"
            for (key, value) in contextInfo.sorted(by: { $0.key < $1.key }) {
                desc += "\n  \(key): \(value)"
            }
        }

        return desc
    }

    /// Format error for logging
    func formatForLogging() -> String {
        var desc = "[\(category)] \(localizedDescription)"

        if !contextInfo.isEmpty {
            desc += "\nContext:"
            for (key, value) in contextInfo.sorted(by: { $0.key < $1.key }) {
                desc += "\n  \(key): \(value)"
            }
        }

        return desc
    }

    /// Convert error to dictionary for serialization
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "type": String(describing: Self.self),
            "error_type": errorType.rawValue,
            "description": localizedDescription
        ]

        if !contextInfo.isEmpty {
            dict["context"] = contextInfo
        }

        if let reason = failureReason {
            dict["reason"] = reason
        }

        if let suggestion = recoverySuggestion {
            dict["suggestion"] = suggestion
        }

        return dict
    }
}
