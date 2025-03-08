import ErrorHandling
import ErrorHandlingDomains
import UmbraCoreTypes

/// FoundationIndependent representation of a security operation result.
/// This data transfer object encapsulates the outcome of security-related operations
/// including success with data or failure with error information.
public struct SecurityResultDTO: Sendable, Equatable {

  // MARK: - Properties

  /// Success or failure status
  public let success: Bool

  /// Operation result data, if successful
  public let data: SecureBytes?

  /// Error code if operation failed
  public let errorCode: Int?

  /// Error message if operation failed
  public let errorMessage: String?

  /// Security error type
  public let error: UmbraErrors.Security.Protocols?

  // MARK: - Initializers

  /// Initialize a successful result with data
  /// - Parameter data: The operation result data
  public init(data: SecureBytes) {
    success=true
    self.data=data
    errorCode=nil
    errorMessage=nil
    error=nil
  }

  /// Initialize a successful result without data
  public init() {
    success=true
    data=nil
    errorCode=nil
    errorMessage=nil
    error=nil
  }

  /// Initialize with success flag and optional data
  /// - Parameters:
  ///   - success: Whether the operation succeeded
  ///   - data: Optional result data
  public init(success: Bool, data: SecureBytes?=nil) {
    self.success=success
    self.data=data
    errorCode=nil
    errorMessage=nil
    error=nil
  }

  /// Initialize a security result
  ///
  /// - Parameters:
  ///   - success: Result status
  ///   - error: Optional error type
  ///   - errorDetails: Optional detailed error message
  public init(
    success: Bool,
    error: UmbraErrors.Security.Protocols?=nil,
    errorDetails: String?=nil
  ) {
    self.success=success
    data=nil
    self.error=error

    // Derive error code based on error type
    if let error {
      switch error {
        case .invalidFormat:
          errorCode=1001
        case .unsupportedOperation:
          errorCode=1002
        case .incompatibleVersion:
          errorCode=1003
        case .missingProtocolImplementation:
          errorCode=1004
        case .invalidState:
          errorCode=1005
        case .internalError:
          errorCode=1006
        @unknown default:
          errorCode=1099
      }

      // Set error description
      errorMessage=errorDetails ?? String(describing: error)
    } else {
      errorCode=nil
      errorMessage=errorDetails
    }
  }

  /// Initialize a failure result with error details
  /// - Parameters:
  ///   - errorCode: Numeric error code
  ///   - errorMessage: Human-readable error message
  public init(errorCode: Int, errorMessage: String) {
    success=false
    data=nil
    self.errorCode=errorCode
    self.errorMessage=errorMessage
    error = .internalError("Error code: \(errorCode), Message: \(errorMessage)")
  }

  // MARK: - Utility Methods

  /// Create a successful result with the given data
  /// - Parameter data: Result data
  /// - Returns: A success result DTO
  public static func success(data: SecureBytes) -> SecurityResultDTO {
    SecurityResultDTO(data: data)
  }

  /// Create a successful result with no data
  /// - Returns: A success result DTO
  public static func success() -> SecurityResultDTO {
    SecurityResultDTO()
  }

  /// Create a failure result with the given error information
  /// - Parameters:
  ///   - code: Error code
  ///   - message: Error message
  /// - Returns: A failure result DTO
  public static func failure(code: Int, message: String) -> SecurityResultDTO {
    SecurityResultDTO(errorCode: code, errorMessage: message)
  }

  /// Create a failure result DTO
  /// - Parameters:
  ///   - error: The security error type
  ///   - details: Optional error details
  /// - Returns: A failure result DTO
  public static func failure(
    error: UmbraErrors.Security.Protocols,
    details: String?=nil
  ) -> SecurityResultDTO {
    SecurityResultDTO(success: false, error: error, errorDetails: details)
  }
}
