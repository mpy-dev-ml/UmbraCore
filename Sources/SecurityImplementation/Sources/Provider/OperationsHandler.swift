/**
 # UmbraCore Security Operations Handler
 
 This file provides functionality for routing security operations to the appropriate
 specialised handlers and services within the UmbraCore security framework.
 
 ## Responsibilities
 
 * Route security operations to the appropriate service based on operation type
 * Retrieve keys when needed for cryptographic operations
 * Handle errors consistently across all operations
 * Enforce security policies for operations
 
 ## Design Pattern
 
 This class follows the Command pattern, encapsulating each security operation request
 as an object that contains all information needed to process the request. This allows
 for a clean separation of concerns between the client (SecurityProvider) and the
 services that perform the actual operations.
 
 ## Security Considerations
 
 * Centralised error handling ensures consistent security reporting
 * Key retrieval is handled consistently for all operations
 * Validation is performed before routing operations
 * Each operation type is handled by a specialised method for clarity and maintainability
 */

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import ErrorHandlingDomains

/// Handles routing of security operations to the appropriate services
///
/// OperationsHandler is responsible for taking security operation requests and
/// routing them to the appropriate service, handling key retrieval and error cases.
final class OperationsHandler {
  // MARK: - Properties
  
  /// The crypto service for cryptographic operations
  private let cryptoService: CryptoServiceProtocol
  
  /// The key manager for key operations
  private let keyManager: KeyManagementProtocol
  
  // MARK: - Initialisation
  
  /// Creates a new operations handler
  /// - Parameters:
  ///   - cryptoService: The crypto service to use
  ///   - keyManager: The key manager to use
  init(cryptoService: CryptoServiceProtocol, keyManager: KeyManagementProtocol) {
    self.cryptoService = cryptoService
    self.keyManager = keyManager
  }
  
  // MARK: - Operation Handling
  
  /// Handle a security operation by routing it to the appropriate handler
  /// - Parameters:
  ///   - operation: The security operation to perform
  ///   - config: Configuration options for the operation
  /// - Returns: Result of the operation
  func handleOperation(
    operation: SecurityOperation,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    switch operation {
    case .symmetricEncryption:
      return await handleSymmetricEncryption(config: config)
      
    case .symmetricDecryption:
      return await handleSymmetricDecryption(config: config)
      
    case .hashing:
      return await handleHashing(config: config)
      
    case .asymmetricEncryption:
      return await handleAsymmetricEncryption(config: config)
      
    case .asymmetricDecryption:
      return await handleAsymmetricDecryption(config: config)
      
    case .macGeneration:
      return await handleMACGeneration(config: config)
      
    case .signatureGeneration:
      return await handleSignatureGeneration(config: config)
      
    case .signatureVerification:
      return await handleSignatureVerification(config: config)
      
    case .randomGeneration:
      return await handleRandomGeneration(config: config)
      
    case .keyGeneration, .keyStorage, .keyRetrieval, .keyRotation, .keyDeletion:
      return handleKeyManagementOperation(operation: operation, config: config)
      
    @unknown default:
      return SecurityResultDTO.failure(
        error: .notImplemented
      )
    }
  }
  
  // MARK: - Operation Type Handlers
  
  /// Handle symmetric encryption operations
  /// - Parameter config: Configuration for the encryption
  /// - Returns: Result of the encryption
  private func handleSymmetricEncryption(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // First check if we need to retrieve a key
    let keyResult = await retrieveKeyIfNeeded(config: config)
    
    switch keyResult {
    case .success(let key):
      // Check if we have input data
      guard let inputData = config.inputData else {
        return SecurityResultDTO.failure(
          error: .invalidInput(reason: "No input data provided for encryption")
        )
      }
      
      // Perform the encryption with the key
      return await cryptoService.encryptSymmetricDTO(
        data: inputData,
        key: key,
        config: config
      )
      
    case .failure(let error):
      return SecurityResultDTO.failure(error: error)
    }
  }
  
  /// Handle symmetric decryption operations
  /// - Parameter config: Configuration for the decryption
  /// - Returns: Result of the decryption
  private func handleSymmetricDecryption(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // First check if we need to retrieve a key
    let keyResult = await retrieveKeyIfNeeded(config: config)
    
    switch keyResult {
    case .success(let key):
      // Check if we have input data
      guard let inputData = config.inputData else {
        return SecurityResultDTO.failure(
          error: .invalidInput(reason: "No input data provided for decryption")
        )
      }
      
      // Perform the decryption with the key
      return await cryptoService.decryptSymmetricDTO(
        data: inputData,
        key: key,
        config: config
      )
      
    case .failure(let error):
      return SecurityResultDTO.failure(error: error)
    }
  }
  
  /// Handle hashing operations
  /// - Parameter config: Configuration for the hashing
  /// - Returns: Result of the hashing
  private func handleHashing(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // Check if we have input data
    guard let inputData = config.inputData else {
      return SecurityResultDTO.failure(
        error: .invalidInput(reason: "No input data provided for hashing")
      )
    }
    
    // Perform the hashing
    return await cryptoService.hashDTO(
      data: inputData,
      config: config
    )
  }
  
  /// Handle asymmetric encryption operations
  /// - Parameter config: Configuration for the encryption
  /// - Returns: Result of the encryption
  private func handleAsymmetricEncryption(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // These operations are currently not implemented
    return SecurityResultDTO.failure(
      error: .notImplemented
    )
  }
  
  /// Handle asymmetric decryption operations
  /// - Parameter config: Configuration for the decryption
  /// - Returns: Result of the decryption
  private func handleAsymmetricDecryption(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // These operations are currently not implemented
    return SecurityResultDTO.failure(
      error: .notImplemented
    )
  }
  
  /// Handle MAC generation operations
  /// - Parameter config: Configuration for the MAC generation
  /// - Returns: Result of the MAC generation
  private func handleMACGeneration(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // These operations are currently not implemented
    return SecurityResultDTO.failure(
      error: .notImplemented
    )
  }
  
  /// Handle signature generation operations
  /// - Parameter config: Configuration for the signature generation
  /// - Returns: Result of the signature generation
  private func handleSignatureGeneration(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // These operations are currently not implemented
    return SecurityResultDTO.failure(
      error: .notImplemented
    )
  }
  
  /// Handle signature verification operations
  /// - Parameter config: Configuration for the signature verification
  /// - Returns: Result of the signature verification
  private func handleSignatureVerification(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // These operations are currently not implemented
    return SecurityResultDTO.failure(
      error: .notImplemented
    )
  }
  
  /// Handle random data generation operations
  /// - Parameter config: Configuration for the random generation
  /// - Returns: Result of the random generation
  private func handleRandomGeneration(
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // These operations are currently not implemented
    return SecurityResultDTO.failure(
      error: .notImplemented
    )
  }
  
  /// Handle key management operations
  /// - Parameters:
  ///   - operation: The key management operation to perform
  ///   - config: Configuration for the operation
  /// - Returns: Result of the operation
  private func handleKeyManagementOperation(
    operation: SecurityOperation,
    config: SecurityConfigDTO
  ) -> SecurityResultDTO {
    // Key management operations should be performed via the KeyManagement interface
    return SecurityResultDTO.failure(
      error: .serviceError(
        code: 104,
        reason: "Key management operations should be performed via KeyManagement interface"
      )
    )
  }
  
  // MARK: - Helper Methods
  
  /// Retrieve a key if specified by identifier in the configuration
  /// - Parameter config: The configuration potentially containing a key identifier
  /// - Returns: The key if found, or an error if not found or not specified
  private func retrieveKeyIfNeeded(
    config: SecurityConfigDTO
  ) async -> Result<SecureBytes, UmbraErrors.Security.Protocols> {
    // Check if a key is already provided in the config
    if let key = config.key {
      return .success(key)
    }
    
    // Check if a key identifier is provided
    if let keyID = config.keyIdentifier {
      // Retrieve the key from the key manager
      let keyResult = await keyManager.retrieveKey(withIdentifier: keyID)
      
      switch keyResult {
      case .success(let key):
        return .success(key)
      case .failure:
        return .failure(
          .serviceError(code: 100, reason: "Key not found: \(keyID)")
        )
      }
    }
    
    // Neither key nor key identifier provided
    return .failure(
      .invalidInput(reason: "No key or key identifier provided")
    )
  }
}
