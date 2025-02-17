import Foundation
import UmbraCore

/// Configuration options for cryptographic operations
@frozen public struct CryptoConfiguration: Sendable {
    /// Key length in bits (256 for AES-256)
    public let keyLength: Int
    
    /// IV length in bytes for AES-GCM
    public let ivLength: Int
    
    /// Salt length in bytes for key derivation
    public let saltLength: Int
    
    /// Minimum number of iterations for PBKDF2
    public let minimumPBKDF2Iterations: Int
    
    /// Authentication tag length in bytes for AES-GCM
    public let authenticationTagLength: Int
    
    /// Security level for cryptographic operations
    public let securityLevel: UmbraCore.SecurityLevel
    
    /// Creates default configuration with high security
    public static let `default` = CryptoConfiguration(securityLevel: .high)
    
    /// Initialises a new configuration with the specified security level
    public init(securityLevel: UmbraCore.SecurityLevel) {
        self.securityLevel = securityLevel
        self.keyLength = securityLevel.recommendedKeyLength
        self.ivLength = 12 // Standard for AES-GCM
        self.saltLength = 16 // NIST recommended minimum
        self.minimumPBKDF2Iterations = securityLevel.recommendedPBKDF2Iterations
        self.authenticationTagLength = 16 // Standard for AES-GCM
    }
    
    /// Initialises a new configuration with custom values
    public init(
        keyLength: Int = 256,
        ivLength: Int = 12,
        saltLength: Int = 16,
        minimumPBKDF2Iterations: Int = 310_000,
        authenticationTagLength: Int = 16,
        securityLevel: UmbraCore.SecurityLevel = .high
    ) {
        self.keyLength = keyLength
        self.ivLength = ivLength
        self.saltLength = saltLength
        self.minimumPBKDF2Iterations = minimumPBKDF2Iterations
        self.authenticationTagLength = authenticationTagLength
        self.securityLevel = securityLevel
    }
}
