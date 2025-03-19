import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains

/// Primary entry point for the SecurityBridge module.
///
/// This module is specifically designed to include Foundation dependencies and serve
/// as the boundary layer between Foundation types and foundation-free domain types.
/// It centralises all Foundation conversions in one place, providing a clear boundary
/// between the two type systems.
///
/// Key responsibilities:
/// - Converting between Foundation types (Data, URL, Date) and domain types (SecureBytes,
/// ResourceLocator, TimePoint)
/// - Adapting Foundation-dependent implementations to foundation-free protocols
/// - Providing utilities for XPC service communication
public enum SecurityBridge {
    /// Module version
    public static let version = "1.0.0"
}

// Explicit type aliases to resolve ambiguities
extension SecurityBridge {
    /// Type alias to disambiguate the SecurityConfigDTO from CoreDTOs
    public typealias ConfigDTO = CoreDTOs.SecurityConfigDTO
    
    /// Type alias to disambiguate the SecurityErrorDTO
    public typealias ErrorDTO = CoreDTOs.SecurityErrorDTO
    
    /// Type alias for operation results
    public typealias OperationResultDTO<T: Equatable> = CoreDTOs.OperationResultDTO<T>
    
    /// Type alias for security errors
    public typealias SecurityError = UmbraErrors.Security.Core
}

/// Extension to provide access to the DTO adapters
extension SecurityBridge {
    /// Functions related to Data Transfer Objects (DTOs) for security operations
    public enum DTOAdapters {
        // MARK: - Error Conversions
        
        /// Convert SecurityErrorDTO to ErrorDTO
        ///
        /// - Parameter error: The SecurityErrorDTO to convert
        /// - Returns: An ErrorDTO with equivalent information
        public static func toDTO(error: SecurityError) -> ErrorDTO {
            SecurityDTOAdapter.toDTO(error: error)
        }
        
        /// Convert ErrorDTO to SecurityErrorDTO
        ///
        /// - Parameter dto: The ErrorDTO to convert
        /// - Returns: A SecurityErrorDTO with equivalent information
        public static func fromDTO(error dto: ErrorDTO) -> SecurityError {
            SecurityDTOAdapter.fromDTO(error: dto)
        }
        
        // MARK: - XPC Conversions
        
        /// Convert SecurityConfigDTO to XPC dictionary
        ///
        /// - Parameter config: The SecurityConfigDTO to convert
        /// - Returns: A dictionary suitable for XPC transfer
        public static func toXPC(config: ConfigDTO) -> [String: Any] {
            XPCSecurityDTOAdapter.fromConfigDTO(config: config)
        }
        
        /// Convert XPC dictionary to SecurityConfigDTO
        ///
        /// - Parameter dictionary: The XPC dictionary to convert
        /// - Returns: A SecurityConfigDTO with equivalent settings
        public static func configFromXPC(dictionary: [String: Any]) -> ConfigDTO {
            XPCSecurityDTOAdapter.toConfigDTO(dictionary: dictionary)
        }
        
        /// Convert OperationResultDTO to XPC dictionary
        ///
        /// - Parameter result: The OperationResultDTO to convert
        /// - Returns: A dictionary suitable for XPC transfer
        public static func toXPC<T: Codable & Equatable & Sendable>(result: OperationResultDTO<T>) -> [String: Any] {
            do {
                return try XPCSecurityDTOAdapter.convertResultToXPC(result)
            } catch {
                // If conversion fails, return a basic error dictionary
                return [
                    "status": "failure",
                    "errorCode": -1,
                    "errorMessage": "Failed to convert result to XPC: \(error.localizedDescription)",
                    "details": [:]
                ]
            }
        }
        
        /// Convert XPC dictionary to OperationResultDTO
        ///
        /// - Parameters:
        ///   - dictionary: The XPC dictionary to convert
        ///   - type: The expected type for the value
        /// - Returns: An OperationResultDTO with equivalent information
        public static func operationResultFromXPC<T: Codable & Equatable & Sendable>(
            dictionary: [String: Any],
            type: T.Type
        ) -> OperationResultDTO<T> {
            XPCSecurityDTOAdapter.convertXPCToResult(dictionary, type: type)
        }
        
        // MARK: - Protocol Conversions
        
        /// Convert SecurityConfigDTO to itself
        ///
        /// - Parameter config: The SecurityConfigDTO to convert
        /// - Returns: The same SecurityConfigDTO
        public static func toDTO(config: ConfigDTO) -> ConfigDTO {
            config
        }
        
        /// Convert SecurityConfigDTO to itself
        ///
        /// - Parameter dto: The SecurityConfigDTO to convert
        /// - Returns: The same SecurityConfigDTO
        public static func fromDTO(config dto: ConfigDTO) -> ConfigDTO {
            dto
        }
        
        /// Convert SecurityConfigDTO to itself
        ///
        /// - Parameter dto: The SecurityConfigDTO to convert
        /// - Returns: The same SecurityConfigDTO
        public static func keyConfigFromDTO(config dto: ConfigDTO) -> ConfigDTO {
            dto
        }
    }
}

/// Extension to provide Foundation <-> FoundationIndependent conversions for security types
extension SecurityBridge {
    // MARK: - Secure Bytes Conversions
    
    /// Convert Foundation Data to SecureBytes
    ///
    /// - Parameter data: The Data to convert
    /// - Returns: SecureBytes containing the same bytes
    public static func toSecureBytes(data: Data) -> SecureBytes {
        let bytes = [UInt8](data)
        return SecureBytes(bytes: bytes)
    }
    
    /// Convert SecureBytes to Foundation Data
    ///
    /// - Parameter bytes: The SecureBytes to convert
    /// - Returns: Data containing the same bytes
    public static func toData(secureBytes: SecureBytes) -> Data {
        var buffer = [UInt8](repeating: 0, count: secureBytes.count)
        secureBytes.withUnsafeBytes { sourceBuffer in
            for i in 0..<sourceBuffer.count {
                buffer[i] = sourceBuffer[i]
            }
        }
        return Data(buffer)
    }
}

/// Extension to provide XPC communication utilities
extension SecurityBridge {
    /// Functions related to XPC communication
    public enum XPCUtilities {
        // XPC service names
        public static let securityServiceName = "com.umbra.SecurityService"
        
        // Default timeout values
        public static let defaultOperationTimeout: TimeInterval = 30.0
        
        /// Get the default connection options for XPC security services
        ///
        /// - Returns: Dictionary with connection options
        public static func defaultConnectionOptions() -> [String: Any] {
            [
                "timeout": defaultOperationTimeout,
                "anonymous": false
            ]
        }
    }
}
