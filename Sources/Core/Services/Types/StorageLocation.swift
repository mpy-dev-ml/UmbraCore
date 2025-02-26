import Foundation

/// Represents where a cryptographic key is stored
public enum StorageLocation: String, Sendable, Codable {
    /// Key is stored in the Secure Enclave
    case secureEnclave = "secureEnclave"
    /// Key is stored in the keychain
    case keychain = "keychain"
    /// Key is stored in memory
    case memory = "memory"
}
