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
  public let error: SecurityError?

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

  /// Initialize with success flag and error
  /// - Parameters:
  ///   - success: Whether the operation succeeded
  ///   - error: Optional error type
  ///   - errorDetails: Optional detailed error message
  public init(success: Bool, error: SecurityError?=nil, errorDetails: String?=nil) {
    self.success=success
    data=nil
    self.error=error

    // Derive error code based on error type
    if let error {
      switch error {
        case .encryptionFailed:
          errorCode=1001
        case .decryptionFailed:
          errorCode=1002
        case .keyGenerationFailed:
          errorCode=1003
        case .invalidKey:
          errorCode=1004
        case .hashVerificationFailed:
          errorCode=1005
        case .randomGenerationFailed:
          errorCode=1006
        case .invalidInput:
          errorCode=1007
        case .storageOperationFailed:
          errorCode=1008
        case .timeout:
          errorCode=1009
        case let .serviceError(code, _):
          errorCode=code
        case .internalError:
          errorCode=1010
        case .notImplemented:
          errorCode=1011
      }

      // Use error description if no specific details provided
      errorMessage=errorDetails ?? error.description
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
    error = .serviceError(code: errorCode, reason: errorMessage)
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

  /// Create a failure result with a SecurityError
  /// - Parameters:
  ///   - error: The security error that occurred
  ///   - details: Optional additional details
  /// - Returns: A failure result DTO
  public static func failure(error: SecurityError, details: String?=nil) -> SecurityResultDTO {
    SecurityResultDTO(success: false, error: error, errorDetails: details)
  }
}
