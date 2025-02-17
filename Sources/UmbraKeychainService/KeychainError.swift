import Foundation

/// Errors that can occur during keychain operations
public enum KeychainError: LocalizedError, Equatable {
    /// Item not found in the keychain
    case itemNotFound
    /// Item already exists in the keychain
    case duplicateItem
    /// Invalid data returned from keychain
    case invalidData
    /// Invalid format for keychain item
    case invalidItemFormat
    /// Access to keychain item was denied
    case accessDenied
    /// Unexpected status code from keychain operation
    case unexpectedStatus(OSStatus)
    /// XPC connection failed
    case xpcConnectionFailed
    /// XPC connection was interrupted
    case xpcConnectionInterrupted
    /// XPC connection was invalidated
    case xpcConnectionInvalid
    /// Unknown keychain error
    case unknown

    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        case .invalidData:
            return "Invalid data returned from keychain"
        case .invalidItemFormat:
            return "Invalid format for keychain item"
        case .accessDenied:
            return "Access to keychain item was denied"
        case .unexpectedStatus(let status):
            return "Unexpected keychain status: \(status)"
        case .xpcConnectionFailed:
            return "Failed to establish XPC connection"
        case .xpcConnectionInterrupted:
            return "XPC connection was interrupted"
        case .xpcConnectionInvalid:
            return "XPC connection was invalidated"
        case .unknown:
            return "An unknown keychain error occurred"
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
        case .invalidItemFormat:
            return "Check that the item format matches the expected structure"
        case .accessDenied:
            return "Verify that you have the necessary permissions to access this item"
        case .unexpectedStatus:
            return "Try the operation again. If the problem persists, check the system keychain status"
        case .xpcConnectionFailed:
            return "Check that the XPC service is running and try again"
        case .xpcConnectionInterrupted:
            return "The operation was interrupted. Try again"
        case .xpcConnectionInvalid:
            return "The XPC connection is no longer valid. Restart the service"
        case .unknown:
            return "Try the operation again"
        }
    }

    public static func == (lhs: KeychainError, rhs: KeychainError) -> Bool {
        switch (lhs, rhs) {
        case (.itemNotFound, .itemNotFound),
             (.duplicateItem, .duplicateItem),
             (.invalidData, .invalidData),
             (.invalidItemFormat, .invalidItemFormat),
             (.accessDenied, .accessDenied),
             (.xpcConnectionFailed, .xpcConnectionFailed),
             (.xpcConnectionInterrupted, .xpcConnectionInterrupted),
             (.xpcConnectionInvalid, .xpcConnectionInvalid),
             (.unknown, .unknown):
            return true
        case (.unexpectedStatus(let lhsStatus), .unexpectedStatus(let rhsStatus)):
            return lhsStatus == rhsStatus
        default:
            return false
        }
    }
}
