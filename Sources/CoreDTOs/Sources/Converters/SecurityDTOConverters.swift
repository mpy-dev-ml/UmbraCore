import ErrorHandlingDomains
import Foundation
import UmbraCoreTypes

// MARK: - OperationResultDTO Extensions for Security

public extension OperationResultDTO where T == SecureBytes {
    /// Convert to generic result format
    /// Use as internal utility function for security operations
    /// - Returns: A tuple representing operation result with data and error information
    func toSecurityTuple() -> (success: Bool, data: SecureBytes?, errorCode: Int?, errorMessage: String?) {
        switch status {
        case .success:
            (true, value, nil, nil)
        case .failure, .cancelled:
            (false, nil, errorCode.map { Int($0) }, errorMessage)
        }
    }

    /// Create from security tuple format
    /// - Parameter result: Tuple with security result data
    /// - Returns: An OperationResultDTO representation
    static func fromSecurityTuple(
        success: Bool,
        data: SecureBytes?,
        errorCode: Int?,
        errorMessage: String?
    ) -> OperationResultDTO<SecureBytes> {
        if success {
            OperationResultDTO<SecureBytes>(value: data ?? SecureBytes())
        } else {
            OperationResultDTO<SecureBytes>(
                errorCode: errorCode.map { Int32($0) } ?? -1,
                errorMessage: errorMessage ?? "Unknown security error"
            )
        }
    }
}

// MARK: - SecurityConfigDTO Converters

public extension SecurityConfigDTO {
    /// Convert to a dictionary representation
    /// - Returns: Dictionary with security configuration
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = [
            "algorithm": algorithm,
            "keySizeInBits": keySizeInBits,
        ]

        // Add all options
        for (key, value) in options {
            result[key] = value
        }

        return result
    }

    /// Create from dictionary representation
    /// - Parameter dict: Dictionary with security configuration
    /// - Returns: New SecurityConfigDTO instance
    static func fromDictionary(_ dict: [String: Any]) -> SecurityConfigDTO {
        let algorithm = dict["algorithm"] as? String ?? "AES256"
        let keySizeInBits = dict["keySizeInBits"] as? Int ?? 256

        var options: [String: String] = [:]
        for (key, value) in dict {
            if key != "algorithm", key != "keySizeInBits" {
                options[key] = String(describing: value)
            }
        }

        return SecurityConfigDTO(
            algorithm: algorithm,
            keySizeInBits: keySizeInBits,
            options: options
        )
    }
}

// MARK: - SecurityErrorDTO Extensions

public extension SecurityErrorDTO {
    /// Convert to NSError (only for Foundation environments)
    /// - Returns: NSError representation of this security error
    func toNSError() -> NSError {
        let error = NSError(
            domain: domain,
            code: Int(code),
            userInfo: [
                NSLocalizedDescriptionKey: message,
            ]
        )

        var userInfo = error.userInfo as [String: Any]

        // Add all details to the userInfo dictionary
        for (key, value) in details {
            userInfo[key] = value
        }

        return NSError(
            domain: error.domain,
            code: error.code,
            userInfo: userInfo
        )
    }

    /// Create from NSError
    /// - Parameter error: The NSError to convert
    /// - Returns: A SecurityErrorDTO representation
    static func fromNSError(_ error: NSError) -> SecurityErrorDTO {
        var details: [String: String] = [:]

        // Extract details from userInfo
        for (key, value) in error.userInfo {
            if key != NSLocalizedDescriptionKey {
                details[key as String] = String(describing: value)
            }
        }

        return SecurityErrorDTO(
            code: Int32(error.code),
            domain: error.domain,
            message: error.localizedDescription,
            details: details
        )
    }

    /// Create a generic error
    /// - Parameters:
    ///   - message: Error message
    ///   - details: Optional additional details
    /// - Returns: A new SecurityErrorDTO
    static func genericError(
        message: String,
        details: [String: String] = [:]
    ) -> SecurityErrorDTO {
        SecurityErrorDTO(
            code: 1000,
            domain: "com.umbra.security",
            message: message,
            details: details
        )
    }
}

// MARK: - Notification Extensions

/// Convert security-related notifications to and from standard formats
public extension NotificationDTO {
    /// Create a security notification for an error
    /// - Parameters:
    ///   - error: The security error
    ///   - details: Optional additional details
    /// - Returns: Notification with error information
    static func securityError(
        _ error: SecurityErrorDTO,
        details: [String: String] = [:]
    ) -> NotificationDTO {
        var metadata = details
        metadata["errorDomain"] = error.domain
        metadata["errorCode"] = String(error.code)

        // Add all details from the error
        for (key, value) in error.details {
            metadata[key] = value
        }

        // Convert timestamp to UInt64
        let timestamp = UInt64(Date().timeIntervalSince1970)

        return NotificationDTO.error(
            title: "Security Error",
            message: error.message,
            source: "security_service",
            timestamp: timestamp
        )
    }

    /// Create a security notification for a status event
    /// - Parameters:
    ///   - status: Status description
    ///   - details: Optional additional details
    /// - Returns: Notification with status information
    static func securityStatus(
        _ status: String,
        details: [String: String] = [:]
    ) -> NotificationDTO {
        var metadata = details
        metadata["status"] = status

        // Convert timestamp to UInt64
        let timestamp = UInt64(Date().timeIntervalSince1970)

        return NotificationDTO.info(
            title: "Security Status",
            message: status,
            source: "security_service",
            timestamp: timestamp
        )
    }
}
