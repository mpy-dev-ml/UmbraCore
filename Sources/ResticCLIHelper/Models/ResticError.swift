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

    /// Invalid configuration
    case invalidConfiguration(String)

    /// Repository error
    case repositoryError(String)

    /// Authentication error
    case authenticationError(String)

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
        case .invalidConfiguration(let details):
            return "Invalid configuration: \(details)"
        case .repositoryError(let details):
            return "Repository error: \(details)"
        case .authenticationError(let details):
            return "Authentication error: \(details)"
        case .other(let message):
            return message
        }
    }

    private static func compareAssociatedValues<T: Equatable>(_ lhs: T, _ rhs: T) -> Bool {
        return lhs == rhs
    }

    private static func compareNetworkErrors(_ lhs: Error, _ rhs: Error) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }

    private static func compareCommandFailure(_ lhs: (Int, String), _ rhs: (Int, String)) -> Bool {
        return lhs.0 == rhs.0 && lhs.1 == rhs.1
    }

    private static func compareSimpleErrors(
        _ lhs: ResticError,
        _ rhs: ResticError
    ) -> Bool? {
        switch (lhs, rhs) {
        case (.missingParameter(let left), .missingParameter(let right)):
            return compareAssociatedValues(left, right)
        case (.invalidParameter(let left), .invalidParameter(let right)):
            return compareAssociatedValues(left, right)
        case (.invalidPath(let left), .invalidPath(let right)):
            return compareAssociatedValues(left, right)
        case (.executionFailed(let left), .executionFailed(let right)):
            return compareAssociatedValues(left, right)
        case (.invalidData(let left), .invalidData(let right)):
            return compareAssociatedValues(left, right)
        case (.outputParsingFailed(let left), .outputParsingFailed(let right)):
            return compareAssociatedValues(left, right)
        case (.invalidPassword, .invalidPassword):
            return true
        default:
            return nil
        }
    }

    private static func compareRepositoryErrors(
        _ lhs: ResticError,
        _ rhs: ResticError
    ) -> Bool? {
        switch (lhs, rhs) {
        case (.repositoryNotFound(let left), .repositoryNotFound(let right)):
            return compareAssociatedValues(left, right)
        case (.repositoryCorrupted(let left), .repositoryCorrupted(let right)):
            return compareAssociatedValues(left, right)
        case (.repositoryError(let left), .repositoryError(let right)):
            return compareAssociatedValues(left, right)
        default:
            return nil
        }
    }

    private static func compareAuthAndConfigErrors(
        _ lhs: ResticError,
        _ rhs: ResticError
    ) -> Bool? {
        switch (lhs, rhs) {
        case (.permissionDenied(let left), .permissionDenied(let right)):
            return compareAssociatedValues(left, right)
        case (.invalidArguments(let left), .invalidArguments(let right)):
            return compareAssociatedValues(left, right)
        case (.invalidConfiguration(let left), .invalidConfiguration(let right)):
            return compareAssociatedValues(left, right)
        case (.authenticationError(let left), .authenticationError(let right)):
            return compareAssociatedValues(left, right)
        default:
            return nil
        }
    }

    private static func compareComplexErrors(
        _ lhs: ResticError,
        _ rhs: ResticError
    ) -> Bool? {
        switch (lhs, rhs) {
        case (
            .commandFailed(let exitCode1, let msg1),
            .commandFailed(let exitCode2, let msg2)
        ):
            return compareCommandFailure((exitCode1, msg1), (exitCode2, msg2))
        case (.networkError(let left), .networkError(let right)):
            return compareNetworkErrors(left, right)
        case (.other(let left), .other(let right)):
            return compareAssociatedValues(left, right)
        default:
            return nil
        }
    }

    public static func == (lhs: ResticError, rhs: ResticError) -> Bool {
        // Try comparing simple errors first
        if let result = compareSimpleErrors(lhs, rhs) {
            return result
        }

        // Try comparing repository-related errors
        if let result = compareRepositoryErrors(lhs, rhs) {
            return result
        }

        // Try comparing authentication and configuration errors
        if let result = compareAuthAndConfigErrors(lhs, rhs) {
            return result
        }

        // Finally, try comparing complex errors
        if let result = compareComplexErrors(lhs, rhs) {
            return result
        }

        // If no comparison matched, the errors are different
        return false
    }
}
