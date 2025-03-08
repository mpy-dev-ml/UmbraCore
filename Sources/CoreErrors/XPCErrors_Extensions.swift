/// XPC-specific error types and namespace extensions
///
/// This file provides XPC-specific error type extensions to support
/// the XPC Protocol Consolidation efforts.

/// Namespace for XPC-specific error types
public enum XPCErrors {
  /// XPC Security Error type alias
  /// This provides a clear namespace for XPC security errors
  public typealias SecurityError = CoreErrors.SecurityError

  /// XPC Service Error type alias
  public typealias ServiceError = CoreErrors.ServiceError

  /// XPC Crypto Error type alias
  public typealias CryptoError = CoreErrors.CryptoError
}

/// Extension for SecurityError with XPC-specific functionality
extension SecurityError {
  /// Convert from XPC error representation
  /// - Parameter error: The XPC representation of the error
  /// - Returns: Corresponding SecurityError
  public static func fromXPC(_ error: XPCErrors.SecurityError) -> SecurityError {
    error as SecurityError
  }

  /// Convert to XPC error representation
  /// - Returns: XPC representation of this error
  public func toXPC() -> XPCErrors.SecurityError {
    self as XPCErrors.SecurityError
  }
}

/// Extension for ServiceError with XPC-specific functionality
extension ServiceError {
  /// Convert from XPC error representation
  /// - Parameter error: The XPC representation of the error
  /// - Returns: Corresponding ServiceError
  public static func fromXPC(_ error: XPCErrors.ServiceError) -> ServiceError {
    error as ServiceError
  }

  /// Convert to XPC error representation
  /// - Returns: XPC representation of this error
  public func toXPC() -> XPCErrors.ServiceError {
    self as XPCErrors.ServiceError
  }
}

/// Extension for CryptoError with XPC-specific functionality
extension CryptoError {
  /// Convert from XPC error representation
  /// - Parameter error: The XPC representation of the error
  /// - Returns: Corresponding CryptoError
  public static func fromXPC(_ error: XPCErrors.CryptoError) -> CryptoError {
    error as CryptoError
  }

  /// Convert to XPC error representation
  /// - Returns: XPC representation of this error
  public func toXPC() -> XPCErrors.CryptoError {
    self as XPCErrors.CryptoError
  }
}
