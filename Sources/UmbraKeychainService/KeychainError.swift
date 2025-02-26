import Foundation

/// Errors that can occur during keychain operations
public enum KeychainError: LocalizedError, Equatable {
    /// Item not found in the keychain
    case itemNotFound
    /// Item already exists in the keychain
    case duplicateItem
    /// Authentication failed for the keychain operation
    case authenticationFailed
    /// Unexpected data type returned from keychain
    case unexpectedData
    /// Failed to store item in keychain
    case storeFailed(String)
    /// Failed to retrieve item from keychain
    case retrieveFailed(String)
    /// Failed to delete item from keychain
    case deleteFailed(String)
    /// Unhandled error with status code
    case unhandledError(status: OSStatus)
    /// XPC connection failed
    case xpcConnectionFailed
    /// XPC connection was interrupted
    case xpcConnectionInterrupted
    /// XPC connection was invalidated
    case xpcConnectionInvalidated

    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "The requested item was not found in the keychain"
        case .duplicateItem:
            return "An item with the specified attributes already exists in the keychain"
        case .authenticationFailed:
            return "Authentication failed for the keychain operation"
        case .unexpectedData:
            return "The keychain returned data in an unexpected format"
        case .storeFailed(let message):
            return "Failed to store item in keychain: \(message)"
        case .retrieveFailed(let message):
            return "Failed to retrieve item from keychain: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete item from keychain: \(message)"
        case .unhandledError(let status):
            return "An unhandled keychain error occurred (status: \(status))"
        case .xpcConnectionFailed:
            return "Failed to establish XPC connection"
        case .xpcConnectionInterrupted:
            return "XPC connection was interrupted"
        case .xpcConnectionInvalidated:
            return "XPC connection was invalidated"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .itemNotFound:
            return "Check that the item exists and you have the correct credentials"
        case .duplicateItem:
            return "Update the existing item instead of creating a new one"
        case .authenticationFailed:
            return "Verify that you have the necessary permissions to access this item"
        case .unexpectedData:
            return "Contact support if this issue persists"
        case .storeFailed:
            return "Check that you have write permissions and try again"
        case .retrieveFailed:
            return "Check that you have read permissions and try again"
        case .deleteFailed:
            return "Check that you have delete permissions and try again"
        case .unhandledError:
            return "Contact support if this issue persists"
        case .xpcConnectionFailed:
            return "Check that the XPC service is running and try again"
        case .xpcConnectionInterrupted:
            return "Try reconnecting to the XPC service"
        case .xpcConnectionInvalidated:
            return "Try restarting the application"
        }
    }

    public static func == (lhs: KeychainError, rhs: KeychainError) -> Bool {
        switch (lhs, rhs) {
        case (.itemNotFound, .itemNotFound),
             (.duplicateItem, .duplicateItem),
             (.authenticationFailed, .authenticationFailed),
             (.unexpectedData, .unexpectedData),
             (.xpcConnectionFailed, .xpcConnectionFailed),
             (.xpcConnectionInterrupted, .xpcConnectionInterrupted),
             (.xpcConnectionInvalidated, .xpcConnectionInvalidated):
            return true
        case (.unhandledError(let lhsStatus), .unhandledError(let rhsStatus)):
            return lhsStatus == rhsStatus
        case (.storeFailed, .storeFailed),
             (.retrieveFailed, .retrieveFailed),
             (.deleteFailed, .deleteFailed):
            return true
        default:
            return false
        }
    }
}
