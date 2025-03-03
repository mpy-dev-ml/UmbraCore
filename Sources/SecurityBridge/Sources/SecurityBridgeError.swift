// SecurityBridgeError.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecurityProtocolsCore

/// Error types that can be thrown by the SecurityBridge module
public extension SecurityBridge {
    /// Error types specific to the bridge layer
    enum SecurityBridgeError: Error, Sendable {
        /// Bookmark resolution failed
        case bookmarkResolutionFailed
        /// Implementation is missing
        case implementationMissing(String)
    }
}

/// Mapper to convert between SecurityError and SecurityBridgeError
public struct SecurityBridgeErrorMapper {
    /// Map a SecurityError to a bridge error
    /// - Parameter error: The security error to map
    /// - Returns: A bridge error
    public static func mapToBridgeError(_ error: Error) -> Error {
        guard let securityError = error as? SecurityError else {
            return SecurityBridge.SecurityBridgeError.implementationMissing("Unknown error: \(error.localizedDescription)")
        }
        
        switch securityError {
        case .internalError(let message):
            return SecurityBridge.SecurityBridgeError.implementationMissing(message)
        case .encryptionFailed(let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Encryption failed: \(reason)")
        case .decryptionFailed(let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Decryption failed: \(reason)")
        case .serviceError(let code, let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Service error \(code): \(reason)")
        case .keyGenerationFailed(let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Key generation failed: \(reason)")
        case .invalidKey:
            return SecurityBridge.SecurityBridgeError.implementationMissing("Invalid key")
        case .hashVerificationFailed:
            return SecurityBridge.SecurityBridgeError.implementationMissing("Hash verification failed")
        case .randomGenerationFailed(let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Random generation failed: \(reason)")
        case .invalidInput(let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Invalid input: \(reason)")
        case .storageOperationFailed(let reason):
            return SecurityBridge.SecurityBridgeError.implementationMissing("Storage operation failed: \(reason)")
        case .timeout:
            return SecurityBridge.SecurityBridgeError.implementationMissing("Timeout")
        case .notImplemented:
            return SecurityBridge.SecurityBridgeError.implementationMissing("Not implemented")
        @unknown default:
            return SecurityBridge.SecurityBridgeError.implementationMissing("Unknown security error: \(securityError)")
        }
    }
    
    /// Map a bridge error to a SecurityError
    /// - Parameter error: The bridge error to map
    /// - Returns: A SecurityError
    public static func mapToSecurityError(_ error: Error) -> Error {
        guard let bridgeError = error as? SecurityBridge.SecurityBridgeError else {
            return SecurityError.internalError("Unknown bridge error: \(error.localizedDescription)")
        }
        
        switch bridgeError {
        case .bookmarkResolutionFailed:
            return SecurityError.storageOperationFailed(reason: "Bookmark resolution failed")
        case .implementationMissing(let message):
            return SecurityError.internalError(message)
        }
    }
}
