import Foundation

/// Context information for an error
public struct ErrorContext: Sendable {
    /// Source of the error (e.g. service name)
    public let source: String

    /// Error code if available
    public let code: String?

    /// Error message
    public let message: String

    /// Additional metadata about the error
    public let metadata: [String: String]?

    /// Create a new error context
    /// - Parameters:
    ///   - source: Source of the error (e.g. service name)
    ///   - code: Error code if available
    ///   - message: Error message
    ///   - metadata: Additional metadata about the error
    public init(
        source: String,
        code: String? = nil,
        message: String,
        metadata: [String: String]? = nil
    ) {
        self.source = source
        self.code = code
        self.message = message
        self.metadata = metadata
    }

    /// A human-readable description of the error context
    public var description: String {
        var result = "[\(source)]"

        if let code = code {
            result += " [\(code)]"
        }

        result += ": \(message)"

        if let metadata = metadata, !metadata.isEmpty {
            result += "\nMetadata:"
            for (key, value) in metadata.sorted(by: { $0.key < $1.key }) {
                result += "\n  \(key): \(value)"
            }
        }

        return result
    }
}
