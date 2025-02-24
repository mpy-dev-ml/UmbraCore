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
            return "Check that the data format is correct"
        case .unhandledError:
            return "Try the operation again. If the problem persists, check the system keychain status"
        case .xpcConnectionFailed:
            return "Check that the XPC service is running and try again"
        case .xpcConnectionInterrupted:
            return "The operation was interrupted. Try again"
        case .xpcConnectionInvalidated:
            return "The XPC connection is no longer valid. Restart the service"
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
        default:
            return false
        }
    }
}
