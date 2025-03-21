import CoreDTOs
import Foundation
import Services
import ServicesDTOAdapter

/// Example demonstrating the use of ServicesDTOAdapter
public struct ServicesDTOExample {
    // MARK: - Properties

    /// The credential manager adapter to use for operations
    private let credentialAdapter: CredentialManagerDTOAdapter

    /// The security utils adapter to use for operations
    private let securityAdapter: SecurityUtilsDTOAdapter

    // MARK: - Initialization

    /// Initialize the example with the specified adapters
    /// - Parameters:
    ///   - credentialAdapter: The credential manager adapter to use
    ///   - securityAdapter: The security utils adapter to use
    public init(
        credentialAdapter: CredentialManagerDTOAdapter = CredentialManagerDTOAdapter(),
        securityAdapter: SecurityUtilsDTOAdapter = SecurityUtilsDTOAdapter()
    ) {
        self.credentialAdapter = credentialAdapter
        self.securityAdapter = securityAdapter
    }

    // MARK: - Example Methods

    /// Run all examples
    public func runAllExamples() {
        print("Running ServicesDTOAdapter Examples...")

        runCredentialExamples()
        runSecurityUtilsExamples()
        runErrorHandlingExamples()

        print("Examples complete!")
    }

    /// Example of using the credential manager adapter
    public func runCredentialExamples() {
        print("\n=== Credential Manager Examples ===\n")

        // Generate a sample credential
        let sampleCredential = generateSampleCredential()
        print("Generated sample credential bytes: \(sampleCredential.count) bytes")

        // Store the credential
        let storeConfig = SecurityConfigDTO(
            algorithm: "keychain",
            keySizeInBits: 0,
            options: [
                "service": "com.umbra.example",
                "account": "test-user"
            ]
        )
        
        let storeResult = credentialAdapter.storeCredential(
            sampleCredential,
            config: storeConfig
        )

        switch storeResult {
        case .success:
            print("✅ Successfully stored credential")

            // Retrieve the credential
            let retrieveConfig = SecurityConfigDTO(
                algorithm: "keychain",
                keySizeInBits: 0,
                options: [
                    "service": "com.umbra.example",
                    "account": "test-user"
                ]
            )
            
            let retrieveResult = credentialAdapter.retrieveCredential(
                config: retrieveConfig
            )

            switch retrieveResult {
            case let .success(retrievedCredential):
                print("✅ Successfully retrieved credential: \(retrievedCredential.count) bytes")

                // Delete the credential
                let deleteConfig = SecurityConfigDTO(
                    algorithm: "keychain",
                    keySizeInBits: 0,
                    options: [
                        "service": "com.umbra.example",
                        "account": "test-user"
                    ]
                )
                
                let deleteResult = credentialAdapter.deleteCredential(
                    config: deleteConfig
                )

                switch deleteResult {
                case .success:
                    print("✅ Successfully deleted credential")
                case let .failure(operationError):
                    print("❌ Failed to delete credential: \(operationError.error.message)")
                    print("   Error details: \(operationError.error.details)")
                }

            case let .failure(operationError):
                print("❌ Failed to retrieve credential: \(operationError.error.message)")
                print("   Error details: \(operationError.error.details)")
            }

        case let .failure(operationError):
            print("❌ Failed to store credential: \(operationError.error.message)")
            print("   Error details: \(operationError.error.details)")
        }
    }

    /// Example of using the security utils adapter
    public func runSecurityUtilsExamples() {
        print("\n=== Security Utils Examples ===\n")

        // Generate a key
        let keyConfig = SecurityConfigDTO(
            algorithm: "AES-256",
            keySizeInBits: 256
        )

        let keyResult = securityAdapter.generateKey(config: keyConfig)

        switch keyResult {
        case let .success(key):
            print("✅ Successfully generated key: \(key.count) bytes")

            // Hash data
            let dataToHash = "Hello, world!".data(using: .utf8)!.bytes
            let hashConfig = SecurityConfigDTO.hash(algorithm: "SHA256")

            let hashResult = securityAdapter.hashData(dataToHash, config: hashConfig)

            switch hashResult {
            case let .success(hash):
                print("✅ Successfully hashed data: \(hash.count) bytes")

                // Encrypt data
                let dataToEncrypt = "Secret message".data(using: .utf8)!.bytes

                // Create encryption config with key
                let keyBase64 = Data(key).base64EncodedString()
                let encryptConfig = SecurityConfigDTO(
                    algorithm: "AES",
                    keySizeInBits: 256,
                    options: ["key": keyBase64]
                )

                let encryptResult = securityAdapter.encryptData(
                    dataToEncrypt,
                    config: encryptConfig
                )

                switch encryptResult {
                case let .success(encryptedData):
                    print("✅ Successfully encrypted data: \(encryptedData.count) bytes")

                    // Decrypt data
                    let decryptConfig = SecurityConfigDTO(
                        algorithm: "AES",
                        keySizeInBits: 256,
                        options: ["key": keyBase64]
                    )

                    let decryptResult = securityAdapter.decryptData(
                        encryptedData,
                        config: decryptConfig
                    )

                    switch decryptResult {
                    case let .success(decryptedData):
                        print("✅ Successfully decrypted data: \(decryptedData.count) bytes")

                        if let decryptedString = String(
                            data: Data(decryptedData),
                            encoding: .utf8
                        ) {
                            print("   Decrypted text: \(decryptedString)")
                        }

                    case let .failure(operationError):
                        print("❌ Failed to decrypt data: \(operationError.error.message)")
                        print("   Error details: \(operationError.error.details)")
                    }

                case let .failure(operationError):
                    print("❌ Failed to encrypt data: \(operationError.error.message)")
                    print("   Error details: \(operationError.error.details)")
                }

            case let .failure(operationError):
                print("❌ Failed to hash data: \(operationError.error.message)")
                print("   Error details: \(operationError.error.details)")
            }

        case let .failure(operationError):
            print("❌ Failed to generate key: \(operationError.error.message)")
            print("   Error details: \(operationError.error.details)")
        }
    }

    /// Example of error handling with SecurityErrorDTO
    public func runErrorHandlingExamples() {
        print("\n=== Error Handling Examples ===\n")

        // Example of credential error handling
        do {
            // Attempt to retrieve a non-existent credential
            let nonExistentConfig = SecurityConfigDTO(
                algorithm: "keychain",
                keySizeInBits: 0,
                options: [
                    "service": "com.umbra.nonexistent",
                    "account": "nobody"
                ]
            )
            
            let result = credentialAdapter.retrieveCredential(
                config: nonExistentConfig
            )

            switch result {
            case .success:
                print("⚠️ Unexpected success when retrieving non-existent credential")
            case let .failure(operationError):
                print("✅ Expected error when retrieving non-existent credential:")
                print("   - Code: \(operationError.error.code)")
                print("   - Domain: \(operationError.error.domain)")
                print("   - Message: \(operationError.error.message)")
                print("   - Details: \(operationError.error.details)")
            }

        } catch {
            print("❌ Unexpected exception: \(error)")
        }

        // Example of factory methods for creating SecurityErrorDTO
        print("\n--- SecurityErrorDTO Factory Methods ---\n")

        // Create different types of errors
        let credentialError = SecurityErrorDTO.credentialError(
            message: "Failed to access keychain",
            details: ["reason": "Keychain access denied"]
        )

        let keyError = SecurityErrorDTO.keyError(
            message: "Invalid key size",
            details: ["requiredSize": "256 bits", "providedSize": "128 bits"]
        )

        let encryptionError = SecurityErrorDTO.encryptionError(
            message: "Encryption failed",
            details: ["algorithm": "AES", "reason": "Invalid padding"]
        )

        // Print error details
        print("Credential Error:")
        print("   - Code: \(credentialError.code)")
        print("   - Domain: \(credentialError.domain)")
        print("   - Message: \(credentialError.message)")
        print("   - Details: \(credentialError.details)")

        print("\nKey Error:")
        print("   - Code: \(keyError.code)")
        print("   - Domain: \(keyError.domain)")
        print("   - Message: \(keyError.message)")
        print("   - Details: \(keyError.details)")

        print("\nEncryption Error:")
        print("   - Code: \(encryptionError.code)")
        print("   - Domain: \(encryptionError.domain)")
        print("   - Message: \(encryptionError.message)")
        print("   - Details: \(encryptionError.details)")
    }

    // MARK: - Helper Methods

    /// Generate a sample credential for testing
    /// - Returns: A sample credential as bytes
    private func generateSampleCredential() -> [UInt8] {
        // Generate a random credential (for example, a password)
        let password = "ExamplePassword123!"
        return Array(password.utf8)
    }
}

// MARK: - Data Extensions

extension Data {
    /// Convert Data to array of bytes
    var bytes: [UInt8] {
        [UInt8](self)
    }
}

// MARK: - Main Entry Point

/// Run the Services DTO example
public func runServicesDTOExample() {
    let example = ServicesDTOExample()
    example.runAllExamples()
}

@main
struct ServicesDTOExampleRunner {
    static func main() async {
        print("=== Services DTO Example ===\n")

        runServicesDTOExample()

        print("\n=== Example Complete ===")
    }
}
