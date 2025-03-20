import CoreDTOs
import UmbraCoreTypes
import SecurityBridgeTypes

/// XPCServiceProtocolDTO provides Foundation-independent interfaces for XPC service communication
/// using CoreDTOs instead of Foundation types.
///
/// This protocol is designed to be used in contexts where Foundation independence is desired,
/// such as cross-platform frameworks or libraries that need to minimize dependencies.
public protocol XPCServiceProtocolDTO: Sendable {
    // MARK: - Service Operations
    
    /// Ping the service to check if it's available
    /// - Returns: A Result indicating availability or an error
    func ping() async -> Result<Bool, XPCSecurityErrorDTO>
    
    /// Get the service status
    /// - Returns: A Result containing status information or an error
    func getServiceStatus() async -> Result<XPCServiceDTO.ServiceStatusDTO, XPCSecurityErrorDTO>
    
    /// Get the service version
    /// - Returns: A Result containing version information or an error
    func getServiceVersion() async -> Result<String, XPCSecurityErrorDTO>
    
    /// Reset security settings
    /// - Returns: A Result indicating success or an error
    func resetSecurity() async -> Result<Void, XPCSecurityErrorDTO>
}

/// XPCServiceProtocolStandardDTO provides Foundation-independent interfaces for standard
/// cryptographic operations using CoreDTOs instead of Foundation types.
public protocol XPCServiceProtocolStandardDTO: XPCServiceProtocolDTO {
    // MARK: - Cryptographic Operations
    
    /// Generate random data
    /// - Parameter length: The length of the random data to generate in bytes
    /// - Returns: A Result containing the random data or an error
    func generateRandomData(length: Int) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    
    /// Encrypt data using the specified key
    /// - Parameters:
    ///   - data: The data to encrypt
    ///   - keyIdentifier: Optional key identifier
    /// - Returns: A Result containing the encrypted data or an error
    func encryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    
    /// Decrypt data using the specified key
    /// - Parameters:
    ///   - data: The data to decrypt
    ///   - keyIdentifier: Optional key identifier
    /// - Returns: A Result containing the decrypted data or an error
    func decryptData(_ data: SecureBytes, keyIdentifier: String?) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    
    /// Sign data using the specified key
    /// - Parameters:
    ///   - data: The data to sign
    ///   - keyIdentifier: Key identifier
    /// - Returns: A Result containing the signature or an error
    func sign(_ data: SecureBytes, keyIdentifier: String) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    
    /// Verify a signature
    /// - Parameters:
    ///   - signature: The signature to verify
    ///   - data: The data that was signed
    ///   - keyIdentifier: Key identifier
    /// - Returns: A Result containing a boolean indicating validity or an error
    func verify(signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async -> Result<Bool, XPCSecurityErrorDTO>
    
    /// Get the hardware identifier
    /// - Returns: A Result containing a hardware identifier string or an error
    func getHardwareIdentifier() async -> Result<String, XPCSecurityErrorDTO>
}

/// XPCServiceProtocolCompleteDTO provides Foundation-independent interfaces for extended
/// cryptographic operations using CoreDTOs instead of Foundation types.
public protocol XPCServiceProtocolCompleteDTO: XPCServiceProtocolStandardDTO {
    // MARK: - Key Management
    
    /// Generate a key of the specified type
    /// - Parameters:
    ///   - keyType: The type of key to generate
    ///   - keyIdentifier: Optional key identifier
    ///   - metadata: Optional metadata for the key
    /// - Returns: A Result containing the key identifier or an error
    func generateKey(
        keyType: XPCServiceDTO.KeyTypeDTO,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityErrorDTO>
    
    /// Delete a key
    /// - Parameter keyIdentifier: Key identifier
    /// - Returns: A Result indicating success or an error
    func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityErrorDTO>
    
    /// List available keys
    /// - Returns: A Result containing a list of key identifiers or an error
    func listKeys() async -> Result<[String], XPCSecurityErrorDTO>
    
    /// Import a key
    /// - Parameters:
    ///   - keyData: The key data
    ///   - keyType: The type of key
    ///   - keyFormat: The format of the key
    ///   - keyIdentifier: Optional key identifier
    ///   - metadata: Optional metadata for the key
    /// - Returns: A Result containing the key identifier or an error
    func importKey(
        keyData: SecureBytes,
        keyType: XPCServiceDTO.KeyTypeDTO,
        keyFormat: XPCServiceDTO.KeyFormatDTO,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityErrorDTO>
    
    /// Export a key
    /// - Parameters:
    ///   - keyIdentifier: Key identifier
    ///   - keyFormat: The desired format for the exported key
    /// - Returns: A Result containing the key data or an error
    func exportKey(
        keyIdentifier: String, 
        keyFormat: XPCServiceDTO.KeyFormatDTO
    ) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    
    /// Get information about a key
    /// - Parameter keyIdentifier: Key identifier
    /// - Returns: A Result containing key information or an error
    func getKeyInfo(keyIdentifier: String) async -> Result<XPCServiceDTO.KeyInfoDTO, XPCSecurityErrorDTO>
    
    // MARK: - Advanced Cryptographic Operations
    
    /// Derive a key from another key
    /// - Parameters:
    ///   - keyIdentifier: Key identifier of the source key
    ///   - info: Optional context information for derivation
    ///   - salt: Optional salt for derivation
    ///   - keyLength: The desired length of the derived key in bytes
    /// - Returns: A Result containing the derived key identifier or an error
    func deriveKey(
        fromKeyIdentifier keyIdentifier: String,
        info: SecureBytes?,
        salt: SecureBytes?,
        keyLength: Int
    ) async -> Result<String, XPCSecurityErrorDTO>
    
    /// Hash data using the specified algorithm
    /// - Parameters:
    ///   - data: The data to hash
    ///   - algorithm: The hash algorithm to use
    /// - Returns: A Result containing the hash or an error
    func hash(
        _ data: SecureBytes,
        algorithm: String
    ) async -> Result<SecureBytes, XPCSecurityErrorDTO>
    
    // MARK: - Synchronization
    
    /// Synchronize keys with the service
    /// - Parameter syncData: The key data to synchronize
    /// - Throws: XPCSecurityErrorDTO if synchronization fails
    func synchronizeKeys(_ syncData: SecureBytes) async throws
    
    /// Ping the service asynchronously
    /// - Returns: A Result indicating availability or an error
    func pingAsync() async -> Result<Bool, XPCSecurityErrorDTO>
}
