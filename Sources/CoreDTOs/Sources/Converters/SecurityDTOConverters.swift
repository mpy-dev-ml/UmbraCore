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
                    errorCode: errorCode, 
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
            return OperationResultDTO<SecureBytes>.success(result.data ?? SecureBytes())
        } else {
            return OperationResultDTO<SecureBytes>.failure(
                errorCode: result.errorCode ?? -1,
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
        let keySizeStr = options["keySizeInBits"] ?? "256"
        let keySize = Int(keySizeStr) ?? 256
        
        // Create a base configuration
        var config = SecurityProtocolsCore.SecurityConfigDTO(
            algorithm: algorithm,
            keySizeInBits: keySize
        )
        
        // Add key identifier if present
        if let keyID = options["keyIdentifier"] {
            config = config.withKeyIdentifier(keyID)
        }
        
        // Add iterations if present
        if let iterationsStr = options["iterations"], let iterations = Int(iterationsStr) {
            config = SecurityProtocolsCore.SecurityConfigDTO(
                algorithm: algorithm,
                keySizeInBits: keySize,
                initializationVector: config.initializationVector,
                additionalAuthenticatedData: config.additionalAuthenticatedData,
                iterations: iterations,
                options: config.options,
                keyIdentifier: config.keyIdentifier,
                inputData: config.inputData,
                key: config.key,
                additionalData: config.additionalData
            )
        }
        
        // Add any input data
        if let inputData = inputData {
            let secureInputData = SecureBytes(bytes: Array(inputData))
            config = config.withInputData(secureInputData)
        }
        
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
            inputData: config.inputData,
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
                if let byte = secureInputData[i] {
                    inputData?.append(byte)
                }
            }
        }
        
        return SecurityConfigDTO(
            options: options,
            inputData: inputData
        )
    }
}

// MARK: - NotificationDTO Extensions for Security

public extension NotificationDTO {
    /// Create a security notification for an error
    /// - Parameters:
    ///   - error: The security error
    ///   - details: Optional additional details
    ///   - timestamp: Current timestamp
    /// - Returns: A NotificationDTO for the security error
    static func forSecurityError(
        _ error: UmbraErrors.Security.Protocols,
        details: String? = nil,
        timestamp: UInt64
    ) -> NotificationDTO {
        let errorCode: Int
        
        // Map error type to code
        switch error {
        case .invalidFormat:
            errorCode = 1001
        case .unsupportedOperation:
            errorCode = 1002
        case .incompatibleVersion:
            errorCode = 1003
        case .missingProtocolImplementation:
            errorCode = 1004
        case .invalidState:
            errorCode = 1005
        case .internalError:
            errorCode = 1006
        case .invalidInput:
            errorCode = 1007
        case .encryptionFailed:
            errorCode = 1008
        case .decryptionFailed:
            errorCode = 1009
        case .randomGenerationFailed:
            errorCode = 1010
        case .storageOperationFailed:
            errorCode = 1011
        case .serviceError:
            errorCode = 1012
        case .notImplemented:
            errorCode = 1013
        @unknown default:
            errorCode = 1099
        }
        
        let errorTitle = "Security Error"
        let errorMessage = details ?? String(describing: error)
        
        // Create notification with error metadata
        return NotificationDTO.error(
            title: errorTitle,
            message: errorMessage,
            source: "SecurityProvider",
            timestamp: timestamp,
            id: "sec_err_\(errorCode)"
        ).withUpdatedMetadata([
            "errorCode": String(errorCode),
            "errorType": String(describing: error),
            "category": "security"
        ])
    }
}
