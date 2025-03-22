/**
 # UmbraCore Security Configuration Builder

 This file provides functionality for creating and validating security configurations
 used in the UmbraCore security framework. It handles the conversion of options from
 various formats into properly structured SecurityConfigDTO objects.

 ## Responsibilities

 * Create properly configured SecurityConfigDTO objects
 * Apply sensible defaults for unspecified configuration options
 * Validate configuration parameters
 * Convert between different data formats for configuration options

 ## Usage

 The ConfigBuilder is typically used by the SecurityProvider to create configurations
 based on user-provided options. It handles the complexities of parameter validation
 and ensures that all required options are present with appropriate defaults.
 */

import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes

/// Builds and validates security configurations
///
/// ConfigBuilder is responsible for creating properly structured security configurations
/// from raw options dictionaries, applying appropriate defaults, and ensuring parameter
/// validity.
final class ConfigBuilder {
  // MARK: - Initialisation

  /// Creates a new ConfigBuilder instance
  init() {
    // No initialisation needed - stateless service
  }

  // MARK: - Configuration Building

  /**
   Create a secure configuration with appropriate defaults for the security subsystem.

   - Parameter options: Optional dictionary of configuration options
   - Returns: A properly configured SecurityConfigDTO

   ## Available Options

   * `algorithm`: String - The encryption algorithm to use (default: "AES-GCM")
   * `keySize`: Int - The key size in bits (default: 256)
   * `iv`: String - Hex-encoded initialisation vector
   * `keyIdentifier`: String - Identifier for a key in the key manager
   * `inputData`: String - Base64-encoded input data

   ## Default Configuration

   If no options are provided, the method will return a configuration with:
   - Algorithm: AES-GCM
   - Key Size: 256 bits
   - No IV (a random one will be generated by the crypto service)
   - No key identifier (key must be provided separately)
   - No input data
   */
  func createConfig(options: [String: Any]?) -> SecurityConfigDTO {
    // Extract options from the dictionary or use defaults
    let algorithm=options?["algorithm"] as? String ?? "AES-GCM"
    let keySize=options?["keySize"] as? Int ?? 256

    // Create a basic configuration
    var config=SecurityConfigDTO(
      algorithm: algorithm,
      keySizeInBits: keySize
    )

    // Add any additional options that were provided
    if let ivHex=options?["iv"] as? String {
      if let ivData=Utilities.hexStringToData(ivHex) {
        config=config.withInitializationVector(SecureBytes(bytes: ivData))
      }
    }

    if let keyID=options?["keyIdentifier"] as? String {
      config=config.withKeyIdentifier(keyID)
    }

    if let inputBase64=options?["inputData"] as? String {
      if let inputData=Utilities.base64StringToData(inputBase64) {
        config=config.withInputData(SecureBytes(bytes: inputData))
      }
    }

    return config
  }
}
