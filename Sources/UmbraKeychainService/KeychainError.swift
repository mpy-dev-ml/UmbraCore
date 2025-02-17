import Foundation

/// Errors that can occur during keychain operations
public enum KeychainError: LocalizedError, Sendable {
    /// Item already exists in the keychain
    case duplicateItem
    /// Item not found in the keychain
    case itemNotFound
    /// Retrieved data is in an invalid format
    case invalidDataFormat
    /// Error creating access control
    case accessControlError(Error)
    /// Unhandled keychain error
    case unhandledError(status: OSStatus)
    /// Unknown error occurred
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .duplicateItem:
            return "Item already exists in the keychain"
        case .itemNotFound:
            return "Item not found in the keychain"
        case .invalidDataFormat:
            return "Retrieved data is in an invalid format"
        case .accessControlError(let error):
            return "Failed to create access control: \(error.localizedDescription)"
        case .unhandledError(let status):
            return "Unhandled keychain error (status: \(status))"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}
