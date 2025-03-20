import CoreErrors

/// Type alias for the SecurityError type
public typealias XPCSecurityError = SecurityError

/// Foundation-independent representation of an XPC security error.
/// This DTO is designed to replace the XPCSecurityError type in contexts
/// where Foundation independence is required.
public struct XPCSecurityErrorDTO: Error, Sendable, Equatable, CustomStringConvertible {
    // MARK: - Error Code Enum
    
    /// Enumeration of XPC security error codes
    public enum ErrorCode: Int32, Sendable, Equatable, CustomStringConvertible {
        /// Unknown error
        case unknown = 0
        /// Invalid input data or parameters
        case invalidInput = 1001
        /// Cryptographic operation failed
        case cryptographicError = 1002
        /// Key not found
        case keyNotFound = 1003
        /// Service is unavailable
        case serviceUnavailable = 1004
        /// Operation not supported
        case unsupportedOperation = 1005
        /// Permission denied
        case permissionDenied = 1007
        
        /// String description of the error code
        public var description: String {
            switch self {
            case .unknown:
                "Unknown Error"
            case .invalidInput:
                "Invalid Input"
            case .cryptographicError:
                "Cryptographic Error"
            case .keyNotFound:
                "Key Not Found"
            case .serviceUnavailable:
                "Service Unavailable"
            case .unsupportedOperation:
                "Unsupported Operation"
            case .permissionDenied:
                "Permission Denied"
            }
        }
    }
    
    // MARK: - Properties
    
    /// Error code
    public let code: ErrorCode
    
    /// Error message
    public var message: String {
        return details["message"] ?? code.description
    }
    
    /// Additional details about the error
    public let details: [String: String]
    
    // MARK: - Initialization
    
    /// Create an XPC security error DTO
    /// - Parameters:
    ///   - code: Error code
    ///   - details: Additional details
    public init(code: ErrorCode, details: [String: String] = [:]) {
        self.code = code
        self.details = details
    }
    
    // MARK: - CustomStringConvertible
    
    /// String description of the error
    public var description: String {
        if details.isEmpty {
            return "\(code.description)"
        }
        return "\(code.description): \(message)"
    }
    
    // MARK: - Factory Methods
    
    /// Create an unknown error
    /// - Parameter details: Optional error details
    /// - Returns: An XPCSecurityErrorDTO
    public static func unknown(details: String? = nil) -> XPCSecurityErrorDTO {
        var detailsDict: [String: String] = [:]
        if let details = details {
            detailsDict["message"] = details
        }
        return XPCSecurityErrorDTO(code: .unknown, details: detailsDict)
    }
    
    /// Create an invalid input error
    /// - Parameter details: Description of the invalid input
    /// - Returns: An XPCSecurityErrorDTO
    public static func invalidInput(details: String) -> XPCSecurityErrorDTO {
        return XPCSecurityErrorDTO(
            code: .invalidInput,
            details: ["message": details]
        )
    }
    
    /// Create a cryptographic error
    /// - Parameters:
    ///   - operation: The operation that failed
    ///   - details: Error details
    /// - Returns: An XPCSecurityErrorDTO
    public static func cryptographicError(
        operation: String,
        details: String
    ) -> XPCSecurityErrorDTO {
        return XPCSecurityErrorDTO(
            code: .cryptographicError,
            details: [
                "operation": operation,
                "message": details
            ]
        )
    }
    
    /// Create a key not found error
    /// - Parameter identifier: Key identifier
    /// - Returns: An XPCSecurityErrorDTO
    public static func keyNotFound(identifier: String) -> XPCSecurityErrorDTO {
        return XPCSecurityErrorDTO(
            code: .keyNotFound,
            details: ["keyIdentifier": identifier]
        )
    }
    
    /// Create a service unavailable error
    /// - Parameters:
    ///   - service: Service name
    ///   - reason: Reason for unavailability
    /// - Returns: An XPCSecurityErrorDTO
    public static func serviceUnavailable(
        service: String = "XPC Service",
        reason: String = "Service is not available"
    ) -> XPCSecurityErrorDTO {
        return XPCSecurityErrorDTO(
            code: .serviceUnavailable,
            details: [
                "service": service,
                "reason": reason
            ]
        )
    }
    
    /// Create an unsupported operation error
    /// - Parameter operation: Operation name
    /// - Returns: An XPCSecurityErrorDTO
    public static func unsupportedOperation(operation: String) -> XPCSecurityErrorDTO {
        return XPCSecurityErrorDTO(
            code: .unsupportedOperation,
            details: ["operation": operation]
        )
    }
    
    /// Create a permission denied error
    /// - Parameter details: Error details
    /// - Returns: An XPCSecurityErrorDTO
    public static func permissionDenied(details: String) -> XPCSecurityErrorDTO {
        return XPCSecurityErrorDTO(
            code: .permissionDenied,
            details: ["message": details]
        )
    }
}

/// Basic service status DTO for XPC services
public struct ServiceStatusDTO: Equatable {
    /// The current service status (e.g., "healthy", "degraded", "unavailable")
    public let status: String
    
    /// The service version
    public let version: String
    
    /// Additional key-value information as strings
    public let stringInfo: [String: String]
    
    /// Additional key-value information as integers
    public let intInfo: [String: Int]
    
    /// Initialize a new ServiceStatusDTO
    /// - Parameters:
    ///   - status: The current service status
    ///   - version: The service version
    ///   - stringInfo: Additional string information
    ///   - intInfo: Additional integer information
    public init(
        status: String,
        version: String,
        stringInfo: [String: String] = [:],
        intInfo: [String: Int] = [:]
    ) {
        self.status = status
        self.version = version
        self.stringInfo = stringInfo
        self.intInfo = intInfo
    }
}

/// Key information DTO
public struct KeyInfoDTO: Equatable {
    /// The key identifier
    public let identifier: String
    
    /// The key type
    public let type: KeyTypeDTO
    
    /// Indicates if the key is protected by secure enclave
    public let isSecureEnclaveProtected: Bool
    
    /// Additional attributes
    public let attributes: [String: String]
    
    /// Initialize a new KeyInfoDTO
    /// - Parameters:
    ///   - identifier: The key identifier
    ///   - type: The key type
    ///   - isSecureEnclaveProtected: Indicates if the key is protected by secure enclave
    ///   - attributes: Additional attributes
    public init(
        identifier: String,
        type: KeyTypeDTO,
        isSecureEnclaveProtected: Bool = false,
        attributes: [String: String] = [:]
    ) {
        self.identifier = identifier
        self.type = type
        self.isSecureEnclaveProtected = isSecureEnclaveProtected
        self.attributes = attributes
    }
}

/// Key type DTO
public enum KeyTypeDTO: String, Equatable {
    case rsa
    case ec
    case aes
    case hmac
    case unknown
}
