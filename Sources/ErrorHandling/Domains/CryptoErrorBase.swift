import ErrorHandlingInterfaces
import Foundation

public extension UmbraErrors {
    /// Cryptography error domain
    enum Crypto {
        // This namespace contains the various cryptography error types
        // Implementation in separate files:
        // - CryptoCoreErrors.swift - Core cryptography errors
        // - CryptoKeychainErrors.swift - Keychain-specific errors
    }
}
