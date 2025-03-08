/// SecurityErrorMapper
///
/// Provides functionality for mapping between different SecurityError types across modules.
/// This utility helps resolve ambiguity and provides consistent error handling throughout the
/// UmbraCore security stack.
///
/// Usage:
/// ```swift
/// // Convert any error to CoreErrors.SecurityError
/// let coreError = SecurityErrorMapper.mapToCoreError(error)
///
/// // Convert CoreErrors.SecurityError to an appropriate domain-specific error
/// let domainError = SecurityErrorMapper.mapFromCoreError(coreError)
/// ```

import Foundation

/// Utility for mapping between different SecurityError types in the UmbraCore security stack.
/// This implementation uses type erasure to avoid circular dependencies between modules.
public enum SecurityErrorMapper {

  /// Maps any domain-specific error to the centralised CoreErrors.SecurityError.
  ///
  /// This method uses runtime type identification to handle different error types
  /// without requiring direct imports of all security-related modules.
  ///
  /// - Parameter error: Any error to map
  /// - Returns: The equivalent CoreErrors.SecurityError
  public static func mapToCoreError(_ error: Error) -> SecurityError {
    // Already a CoreErrors.SecurityError - return directly
    if let coreError = error as? SecurityError {
      return coreError
    }

    // Use type name inspection to map from other module's SecurityError types
    // This avoids direct imports while maintaining functionality
    let errorType = String(describing: type(of: error))
    let errorDescription = String(describing: error)

    // Handle SecurityProtocolsCore.SecurityError by inspecting properties
    if errorType.hasSuffix("SecurityError") || errorType.contains("SecurityProtocolsCore") {
      // Extract case information from the error description
      if errorDescription.contains("encryptionFailed") {
        return .encryptionFailed
      } else if errorDescription.contains("decryptionFailed") {
        return .decryptionFailed
      } else if errorDescription.contains("keyGenerationFailed") {
        return .keyGenerationFailed
      } else if errorDescription.contains("invalidData") {
        return .invalidData
      } else if errorDescription.contains("hashingFailed") {
        return .hashingFailed
      } else if errorDescription.contains("serviceFailed") {
        return .serviceFailed
      } else if errorDescription.contains("notImplemented") {
        return .notImplemented
      } else if errorDescription.contains("bookmarkError") {
        return .bookmarkError
      } else if errorDescription.contains("accessError") {
        return .accessError
      } else if errorDescription.contains("cryptoError") {
        return .cryptoError
      } else if errorDescription.contains("bookmarkCreationFailed") {
        return .bookmarkCreationFailed
      } else if errorDescription.contains("bookmarkResolutionFailed") {
        return .bookmarkResolutionFailed
      }
    }

    // Handle XPCProtocolsCore.SecurityProtocolError
    if errorType.contains("SecurityProtocolError") {
      if errorDescription.contains("implementationMissing") {
        let name = extractErrorParam(from: errorDescription, param: "name")
        return .general("Implementation missing: \(name)")
      }
    }

    // Handle XPC errors
    if errorType.contains("XPCErrors.SecurityError") {
      return .general("XPC error: \(errorDescription)")
    }

    // Default case for other error types
    return .general("Unknown error: \(error.localizedDescription)")
  }

  /// Maps from CoreErrors.SecurityError to an appropriate domain-specific error.
  ///
  /// This method provides a way to convert back from the centralised error type
  /// to a module-specific error type. It returns a type-erased Error which can
  /// be cast to the appropriate type by the caller.
  ///
  /// - Parameter error: A CoreErrors.SecurityError
  /// - Returns: An appropriate domain-specific error
  public static func mapFromCoreError(_ error: SecurityError) -> Error {
    // Return the CoreErrors.SecurityError directly
    // Client code will need to handle conversion to specific types
    error
  }

  /// Specialised mapper for XPC errors.
  ///
  /// Maps any Error to a CoreErrors.XPCErrors.SecurityError.
  /// Note that XPCErrors.SecurityError is a type alias for CoreErrors.SecurityError.
  ///
  /// - Parameter error: Any error to map
  /// - Returns: The equivalent CoreErrors.XPCErrors.SecurityError
  public static func mapToXPCError(_ error: Error) -> XPCErrors.SecurityError {
    // Handle existing XPC error
    if let xpcError = error as? XPCErrors.SecurityError {
      return xpcError
    }

    // Map from CoreErrors.SecurityError
    if let coreError = error as? SecurityError {
      // Since XPCErrors.SecurityError is a type alias for CoreErrors.SecurityError,
      // we can simply return the core error
      return coreError
    }

    // For any other error type, convert to CoreErrors.SecurityError first,
    // then return as XPCErrors.SecurityError
    return mapToCoreError(error)
  }

  /// Helper function to convert a CoreErrors.XPCErrors.SecurityError to a
  /// SecurityProtocolsCore.SecurityError
  ///
  /// This helper method provides a consistent way to map from XPC errors to protocol errors.
  /// It uses a type-erased approach to avoid direct module dependencies.
  ///
  /// - Parameter error: The XPC error to convert
  /// - Returns: A protocol error that the client code can cast to the appropriate type
  public static func mapToSPCError(_ error: Error) -> Error {
    // Return the original error - client code will handle the conversion
    // based on the module context where it's called
    error
  }

  /// Maps a CoreErrors.SecurityError to an NSError
  ///
  /// Provides a way to convert SecurityError to Objective-C compatible NSError
  /// for interfacing with Objective-C code.
  ///
  /// - Parameter error: The SecurityError to convert
  /// - Returns: An equivalent NSError
  public static func mapToNSError(_ error: SecurityError) -> NSError {
    let domain = "com.umbra.security.error"
    var code = 0
    var description = ""

    switch error {
      case .encryptionFailed:
        code = 1_001
        description = "Encryption failed"
      case .decryptionFailed:
        code = 1_002
        description = "Decryption failed"
      case .keyGenerationFailed:
        code = 1_003
        description = "Key generation failed"
      case .invalidData:
        code = 1_004
        description = "Invalid data"
      case .hashingFailed:
        code = 1_005
        description = "Hashing failed"
      case .serviceFailed:
        code = 1_006
        description = "Service failed"
      case .notImplemented:
        code = 1_007
        description = "Not implemented"
      case .bookmarkError:
        code = 1_008
        description = "Bookmark error"
      case .accessError:
        code = 1_009
        description = "Access error"
      case .cryptoError:
        code = 1_010
        description = "Crypto error"
      case .bookmarkCreationFailed:
        code = 1_011
        description = "Bookmark creation failed"
      case .bookmarkResolutionFailed:
        code = 1_012
        description = "Bookmark resolution failed"
      case let .general(message):
        code = 1_099
        description = message
    }

    return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
  }

  // MARK: - Helper Methods

  /// Extracts a parameter value from an error description string
  ///
  /// This helper method parses error descriptions to extract parameter values
  /// when mapping between different error types without direct type access.
  ///
  /// - Parameters:
  ///   - description: The error description string to parse
  ///   - param: The parameter name to extract
  /// - Returns: The extracted parameter value or a default string if not found
  private static func extractErrorParam(from description: String, param: String) -> String {
    // Simple parser to extract parameter values from error descriptions
    // Format example: "encryptionFailed(reason: "bad key")"
    guard let paramRange = description.range(of: "\(param): ") else {
      return "Unknown \(param)"
    }

    let valueStart = paramRange.upperBound
    let valueSubstring = description[valueStart...]

    // Handle quoted string values
    if valueSubstring.starts(with: "\"") {
      guard let endQuoteRange = valueSubstring.dropFirst().firstIndex(of: "\"") else {
        return String(valueSubstring)
      }
      let endIndex = valueSubstring.index(endQuoteRange, offsetBy: 1)
      return String(valueSubstring[..<endIndex]).replacingOccurrences(of: "\"", with: "")
    }

    // Handle non-quoted values (extract until next delimiter)
    guard let endParamRange = valueSubstring.firstIndex(where: { $0 == "," || $0 == ")" }) else {
      return String(valueSubstring)
    }

    return String(valueSubstring[..<endParamRange])
  }
}
