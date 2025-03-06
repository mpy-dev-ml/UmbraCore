import Core
import Foundation
import XCTest

/// Tests for the CryptoService class that handles encryption, decryption, and key operations
final class CryptoTests: XCTestCase {
  // MARK: - Properties

  private var container: ServiceContainer!
  private var service: CryptoService!

  // MARK: - Test Lifecycle

  override func setUp() async throws {
    container=ServiceContainer()
    service=CryptoService()
  }

  override func tearDown() async throws {
    container=nil
    service=nil
  }

  // MARK: - Service Lifecycle Tests

  /// Tests the initialization lifecycle of the CryptoService
  func testServiceInitialization() async throws {
    try await container.register(service)
    let initialState=await service.state
    XCTAssertEqual(
      initialState,
      .uninitialized,
      "Service should start in uninitialized state"
    )

    try await container.initialiseAll()
    let readyState=await service.state
    XCTAssertEqual(
      readyState,
      .ready,
      "Service should transition to ready state after initialization"
    )
  }

  // MARK: - Key Management Tests

  /// Tests key generation and key derivation functionality
  func testKeyGeneration() async throws {
    try await container.register(service)
    try await container.initialiseAll()

    // Test key generation
    let key=try await service.generateKey()
    XCTAssertEqual(
      key.count,
      32,
      "Generated key should be 32 bytes (AES-256)"
    )

    // Test key derivation
    let password="test-password"
    let salt=Array("test-salt".utf8)
    let derivedKey=try await service.deriveKey(
      from: password,
      salt: salt
    )
    XCTAssertEqual(
      derivedKey.count,
      32,
      "Derived key should be 32 bytes (AES-256)"
    )

    // Same password and salt should yield same key
    let sameKey=try await service.deriveKey(
      from: password,
      salt: salt
    )
    XCTAssertEqual(
      derivedKey,
      sameKey,
      "Same password and salt should produce identical keys"
    )

    // Different password should yield different key
    let differentKey=try await service.deriveKey(
      from: "different-password",
      salt: salt
    )
    XCTAssertNotEqual(
      derivedKey,
      differentKey,
      "Different passwords should produce different keys"
    )

    // Different salt should yield different key
    let differentSalt=Array("different-salt".utf8)
    let keyWithDifferentSalt=try await service.deriveKey(
      from: password,
      salt: differentSalt
    )
    XCTAssertNotEqual(
      derivedKey,
      keyWithDifferentSalt,
      "Different salts should produce different keys"
    )
  }

  // MARK: - Encryption Tests

  /// Tests encryption and decryption operations with various scenarios
  func testEncryptionDecryption() async throws {
    try await container.register(service)
    try await container.initialiseAll()

    // Test basic encryption/decryption
    let key=try await service.generateKey()
    let data=Array("Hello, World!".utf8)

    let encryptedResult=try await service.encrypt(data, using: key)
    XCTAssertFalse(
      encryptedResult.encrypted.isEmpty,
      "Encrypted data should not be empty"
    )
    XCTAssertFalse(
      encryptedResult.initializationVector.isEmpty,
      "Initialization vector should not be empty"
    )
    XCTAssertFalse(
      encryptedResult.tag.isEmpty,
      "Authentication tag should not be empty"
    )

    let decrypted=try await service.decrypt(encryptedResult, using: key)
    XCTAssertEqual(
      data,
      decrypted,
      "Decrypted data should match original input"
    )

    // Test wrong key fails decryption
    let wrongKey=try await service.generateKey()
    do {
      _=try await service.decrypt(encryptedResult, using: wrongKey)
      XCTFail("Decryption should fail with wrong key")
    } catch let error as SecurityError {
      XCTAssertTrue(
        error.errorDescription?.contains("Decryption failed") == true,
        "Error should indicate decryption failure"
      )
    }
  }

  // MARK: - Error Handling Tests

  /// Tests various error conditions and their handling
  func testErrorHandling() async throws {
    // Test operations before initialization
    do {
      _=try await service.generateKey()
      XCTFail("Service should not allow operations before initialization")
    } catch let error as ServiceError {
      XCTAssertTrue(
        error.errorDescription?.contains("Service not ready") == true,
        "Error should indicate service not ready"
      )
    }

    try await container.register(service)
    try await container.initialiseAll()

    // Test invalid key size
    do {
      let invalidKey=Array(repeating: UInt8(0), count: 16) // Too short
      _=try await service.encrypt([1, 2, 3], using: invalidKey)
      XCTFail("Encryption should fail with invalid key size")
    } catch let error as SecurityError {
      XCTAssertTrue(
        error.errorDescription?.contains("Invalid key size") == true,
        "Error should indicate invalid key size"
      )
    }
  }

  // MARK: - Performance Tests

  /// Tests the performance of encryption and decryption operations
  func testPerformance() async throws {
    try await container.register(service)
    try await container.initialiseAll()

    let key=try await service.generateKey()

    // Create 1MB of test data
    let largeData=Array(repeating: UInt8(0), count: 1024 * 1024)

    // Measure encryption time
    let startEncrypt=Date()
    let encryptedResult=try await service.encrypt(largeData, using: key)
    let encryptDuration=Date().timeIntervalSince(startEncrypt)
    XCTAssertLessThan(
      encryptDuration,
      1.0,
      "Encryption of 1MB data should take less than 1 second"
    )

    // Measure decryption time
    let startDecrypt=Date()
    _=try await service.decrypt(encryptedResult, using: key)
    let decryptDuration=Date().timeIntervalSince(startDecrypt)
    XCTAssertLessThan(
      decryptDuration,
      1.0,
      "Decryption of 1MB data should take less than 1 second"
    )
  }
}
