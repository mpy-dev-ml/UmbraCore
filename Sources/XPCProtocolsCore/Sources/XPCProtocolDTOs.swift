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

/// Namespace for XPC Protocol DTO utilities
public enum XPCProtocolDTOs {
    /// Converts between SecurityErrorDTO and XPCSecurityError types
    public enum SecurityErrorConverter {
        /// Convert from XPCSecurityError to SecurityErrorDTO
        /// - Parameter error: The XPC security error to convert
        /// - Returns: A foundation-independent SecurityErrorDTO
        public static func toDTO(_ error: XPCProtocolsCore.XPCSecurityError) -> SecurityErrorDTO {
            switch error {
            case .serviceUnavailable:
                SecurityErrorDTO(
                    code: 10_001,
                    domain: "xpc.service",
                    message: "Service is unavailable"
                )

            case let .serviceNotReady(reason):
                SecurityErrorDTO(
                    code: 10_002,
                    domain: "xpc.service",
                    message: "Service is not ready",
                    details: ["reason": reason]
                )

            case let .timeout(after):
                SecurityErrorDTO(
                    code: 10_003,
                    domain: "xpc.service",
                    message: "Operation timed out",
                    details: ["timeoutInterval": String(after)]
                )

            case let .authenticationFailed(reason):
                SecurityErrorDTO(
                    code: 10_004,
                    domain: "xpc.security",
                    message: "Authentication failed",
                    details: ["reason": reason]
                )

            case let .authorizationDenied(operation):
                SecurityErrorDTO(
                    code: 10_005,
                    domain: "xpc.security",
                    message: "Authorization denied",
                    details: ["operation": operation]
                )

            case let .operationNotSupported(name):
                SecurityErrorDTO(
                    code: 10_006,
                    domain: "xpc.operation",
                    message: "Operation not supported",
                    details: ["operation": name]
                )

            case let .invalidInput(details):
                SecurityErrorDTO(
                    code: 10_007,
                    domain: "xpc.input",
                    message: "Invalid input parameters",
                    details: ["details": details]
                )

            case let .invalidState(details):
                SecurityErrorDTO(
                    code: 10_008,
                    domain: "xpc.state",
                    message: "Invalid state for operation",
                    details: ["details": details]
                )

            case let .keyNotFound(identifier):
                SecurityErrorDTO(
                    code: 10_009,
                    domain: "xpc.key",
                    message: "Key not found",
                    details: ["identifier": identifier]
                )

            case let .invalidKeyType(expected, received):
                SecurityErrorDTO(
                    code: 10_010,
                    domain: "xpc.key",
                    message: "Invalid key type",
                    details: ["expected": expected, "received": received]
                )

            case let .cryptographicError(operation, details):
                SecurityErrorDTO(
                    code: 10_011,
                    domain: "xpc.crypto",
                    message: "Cryptographic error",
                    details: ["operation": operation, "details": details]
                )

            case let .internalError(reason):
                SecurityErrorDTO(
                    code: 10_012,
                    domain: "xpc.internal",
                    message: "Internal service error",
                    details: ["reason": reason]
                )

            case .connectionInterrupted:
                SecurityErrorDTO(
                    code: 10_013,
                    domain: "xpc.connection",
                    message: "Connection interrupted"
                )

            case let .connectionInvalidated(reason):
                SecurityErrorDTO(
                    code: 10_014,
                    domain: "xpc.connection",
                    message: "Connection invalidated",
                    details: ["reason": reason]
                )

            case let .operationFailed(operation, reason):
                SecurityErrorDTO(
                    code: 10_015,
                    domain: "xpc.operation",
                    message: "Operation failed",
                    details: ["operation": operation, "reason": reason]
                )

            case let .notImplemented(reason):
                SecurityErrorDTO(
                    code: 10_016,
                    domain: "xpc.implementation",
                    message: "Feature not implemented",
                    details: ["reason": reason]
                )
            }
        }

        /// Convert from SecurityErrorDTO to XPCSecurityError
        /// - Parameter dto: The DTO to convert
        /// - Returns: An XPCSecurityError
        public static func fromDTO(_ dto: SecurityErrorDTO) -> XPCProtocolsCore.XPCSecurityError {
            // Parse the domain and code to determine the appropriate XPCSecurityError
            switch dto.domain {
            case "xpc.service":
                if dto.code == 10_001 {
                    return .serviceUnavailable
                } else if dto.code == 10_002 {
                    return .serviceNotReady(reason: dto.details["reason"] ?? dto.message)
                } else if dto.code == 10_003 {
                    let interval = Double(dto.details["timeoutInterval"] ?? "0") ?? 0
                    return .timeout(after: interval)
                }

            case "xpc.security":
                if dto.code == 10_004 {
                    return .authenticationFailed(reason: dto.details["reason"] ?? dto.message)
                } else if dto.code == 10_005 {
                    return .authorizationDenied(operation: dto.details["operation"] ?? "unknown")
                }

            case "xpc.operation":
                if dto.code == 10_006 {
                    return .operationNotSupported(name: dto.details["operation"] ?? "unknown")
                } else if dto.code == 10_015 {
                    return .operationFailed(
                        operation: dto.details["operation"] ?? "unknown",
                        reason: dto.details["reason"] ?? dto.message
                    )
                }

            case "xpc.input":
                return .invalidInput(details: dto.details["details"] ?? dto.message)

            case "xpc.state":
                return .invalidState(details: dto.details["details"] ?? dto.message)

            case "xpc.key":
                if dto.code == 10_009 {
                    return .keyNotFound(identifier: dto.details["identifier"] ?? "unknown")
                } else if dto.code == 10_010 {
                    return .invalidKeyType(
                        expected: dto.details["expected"] ?? "unknown",
                        received: dto.details["received"] ?? "unknown"
                    )
                }

            case "xpc.crypto":
                return .cryptographicError(
                    operation: dto.details["operation"] ?? "unknown",
                    details: dto.details["details"] ?? dto.message
                )

            case "xpc.internal":
                return .internalError(reason: dto.details["reason"] ?? dto.message)

            case "xpc.connection":
                if dto.code == 10_013 {
                    return .connectionInterrupted
                } else if dto.code == 10_014 {
                    return .connectionInvalidated(reason: dto.details["reason"] ?? dto.message)
                }

            case "xpc.implementation":
                return .notImplemented(reason: dto.details["reason"] ?? dto.message)

            default:
                break
            }

            // Default fallback if we couldn't determine a specific error
            return .internalError(reason: dto.message)
        }

        /// Create a security error DTO from a Swift error
        /// - Parameter error: Swift error to convert
        /// - Returns: Security error DTO
        public static func createSecurityErrorDTO(from error: Error) -> SecurityErrorDTO {
            // If it's already a SecurityErrorDTO, just return it
            if let secError = error as? SecurityErrorDTO {
                return secError
            }

            // Create a generic error with description
            return SecurityErrorDTO.genericError(
                message: error.localizedDescription,
                details: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    /// Service status DTO for Foundation-independent status representation
    public struct ServiceStatusDTO: Sendable, Equatable {
        /// Timestamp in seconds since epoch
        public let timestamp: Int64

        /// Protocol version
        public let protocolVersion: String

        /// Service version if available
        public let serviceVersion: String?

        /// Device identifier if available
        public let deviceIdentifier: String?

        /// Additional status information
        public let additionalInfo: [String: String]?

        /// Initializer
        public init(
            timestamp: Int64,
            protocolVersion: String,
            serviceVersion: String? = nil,
            deviceIdentifier: String? = nil,
            additionalInfo: [String: String]? = nil
        ) {
            self.timestamp = timestamp
            self.protocolVersion = protocolVersion
            self.serviceVersion = serviceVersion
            self.deviceIdentifier = deviceIdentifier
            self.additionalInfo = additionalInfo
        }

        /// Create a status with current timestamp
        public static func current(
            protocolVersion: String,
            serviceVersion: String? = nil,
            deviceIdentifier: String? = nil,
            additionalInfo: [String: String]? = nil
        ) -> ServiceStatusDTO {
            // Get current timestamp in seconds since 1970
            let currentTimestamp = Int64(CFAbsoluteTimeGetCurrent() + 978_307_200) // Convert to Unix epoch

            return ServiceStatusDTO(
                timestamp: currentTimestamp,
                protocolVersion: protocolVersion,
                serviceVersion: serviceVersion,
                deviceIdentifier: deviceIdentifier,
                additionalInfo: additionalInfo
            )
        }

        /// Create a status indicating service failure
        public static func failure(
            errorReason: String,
            protocolVersion: String
        ) -> ServiceStatusDTO {
            let currentTimestamp = Int64(CFAbsoluteTimeGetCurrent() + 978_307_200) // Convert to Unix epoch

            return ServiceStatusDTO(
                timestamp: currentTimestamp,
                protocolVersion: protocolVersion,
                serviceVersion: nil,
                deviceIdentifier: nil,
                additionalInfo: ["error": errorReason]
            )
        }
    }
}

// MARK: - Void Extensions for OperationResultDTO

/// A type that wraps Void to make it Equatable for use with OperationResultDTO
public struct VoidResult: Sendable, Equatable {
    public init() {}
}

/// Extension to convert between OperationResultDTO<VoidResult> and void operations
public extension OperationResultDTO where T == VoidResult {
    /// Create a success result with no value
    static func success() -> Self {
        OperationResultDTO(value: VoidResult())
    }

    /// Create a failure result with the given error information
    /// - Parameters:
    ///   - code: Error code
    ///   - message: Error message
    ///   - details: Additional error details
    /// - Returns: Failure operation result
    static func failure(
        code: Int32,
        message: String,
        details: [String: String] = [:]
    ) -> Self {
        OperationResultDTO(
            status: .failure,
            errorCode: code,
            errorMessage: message,
            details: details
        )
    }
}

/// Extension to create a generic OperationResult
public extension OperationResultDTO {
    /// Create a success result without a known type
    /// Note: This should be used carefully to avoid type safety issues
    static func successWithoutValue() -> Self where T: OptionalProtocol {
        // Create a wrapper that properly handles nil for optional types
        let optionalNil = T.createEmpty()
        return Self(value: optionalNil)
    }
}

/// Protocol to allow type-safe operations with nil values
/// This is used to make operations like successWithoutValue work safely
public protocol OptionalProtocol {
    /// Associated value type
    associatedtype Wrapped

    /// Test if the value is present
    var hasValue: Bool { get }

    /// Unwrap the value or return nil
    func unwrapped() -> Wrapped?

    /// Initialize with a nil value
    init()

    /// Create an empty optional value
    static func createEmpty() -> Self
}

/// Make Optional conform to OptionalProtocol
extension Optional: OptionalProtocol {
    /// Test if the value is present
    public var hasValue: Bool {
        self != nil
    }

    /// Unwrap the value or return nil
    public func unwrapped() -> Wrapped? {
        self
    }

    /// Initialize with a nil value
    public init() {
        self = nil
    }

    /// Create an empty optional value
    public static func createEmpty() -> Self {
        nil
    }
}

/// Extension to convert between XPCServiceStatus and XPCProtocolDTOs.ServiceStatusDTO
public extension XPCServiceStatus {
    /// Convert to ServiceStatusDTO
    func toDTO() -> XPCProtocolDTOs.ServiceStatusDTO {
        XPCProtocolDTOs.ServiceStatusDTO(
            timestamp: Int64(timestamp.timeIntervalSince1970),
            protocolVersion: protocolVersion,
            serviceVersion: serviceVersion,
            deviceIdentifier: deviceIdentifier,
            additionalInfo: additionalInfo
        )
    }

    /// Initialize from ServiceStatusDTO
    /*
     public init(fromDTO dto: XPCProtocolDTOs.ServiceStatusDTO) {
         self.init(
             timestamp: Date(timeIntervalSince1970: TimeInterval(dto.timestamp)),
             protocolVersion: dto.protocolVersion,
             serviceVersion: dto.serviceVersion,
             deviceIdentifier: dto.deviceIdentifier,
             additionalInfo: dto.additionalInfo
         )
     }
     */
}
