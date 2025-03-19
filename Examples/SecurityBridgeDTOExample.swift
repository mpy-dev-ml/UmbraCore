import Foundation
import CoreDTOs
import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes

/// This example demonstrates how to use the CoreDTOs integration in the SecurityBridge module.
/// It shows the conversion between Foundation-dependent types and Foundation-independent
/// CoreDTOs for security operations.

// Example 1: Converting errors between DTO and native representations
func errorConversionExample() {
    print("=== Error Conversion Example ===")
    
    // Create a native security error
    let nativeError = UmbraErrors.Security.Protocols.invalidFormat(reason: "Invalid key format")
    
    // Convert to DTO format
    let errorDTO = SecurityBridge.DTOAdapters.toErrorDTO(error: nativeError)
    print("Native error converted to DTO: \(errorDTO)")
    
    // Convert back to native format
    let convertedError = SecurityBridge.DTOAdapters.fromErrorDTO(dto: errorDTO)
    print("DTO converted back to native error: \(convertedError)")
    
    // Create a DTO directly
    let directDTO = SecurityErrorDTO.keyError(
        message: "Failed to generate key",
        details: ["algorithm": "AES-256", "keySize": "256"]
    )
    print("Directly created DTO: \(directDTO)")
    
    // Convert to NSError for Foundation-compatible APIs
    let nsError = FoundationConversions.toNSError(errorDTO: directDTO)
    print("DTO converted to NSError: \(nsError)")
}

// Example 2: Using SecurityConfigDTO for encryption configuration
func configurationExample() {
    print("\n=== Configuration Example ===")
    
    // Create encryption config using native types
    let nativeConfig = SecurityProtocols.EncryptionConfig(
        algorithm: .aes256GCM,
        keySizeInBits: 256,
        key: createRandomSecureBytes(count: 32),
        initializationVector: createRandomSecureBytes(count: 12),
        ivSizeBytes: 12,
        authenticationTagLength: 16
    )
    
    // Convert to DTO format
    let configDTO = SecurityBridge.DTOAdapters.toDTO(config: nativeConfig)
    print("Native config converted to DTO: \(configDTO)")
    
    // Convert back to native format
    let convertedConfig = SecurityBridge.DTOAdapters.fromDTO(config: configDTO)
    print("DTO converted back to native config: \(convertedConfig)")
    
    // Create a DTO directly
    let directDTO = SecurityConfigDTO.aesGCM().withOptions([
        "ivSize": "12",
        "authTagLength": "16"
    ])
    print("Directly created DTO: \(directDTO)")
}

// Example 3: Using XPC with DTOs
func xpcExample() {
    print("\n=== XPC Communication Example ===")
    
    // Create a sample error DTO
    let errorDTO = SecurityErrorDTO.encryptionError(
        message: "Encryption failed due to invalid key",
        details: ["operation": "encrypt", "dataSize": "1024"]
    )
    
    // Convert to XPC-safe dictionary
    let xpcDict = SecurityBridge.DTOAdapters.toXPC(error: errorDTO)
    print("Error DTO converted to XPC dictionary: \(xpcDict)")
    
    // Simulate receiving the dictionary from XPC
    let receivedErrorDTO = SecurityBridge.DTOAdapters.errorFromXPC(dictionary: xpcDict)
    print("XPC dictionary converted back to Error DTO: \(receivedErrorDTO)")
    
    // Create an operation result
    let result = OperationResultDTO<String>.success("Operation completed successfully")
    
    // Convert to XPC-safe dictionary
    let resultDict = SecurityBridge.DTOAdapters.toXPC(result: result)
    print("Operation result converted to XPC dictionary: \(resultDict)")
    
    // Simulate receiving the dictionary from XPC
    let receivedResult = SecurityBridge.DTOAdapters.operationResultFromXPC(
        dictionary: resultDict,
        type: String.self
    )
    print("XPC dictionary converted back to operation result: \(receivedResult)")
}

// Utility function to create random SecureBytes for demonstration
func createRandomSecureBytes(count: Int) -> SecureBytes {
    var bytes = [UInt8](repeating: 0, count: count)
    for i in 0..<count {
        bytes[i] = UInt8.random(in: 0...255)
    }
    return SecureBytes(bytes: bytes)
}

// Run the examples
func runAllExamples() {
    print("CoreDTOs in SecurityBridge Examples\n")
    errorConversionExample()
    configurationExample()
    xpcExample()
}

// Execute the examples
runAllExamples()
