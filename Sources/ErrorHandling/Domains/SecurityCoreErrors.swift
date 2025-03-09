import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors.Security {
  /// Core security errors related to authentication, authorisation, encryption, etc.
  public enum Core: Error, UmbraError, StandardErrorCapabilities, AuthenticationErrors, SecurityOperationErrors {
    // Authentication errors
    /// Authentication failed due to invalid credentials or expired session
    case authenticationFailed(reason: String)
    
    /// Authorisation failed due to insufficient permissions
    case authorizationFailed(reason: String)
    
    /// Insufficient permissions to access a resource
    case insufficientPermissions(resource: String, requiredPermission: String)
    
    // Cryptographic operation errors
    /// Encryption operation failed
    case encryptionFailed(reason: String)
    
    /// Decryption operation failed
    case decryptionFailed(reason: String)
    
    /// Hash operation failed
    case hashingFailed(reason: String)
    
    /// Signature verification failed
    case signatureInvalid(reason: String)
    
    /// Invalid certificate or certificate chain
    case certificateInvalid(reason: String)
    
    /// Certificate has expired
    case certificateExpired(reason: String)
    
    // Security policy errors
    /// Operation violates security policy
    case policyViolation(policy: String, reason: String)
    
    /// Secure connection failed
    case secureConnectionFailed(reason: String)
    
    /// Secure storage operation failed
    case secureStorageFailed(operation: String, reason: String)
    
    /// Tampered data detected
    case dataIntegrityViolation(reason: String)
    
    /// Generic security error
    case internalError(reason: String)
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for security core errors
    public var domain: String {
      "Security.Core"
    }
    
    /// Error code uniquely identifying the error type
    public var code: String {
      switch self {
      case .authenticationFailed:
        return "authentication_failed"
      case .authorizationFailed:
        return "authorization_failed"
      case .insufficientPermissions:
        return "insufficient_permissions"
      case .encryptionFailed:
        return "encryption_failed"
      case .decryptionFailed:
        return "decryption_failed"
      case .hashingFailed:
        return "hashing_failed"
      case .signatureInvalid:
        return "signature_invalid"
      case .certificateInvalid:
        return "certificate_invalid"
      case .certificateExpired:
        return "certificate_expired"
      case .policyViolation:
        return "policy_violation"
      case .secureConnectionFailed:
        return "secure_connection_failed"
      case .secureStorageFailed:
        return "secure_storage_failed"
      case .dataIntegrityViolation:
        return "data_integrity_violation"
      case .internalError:
        return "internal_error"
      }
    }
    
    /// Human-readable description of the error
    public var errorDescription: String {
      switch self {
      case let .authenticationFailed(reason):
        return "Authentication failed: \(reason)"
      case let .authorizationFailed(reason):
        return "Authorisation failed: \(reason)"
      case let .insufficientPermissions(resource, permission):
        return "Insufficient permissions to access \(resource). Required: \(permission)"
      case let .encryptionFailed(reason):
        return "Encryption failed: \(reason)"
      case let .decryptionFailed(reason):
        return "Decryption failed: \(reason)"
      case let .hashingFailed(reason):
        return "Hash operation failed: \(reason)"
      case let .signatureInvalid(reason):
        return "Signature verification failed: \(reason)"
      case let .certificateInvalid(reason):
        return "Invalid certificate: \(reason)"
      case let .certificateExpired(reason):
        return "Certificate expired: \(reason)"
      case let .policyViolation(policy, reason):
        return "Security policy violation (\(policy)): \(reason)"
      case let .secureConnectionFailed(reason):
        return "Secure connection failed: \(reason)"
      case let .secureStorageFailed(operation, reason):
        return "Secure storage operation '\(operation)' failed: \(reason)"
      case let .dataIntegrityViolation(reason):
        return "Data integrity violation detected: \(reason)"
      case let .internalError(reason):
        return "Internal security error: \(reason)"
      }
    }
    
    /// Source information about where the error occurred
    public var source: ErrorHandlingInterfaces.ErrorSource? {
      nil // Source is typically set when the error is created with context
    }
    
    /// The underlying error, if any
    public var underlyingError: Error? {
      nil // Underlying error is typically set when the error is created with context
    }
    
    /// Additional context for the error
    public var context: ErrorHandlingInterfaces.ErrorContext {
      ErrorHandlingInterfaces.ErrorContext(
        source: domain,
        operation: "security_operation",
        details: errorDescription
      )
    }
    
    /// Creates a new instance of the error with additional context
    public func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
      // Since these are enum cases, we need to return a new instance with the same value
      switch self {
      case let .authenticationFailed(reason):
        return .authenticationFailed(reason: reason)
      case let .authorizationFailed(reason):
        return .authorizationFailed(reason: reason)
      case let .insufficientPermissions(resource, permission):
        return .insufficientPermissions(resource: resource, requiredPermission: permission)
      case let .encryptionFailed(reason):
        return .encryptionFailed(reason: reason)
      case let .decryptionFailed(reason):
        return .decryptionFailed(reason: reason)
      case let .hashingFailed(reason):
        return .hashingFailed(reason: reason)
      case let .signatureInvalid(reason):
        return .signatureInvalid(reason: reason)
      case let .certificateInvalid(reason):
        return .certificateInvalid(reason: reason)
      case let .certificateExpired(reason):
        return .certificateExpired(reason: reason)
      case let .policyViolation(policy, reason):
        return .policyViolation(policy: policy, reason: reason)
      case let .secureConnectionFailed(reason):
        return .secureConnectionFailed(reason: reason)
      case let .secureStorageFailed(operation, reason):
        return .secureStorageFailed(operation: operation, reason: reason)
      case let .dataIntegrityViolation(reason):
        return .dataIntegrityViolation(reason: reason)
      case let .internalError(reason):
        return .internalError(reason: reason)
      }
      // In a real implementation, we would attach the context
    }
    
    /// Creates a new instance of the error with a specified underlying error
    public func with(underlyingError: Error) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the underlying error
    }
    
    /// Creates a new instance of the error with source information
    public func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
      // Similar to above, return a new instance with the same value
      self // In a real implementation, we would attach the source information
    }
    
    // MARK: - AuthenticationErrors Protocol
    
    /// Creates an authentication failure error
    public static func authenticationFailed(reason: String) -> Self {
      .authenticationFailed(reason: reason)
    }
    
    /// Creates an authorization failure error
    public static func authorizationFailed(reason: String) -> Self {
      .authorizationFailed(reason: reason)
    }
    
    /// Creates an error for insufficient permissions
    public static func insufficientPermissions(resource: String, requiredPermission: String) -> Self {
      .insufficientPermissions(resource: resource, requiredPermission: requiredPermission)
    }
    
    // MARK: - SecurityOperationErrors Protocol
    
    /// Creates an error for encryption failure
    public static func encryptionFailed(reason: String) -> Self {
      .encryptionFailed(reason: reason)
    }
    
    /// Creates an error for decryption failure
    public static func decryptionFailed(reason: String) -> Self {
      .decryptionFailed(reason: reason)
    }
    
    /// Creates an error for signature verification failure
    public static func signatureInvalid(reason: String) -> Self {
      .signatureInvalid(reason: reason)
    }
    
    /// Creates an error for hashing failure
    public static func hashingFailed(reason: String) -> Self {
      .hashingFailed(reason: reason)
    }
  }
}
