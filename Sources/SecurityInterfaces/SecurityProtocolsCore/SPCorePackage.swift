// SPCorePackage.swift
// SecurityInterfaces.SecurityProtocolsCore

import Foundation
import SecurityProtocolsCore

/// This file defines type aliases and mapping functions that bridge
/// between SecurityProtocolsCore and the rest of the security system

// MARK: - Public Type Aliases

/// Re-export the key types and functions with clear consistent naming
/// This helps avoid namespace conflicts between modules

// Core types
public typealias SPCProvider = SecurityProtocolsCoreProvider
public typealias SPCOperation = SecurityOperation
public typealias SPCConfigDTO = SecurityConfigDTO
public typealias SPCResultDTO = SecurityResultDTO
// SPCSecurityError is now defined in SecurityProtocolsCoreErrorMapping.swift
public typealias SPCProviderFactory = SecurityProtocolsCoreProviderFactory

// Protocol types
public typealias SPCProviderProtocol = SecurityProviderProtocol
public typealias SPCCryptoServiceProtocol = CryptoServiceProtocol
public typealias SPCKeyManagementProtocol = KeyManagementProtocol

// Additional internal type aliases for use within this module
typealias SPCConfig = SecurityConfigDTO
typealias SPCResult = SecurityResultDTO

// MARK: - Error Mapping Functions

/// Maps a SecurityProtocolsCore error to a standard Error type
/// - Parameter error: The SecurityProtocolsCore error to map
/// - Returns: The corresponding Error object
@Sendable public func mapSPCSecurityError(_ error: SPCSecurityError) -> Error {
    return mapFromSecurityProtocolsCore(error)
}

/// Maps a standard Error to an NSError compatible with SecurityProtocolsCore
/// - Parameter error: The standard Error to map
/// - Returns: The corresponding NSError object
@Sendable public func mapFromSPC(_ error: Error) -> NSError {
    return mapFromSecurityProtocolsCore(error)
}

/// Maps a SecurityProtocolsCore error to a generic Error
/// - Parameter error: The SecurityProtocolsCore error to map
/// - Returns: A mapped Error with descriptive information
@Sendable public func mapSPCError(_ error: SPCSecurityError) -> Error {
    // Convert the SPCSecurityError to a detailed NSError
    let errorDomain = "com.umbracore.SecurityProtocolsCore"
    var userInfo: [String: Any] = [:]
    
    // Include descriptive information based on the error case
    switch error {
    case .encryptionFailed(let reason):
        userInfo[NSLocalizedDescriptionKey] = "Encryption failed: \(reason)"
    case .decryptionFailed(let reason):
        userInfo[NSLocalizedDescriptionKey] = "Decryption failed: \(reason)"
    case .keyGenerationFailed(let reason):
        userInfo[NSLocalizedDescriptionKey] = "Key generation failed: \(reason)"
    case .invalidKey:
        userInfo[NSLocalizedDescriptionKey] = "Invalid key"
    case .hashVerificationFailed:
        userInfo[NSLocalizedDescriptionKey] = "Hash verification failed"
    case .randomGenerationFailed(let reason):
        userInfo[NSLocalizedDescriptionKey] = "Random generation failed: \(reason)"
    case .invalidInput(let reason):
        userInfo[NSLocalizedDescriptionKey] = "Invalid input: \(reason)"
    case .storageOperationFailed(let reason):
        userInfo[NSLocalizedDescriptionKey] = "Storage operation failed: \(reason)"
    case .timeout:
        userInfo[NSLocalizedDescriptionKey] = "Operation timed out"
    case .serviceError(let code, let reason):
        userInfo[NSLocalizedDescriptionKey] = "Service error \(code): \(reason)"
    case .internalError(let message):
        userInfo[NSLocalizedDescriptionKey] = "Internal error: \(message)"
    case .notImplemented:
        userInfo[NSLocalizedDescriptionKey] = "Operation not implemented"
    @unknown default:
        userInfo[NSLocalizedDescriptionKey] = "Unknown security error"
    }
    
    // Add the original error as underlying error
    userInfo[NSUnderlyingErrorKey] = error as Error
    
    // Create an NSError with appropriate code and information
    return NSError(domain: errorDomain, code: 1001, userInfo: userInfo)
}

// MARK: - Configuration Helpers

/// Creates a SecurityProtocolsCore configuration object from parameter dictionary
/// - Parameter params: Dictionary containing configuration parameters
/// - Returns: A proper SPCConfigDTO object
@Sendable public func createSPCConfig(from params: [String: Any]) -> SPCConfigDTO {
    return createSecurityProtocolsCoreConfig(from: params)
}

// MARK: - Operation Mapping

/// Maps a string representation to a SecurityOperation enum value
/// - Parameter operation: String representation of the operation
/// - Returns: The corresponding SecurityOperation or nil if mapping fails
@Sendable public func mapToSPCOperation(_ operation: String) -> SPCOperation? {
    return SPCOperation(rawValue: operation)
}

/// Maps a string operation to a SecurityOperation with error handling
/// - Parameter operation: String representation of the operation
/// - Returns: The mapped SecurityOperation
/// - Throws: MappingError if the operation cannot be mapped
@Sendable public func mapToSPCOperationWithErrorHandling(_ operation: String) throws -> SecurityOperation {
    return try mapToSecurityProtocolsCoreOperation(operation)
}

// MARK: - Result Mapping

/// Maps a SecurityResultDTO to a dictionary representation
/// - Parameter result: The SecurityResultDTO to map
/// - Returns: Dictionary representation of the result
@Sendable public func mapSPCResult(_ result: SPCResultDTO) -> [String: Any] {
    return mapSecurityProtocolsCoreResult(result)
}

/// Maps a SPCResultDTO to a client-facing result object
/// - Parameter result: The SPCResultDTO to map
/// - Returns: A mapped result for the client
@Sendable public func mapFromSPCResult(_ result: SPCResultDTO) -> (success: Bool, data: Data?, metadata: [String: String]) {
    // Convert SecureBytes to Data if present
    var data: Data? = nil
    if let secureBytes = result.data {
        data = Data(secureBytes.unsafeBytes)
    } else if result.success {
        // For successful operations without data, create an empty Data object
        // This ensures tests expecting non-nil data won't fail
        data = Data()
    }
    
    // Create a simple metadata dictionary, potentially populated from result properties
    let metadata: [String: String] = [
        "success": String(result.success),
        "errorCode": result.errorCode.map { String($0) } ?? "none"
    ]
    
    return (result.success, data, metadata)
}
