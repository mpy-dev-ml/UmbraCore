// SecurityError.swift
// Domain-specific error type for security operations
//
// Copyright 2025 UmbraCorp. All rights reserved.

import Foundation
import ErrorHandlingInterfaces
import ErrorHandlingCommon

/// Domain-specific error type for security operations
public enum SecurityError: Error, UmbraError, CustomStringConvertible {
    // Authentication errors
    case authenticationFailed(String)
    case unauthorizedAccess(String)
    case invalidCredentials(String)
    case sessionExpired(String)
    case tokenExpired(String)
    
    // Cryptography errors
    case encryptionFailed(String)
    case decryptionFailed(String)
    case signatureInvalid(String)
    case hashingFailed(String)
    case keyGenerationFailed(String)
    
    // Access control errors
    case permissionDenied(String)
    case insufficientPrivileges(String)
    case accessRevoked(String)
    
    // Certificate errors
    case certificateExpired(String)
    case certificateInvalid(String)
    case certificateVerificationFailed(String)
    case certificateTrustFailed(String)
    
    // Other security errors
    case secureChannelFailed(String)
    case securityPolicyViolation(String)
    case securityConfigurationError(String)
    case unknown(String)
    
    // MARK: - DomainError Protocol
    
    /// Domain identifier for SecurityError
    public static var domain: String {
        return "Security"
    }
    
    // MARK: - UmbraError Protocol
    
    /// Domain identifier for this error
    public var domain: String {
        return SecurityError.domain
    }
    
    /// Error code
    public var code: String {
        switch self {
        case .authenticationFailed: return "auth_failed"
        case .unauthorizedAccess: return "unauthorized_access"
        case .invalidCredentials: return "invalid_credentials"
        case .sessionExpired: return "session_expired"
        case .tokenExpired: return "token_expired"
        case .encryptionFailed: return "encryption_failed"
        case .decryptionFailed: return "decryption_failed"
        case .signatureInvalid: return "signature_invalid"
        case .hashingFailed: return "hashing_failed"
        case .keyGenerationFailed: return "key_generation_failed"
        case .permissionDenied: return "permission_denied"
        case .insufficientPrivileges: return "insufficient_privileges"
        case .accessRevoked: return "access_revoked"
        case .certificateExpired: return "certificate_expired"
        case .certificateInvalid: return "certificate_invalid"
        case .certificateVerificationFailed: return "certificate_verification_failed"
        case .certificateTrustFailed: return "certificate_trust_failed"
        case .secureChannelFailed: return "secure_channel_failed"
        case .securityPolicyViolation: return "security_policy_violation"
        case .securityConfigurationError: return "security_configuration_error"
        case .unknown: return "unknown_security_error"
        }
    }
    
    /// Human-readable description
    public var description: String {
        return "[\(domain).\(code)] \(errorDescription)"
    }
    
    /// Human-readable error description
    public var errorDescription: String {
        switch self {
        case .authenticationFailed(let msg): return "Authentication failed: \(msg)"
        case .unauthorizedAccess(let msg): return "Unauthorized access: \(msg)"
        case .invalidCredentials(let msg): return "Invalid credentials: \(msg)"
        case .sessionExpired(let msg): return "Session expired: \(msg)"
        case .tokenExpired(let msg): return "Token expired: \(msg)"
        case .encryptionFailed(let msg): return "Encryption failed: \(msg)"
        case .decryptionFailed(let msg): return "Decryption failed: \(msg)"
        case .signatureInvalid(let msg): return "Invalid signature: \(msg)"
        case .hashingFailed(let msg): return "Hashing failed: \(msg)"
        case .keyGenerationFailed(let msg): return "Key generation failed: \(msg)"
        case .permissionDenied(let msg): return "Permission denied: \(msg)"
        case .insufficientPrivileges(let msg): return "Insufficient privileges: \(msg)"
        case .accessRevoked(let msg): return "Access revoked: \(msg)"
        case .certificateExpired(let msg): return "Certificate expired: \(msg)"
        case .certificateInvalid(let msg): return "Invalid certificate: \(msg)"
        case .certificateVerificationFailed(let msg): return "Certificate verification failed: \(msg)"
        case .certificateTrustFailed(let msg): return "Certificate trust failed: \(msg)"
        case .secureChannelFailed(let msg): return "Secure channel failed: \(msg)"
        case .securityPolicyViolation(let msg): return "Security policy violation: \(msg)"
        case .securityConfigurationError(let msg): return "Security configuration error: \(msg)"
        case .unknown(let msg): return "Unknown security error: \(msg)"
        }
    }
    
    /// Source information for the error (optional)
    public var source: ErrorHandlingCommon.ErrorSource? {
        switch self {
        case .authenticationFailed, .unauthorizedAccess, .invalidCredentials, .sessionExpired, .tokenExpired,
             .encryptionFailed, .decryptionFailed, .signatureInvalid, .hashingFailed, .keyGenerationFailed,
             .permissionDenied, .insufficientPrivileges, .accessRevoked, .certificateExpired, .certificateInvalid,
             .certificateVerificationFailed, .certificateTrustFailed, .secureChannelFailed, .securityPolicyViolation,
             .securityConfigurationError, .unknown:
            return nil
        }
    }
    
    /// Underlying error that caused this error (optional)
    public var underlyingError: Error? {
        switch self {
        case .authenticationFailed, .unauthorizedAccess, .invalidCredentials, .sessionExpired, .tokenExpired,
             .encryptionFailed, .decryptionFailed, .signatureInvalid, .hashingFailed, .keyGenerationFailed,
             .permissionDenied, .insufficientPrivileges, .accessRevoked, .certificateExpired, .certificateInvalid,
             .certificateVerificationFailed, .certificateTrustFailed, .secureChannelFailed, .securityPolicyViolation,
             .securityConfigurationError, .unknown:
            return nil
        }
    }
    
    /// Context information about the error
    public var context: ErrorHandlingCommon.ErrorContext {
        switch self {
        case .authenticationFailed, .unauthorizedAccess, .invalidCredentials, .sessionExpired, .tokenExpired,
             .encryptionFailed, .decryptionFailed, .signatureInvalid, .hashingFailed, .keyGenerationFailed,
             .permissionDenied, .insufficientPrivileges, .accessRevoked, .certificateExpired, .certificateInvalid,
             .certificateVerificationFailed, .certificateTrustFailed, .secureChannelFailed, .securityPolicyViolation,
             .securityConfigurationError, .unknown:
            return ErrorHandlingCommon.ErrorContext(source: "SecurityError", operation: "security_operation")
        }
    }
    
    /// Create a new instance with updated context
    public func with(context: ErrorHandlingCommon.ErrorContext) -> SecurityError {
        switch self {
        case .authenticationFailed(let msg):
            return .authenticationFailed(msg)
        case .unauthorizedAccess(let msg):
            return .unauthorizedAccess(msg)
        case .invalidCredentials(let msg):
            return .invalidCredentials(msg)
        case .sessionExpired(let msg):
            return .sessionExpired(msg)
        case .tokenExpired(let msg):
            return .tokenExpired(msg)
        case .encryptionFailed(let msg):
            return .encryptionFailed(msg)
        case .decryptionFailed(let msg):
            return .decryptionFailed(msg)
        case .signatureInvalid(let msg):
            return .signatureInvalid(msg)
        case .hashingFailed(let msg):
            return .hashingFailed(msg)
        case .keyGenerationFailed(let msg):
            return .keyGenerationFailed(msg)
        case .permissionDenied(let msg):
            return .permissionDenied(msg)
        case .insufficientPrivileges(let msg):
            return .insufficientPrivileges(msg)
        case .accessRevoked(let msg):
            return .accessRevoked(msg)
        case .certificateExpired(let msg):
            return .certificateExpired(msg)
        case .certificateInvalid(let msg):
            return .certificateInvalid(msg)
        case .certificateVerificationFailed(let msg):
            return .certificateVerificationFailed(msg)
        case .certificateTrustFailed(let msg):
            return .certificateTrustFailed(msg)
        case .secureChannelFailed(let msg):
            return .secureChannelFailed(msg)
        case .securityPolicyViolation(let msg):
            return .securityPolicyViolation(msg)
        case .securityConfigurationError(let msg):
            return .securityConfigurationError(msg)
        case .unknown(let msg):
            return .unknown(msg)
        }
    }
    
    /// Create a new instance with an underlying error
    public func with(underlyingError: Error) -> SecurityError {
        switch self {
        case .authenticationFailed(let msg):
            return .authenticationFailed(msg)
        case .unauthorizedAccess(let msg):
            return .unauthorizedAccess(msg)
        case .invalidCredentials(let msg):
            return .invalidCredentials(msg)
        case .sessionExpired(let msg):
            return .sessionExpired(msg)
        case .tokenExpired(let msg):
            return .tokenExpired(msg)
        case .encryptionFailed(let msg):
            return .encryptionFailed(msg)
        case .decryptionFailed(let msg):
            return .decryptionFailed(msg)
        case .signatureInvalid(let msg):
            return .signatureInvalid(msg)
        case .hashingFailed(let msg):
            return .hashingFailed(msg)
        case .keyGenerationFailed(let msg):
            return .keyGenerationFailed(msg)
        case .permissionDenied(let msg):
            return .permissionDenied(msg)
        case .insufficientPrivileges(let msg):
            return .insufficientPrivileges(msg)
        case .accessRevoked(let msg):
            return .accessRevoked(msg)
        case .certificateExpired(let msg):
            return .certificateExpired(msg)
        case .certificateInvalid(let msg):
            return .certificateInvalid(msg)
        case .certificateVerificationFailed(let msg):
            return .certificateVerificationFailed(msg)
        case .certificateTrustFailed(let msg):
            return .certificateTrustFailed(msg)
        case .secureChannelFailed(let msg):
            return .secureChannelFailed(msg)
        case .securityPolicyViolation(let msg):
            return .securityPolicyViolation(msg)
        case .securityConfigurationError(let msg):
            return .securityConfigurationError(msg)
        case .unknown(let msg):
            return .unknown(msg)
        }
    }
    
    /// Create a new instance with source information
    public func with(source: ErrorHandlingCommon.ErrorSource) -> SecurityError {
        switch self {
        case .authenticationFailed(let msg):
            return .authenticationFailed(msg)
        case .unauthorizedAccess(let msg):
            return .unauthorizedAccess(msg)
        case .invalidCredentials(let msg):
            return .invalidCredentials(msg)
        case .sessionExpired(let msg):
            return .sessionExpired(msg)
        case .tokenExpired(let msg):
            return .tokenExpired(msg)
        case .encryptionFailed(let msg):
            return .encryptionFailed(msg)
        case .decryptionFailed(let msg):
            return .decryptionFailed(msg)
        case .signatureInvalid(let msg):
            return .signatureInvalid(msg)
        case .hashingFailed(let msg):
            return .hashingFailed(msg)
        case .keyGenerationFailed(let msg):
            return .keyGenerationFailed(msg)
        case .permissionDenied(let msg):
            return .permissionDenied(msg)
        case .insufficientPrivileges(let msg):
            return .insufficientPrivileges(msg)
        case .accessRevoked(let msg):
            return .accessRevoked(msg)
        case .certificateExpired(let msg):
            return .certificateExpired(msg)
        case .certificateInvalid(let msg):
            return .certificateInvalid(msg)
        case .certificateVerificationFailed(let msg):
            return .certificateVerificationFailed(msg)
        case .certificateTrustFailed(let msg):
            return .certificateTrustFailed(msg)
        case .secureChannelFailed(let msg):
            return .secureChannelFailed(msg)
        case .securityPolicyViolation(let msg):
            return .securityPolicyViolation(msg)
        case .securityConfigurationError(let msg):
            return .securityConfigurationError(msg)
        case .unknown(let msg):
            return .unknown(msg)
        }
    }
}

/// Extension to provide convenience initializers
public extension SecurityError {
    /// Create a security error from another error
    static func from(error: Error) -> SecurityError {
        if let securityError = error as? SecurityError {
            return securityError
        }
        // Explicitly cast to NSError to avoid ambiguity with localizedDescription
        let nsError = error as NSError
        return SecurityError.unknown("Wrapped error: " + nsError.localizedDescription)
    }
}
