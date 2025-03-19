import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import CoreDTOs

/// FoundationConversions provides utilities for converting between Foundation types
/// and foundation-free types when communicating through XPC or with legacy systems.
public enum FoundationConversions {
    // MARK: - Dictionary Conversions

    /// Convert a dictionary of [String: SecureBytes] to [String: Data]
    ///
    /// - Parameter dictionary: Dictionary of strings to SecureBytes
    /// - Returns: Dictionary of strings to Data
    public static func toFoundation(dictionary: [String: UmbraCoreTypes.SecureBytes])
        -> [String: Data] {
        dictionary.mapValues { secureBytes -> Data in
            let bytes = Array(secureBytes)
            let nsData = NSData(bytes: bytes, length: bytes.count)
            return Data(referencing: nsData)
        }
    }

    /// Convert a dictionary of [String: Data] to [String: SecureBytes]
    ///
    /// - Parameter dictionary: Dictionary of strings to Data
    /// - Returns: Dictionary of strings to SecureBytes
    public static func fromFoundation(dictionary: [String: Data])
        -> [String: UmbraCoreTypes.SecureBytes] {
        dictionary.mapValues { data -> UmbraCoreTypes.SecureBytes in
            let bytes = [UInt8](data)
            return UmbraCoreTypes.SecureBytes(bytes: bytes)
        }
    }

    // MARK: - Array Conversions

    /// Convert an array of SecureBytes to an array of Data
    ///
    /// - Parameter array: Array of SecureBytes
    /// - Returns: Array of equivalent Data
    public static func toFoundation(array: [UmbraCoreTypes.SecureBytes]) -> [Data] {
        array.map { secureBytes -> Data in
            let bytes = Array(secureBytes)
            let nsData = NSData(bytes: bytes, length: bytes.count)
            return Data(referencing: nsData)
        }
    }

    /// Convert an array of Data to an array of SecureBytes
    ///
    /// - Parameter array: Array of Data
    /// - Returns: Array of equivalent UmbraCoreTypes.SecureBytes
    public static func fromFoundation(array: [Data]) -> [UmbraCoreTypes.SecureBytes] {
        array.map { data -> UmbraCoreTypes.SecureBytes in
            let bytes = [UInt8](data)
            return UmbraCoreTypes.SecureBytes(bytes: bytes)
        }
    }

    // MARK: - JSON Conversions

    /// Convert SecureBytes to JSON Data
    ///
    /// - Parameter secureBytes: SecureBytes to convert to JSON
    /// - Returns: Data representation of JSON
    /// - Throws: AdapterError if conversion fails
    public static func jsonData(from secureBytes: UmbraCoreTypes.SecureBytes) throws -> Data {
        let bytes = Array(secureBytes)
        let nsData = NSData(bytes: bytes, length: bytes.count)
        let data = Data(referencing: nsData)

        // Verify that the data is valid JSON
        do {
            _ = try JSONSerialization.jsonObject(with: data)
            return data
        } catch {
            throw UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Data is not valid JSON: \(error.localizedDescription)")
        }
    }

    /// Convert a JSON-serializable object to UmbraCoreTypes.SecureBytes
    ///
    /// - Parameter jsonObject: Any JSONSerialization-compatible object
    /// - Returns: UmbraCoreTypes.SecureBytes containing the UTF-8 encoded JSON
    /// - Throws: AdapterError if conversion fails
    public static func secureBytes(from object: Any) throws -> UmbraCoreTypes.SecureBytes {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: [])
            let bytes = [UInt8](data)
            return UmbraCoreTypes.SecureBytes(bytes: bytes)
        } catch {
            throw UmbraErrors.Security.Protocols
                .invalidFormat(reason: "Could not convert object to JSON: \(error.localizedDescription)")
        }
    }
    
    // MARK: - DTO Conversions
    
    /// Convert SecurityErrorDTO to NSError
    ///
    /// - Parameter errorDTO: The SecurityErrorDTO to convert
    /// - Returns: An NSError representation
    public static func toNSError(errorDTO: SecurityErrorDTO) -> NSError {
        NSError(
            domain: errorDTO.domain,
            code: Int(errorDTO.code),
            userInfo: [
                NSLocalizedDescriptionKey: errorDTO.message,
                "details": errorDTO.details
            ]
        )
    }
    
    /// Convert NSError to SecurityErrorDTO
    ///
    /// - Parameter error: The NSError to convert
    /// - Returns: A SecurityErrorDTO representation
    public static func toErrorDTO(error: NSError) -> SecurityErrorDTO {
        // Extract details from user info if available
        var details: [String: String] = [:]
        
        if let detailsDict = error.userInfo["details"] as? [String: String] {
            details = detailsDict
        } else {
            // Convert other user info to string details
            for (key, value) in error.userInfo where key != NSLocalizedDescriptionKey {
                details[key] = String(describing: value)
            }
        }
        
        return SecurityErrorDTO(
            code: Int32(error.code),
            domain: error.domain,
            message: error.localizedDescription,
            details: details
        )
    }
    
    /// Convert SecurityConfigDTO to a Foundation-compatible dictionary
    ///
    /// - Parameter configDTO: The SecurityConfigDTO to convert
    /// - Returns: A [String: Any] dictionary with Foundation types
    public static func toFoundationDictionary(configDTO: SecurityConfigDTO) -> [String: Any] {
        var result: [String: Any] = [
            "algorithm": configDTO.algorithm,
            "keySizeInBits": configDTO.keySizeInBits,
            "options": configDTO.options
        ]
        
        // Convert input data to Foundation Data if present
        if let inputData = configDTO.inputData {
            result["inputData"] = Data(inputData)
        }
        
        return result
    }
    
    /// Create SecurityConfigDTO from a Foundation dictionary
    ///
    /// - Parameter dictionary: A Foundation dictionary with configuration values
    /// - Returns: A SecurityConfigDTO instance
    public static func toSecurityConfigDTO(dictionary: [String: Any]) -> SecurityConfigDTO {
        // Extract required values with defaults
        let algorithm = dictionary["algorithm"] as? String ?? "DEFAULT"
        let keySizeInBits = dictionary["keySizeInBits"] as? Int ?? 256
        
        // Extract options dictionary
        var options: [String: String] = [:]
        if let optionsDict = dictionary["options"] as? [String: String] {
            options = optionsDict
        } else if let optionsDict = dictionary["options"] as? [String: Any] {
            // Convert non-string values to strings
            for (key, value) in optionsDict {
                options[key] = String(describing: value)
            }
        }
        
        // Extract input data if present
        var inputData: [UInt8]?
        if let data = dictionary["inputData"] as? Data {
            inputData = [UInt8](data)
        }
        
        return SecurityConfigDTO(
            algorithm: algorithm,
            keySizeInBits: keySizeInBits,
            options: options,
            inputData: inputData
        )
    }
    
    /// Convert OperationResultDTO to a Foundation-compatible dictionary
    ///
    /// - Parameter result: The OperationResultDTO to convert
    /// - Returns: A [String: Any] dictionary suitable for serialization
    public static func toFoundationDictionary<T: Encodable>(result: OperationResultDTO<T>) -> [String: Any] {
        var dictionary: [String: Any] = [
            "success": result.isSuccess
        ]
        
        // Add value if successful and encodable
        if result.isSuccess, let value = result.value {
            do {
                let data = try JSONEncoder().encode(value)
                dictionary["valueData"] = data
                
                // Also try to convert to a JSON object for easier debugging
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                    dictionary["valueJson"] = jsonObject
                }
            } catch {
                // If encoding fails, add error information
                dictionary["encodingError"] = error.localizedDescription
            }
        }
        
        // Add error information if failed
        if !result.isSuccess, let error = result.error {
            dictionary["error"] = toNSError(errorDTO: error)
            dictionary["errorInfo"] = [
                "code": error.code,
                "domain": error.domain,
                "message": error.message,
                "details": error.details
            ]
        }
        
        return dictionary
    }
}
