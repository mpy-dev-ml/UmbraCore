import ErrorHandlingInterfaces
import Foundation

extension UmbraErrors {
  /// Cryptography error domain
  public enum Crypto {
    // This namespace contains the various cryptography error types
    // Implementation in separate files:
    // - CryptoCoreErrors.swift - Core cryptography errors
    // - CryptoKeychainErrors.swift - Keychain-specific errors
  }
}
