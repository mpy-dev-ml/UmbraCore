import Foundation

/// Errors that can occur when working with Restic
public enum ResticError: LocalizedError, Equatable {
    /// A required parameter is missing
    case missingParameter(String)

    /// A parameter has an invalid value
    case invalidParameter(String)

    /// A path is invalid or does not exist
    case invalidPath(String)

    /// Command execution failed
    case executionFailed(String)

    /// Invalid data format
    case invalidData(String)

    /// Output parsing failed
    case outputParsingFailed(String)

    /// Command execution failed with specific exit code
    case commandFailed(exitCode: Int, message: String)

    /// Repository not found or inaccessible
    case repositoryNotFound(path: String)

    /// Invalid repository password
    case invalidPassword

    /// Repository is corrupted
    case repositoryCorrupted(details: String)

    /// Network error occurred
    case networkError(underlying: Error)

    /// Permission denied
    case permissionDenied(path: String)

    /// Invalid command arguments
    case invalidArguments(details: String)

    /// Generic error
    case other(message: String)

    public var errorDescription: String? {
        switch self {
        case .missingParameter(let param):
            return "Missing required parameter: \(param)"
        case .invalidParameter(let details):
            return "Invalid parameter: \(details)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .executionFailed(let error):
            return "Command execution failed: \(error)"
        case .invalidData(let details):
            return "Invalid data format: \(details)"
        case .outputParsingFailed(let details):
            return "Failed to parse output: \(details)"
        case .commandFailed(let exitCode, let message):
            return "Command failed with exit code \(exitCode): \(message)"
        case .repositoryNotFound(let path):
            return "Repository not found at path: \(path)"
        case .invalidPassword:
            return "Invalid repository password"
        case .repositoryCorrupted(let details):
            return "Repository is corrupted: \(details)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .invalidArguments(let details):
            return "Invalid arguments: \(details)"
        case .other(let message):
            return message
        }
    }

    public static func == (lhs: ResticError, rhs: ResticError) -> Bool {
        switch (lhs, rhs) {
        case (.missingParameter(let l), .missingParameter(let r)): return l == r
        case (.invalidParameter(let l), .invalidParameter(let r)): return l == r
        case (.invalidPath(let l), .invalidPath(let r)): return l == r
        case (.executionFailed(let l), .executionFailed(let r)): return l == r
        case (.invalidData(let l), .invalidData(let r)): return l == r
        case (.outputParsingFailed(let l), .outputParsingFailed(let r)): return l == r
        case (.commandFailed(let l1, let l2), .commandFailed(let r1, let r2)): return l1 == r1 && l2 == r2
        case (.repositoryNotFound(let l), .repositoryNotFound(let r)): return l == r
        case (.invalidPassword, .invalidPassword): return true
        case (.repositoryCorrupted(let l), .repositoryCorrupted(let r)): return l == r
        case (.networkError(let l), .networkError(let r)): return l.localizedDescription == r.localizedDescription
        case (.permissionDenied(let l), .permissionDenied(let r)): return l == r
        case (.invalidArguments(let l), .invalidArguments(let r)): return l == r
        case (.other(let l), .other(let r)): return l == r
        default: return false
        }
    }
}
