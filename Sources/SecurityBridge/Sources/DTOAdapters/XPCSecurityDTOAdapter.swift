import CoreDTOs
import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// XPCSecurityDTOAdapter enables conversion between CoreDTOs types
/// and XPC-compatible types for security operations.
public enum XPCSecurityDTOAdapter {
    // Type aliases for clarity
    public typealias ConfigDTO = CoreDTOs.SecurityConfigDTO
    public typealias ErrorDTO = CoreDTOs.SecurityErrorDTO
    public typealias OperationResultDTO<T> = CoreDTOs.OperationResultDTO<T> where T: Sendable, T: Equatable

    // MARK: - Standard Conversions

    /// Serialize an OperationResultDTO containing a Codable value into an XPC-friendly dictionary
    ///
    /// - Parameters:
    ///   - result: The OperationResultDTO to convert
    ///   - encoder: The JSONEncoder to use for encoding the value
    /// - Returns: A dictionary representation of the result suitable for XPC
    public static func convertResultToXPC(
        _ result: OperationResultDTO<some Codable & Sendable & Equatable>,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> [String: Any] {
        var dictionary: [String: Any] = [
            "status": result.status.rawValue,
            "details": result.details,
        ]

        // Add error information if present
        if let errorCode = result.errorCode {
            dictionary["errorCode"] = errorCode
        }
        if let errorMessage = result.errorMessage {
            dictionary["errorMessage"] = errorMessage
        }

        // Add value data if present and status is success
        if result.status == .success, let value = result.value {
            do {
                let data = try encoder.encode(value)
                dictionary["valueData"] = data
            } catch {
                // If encoding fails, return a failure result instead
                throw error
            }
        }

        return dictionary
    }

    /// Deserialize an XPC-friendly dictionary into an OperationResultDTO containing a Codable value
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary to deserialize
    ///   - type: The type of value to decode
    /// - Returns: The deserialized OperationResultDTO
    public static func convertXPCToResult<T: Codable & Sendable & Equatable>(
        _ dictionary: [String: Any],
        type: T.Type
    ) -> OperationResultDTO<T> {
        // Extract common fields
        let statusString = dictionary["status"] as? String ?? "failure"
        let status = OperationResultDTO<T>.Status(rawValue: statusString) ?? .failure
        let details = (dictionary["details"] as? [String: String]) ?? [:]

        switch status {
        case .success:
            // For success status, try to decode the value
            if let data = dictionary["valueData"] as? Data {
                do {
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(type, from: data)
                    return .success(value, details: details)
                } catch {
                    // If decoding fails, return a failure result
                    return .failure(
                        errorCode: -1,
                        errorMessage: "Failed to decode value: \(error.localizedDescription)",
                        details: details
                    )
                }
            } else {
                // If no value data is present but we have a success status and T is Optional,
                // return success with nil
                if let optionalType = T.self as? ExpressibleByNilLiteral.Type,
                   let nilValue = optionalType.init(nilLiteral: ()) as? T
                {
                    return .success(nilValue, details: details)
                } else {
                    // Otherwise, return a failure
                    return .failure(
                        errorCode: -1,
                        errorMessage: "Missing value data for non-optional type",
                        details: details
                    )
                }
            }

        case .failure:
            // For failure status, extract error details
            let errorCode = dictionary["errorCode"] as? Int32 ?? -1
            let errorMessage = dictionary["errorMessage"] as? String ?? "Unknown error"

            return .failure(
                errorCode: errorCode,
                errorMessage: errorMessage,
                details: details
            )

        case .cancelled:
            // For cancelled status, extract message if available
            let message = dictionary["errorMessage"] as? String ?? "Operation cancelled"

            return OperationResultDTO(
                status: .cancelled,
                errorMessage: message,
                details: details
            )

        @unknown default:
            // For any unknown status, treat as failure
            return .failure(
                errorCode: -1,
                errorMessage: "Unknown operation status: \(statusString)",
                details: details
            )
        }
    }

    /// Convert a dictionary of XPC-compatible values to a SecurityConfigDTO
    ///
    /// - Parameter dictionary: The dictionary to convert
    /// - Returns: A SecurityConfigDTO
    public static func toConfigDTO(dictionary: [String: Any]) -> ConfigDTO {
        // Extract algorithm and key size
        let algorithm = dictionary["algorithm"] as? String ?? "AES"
        let keySizeInBits = dictionary["keySizeInBits"] as? Int ?? 256

        // Extract options
        let options = dictionary["options"] as? [String: String] ?? [:]

        // Extract input data
        let inputData = dictionary["inputData"] as? [UInt8]

        // Create and return the DTO
        return ConfigDTO(
            algorithm: algorithm,
            keySizeInBits: keySizeInBits,
            options: options,
            inputData: inputData
        )
    }

    /// Convert a SecurityConfigDTO to a dictionary of XPC-compatible values
    ///
    /// - Parameter config: The SecurityConfigDTO to convert
    /// - Returns: A dictionary for XPC transport
    public static func fromConfigDTO(config: ConfigDTO) -> [String: Any] {
        var dictionary: [String: Any] = [
            "algorithm": config.algorithm,
            "keySizeInBits": config.keySizeInBits,
            "options": config.options,
        ]

        if let inputData = config.inputData {
            dictionary["inputData"] = inputData
        }

        return dictionary
    }

    /// Convert a SecurityErrorDTO to a dictionary of XPC-compatible values
    ///
    /// - Parameter error: The SecurityErrorDTO to convert
    /// - Returns: A dictionary for XPC transport
    public static func fromErrorDTO(error: ErrorDTO) -> [String: Any] {
        var dictionary: [String: Any] = [
            "code": error.code,
            "domain": error.domain,
            "message": error.message,
        ]

        if !error.details.isEmpty {
            dictionary["details"] = error.details
        }

        return dictionary
    }

    /// Convert a dictionary of XPC-compatible values to a SecurityErrorDTO
    ///
    /// - Parameter dictionary: The dictionary to convert
    /// - Returns: A SecurityErrorDTO
    public static func toErrorDTO(dictionary: [String: Any]) -> ErrorDTO {
        let code = (dictionary["code"] as? Int).flatMap { Int32($0) } ?? -1
        let domain = dictionary["domain"] as? String ?? "unknown"
        let message = dictionary["message"] as? String ?? "Unknown error"
        let details = dictionary["details"] as? [String: String] ?? [:]

        return ErrorDTO(
            code: code,
            domain: domain,
            message: message,
            details: details
        )
    }
}
