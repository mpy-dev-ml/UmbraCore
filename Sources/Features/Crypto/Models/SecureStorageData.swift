import Foundation

/// Structure representing encrypted data and its metadata
@frozen public struct SecureStorageData: Codable, Sendable {
    /// The encrypted data
    public let encryptedData: Data
    /// The initialization vector used for encryption
    public let iv: Data
    /// Salt used for key derivation, if applicable
    public let salt: Data?
    /// Timestamp when the data was stored
    public let timestamp: Date
    /// Version of the encryption format
    public let version: Int
    
    /// Current version of the storage format
    public static let currentVersion = 1
    
    /// Initialises new secure storage data
    /// - Parameters:
    ///   - encryptedData: The encrypted data
    ///   - iv: The initialization vector used
    ///   - salt: Optional salt used for key derivation
    ///   - timestamp: When the data was stored (defaults to now)
    ///   - version: Storage format version (defaults to current)
    public init(
        encryptedData: Data,
        iv: Data,
        salt: Data? = nil,
        timestamp: Date = Date(),
        version: Int = SecureStorageData.currentVersion
    ) {
        self.encryptedData = encryptedData
        self.iv = iv
        self.salt = salt
        self.timestamp = timestamp
        self.version = version
    }
}
