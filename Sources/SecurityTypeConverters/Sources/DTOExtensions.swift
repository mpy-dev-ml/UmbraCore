import CoreErrors
import CoreTypesInterfaces
import FoundationBridgeTypes
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore

// MARK: - SecurityConfigDTO Extensions

public extension SecurityProtocolsCore.SecurityConfigDTO {
    /// Converts to BinaryData format for cross-module transport
    /// - Returns: BinaryData representation of this config
    func toBinaryData() -> CoreTypesInterfaces.BinaryData {
        // Create a serialized representation
        let serialized = try? self.secureSerialize()
        if let bytes = serialized?.bytes {
            return CoreTypesInterfaces.BinaryData(bytes: bytes)
        }
        
        // Fallback for serialization failure
        let algorithmBytes = Array(algorithm.utf8)
        return CoreTypesInterfaces.BinaryData(bytes: algorithmBytes)
    }
    
    /// Create a copy with modified input data
    /// - Parameter data: BinaryData to use as input
    /// - Returns: New config with updated input data
    func withBinaryInputData(_ data: CoreTypesInterfaces.BinaryData) -> SecurityProtocolsCore.SecurityConfigDTO {
        let secureBytes = SecureBytes(bytes: data.rawBytes)
        return self.withInputData(secureBytes)
    }
    
    /// Create a copy with modified key
    /// - Parameter key: BinaryData key
    /// - Returns: New config with updated key
    func withBinaryKey(_ key: CoreTypesInterfaces.BinaryData) -> SecurityProtocolsCore.SecurityConfigDTO {
        let secureBytes = SecureBytes(bytes: key.rawBytes)
        return self.withKey(secureBytes)
    }
}

// MARK: - SecurityResultDTO Extensions

public extension SecurityProtocolsCore.SecurityResultDTO {
    /// Convert result data to BinaryData
    /// - Returns: BinaryData representation or nil if no data
    func resultToBinaryData() -> CoreTypesInterfaces.BinaryData? {
        guard let data = self.data else { return nil }
        return CoreTypesInterfaces.BinaryData(bytes: data.bytes)
    }
    
    /// Create from BinaryData
    /// - Parameter data: The BinaryData to wrap
    /// - Returns: A success result DTO containing the data
    static func from(binaryData: CoreTypesInterfaces.BinaryData) -> SecurityProtocolsCore.SecurityResultDTO {
        let secureBytes = SecureBytes(bytes: binaryData.rawBytes)
        return SecurityProtocolsCore.SecurityResultDTO(data: secureBytes)
    }
    
    /// Create a result from a SecurityError
    /// - Parameter error: The security error to wrap
    /// - Returns: A failure result DTO containing the error
    static func from(error: SecurityProtocolsCore.SecurityError) -> SecurityProtocolsCore.SecurityResultDTO {
        return SecurityProtocolsCore.SecurityResultDTO(
            success: false,
            errorMessage: errorMessageFrom(error),
            error: error
        )
    }
    
    /// Create a result from a CoreErrors SecurityError
    /// - Parameter error: The core error to wrap
    /// - Returns: A failure result DTO containing the error
    static func from(coreError: CoreErrors.SecurityError) -> SecurityProtocolsCore.SecurityResultDTO {
        return SecurityProtocolsCore.SecurityResultDTO(
            success: false,
            errorMessage: String(describing: coreError),
            error: nil  // Core error can't be directly stored in SecurityResultDTO
        )
    }
    
    /// Create a result from an XPC SecurityError
    /// - Parameter error: The XPC error to wrap
    /// - Returns: A failure result DTO containing the error
    static func from(xpcError: CoreErrors.XPCErrors.SecurityError) -> SecurityProtocolsCore.SecurityResultDTO {
        return SecurityProtocolsCore.SecurityResultDTO(
            success: false,
            errorMessage: String(describing: xpcError),
            error: nil  // XPC error can't be directly stored in SecurityResultDTO
        )
    }
    
    /// Extract descriptive error message from SecurityError
    private static func errorMessageFrom(_ error: SecurityProtocolsCore.SecurityError) -> String {
        switch error {
        case let .encryptionFailed(reason):
            return "Encryption failed: \(reason)"
        case let .decryptionFailed(reason):
            return "Decryption failed: \(reason)"
        case let .keyGenerationFailed(reason):
            return "Key generation failed: \(reason)"
        case .invalidKey:
            return "Invalid key"
        case .hashVerificationFailed:
            return "Hash verification failed"
        case let .randomGenerationFailed(reason):
            return "Random generation failed: \(reason)"
        case let .invalidInput(reason):
            return "Invalid input: \(reason)"
        case let .storageOperationFailed(reason):
            return "Storage operation failed: \(reason)"
        case .timeout:
            return "Operation timed out"
        case let .serviceError(code, reason):
            return "Service error \(code): \(reason)"
        case let .internalError(message):
            return "Internal error: \(message)"
        case .notImplemented:
            return "Operation not implemented"
        @unknown default:
            return "Unknown security error"
        }
    }
}
