/// Custom error for security interfaces that doesn't require Foundation dependencies
public enum SecurityBridgeError: Error, Sendable {
    /// Error when an implementation is missing
    case implementationMissing(String)
    
    /// Error when an operation is not supported
    case operationNotSupported(String)
    
    /// Error when data conversion fails
    case dataConversionFailed(String)
    
    /// Error when a security operation fails
    case securityOperationFailed(String)
    
    /// Error when a parameter is invalid
    case invalidParameter(String)
    
    /// Error when authentication fails
    case authenticationFailed(String)
    
    /// Error when a service is unavailable
    case serviceUnavailable(String)
    
    /// Error when a timeout occurs
    case timeout(String)
    
    /// Unknown error with description
    case unknown(String)
}
