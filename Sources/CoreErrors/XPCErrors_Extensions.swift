/// XPC-specific error types and namespace extensions
///
/// This file provides XPC-specific error type extensions to support
/// the XPC Protocol Consolidation efforts.

import ErrorHandling
import ErrorHandlingDomains

/// Namespace for XPC-specific error types
/// @available(*, deprecated, message: "Use UmbraErrors.Security.XPC directly")
public enum XPCErrors {
  /// XPC Security Error type alias
  /// This provides a clear namespace for XPC security errors
  /// @available(*, deprecated, message: "Use UmbraErrors.Security.XPC directly")
  public typealias SecurityError=UmbraErrors.Security.XPC

  /// XPC Service Error type alias
  /// @available(*, deprecated, message: "Use UmbraErrors.Service directly")
  public typealias ServiceError=CoreErrors.ServiceError

  /// XPC Crypto Error type alias
  /// @available(*, deprecated, message: "Use UmbraErrors.Crypto directly")
  public typealias CryptoError=CoreErrors.CryptoError
}

/// Extension for UmbraErrors.Security.Core with XPC-specific functionality
extension UmbraErrors.Security.Core {
  /// Convert to XPC error representation
  /// - Returns: XPC representation of this error
  public func toXPC() -> UmbraErrors.Security.XPC {
    SecurityErrorMapper.mapToXPCError(self)
  }
}

/// Extension for UmbraErrors.Security.XPC with conversion functionality
extension UmbraErrors.Security.XPC {
  /// Convert to Core error representation
  /// - Returns: Core representation of this error
  public func toCore() -> UmbraErrors.Security.Core {
    SecurityErrorMapper.mapToCoreError(self)
  }

  /// Convert to Protocol error representation
  /// - Returns: Protocol representation of this error
  public func toProtocol() -> UmbraErrors.Security.Protocols {
    SecurityErrorMapper.mapToProtocolError(self)
  }
}

/// Extension for UmbraErrors.Security.Protocols with conversion functionality
extension UmbraErrors.Security.Protocols {
  /// Convert to XPC error representation
  /// - Returns: XPC representation of this error
  public func toXPC() -> UmbraErrors.Security.XPC {
    SecurityErrorMapper.mapToXPCError(self)
  }

  /// Convert to Core error representation
  /// - Returns: Core representation of this error
  public func toCore() -> UmbraErrors.Security.Core {
    SecurityErrorMapper.mapToCoreError(self)
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
