import Foundation

/// Errors that can occur during keychain operations
public enum KeychainError: LocalizedError {
    /// Item not found in the keychain
    case itemNotFound
    /// Item already exists in the keychain
    case duplicateItem
    /// Invalid data returned from keychain
    case invalidData
    /// Unexpected status code from keychain operation
    case unexpectedStatus(OSStatus)
    /// XPC connection failed
    case xpcConnectionFailed
    /// XPC connection was interrupted
    case xpcConnectionInterrupted
    /// XPC connection was invalidated
    case xpcConnectionInvalid

    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        case .invalidData:
            return "Invalid data returned from keychain"
        case .unexpectedStatus(let status):
            return "Unexpected keychain status: \(status)"
        case .xpcConnectionFailed:
            return "Failed to establish XPC connection"
        case .xpcConnectionInterrupted:
            return "XPC connection was interrupted"
        case .xpcConnectionInvalid:
            return "XPC connection was invalidated"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .itemNotFound:
            return "Check that the item exists and you have the correct credentials"
        case .duplicateItem:
            return "Update the existing item instead of creating a new one"
        case .invalidData:
            return "Check that the data format is correct"
        case .unexpectedStatus:
            return "Check the keychain access permissions and try again"
        case .xpcConnectionFailed:
            return "Check that the XPC service is running and try again"
        case .xpcConnectionInterrupted:
            return "The operation was interrupted. Please try again"
        case .xpcConnectionInvalid:
            return "Restart the application and try again"
        }
    }
}
