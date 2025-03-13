import Foundation
import ErrorHandling

/// Test error type for security error handling tests
public enum SecTestError: Error, CustomStringConvertible, Equatable {
    case invalidInput(String)
    case invalidKey(String)
    case cryptoError(String)
    case invalidData(String)
    case accessDenied(reason: String)
    case itemNotFound(String)
    case invalidSecurityState(reason: String, state: String? = nil, expectedState: String? = nil)
    case bookmarkError(String)
    case operationFailed(String)
    case accessError(String)
    case internalError(String)
    
    public var description: String {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidKey(let message):
            return "Invalid key: \(message)"
        case .cryptoError(let message):
            return "Crypto error: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .accessDenied(let reason):
            return "Access denied: \(reason)"
        case .itemNotFound(let message):
            return "Item not found: \(message)"
        case .invalidSecurityState(let reason, let state, let expectedState):
            if let state = state, let expectedState = expectedState {
                return "Invalid security state: current '\(state)', expected '\(expectedState)': \(reason)"
            } else {
                return "Invalid security state: \(reason)"
            }
        case .bookmarkError(let message):
            return "Bookmark error: \(message)"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .accessError(let message):
            return "Access error: \(message)"
        case .internalError(let message):
            return "Internal error: \(message)"
        }
    }
}
