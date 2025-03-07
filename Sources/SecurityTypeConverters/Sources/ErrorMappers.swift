import CoreErrors
import SecurityProtocolsCore
import XPCProtocolsCore

/// Provides standardised error mapping between different security error types
public enum SecurityErrorMapper {
    /// Map any error to SecurityError from SecurityProtocolsCore
    /// - Parameter error: The error to map
    /// - Returns: A SecurityError representation of the error from SecurityProtocolsCore
    public static func toSecurityError(_ error: Error) -> SecurityProtocolsCore.SecurityError {
        // Handle existing SecurityError
        if let secError = error as? SecurityProtocolsCore.SecurityError {
            return secError
        }
        
        // Map from CoreErrors.SecurityError
        if let coreError = error as? CoreErrors.SecurityError {
            switch coreError {
            case .notImplemented:
                return SecurityProtocolsCore.SecurityError.notImplemented
            case .invalidData:
                return SecurityProtocolsCore.SecurityError.invalidInput(reason: "Invalid data format")
            case .encryptionFailed:
                return SecurityProtocolsCore.SecurityError.encryptionFailed(reason: "Encryption operation failed")
            case .decryptionFailed:
                return SecurityProtocolsCore.SecurityError.decryptionFailed(reason: "Decryption operation failed")
            case .keyGenerationFailed:
                return SecurityProtocolsCore.SecurityError.keyGenerationFailed(reason: "Key generation failed")
            case .hashingFailed:
                return SecurityProtocolsCore.SecurityError.hashVerificationFailed
            case .serviceFailed:
                return SecurityProtocolsCore.SecurityError.serviceError(code: -1, reason: "Service failure")
            case let .general(message):
                return SecurityProtocolsCore.SecurityError.internalError(message)
            case .cryptoError:
                return SecurityProtocolsCore.SecurityError.internalError("Crypto operation failed")
            case .bookmarkError, .bookmarkCreationFailed, .bookmarkResolutionFailed:
                return SecurityProtocolsCore.SecurityError.storageOperationFailed(reason: "Bookmark operation failed")
            case .accessError:
                return SecurityProtocolsCore.SecurityError.storageOperationFailed(reason: "Access error")
            @unknown default:
                return SecurityProtocolsCore.SecurityError.internalError("Unknown core error")
            }
        }
        
        // Map from CoreErrors.XPCErrors.SecurityError
        if let xpcError = error as? CoreErrors.XPCErrors.SecurityError {
            switch xpcError {
            case .xpcConnectionFailed:
                return SecurityProtocolsCore.SecurityError.serviceError(code: 1001, reason: "XPC connection failed")
            case .serviceNotAvailable:
                return SecurityProtocolsCore.SecurityError.serviceError(code: 1002, reason: "XPC service not available")
            case .communicationError:
                return SecurityProtocolsCore.SecurityError.serviceError(code: 1003, reason: "XPC communication error")
            case .protocolError:
                return SecurityProtocolsCore.SecurityError.serviceError(code: 1004, reason: "XPC protocol error")
            case .versionMismatch:
                return SecurityProtocolsCore.SecurityError.serviceError(code: 1005, reason: "XPC version mismatch")
            case let .general(message):
                return SecurityProtocolsCore.SecurityError.serviceError(code: 1000, reason: message)
            @unknown default:
                return SecurityProtocolsCore.SecurityError.internalError("Unknown XPC error")
            }
        }
        
        // Map from protocol errors - defined at the module level in XPCProtocolsCore
        if let protocolError = error as? XPCProtocolsCore.SecurityProtocolError {
            switch protocolError {
            case let .implementationMissing(reason):
                return SecurityProtocolsCore.SecurityError.notImplemented
            @unknown default:
                return SecurityProtocolsCore.SecurityError.internalError("Unknown protocol error")
            }
        }
        
        // Default case for other error types
        return SecurityProtocolsCore.SecurityError.internalError("Unknown error: \(error.localizedDescription)")
    }
    
    /// Map any error to CoreErrors.SecurityError
    /// - Parameter error: The error to map
    /// - Returns: A CoreErrors.SecurityError representation of the error
    public static func toCoreError(_ error: Error) -> CoreErrors.SecurityError {
        // Handle existing CoreErrors.SecurityError
        if let coreError = error as? CoreErrors.SecurityError {
            return coreError
        }
        
        // Map from SecurityProtocolsCore.SecurityError
        if let secError = error as? SecurityProtocolsCore.SecurityError {
            switch secError {
            case let .encryptionFailed(reason):
                return CoreErrors.SecurityError.encryptionFailed
            case let .decryptionFailed(reason):
                return CoreErrors.SecurityError.decryptionFailed
            case let .keyGenerationFailed(reason):
                return CoreErrors.SecurityError.keyGenerationFailed
            case .invalidKey:
                return CoreErrors.SecurityError.invalidData
            case .hashVerificationFailed:
                return CoreErrors.SecurityError.hashingFailed
            case let .randomGenerationFailed(reason):
                return CoreErrors.SecurityError.cryptoError
            case let .invalidInput(reason):
                return CoreErrors.SecurityError.invalidData
            case let .storageOperationFailed(reason):
                return CoreErrors.SecurityError.bookmarkError
            case .timeout:
                return CoreErrors.SecurityError.serviceFailed
            case let .serviceError(code, reason):
                return CoreErrors.SecurityError.serviceFailed
            case let .internalError(message):
                return CoreErrors.SecurityError.general(message)
            case .notImplemented:
                return CoreErrors.SecurityError.notImplemented
            @unknown default:
                return CoreErrors.SecurityError.general("Unknown security error")
            }
        }
        
        // Map from XPC errors
        if let xpcError = error as? CoreErrors.XPCErrors.SecurityError {
            return CoreErrors.SecurityError.serviceFailed
        }
        
        // Map from protocol errors - defined at the module level in XPCProtocolsCore
        if let protocolError = error as? XPCProtocolsCore.SecurityProtocolError {
            switch protocolError {
            case let .implementationMissing(reason):
                return CoreErrors.SecurityError.notImplemented
            @unknown default:
                return CoreErrors.SecurityError.general("Unknown protocol error")
            }
        }
        
        // Default case
        return CoreErrors.SecurityError.general(error.localizedDescription)
    }
    
    /// Map any error to XPC security error type
    /// - Parameter error: The error to map
    /// - Returns: An CoreErrors.XPCErrors.SecurityError representation
    public static func toXPCError(_ error: Error) -> CoreErrors.XPCErrors.SecurityError {
        // Handle existing XPC error
        if let xpcError = error as? CoreErrors.XPCErrors.SecurityError {
            return xpcError
        }
        
        // Map from CoreErrors.SecurityError
        if let coreError = error as? CoreErrors.SecurityError {
            switch coreError {
            case .notImplemented:
                return CoreErrors.XPCErrors.SecurityError.general("Operation not implemented")
            case .invalidData:
                return CoreErrors.XPCErrors.SecurityError.general("Invalid data format")
            case .encryptionFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Encryption operation failed")
            case .decryptionFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Decryption operation failed")
            case .keyGenerationFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Key generation failed")
            case .hashingFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Hashing failed")
            case .serviceFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Service communication failed")
            case let .general(message):
                return CoreErrors.XPCErrors.SecurityError.general(message)
            case .cryptoError:
                return CoreErrors.XPCErrors.SecurityError.general("Crypto operation failed")
            case .bookmarkError, .bookmarkCreationFailed, .bookmarkResolutionFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Bookmark operation failed")
            case .accessError:
                return CoreErrors.XPCErrors.SecurityError.general("Access error")
            @unknown default:
                return CoreErrors.XPCErrors.SecurityError.general("Unknown core error")
            }
        }
        
        // Map from SecurityProtocolsCore.SecurityError
        if let secError = error as? SecurityProtocolsCore.SecurityError {
            switch secError {
            case let .encryptionFailed(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Encryption failed: \(reason)")
            case let .decryptionFailed(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Decryption failed: \(reason)")
            case let .keyGenerationFailed(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Key generation failed: \(reason)")
            case .invalidKey:
                return CoreErrors.XPCErrors.SecurityError.general("Invalid key")
            case .hashVerificationFailed:
                return CoreErrors.XPCErrors.SecurityError.general("Hash verification failed")
            case let .randomGenerationFailed(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Random generation failed: \(reason)")
            case let .invalidInput(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Invalid input: \(reason)")
            case let .storageOperationFailed(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Storage operation failed: \(reason)")
            case .timeout:
                return CoreErrors.XPCErrors.SecurityError.general("Operation timed out")
            case let .internalError(message):
                return CoreErrors.XPCErrors.SecurityError.general("Internal error: \(message)")
            case let .serviceError(code, reason):
                return CoreErrors.XPCErrors.SecurityError.general("Service error \(code): \(reason)")
            case .notImplemented:
                return CoreErrors.XPCErrors.SecurityError.general("Not implemented")
            @unknown default:
                return CoreErrors.XPCErrors.SecurityError.general("Unknown security error")
            }
        }
        
        // Map from protocol errors - defined at the module level in XPCProtocolsCore
        if let protocolError = error as? XPCProtocolsCore.SecurityProtocolError {
            switch protocolError {
            case let .implementationMissing(reason):
                return CoreErrors.XPCErrors.SecurityError.general("Implementation missing: \(reason)")
            @unknown default:
                return CoreErrors.XPCErrors.SecurityError.general("Unknown protocol error")
            }
        }
        
        // Default case for other error types
        return CoreErrors.XPCErrors.SecurityError.general("Unknown error: \(error.localizedDescription)")
    }
}
