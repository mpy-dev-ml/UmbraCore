import Foundation
import SecurityTypes

/// A class for managing secure storage and retrieval of credentials
actor CredentialManager {
    private let keychain: SecureStorageProvider
    
    /// Initialize a new CredentialManager
    /// - Parameter keychain: The secure storage provider to use
    public init(keychain: SecureStorageProvider) {
        self.keychain = keychain
    }
    
    /// Store a credential securely
    /// - Parameters:
    ///   - credential: The credential to store
    ///   - identifier: Unique identifier for the credential
    public func store(credential: String, withIdentifier identifier: String) async throws {
        guard let data = credential.data(using: .utf8) else {
            throw SecurityError.invalidData(reason: "Could not convert credential to data")
        }
        try await keychain.save(data, forKey: identifier)
    }
    
    /// Retrieve a stored credential
    /// - Parameter identifier: Identifier of the credential to retrieve
    /// - Returns: The stored credential
    public func retrieve(withIdentifier identifier: String) async throws -> String {
        let data = try await keychain.load(forKey: identifier)
        guard let credential = String(data: data, encoding: .utf8) else {
            throw SecurityError.invalidData(reason: "Could not convert data to credential")
        }
        return credential
    }
    
    /// Delete a stored credential
    /// - Parameter identifier: Identifier of the credential to delete
    public func delete(withIdentifier identifier: String) async throws {
        try await keychain.delete(forKey: identifier)
    }
    
    /// Check if a credential exists
    /// - Parameter identifier: Identifier to check
    /// - Returns: True if the credential exists, false otherwise
    public func exists(withIdentifier identifier: String) async -> Bool {
        do {
            _ = try await keychain.load(forKey: identifier)
            return true
        } catch {
            return false
        }
    }
}
