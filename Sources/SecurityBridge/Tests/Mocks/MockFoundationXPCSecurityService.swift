import Foundation
@testable import SecurityBridge
import SecurityProtocolsCore

final class MockFoundationXPCSecurityService: NSObject, @unchecked Sendable {
  // MARK: - Test Control Properties

  var shouldFail=false
  var errorToThrow: Error?
  var methodCalls: [String]=[]

  // Data for key management methods
  var keyListResponse: [String]?
  var keyDataToReturn: Data?

  // Data for crypto service methods
  var encryptedDataToReturn: Data?
  var decryptedDataToReturn: Data?
  var signatureToReturn: Data?
  var verificationResult=true
  var hashDataToReturn: Data?
  var randomDataToReturn: Data?

  // MARK: - Basic crypto methods

  func encrypt(data: Data, key _: Data, completion: @escaping (Data?, Error?) -> Void) {
    methodCalls.append("encrypt")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock encryption failed"]
        )
      )
    } else {
      // Default implementation returns either the pre-configured data or original data
      completion(encryptedDataToReturn ?? data, nil)
    }
  }

  func encryptDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void) {
    methodCalls.append("encryptDataXPC")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock encryption failed")
    } else {
      // Default implementation returns either the pre-configured data or original data
      completion(encryptedDataToReturn ?? data, nil, nil)
    }
  }

  func decrypt(data: Data, key _: Data, completion: @escaping (Data?, Error?) -> Void) {
    methodCalls.append("decrypt")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock decryption failed"]
        )
      )
    } else {
      // Default implementation returns either the pre-configured data or original data
      completion(decryptedDataToReturn ?? data, nil)
    }
  }

  func decryptDataXPC(_ data: Data, completion: @escaping (Data?, NSNumber?, String?) -> Void) {
    methodCalls.append("decryptDataXPC")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock decryption failed")
    } else {
      // Default implementation returns either the pre-configured data or original data
      completion(decryptedDataToReturn ?? data, nil, nil)
    }
  }

  func generateKey(bits: Int, completion: @escaping (Data?, Error?) -> Void) {
    methodCalls.append("generateKey(bits: \(bits))")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock key generation failed"]
        )
      )
    } else {
      // Default implementation returns pre-configured key data or a simple sequence
      let defaultKeyData=Data((0..<32).map { UInt8($0 % 256) })
      completion(keyDataToReturn ?? defaultKeyData, nil)
    }
  }

  func generateKeyXPC(bits _: Int, completion: @escaping (Data?, NSNumber?, String?) -> Void) {
    methodCalls.append("generateKeyXPC")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock key generation failed")
    } else {
      // Default implementation returns pre-configured key data or a simple sequence
      let defaultKeyData=Data((0..<32).map { UInt8($0 % 256) })
      completion(keyDataToReturn ?? defaultKeyData, nil, nil)
    }
  }

  func generateRandomData(length: Int, completion: @escaping (Data?, Error?) -> Void) {
    methodCalls.append("generateRandomData")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock random data generation failed"]
        )
      )
    } else {
      // Default implementation returns pre-configured random data or a simple sequence
      let defaultRandomData=Data((0..<length).map { UInt8($0 % 256) })
      completion(randomDataToReturn ?? defaultRandomData, nil)
    }
  }

  func generateRandomDataXPC(
    _ length: Int,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("generateRandomDataXPC")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock random data generation failed")
    } else {
      // Default implementation returns pre-configured random data or a simple sequence
      let defaultRandomData=Data((0..<length).map { UInt8($0 % 256) })
      completion(randomDataToReturn ?? defaultRandomData, nil, nil)
    }
  }

  // MARK: - Hash functions

  func calculateHash(
    data _: Data,
    algorithm: String,
    completion: @escaping (Data?, Error?) -> Void
  ) {
    methodCalls.append("calculateHash(\(algorithm))")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock hash calculation failed"]
        )
      )
    } else {
      // Default implementation returns pre-configured hash data or a simple mock hash
      let defaultHashData=Data((0..<32).map { _ in UInt8.random(in: 0...255) })
      completion(hashDataToReturn ?? defaultHashData, nil)
    }
  }

  func calculateHashXPC(
    _: Data,
    algorithm: String,
    optionsJson _: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("calculateHashXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock hash calculation failed")
    } else {
      // Default implementation returns pre-configured hash data or a simple mock hash
      let defaultHashData=Data((0..<32).map { _ in UInt8.random(in: 0...255) })
      completion(hashDataToReturn ?? defaultHashData, nil, nil)
    }
  }

  // MARK: - Key management methods

  func storeSecurely(
    _: Data,
    identifier: String,
    completion: @escaping (Error?) -> Void
  ) {
    methodCalls.append("storeSecurely(\(identifier))")

    if shouldFail {
      completion(
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock credential storage failed"]
        )
      )
    } else {
      completion(nil)
    }
  }

  func storeSecurelyXPC(
    _: Data,
    identifier: String,
    completion: @escaping (NSNumber?, String?) -> Void
  ) {
    methodCalls.append("storeSecurelyXPC(\(identifier))")

    if shouldFail {
      completion(NSNumber(value: 500), "Mock credential storage failed")
    } else {
      completion(nil, nil)
    }
  }

  func retrieveSecurely(identifier: String, completion: @escaping (Data?, Error?) -> Void) {
    methodCalls.append("retrieveSecurely(\(identifier))")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock credential retrieval failed"]
        )
      )
    } else {
      // Default implementation returns a mock credential
      let defaultCredential=Data([0xDE, 0xAD, 0xBE, 0xEF])
      completion(defaultCredential, nil)
    }
  }

  func retrieveSecurelyXPC(
    _ identifier: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("retrieveSecurelyXPC(\(identifier))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock credential retrieval failed")
    } else {
      // Default implementation returns a mock credential
      let defaultCredential=Data([0xDE, 0xAD, 0xBE, 0xEF])
      completion(defaultCredential, nil, nil)
    }
  }

  func listKeyIdentifiers(completion: @escaping ([String]?, Error?) -> Void) {
    methodCalls.append("listKeyIdentifiers")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock key listing failed"]
        )
      )
    } else {
      // Default implementation returns pre-configured list or a default list
      let defaultKeys=["key1", "key2", "key3"]
      completion(keyListResponse ?? defaultKeys, nil)
    }
  }

  func listKeyIdentifiersXPC(completion: @escaping ([String]?, NSNumber?, String?) -> Void) {
    methodCalls.append("listKeyIdentifiersXPC")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock key listing failed")
    } else {
      // Default implementation returns pre-configured list or a default list
      let defaultKeys=["key1", "key2", "key3"]
      completion(keyListResponse ?? defaultKeys, nil, nil)
    }
  }

  // MARK: - Digital signature methods

  func signData(
    _: Data,
    algorithm: String,
    completion: @escaping (Data?, Error?) -> Void
  ) {
    methodCalls.append("signData(\(algorithm))")

    if shouldFail {
      completion(
        nil,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock signing failed"]
        )
      )
    } else {
      // Default implementation returns pre-configured signature or a simple mock
      let defaultSignature=Data((0..<64).map { UInt8($0 % 256) })
      completion(signatureToReturn ?? defaultSignature, nil)
    }
  }

  func signDataXPC(
    _: Data,
    algorithm: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("signDataXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Signing failed")
    } else {
      // Default implementation returns pre-configured signature or a simple mock
      let defaultSignature=Data((0..<64).map { UInt8($0 % 256) })
      completion(signatureToReturn ?? defaultSignature, nil, nil)
    }
  }

  func verifySignature(
    _: Data,
    forData _: Data,
    algorithm: String,
    completion: @escaping (Bool, Error?) -> Void
  ) {
    methodCalls.append("verifySignature(\(algorithm))")

    if shouldFail {
      completion(
        false,
        errorToThrow ?? NSError(
          domain: "MockSecurityError", code: 500,
          userInfo: [NSLocalizedDescriptionKey: "Mock verification failed"]
        )
      )
    } else {
      // Default implementation returns pre-configured result
      completion(verificationResult, nil)
    }
  }

  func verifySignatureXPC(
    _: Data,
    forData _: Data,
    algorithm: String,
    completion: @escaping (NSNumber?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("verifySignatureXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Verification failed")
    } else {
      // Default implementation returns pre-configured result
      completion(NSNumber(value: verificationResult ? 1 : 0), nil, nil)
    }
  }

  // MARK: - XPC-specific methods

  func hashDataXPC(
    data _: Data,
    algorithm: String,
    optionsJson _: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("hashDataXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock hashing failed")
    } else {
      // Return either the pre-configured hash or a simple hash of the data
      completion(hashDataToReturn ?? Data([0xA1, 0xB2, 0xC3]), nil, nil)
    }
  }

  func encryptSymmetricXPC(
    data: Data,
    key _: Data,
    algorithm: String,
    keySizeInBits _: Int,
    iv _: Data?,
    aad _: Data?,
    optionsJson _: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("encryptSymmetricXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock encryption failed")
    } else {
      // Return either the pre-configured encrypted data or the original data
      completion(encryptedDataToReturn ?? data, nil, nil)
    }
  }

  func decryptSymmetricXPC(
    data: Data,
    key _: Data,
    algorithm: String,
    keySizeInBits _: Int,
    iv _: Data?,
    aad _: Data?,
    optionsJson _: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("decryptSymmetricXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock decryption failed")
    } else {
      // Return either the pre-configured decrypted data or the original data
      completion(decryptedDataToReturn ?? data, nil, nil)
    }
  }

  func encryptAsymmetricXPC(
    data: Data,
    publicKey _: Data,
    algorithm: String,
    keySizeInBits _: Int,
    optionsJson _: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("encryptAsymmetricXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock asymmetric encryption failed")
    } else {
      // Return either the pre-configured encrypted data or the original data
      completion(encryptedDataToReturn ?? data, nil, nil)
    }
  }

  func decryptAsymmetricXPC(
    data: Data,
    privateKey _: Data,
    algorithm: String,
    keySizeInBits _: Int,
    optionsJson _: String,
    completion: @escaping (Data?, NSNumber?, String?) -> Void
  ) {
    methodCalls.append("decryptAsymmetricXPC(\(algorithm))")

    if shouldFail {
      completion(nil, NSNumber(value: 500), "Mock asymmetric decryption failed")
    } else {
      // Return either the pre-configured decrypted data or the original data
      completion(decryptedDataToReturn ?? data, nil, nil)
    }
  }
}
