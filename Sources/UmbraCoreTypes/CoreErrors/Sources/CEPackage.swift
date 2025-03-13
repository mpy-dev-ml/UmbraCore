import CoreErrors
import ErrorHandlingDomains

// MARK: - Type Aliases for CoreErrors Types

/// Type alias for CoreErrors.ResourceError
public typealias CEResourceError = CoreErrors.ResourceError

/// Type alias for CoreErrors.SecurityError
public typealias CESecurityError = CoreErrors.SecurityError

// MARK: - Error Types Definition

/// Error types specific to UmbraCoreTypes SecureBytes
public enum SecureBytesError: Error, Equatable {
    case invalidHexString
    case outOfBounds
    case allocationFailed
}

/// Error types specific to UmbraCoreTypes TimePoint
public enum TimePointError: Error, Equatable {
    case invalidFormat
    case outOfRange
}
