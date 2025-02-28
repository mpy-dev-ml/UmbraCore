import Foundation

/// Metadata about a cryptographic key
public struct KeyMetadata: Sendable, Codable {
    /// Current status of the key
    public var status: KeyStatus

    /// Storage location of the key
    public let storageLocation: StorageLocation

    /// Access control settings for the key
    public enum AccessControls: String, Sendable, Codable {
        /// No special access controls
        case none
        /// Requires user authentication
        case requiresAuthentication
        /// Requires biometric authentication
        case requiresBiometric
        /// Requires both user and biometric authentication
        case requiresBoth
    }

    /// Access controls applied to the key
    public let accessControls: AccessControls

    /// Creation date of the key
    public let createdAt: Date

    /// Last modification date of the key
    public var lastModified: Date

    /// Expiry date of the key (if applicable)
    public var expiryDate: Date?

    /// Key algorithm and parameters
    public let algorithm: String

    /// Key size in bits
    public let keySize: Int

    /// Whether the key is isolated to the current process
    public var isProcessIsolated: Bool

    /// Custom metadata associated with the key
    public var customMetadata: [String: String]?

    /// Create new key metadata
    /// - Parameters:
    ///   - storageLocation: Where the key is stored
    ///   - accessControls: Access control settings
    ///   - algorithm: Key algorithm
    ///   - keySize: Key size in bits
    ///   - expiryDate: Optional expiry date for the key
    ///   - isProcessIsolated: Whether the key is isolated to the current process
    ///   - customMetadata: Additional metadata
    public init(
        storageLocation: StorageLocation,
        accessControls: AccessControls = .none,
        algorithm: String,
        keySize: Int,
        expiryDate: Date? = nil,
        isProcessIsolated: Bool = false,
        customMetadata: [String: String]? = nil
    ) {
        self.status = KeyStatus.active
        self.storageLocation = storageLocation
        self.accessControls = accessControls
        self.algorithm = algorithm
        self.keySize = keySize
        self.createdAt = Date()
        self.lastModified = Date()
        self.expiryDate = expiryDate
        self.isProcessIsolated = isProcessIsolated
        self.customMetadata = customMetadata
    }
}
