import UmbraCoreTypes

/// FoundationIndependent configuration for security operations.
/// This struct provides configuration options for various security operations
/// without using any Foundation types.
public struct SecurityConfigDTO: Sendable, Equatable {
    // MARK: - Configuration Properties

    /// The algorithm to use for the operation
    public let algorithm: String

    /// Key size in bits
    public let keySizeInBits: Int

    /// Options dictionary for algorithm-specific parameters
    public let options: [String: String]

    /// Input data for the security operation
    public let inputData: [UInt8]?

    // MARK: - Initializers

    /// Initialize a security configuration
    /// - Parameters:
    ///   - algorithm: The algorithm identifier (e.g., "AES-GCM", "RSA", "PBKDF2")
    ///   - keySizeInBits: Key size in bits
    ///   - options: Additional algorithm-specific options
    ///   - inputData: Optional input data for the operation
    public init(
        algorithm: String,
        keySizeInBits: Int,
        options: [String: String] = [:],
        inputData: [UInt8]? = nil
    ) {
        self.algorithm = algorithm
        self.keySizeInBits = keySizeInBits
        self.options = options
        self.inputData = inputData
    }
    
    /// Create a new instance with updated options
    /// - Parameter newOptions: Additional options to merge with existing ones
    /// - Returns: A new SecurityConfigDTO with updated options
    public func withOptions(_ newOptions: [String: String]) -> SecurityConfigDTO {
        var mergedOptions = self.options
        for (key, value) in newOptions {
            mergedOptions[key] = value
        }
        
        return SecurityConfigDTO(
            algorithm: self.algorithm,
            keySizeInBits: self.keySizeInBits,
            options: mergedOptions,
            inputData: self.inputData
        )
    }
    
    /// Create a new instance with input data
    /// - Parameter data: The input data to use
    /// - Returns: A new SecurityConfigDTO with the specified input data
    public func withInputData(_ data: [UInt8]) -> SecurityConfigDTO {
        return SecurityConfigDTO(
            algorithm: self.algorithm,
            keySizeInBits: self.keySizeInBits,
            options: self.options,
            inputData: data
        )
    }
}

// MARK: - Factory Methods

public extension SecurityConfigDTO {
    /// Create a configuration for AES-GCM with 256-bit key
    /// - Returns: A SecurityConfigDTO configured for AES-GCM
    static func aesGCM() -> SecurityConfigDTO {
        return SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: 256
        )
    }
    
    /// Create a configuration for RSA with 2048-bit key
    /// - Returns: A SecurityConfigDTO configured for RSA
    static func rsa() -> SecurityConfigDTO {
        return SecurityConfigDTO(
            algorithm: "RSA",
            keySizeInBits: 2048
        )
    }
    
    /// Create a configuration for PBKDF2 with SHA-256
    /// - Parameters:
    ///   - iterations: Number of iterations for key derivation
    /// - Returns: A SecurityConfigDTO configured for PBKDF2
    static func pbkdf2(iterations: Int = 10000) -> SecurityConfigDTO {
        return SecurityConfigDTO(
            algorithm: "PBKDF2",
            keySizeInBits: 256,
            options: ["iterations": String(iterations), "hashAlgorithm": "SHA256"]
        )
    }
}
