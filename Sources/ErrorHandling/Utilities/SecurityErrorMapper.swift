import Foundation
import ErrorHandling
import ErrorHandlingCommon
import ErrorHandlingCore
import ErrorHandlingDomains
import ErrorHandlingInterfaces
import ErrorHandlingMapping
import ErrorHandlingModels

/// A utility class for mapping security errors between different domains
public class SecurityErrorMapper {
  /// Initialiser for the SecurityErrorMapper
  public init() {}
  
  /// Maps an external error to a security core error
  /// - Parameter error: The external error to map
  /// - Returns: A mapped security core error, or nil if mapping is not possible
  public func mapToCoreError(_ error: Error) -> UmbraErrors.GeneralSecurity.Core? {
    // Check if the error is already a security error
    if let securityError = error as? UmbraErrors.GeneralSecurity.Core {
      return securityError
    }
    
    // Extract error information from the external error
    let nsError = error as NSError
    let domain = nsError.domain
    let code = nsError.code
    let userInfo = nsError.userInfo
    
    // Map common error patterns to security core errors
    
    // Authentication errors
    if domain == "com.auth.error" || domain.contains("authentication") {
      return .invalidInput(reason: "Authentication failed: \(nsError.localizedDescription)")
    }
    
    // Encryption/decryption errors
    if domain.contains("crypto") || domain.contains("encryption") {
      if code == -1 {
        return .encryptionFailed(reason: "Encryption operation failed: \(nsError.localizedDescription)")
      } else if code == -2 {
        return .decryptionFailed(reason: "Decryption operation failed: \(nsError.localizedDescription)")
      } else if code == -3 {
        return .keyGenerationFailed(reason: "Key generation failed: \(nsError.localizedDescription)")
      }
    }
    
    // Timeout errors
    if domain.contains("timeout") || nsError.localizedDescription.contains("timed out") {
      return .timeout(operation: "Security operation")
    }
    
    // Hash verification errors
    if domain.contains("hash") || domain.contains("verification") {
      return .hashVerificationFailed(reason: "Hash verification failed: \(nsError.localizedDescription)")
    }
    
    // Default to internal error if no specific mapping is found
    return .internalError("Unmapped external error: \(nsError.localizedDescription)")
  }
  
  /// Maps a security core error to a generic error
  /// - Parameter error: The security core error to map
  /// - Returns: A generic error representation
  public func mapToGenericError(_ error: UmbraErrors.GeneralSecurity.Core) -> GenericError {
    let source = ErrorHandlingInterfaces.ErrorSource(
      file: #file,
      line: #line,
      function: #function
    )
    
    let context = ErrorHandlingInterfaces.ErrorContext(
      source: "SecurityModule",
      operation: "SecurityOperation",
      details: "Mapped from security core error"
    )
    
    // Create a generic error with appropriate details
    return GenericError(
      domain: "Security",
      code: String(describing: error),
      message: getErrorMessage(from: error),
      details: [:],
      source: source,
      underlyingError: error,
      context: context
    )
  }
  
  /// Extracts a user-friendly message from a security core error
  /// - Parameter error: The security core error
  /// - Returns: A user-friendly error message
  private func getErrorMessage(from error: UmbraErrors.GeneralSecurity.Core) -> String {
    switch error {
    case .encryptionFailed(let reason):
      return "Encryption failed: \(reason)"
    case .decryptionFailed(let reason):
      return "Decryption failed: \(reason)"
    case .keyGenerationFailed(let reason):
      return "Key generation failed: \(reason)"
    case .invalidKey(let reason):
      return "Invalid key: \(reason)"
    case .hashVerificationFailed(let reason):
      return "Hash verification failed: \(reason)"
    case .randomGenerationFailed(let reason):
      return "Random generation failed: \(reason)"
    case .invalidInput(let reason):
      return "Invalid input: \(reason)"
    case .storageOperationFailed(let reason):
      return "Storage operation failed: \(reason)"
    case .timeout(let operation):
      return "Operation timed out: \(operation)"
    case .serviceError(let code, let reason):
      return "Service error \(code): \(reason)"
    case .internalError(let message):
      return "Internal error: \(message)"
    case .notImplemented(let feature):
      return "Not implemented: \(feature)"
    }
  }
}
