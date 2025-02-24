import Foundation

/// UmbraCore provides the foundational types and protocols for the Umbra security framework.
public enum UmbraCore {
    /// The current version of the UmbraCore framework
    public static let version = "1.0.0"

    /// Configuration options for the UmbraCore framework
    public struct Configuration {
        /// Whether to use verbose logging
        public var verboseLogging: Bool

        /// The default security level for cryptographic operations
        public var defaultSecurityLevel: SecurityLevel

        public init(
            verboseLogging: Bool = false,
            defaultSecurityLevel: SecurityLevel = .high
        ) {
            self.verboseLogging = verboseLogging
            self.defaultSecurityLevel = defaultSecurityLevel
        }
    }

    /// Security levels for cryptographic operations
    @frozen
    public enum SecurityLevel: Sendable {
        /// High security - suitable for sensitive data
        case high
        /// Medium security - balanced between security and performance
        case medium
        /// Low security - suitable for non-sensitive data or testing
        case low

        /// Recommended key length in bits for this security level
        public var recommendedKeyLength: Int {
            switch self {
            case .high: return 256
            case .medium: return 192
            case .low: return 128
            }
        }

        /// Recommended number of PBKDF2 iterations for this security level
        public var recommendedPBKDF2Iterations: Int {
            switch self {
            case .high: return 310_000
            case .medium: return 200_000
            case .low: return 100_000
            }
        }
    }
}

/// Represents an error that can occur in the UmbraCore framework
public protocol UmbraError: LocalizedError {
    /// The error domain
    var domain: String { get }

    /// Whether this error is recoverable
    var isRecoverable: Bool { get }

    /// Additional error context, if any
    var context: [String: Any] { get }
}
