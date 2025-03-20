import CoreDTOs
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XPCProtocolsCore
import SecurityBridgeTypes

// MARK: - Protocol Definition

/// Protocol for XPC service communication using DTOs
public protocol XPCServiceProtocolStandardDTO: Sendable {
    func ping() async -> Result<Bool, XPCSecurityErrorDTO>
    func getServiceStatus() async -> Result<XPCServiceDTO.ServiceStatusDTO, XPCSecurityErrorDTO>
    func getServiceVersion() async -> Result<String, XPCSecurityErrorDTO>
    func getHardwareIdentifier() async -> Result<String, XPCSecurityErrorDTO>
    func resetSecurity() async -> Result<Void, XPCSecurityErrorDTO>
    func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    func synchronizeKeys(_ syncData: SecureBytes) async throws
}

// DEPRECATED: /// XPCServiceDTOAdapter provides a Foundation-independent implementation
/// of XPC communication for security services using CoreDTOs.
@available(*, deprecated, message: "This file is being refactored as part of XPC Protocol Consolidation")
// DEPRECATED: public final class XPCServiceDTOAdapter: XPCServiceProtocolStandardDTO, @unchecked Sendable {
    // MARK: - Properties
    
    /// The NSXPCConnection that handles the XPC communication
    private let connection: NSXPCConnection
    
    // Using a lock to make connection access thread-safe
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Initialize with an XPC connection
    /// - Parameter connection: The NSXPCConnection to use
    public init(connection: NSXPCConnection) {
        self.connection = connection
        connection.resume()
    }
    
    // MARK: - Service Operations
    
    /// Ping the XPC service
    /// - Returns: A Result containing a boolean indicating success or an error
    public func ping() async -> Result<Bool, XPCSecurityErrorDTO> {
        // Temporary mock implementation
        return .success(true)
    }
    
    /// Get the service status
    /// - Returns: A Result containing the service status or an error
    public func getServiceStatus() async -> Result<XPCServiceDTO.ServiceStatusDTO, XPCSecurityErrorDTO> {
        // Temporary mock implementation
        let statusDTO = XPCServiceDTO.ServiceStatusDTO(
            status: "healthy",
            version: "1.0.0",
            metrics: ["responseTime": 0.05],
            stringInfo: ["message": "Service is operational"]
        )
        return .success(statusDTO)
    }
    
    /// Get the service version
    /// - Returns: A Result containing a version string or an error
    public func getServiceVersion() async -> Result<String, XPCSecurityErrorDTO> {
        // Temporary mock implementation
        return .success("1.0.0")
    }
    
    /// Get the hardware identifier
    /// - Returns: A Result containing a hardware identifier or an error
    public func getHardwareIdentifier() async -> Result<String, XPCSecurityErrorDTO> {
        // Temporary mock implementation
        return .success("mock-hardware-id")
    }
    
    /// Reset security settings
    /// - Returns: A Result indicating success or an error
    public func resetSecurity() async -> Result<Void, XPCSecurityErrorDTO> {
        // Temporary mock implementation
        return .success(())
    }
    
    /// Generate random data
    /// - Parameter length: The length of the random data to generate
    /// - Returns: A Result containing the random data or an error
    public func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityErrorDTO> {
        // Temporary mock implementation
        return .success(SecureBytes(bytes: Array(repeating: 0, count: length)))
    }
    
    /// Synchronize keys with the XPC service
    /// - Parameter syncData: The synchronization data
    /// - Throws: XPCSecurityErrorDTO if synchronization fails
    public func synchronizeKeys(_ syncData: SecureBytes) async throws {
        // Temporary mock implementation - no action needed
    }
}

// MARK: - DTO Converter

/// Utility for converting between DTO and non-DTO types
public enum XPCSecurityDTOConverter {
    /// Convert a SecurityError to an XPCSecurityErrorDTO
    /// - Parameter error: The error to convert
    /// - Returns: An XPCSecurityErrorDTO representation of the error
    // DEPRECATED: public static func toDTO(_ error: XPCProtocolsCore.SecurityError) -> XPCSecurityErrorDTO {
        // DEPRECATED: switch error {
        case .serviceUnavailable:
            return XPCSecurityErrorDTO(code: .serviceUnavailable, details: ["message": "XPC service is unavailable"])
            
        case .serviceNotReady(let reason):
            return XPCSecurityErrorDTO(code: .serviceUnavailable, details: ["message": "XPC service not ready", "reason": reason])
            
        case .timeout(let after):
            return XPCSecurityErrorDTO(code: .unknown, details: ["message": "XPC operation timed out", "timeoutSeconds": String(after)])
            
        case .authenticationFailed(let reason):
            return XPCSecurityErrorDTO(code: .permissionDenied, details: ["message": "Authentication failed", "reason": reason])
            
        case .authorizationDenied(let operation):
            return XPCSecurityErrorDTO(code: .permissionDenied, details: ["message": "Authorization denied", "operation": operation])
            
        case .operationNotSupported(let name):
            return XPCSecurityErrorDTO(code: .unsupportedOperation, details: ["message": "Operation not supported", "operation": name])
            
        case .notImplemented(let reason):
            return XPCSecurityErrorDTO(code: .unsupportedOperation, details: ["message": "Not implemented", "reason": reason])
            
        case .invalidInput(let details):
            return XPCSecurityErrorDTO(code: .invalidInput, details: ["message": "Invalid input", "details": details])
            
        case .invalidState(let details):
            return XPCSecurityErrorDTO(code: .unknown, details: ["message": "Invalid state", "details": details])
            
        case .keyNotFound(let identifier):
            return XPCSecurityErrorDTO(code: .keyNotFound, details: ["message": "Key not found", "identifier": identifier])
            
        case .invalidKeyType(let expected, let received):
            return XPCSecurityErrorDTO(code: .cryptographicError, details: [
                // DEPRECATED: "message": "Invalid key type",
                "expected": expected,
                "received": received
            ])
            
        case .cryptographicError(let operation, let details):
            return XPCSecurityErrorDTO(code: .cryptographicError, details: [
                // DEPRECATED: "message": "Cryptographic error",
                "operation": operation,
                "details": details
            ])
            
        case .internalError(let reason):
            // DEPRECATED: return XPCSecurityErrorDTO(code: .unknown, details: ["message": "Internal error", "reason": reason])
            
        case .connectionInterrupted:
            return XPCSecurityErrorDTO(code: .serviceUnavailable, details: ["message": "Connection interrupted"])
            
        case .connectionInvalidated(let reason):
            return XPCSecurityErrorDTO(code: .serviceUnavailable, details: ["message": "Connection invalidated", "reason": reason])
            
        case .operationFailed(let operation, let reason):
            return XPCSecurityErrorDTO(code: .unknown, details: [
                "message": "Operation failed",
                "operation": operation,
                "reason": reason
            ])
            
        @unknown default:
            // Handle future cases that might be added to the SecurityError enum
            // DEPRECATED: return XPCSecurityErrorDTO(code: .unknown, details: ["message": "Unknown security error"])
        }
    }
}
