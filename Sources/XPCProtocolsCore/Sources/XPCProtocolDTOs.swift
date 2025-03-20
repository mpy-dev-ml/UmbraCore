/**
 # XPC Protocol DTOs

 This file provides standardised Data Transfer Objects for XPC protocol communications
 by leveraging the Foundation-independent CoreDTOs module. These DTOs enable consistent
 data exchange between XPC clients and services without relying on Foundation types.

 ## Features

 * Exports CoreDTOs types for use in XPC protocols
 * Provides adapters to convert between legacy types and DTOs
 * Standardises error handling and data representation
 * Enables fully Foundation-independent XPC communication
 */

import CoreDTOs
@_exported import struct CoreDTOs.OperationResultDTO
@_exported import struct CoreDTOs.SecurityConfigDTO
@_exported import struct CoreDTOs.SecurityErrorDTO
import CoreFoundation
import UmbraCoreTypes
import Foundation

/// Namespace for XPC Protocol DTO utilities
public enum XPCProtocolDTOs {
    /// Service status data transfer object
    public struct ServiceStatusDTO: Equatable, Sendable {
        /// Timestamp of status in milliseconds since epoch
        public let timestamp: Int64
        
        /// Protocol version string
        public let protocolVersion: String
        
        /// Service version string
        public let serviceVersion: String
        
        /// Device identifier (if applicable)
        public let deviceIdentifier: String
        
        /// Additional status information
        public let additionalInfo: [String: String]
        
        /// Initialize with all properties
        public init(
            timestamp: Int64,
            protocolVersion: String,
            serviceVersion: String,
            deviceIdentifier: String = "",
            additionalInfo: [String: String] = [:]
        ) {
            self.timestamp = timestamp
            self.protocolVersion = protocolVersion
            self.serviceVersion = serviceVersion
            self.deviceIdentifier = deviceIdentifier
            self.additionalInfo = additionalInfo
        }
        
        /// Create a status DTO with current timestamp
        public static func current(
            protocolVersion: String,
            serviceVersion: String,
            deviceIdentifier: String = "",
            additionalInfo: [String: String] = [:]
        ) -> Self {
            ServiceStatusDTO(
                timestamp: Int64(Date().timeIntervalSince1970 * 1000),
                protocolVersion: protocolVersion,
                serviceVersion: serviceVersion,
                deviceIdentifier: deviceIdentifier,
                additionalInfo: additionalInfo
            )
        }
    }
    
    /// Converts between SecurityErrorDTO and XPCSecurityError types
    public enum SecurityErrorConverter {
        /// Convert from XPCSecurityError to SecurityErrorDTO
        /// - Parameter error: The XPC security error to convert
        /// - Returns: A foundation-independent SecurityErrorDTO
        public static func toDTO(_ error: XPCProtocolsCore.XPCSecurityError) -> SecurityErrorDTO {
            switch error {
            case .serviceUnavailable:
                SecurityErrorDTO(
                    code: 10001,
                    message: "Service is unavailable"
                )

            case let .serviceNotReady(reason):
                SecurityErrorDTO(
                    code: 10002,
                    message: "Service is not ready",
                    details: ["reason": reason]
                )

            case let .timeout(after):
                SecurityErrorDTO(
                    code: 10003,
                    message: "Operation timed out",
                    details: ["timeoutInterval": String(after)]
                )

            case let .authenticationFailed(reason):
                SecurityErrorDTO(
                    code: 10004,
                    message: "Authentication failed",
                    details: ["reason": reason]
                )

            case let .authorizationDenied(operation):
                SecurityErrorDTO(
                    code: 10005,
                    message: "Authorization denied",
                    details: ["operation": operation]
                )

            case let .operationNotSupported(name):
                SecurityErrorDTO(
                    code: 10006,
                    message: "Operation not supported",
                    details: ["operation": name]
                )

            case let .invalidInput(details):
                SecurityErrorDTO(
                    code: 10007,
                    message: "Invalid input parameters",
                    details: ["details": details]
                )

            case let .invalidState(details):
                SecurityErrorDTO(
                    code: 10008,
                    message: "Invalid state for operation",
                    details: ["details": details]
                )

            case let .keyNotFound(identifier):
                SecurityErrorDTO(
                    code: 10009,
                    message: "Key not found",
                    details: ["identifier": identifier]
                )

            case let .invalidKeyType(expected, received):
                SecurityErrorDTO(
                    code: 10010,
                    message: "Invalid key type",
                    details: ["expected": expected, "received": received]
                )

            case let .cryptographicError(operation, details):
                SecurityErrorDTO(
                    code: 10011,
                    message: "Cryptographic error",
                    details: ["operation": operation, "details": details]
                )

            case let .keyManagementError(operation, details):
                SecurityErrorDTO(
                    code: 10017,
                    message: "Key management error",
                    details: ["operation": operation, "details": details]
                )

            case let .internalError(reason):
                SecurityErrorDTO(
                    code: 10012,
                    message: "Internal service error",
                    details: ["reason": reason]
                )

            case .connectionInterrupted:
                SecurityErrorDTO(
                    code: 10013,
                    message: "Connection interrupted"
                )

            case let .connectionInvalidated(reason):
                SecurityErrorDTO(
                    code: 10014,
                    message: "Connection invalidated",
                    details: ["reason": reason]
                )

            case let .operationFailed(operation, reason):
                SecurityErrorDTO(
                    code: 10015,
                    message: "Operation failed",
                    details: ["operation": operation, "reason": reason]
                )

            case let .notImplemented(reason):
                SecurityErrorDTO(
                    code: 10016,
                    message: "Feature not implemented",
                    details: ["reason": reason]
                )
            }
        }

        /// Convert from SecurityErrorDTO to XPCSecurityError
        /// - Parameter dto: The security error DTO to convert
        /// - Returns: An XPCSecurityError
        public static func fromDTO(_ dto: SecurityErrorDTO) -> XPCProtocolsCore.XPCSecurityError {
            // Match error code to a specific error type
            if dto.code == 1001 {
                return .invalidInput(details: dto.message)
            } else if dto.code == 1002 {
                return .authenticationFailed(reason: dto.message)
            } else if dto.code == 1003 {
                return .cryptographicError(operation: dto.details["operation"] ?? "unknown", details: dto.message)
            } else if dto.code == 1004 {
                return .timeout(after: Double(dto.details["timeout"] ?? "30") ?? 30)
            } else if dto.code == 1005 {
                return .connectionInterrupted
            }
            
            // Default fallback if we couldn't determine a specific error
            return .internalError(reason: dto.message)
        }
    }
}

/// A type that wraps Void to make it Equatable for use with OperationResultDTO
public struct VoidResult: Sendable, Equatable {
    public init() {}
}

/// Extension to convert between XPCServiceStatus and XPCProtocolDTOs.ServiceStatusDTO
extension XPCServiceStatus {
    /// Convert to ServiceStatusDTO
    func toDTO() -> XPCProtocolDTOs.ServiceStatusDTO {
        XPCProtocolDTOs.ServiceStatusDTO(
            timestamp: Int64(timestamp.timeIntervalSince1970),
            protocolVersion: protocolVersion,
            serviceVersion: serviceVersion ?? "unknown",
            deviceIdentifier: deviceIdentifier ?? "",
            additionalInfo: additionalInfo ?? [:]
        )
    }
}

/// Extension to create empty optionals
extension Optional {
    /// Initialize with nil value
    init() {
        self = nil
    }
    
    /// Create an empty optional value
    static func createEmpty() -> Self {
        nil
    }
}
