import CryptoSwiftFoundationIndependent
import SecurityProtocolsCore
import UmbraCoreTypes

/// Implementation of the CryptoServiceProtocol using CryptoSwiftFoundationIndependent
public final class CryptoServiceImpl: CryptoServiceProtocol {

  // MARK: - Initialization

  public init() {}

  // MARK: - CryptoServiceProtocol Implementation

  public func encrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, SecurityError> {
    do {
      // Default to AES-GCM with a random IV
      let iv=CryptoWrapper.generateRandomIVSecure()

      // Combine IV with encrypted data
      let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)

      // Return IV + encrypted data
      let ivData=iv
      let combinedData=SecureBytes.combine(ivData, encrypted)

      return .success(combinedData)
    } catch {
      return .failure(
        .encryptionFailed(reason: "Failed to encrypt data: \(error.localizedDescription)")
      )
    }
  }

  public func decrypt(
    data: SecureBytes,
    using key: SecureBytes
  ) async -> Result<SecureBytes, SecurityError> {
    do {
      // Extract IV from combined data (first 12 bytes)
      guard data.count > 12 else {
        return .failure(.invalidInput(reason: "Encrypted data too short"))
      }

      let (iv, encryptedData)=try data.split(at: 12)

      // Decrypt the data
      let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)

      return .success(decrypted)
    } catch {
      return .failure(
        .decryptionFailed(reason: "Failed to decrypt data: \(error.localizedDescription)")
      )
    }
  }

  public func generateKey() async -> Result<SecureBytes, SecurityError> {
    // Generate a 256-bit key (32 bytes)
    let key=CryptoWrapper.generateRandomKeySecure(size: 32)
    return .success(key)
  }

  public func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    let hashedData=CryptoWrapper.sha256(data)
    return .success(hashedData)
  }

  public func verify(data: SecureBytes, against hash: SecureBytes) async -> Bool {
    let computedHash=CryptoWrapper.sha256(data)
    return computedHash == hash
  }

  /// Generate cryptographically secure random data
  /// - Parameter length: The length of random data to generate in bytes
  /// - Returns: Result containing random data or error
  public func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    do {
      var randomBytes=[UInt8](repeating: 0, count: length)

      // Generate random bytes using CryptoKit's secure random number generator
      let status=try CryptoWrapper.generateSecureRandomBytes(&randomBytes, length: length)

      if status {
        return .success(SecureBytes(randomBytes))
      } else {
        return .failure(.randomGenerationFailed(reason: "Failed to generate secure random bytes"))
      }
    } catch {
      return .failure(
        .randomGenerationFailed(
          reason: "Error during random generation: \(error.localizedDescription)"
        )
      )
    }
  }

  // MARK: - Symmetric Encryption

  public func encryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    do {
      // Use configuration to determine algorithm and parameters
      switch config.algorithm {
        case "AES-GCM":
          // Use the provided IV or generate a new one
          let iv=config.initializationVector ?? CryptoWrapper.generateRandomIVSecure()

          // Encrypt the data
          let encrypted=try CryptoWrapper.encryptAES_GCM(data: data, key: key, iv: iv)

          // Combine IV with encrypted data
          let combinedData=SecureBytes.combine(iv, encrypted)
          return SecurityResultDTO.success(data: combinedData)

        default:
          return SecurityResultDTO.failure(
            code: 400,
            message: "Unsupported algorithm: \(config.algorithm)"
          )
      }
    } catch {
      return SecurityResultDTO.failure(
        code: 500,
        message: "Encryption failed: \(error.localizedDescription)"
      )
    }
  }

  public func decryptSymmetric(
    data: SecureBytes,
    key: SecureBytes,
    config: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    do {
      switch config.algorithm {
        case "AES-GCM":
          // If IV is provided, use it, otherwise extract from data
          if let iv=config.initializationVector {
            // Use the provided IV directly with the data
            let decrypted=try CryptoWrapper.decryptAES_GCM(data: data, key: key, iv: iv)
            return SecurityResultDTO.success(data: decrypted)
          } else {
            // Extract IV from combined data (first 12 bytes)
            guard data.count > 12 else {
              return SecurityResultDTO.failure(
                code: 400,
                message: "Encrypted data too short"
              )
            }

            let (iv, encryptedData)=try data.split(at: 12)
            let decrypted=try CryptoWrapper.decryptAES_GCM(data: encryptedData, key: key, iv: iv)
            return SecurityResultDTO.success(data: decrypted)
          }

        default:
          return SecurityResultDTO.failure(
            code: 400,
            message: "Unsupported algorithm: \(config.algorithm)"
          )
      }
    } catch {
      return SecurityResultDTO.failure(
        code: 500,
        message: "Decryption failed: \(error.localizedDescription)"
      )
    }
  }

  // MARK: - Asymmetric Encryption

  public func encryptAsymmetric(
    data _: SecureBytes,
    publicKey _: SecureBytes,
    config _: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // Asymmetric encryption is not yet implemented in CryptoSwiftFoundationIndependent
    // This would require more complex integration with platform-specific crypto APIs
    SecurityResultDTO.failure(
      code: 501,
      message: "Asymmetric encryption not implemented"
    )
  }

  public func decryptAsymmetric(
    data _: SecureBytes,
    privateKey _: SecureBytes,
    config _: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // Asymmetric decryption is not yet implemented in CryptoSwiftFoundationIndependent
    // This would require more complex integration with platform-specific crypto APIs
    SecurityResultDTO.failure(
      code: 501,
      message: "Asymmetric decryption not implemented"
    )
  }

  // MARK: - Hashing

  public func hash(
    data: SecureBytes,
    config _: SecurityConfigDTO
  ) async -> SecurityResultDTO {
    // Currently only supporting SHA-256
    let hashedData=CryptoWrapper.sha256(data)
    return SecurityResultDTO.success(data: hashedData)
  }
}
