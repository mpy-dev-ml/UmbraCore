import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

// MARK: - OperationResultDTO Extensions for Security

public extension OperationResultDTO where T == SecureBytes {
    /// Convert to SecurityResultDTO
    /// - Returns: A SecurityResultDTO representation of this operation result
    func toSecurityResultDTO() -> SecurityProtocolsCore.SecurityResultDTO {
        switch status {
        case .success:
            if let value = value {
                return SecurityProtocolsCore.SecurityResultDTO(data: value)
            } else {
                return SecurityProtocolsCore.SecurityResultDTO(success: true)
            }
        case .failure, .cancelled:
            if let errorCode = errorCode, let errorMessage = errorMessage {
                return SecurityProtocolsCore.SecurityResultDTO(
                    errorCode: Int(errorCode), 
                    errorMessage: errorMessage
                )
            } else {
                return SecurityProtocolsCore.SecurityResultDTO(
                    success: false,
                    error: .internalError(errorMessage ?? "Unknown error")
                )
            }
        }
    }
    
    /// Create from SecurityResultDTO
    /// - Parameter result: The SecurityResultDTO to convert
    /// - Returns: An OperationResultDTO representation
    static func fromSecurityResultDTO(_ result: SecurityProtocolsCore.SecurityResultDTO) -> OperationResultDTO<SecureBytes> {
        if result.success {
            return OperationResultDTO<SecureBytes>(value: result.data ?? SecureBytes())
        } else {
            return OperationResultDTO<SecureBytes>(
                errorCode: Int32(result.errorCode ?? -1),
                errorMessage: result.errorMessage ?? "Unknown security error"
            )
        }
    }
}

// MARK: - SecurityConfigDTO Converters

public extension SecurityConfigDTO {
    /// Convert to SecurityProtocolsCore.SecurityConfigDTO
    /// - Returns: A SecurityProtocolsCore.SecurityConfigDTO with equivalent configuration
    func toSecurityProtocolsCoreConfig() -> SecurityProtocolsCore.SecurityConfigDTO {
        // Extract algorithm and key size information from options
        let algorithm = options["algorithm"] ?? "AES-GCM"
        let keySizeInBits = Int(options["keySizeInBits"] ?? "256") ?? 256
        
        // Create a configuration with all the necessary parameters
        let config = SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: algorithm,
            keySizeInBits: keySizeInBits
        )
        
        // Add options
        var allOptions = [String: String]()
        for (key, value) in options {
            if !["algorithm", "keySizeInBits", "keyIdentifier", "iterations"].contains(key) {
                allOptions[key] = value
            }
        }
        
        // Create a final config with all options
        return SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            initializationVector: config.initializationVector,
            additionalAuthenticatedData: config.additionalAuthenticatedData,
            iterations: config.iterations,
            options: allOptions,
            keyIdentifier: config.keyIdentifier,
            inputData: convertToSecureBytes(inputData),
            key: config.key,
            additionalData: config.additionalData
        )
    }
    
    /// Create from SecurityProtocolsCore.SecurityConfigDTO
    /// - Parameter config: The SecurityProtocolsCore.SecurityConfigDTO to convert
    /// - Returns: A SecurityConfigDTO representation
    static func fromSecurityProtocolsCoreConfig(_ config: SecurityProtocolsCore.SecurityConfigDTO) -> SecurityConfigDTO {
        // Build options dictionary
        var options = config.options
        options["algorithm"] = config.algorithm
        options["keySizeInBits"] = String(config.keySizeInBits)
        
        if let keyId = config.keyIdentifier {
            options["keyIdentifier"] = keyId
        }
        
        if let iterations = config.iterations {
            options["iterations"] = String(iterations)
        }
        
        // Convert input data if present
        var inputData: [UInt8]? = nil
        if let secureInputData = config.inputData {
            inputData = []
            for i in 0 ..< secureInputData.count {
                inputData?.append(secureInputData[i])
            }
        }
        
        return SecurityConfigDTO(
            algorithm: config.algorithm,
            keySizeInBits: config.keySizeInBits,
            options: options,
            inputData: inputData
        )
    }
    
    /// Helper to convert [UInt8]? to SecureBytes?
    private func convertToSecureBytes(_ bytes: [UInt8]?) -> SecureBytes? {
        guard let bytes = bytes else { return nil }
        return SecureBytes(bytes: bytes)
    }
}

// MARK: - NotificationDTO Extensions for Security

public extension NotificationDTO {
    /// Create a security notification for an error
    /// - Parameters:
    ///   - error: The security error
    ///   - details: Optional additional details
    /// - Returns: A notification representing a security error
    static func securityError(
        _ error: SecurityErrorDTO,
        details: [String: String] = [:]
    ) -> NotificationDTO {
        var metadata = details
        metadata["errorDomain"] = error.domain
        metadata["errorCode"] = String(error.code)
        
        // Generate current timestamp
        let timestamp = UInt64(Date().timeIntervalSince1970)
        
        return NotificationDTO.error(
            title: "Security Error",
            message: error.message,
            source: "security_service",
            timestamp: timestamp
        ).withUpdatedMetadata(metadata)
    }
    
    /// Create a security notification for a warning
    /// - Parameters:
    ///   - message: Warning message
    ///   - details: Optional additional details
    /// - Returns: A notification representing a security warning
    static func securityWarning(
        _ message: String,
        details: [String: String] = [:]
    ) -> NotificationDTO {
        var metadata = details
        metadata["domain"] = "security"
        
        // Generate current timestamp
        let timestamp = UInt64(Date().timeIntervalSince1970)
        
        return NotificationDTO.warning(
            title: "Security Warning",
            message: message,
            source: "security_service",
            timestamp: timestamp
        ).withUpdatedMetadata(metadata)
    }
    
    /// Create a security notification for an info message
    /// - Parameters:
    ///   - message: Information message
    ///   - details: Optional additional details
    /// - Returns: A notification representing security information
    static func securityInfo(
        _ message: String,
        details: [String: String] = [:]
    ) -> NotificationDTO {
        var metadata = details
        metadata["domain"] = "security"
        
        // Generate current timestamp
        let timestamp = UInt64(Date().timeIntervalSince1970)
        
        return NotificationDTO.info(
            title: "Security Info",
            message: message,
            source: "security_service",
            timestamp: timestamp
        ).withUpdatedMetadata(metadata)
    }
}
