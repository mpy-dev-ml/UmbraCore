import CryptoSwiftFoundationIndependent
import SecurityImplementation
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

final class CryptoServiceTests: XCTestCase {

  private var cryptoService: CryptoServiceImpl!

  override func setUp() {
    super.setUp()
    cryptoService = CryptoServiceImpl()
  }

  override func tearDown() {
    cryptoService = nil
    super.tearDown()
  }

  // MARK: - Test Key Generation

  func testGenerateKey() async {
    let result = await cryptoService.generateKey()

    // Verify success case
    if case let .success(key) = result {
      XCTAssertEqual(key.count, 32) // AES-256 key should be 32 bytes
    } else {
      XCTFail("Key generation should succeed")
    }
  }

  // MARK: - Test Symmetric Encryption/Decryption

  func testEncryptAndDecryptSymmetric() async {
    // Generate test data
    let plaintext = SecureBytes(Array("Test secure message".utf8))

    // Generate a key
    let keyResult = await cryptoService.generateKey()
    guard case let .success(key) = keyResult else {
      XCTFail("Failed to generate key")
      return
    }

    // Encrypt the plaintext
    let config = SecurityConfigDTO(
      algorithm: "AES-GCM",
      keySizeInBits: 256
    )
    let encryptResult = await cryptoService.encryptSymmetric(
      data: plaintext,
      key: key,
      config: config
    )

    // Verify encryption was successful
    XCTAssertTrue(encryptResult.success, "Encryption should succeed")
    guard let encryptedData = encryptResult.data else {
      XCTFail("Encrypted data should not be nil")
      return
    }

    // Verify encrypted data is not empty and is different from plaintext
    XCTAssertFalse(encryptedData.isEmpty)
    XCTAssertNotEqual(encryptedData, plaintext)

    // Now decrypt the encrypted data
    let decryptResult = await cryptoService.decryptSymmetric(
      data: encryptedData,
      key: key,
      config: config
    )

    // Verify decryption was successful
    XCTAssertTrue(decryptResult.success, "Decryption should succeed")
    guard let decryptedData = decryptResult.data else {
      XCTFail("Decrypted data should not be nil")
      return
    }

    // Verify decrypted data matches original plaintext
    XCTAssertEqual(decryptedData, plaintext)
  }

  // MARK: - Test Hashing

  func testHash() async {
    // Create test data
    let data = SecureBytes(Array("Data to hash".utf8))

    // Hash the data with SHA-256 config
    let config = SecurityConfigDTO(
      algorithm: "SHA-256",
      keySizeInBits: 256
    )
    let result = await cryptoService.hash(data: data, config: config)

    // Verify hashing was successful
    XCTAssertTrue(result.success, "Hashing should succeed")
    guard let hash = result.data else {
      XCTFail("Hash data should not be nil")
      return
    }

    // Verify hash has expected length for SHA-256 (32 bytes)
    XCTAssertEqual(hash.count, 32)

    // Hash the same data again
    let repeatResult = await cryptoService.hash(data: data, config: config)

    // Verify repeat hashing was successful
    XCTAssertTrue(repeatResult.success, "Repeat hashing should succeed")
    guard let repeatHash = repeatResult.data else {
      XCTFail("Repeat hash data should not be nil")
      return
    }

    // Verify hash consistency (same data should produce same hash)
    XCTAssertEqual(hash, repeatHash)

    // Hash different data
    let differentData = SecureBytes(Array("Different data".utf8))
    let differentResult = await cryptoService.hash(data: differentData, config: config)

    // Verify different data hashing was successful
    XCTAssertTrue(differentResult.success, "Different data hashing should succeed")
    guard let differentHash = differentResult.data else {
      XCTFail("Different hash data should not be nil")
      return
    }

    // Verify different data produces different hash
    XCTAssertNotEqual(hash, differentHash)
  }

  // MARK: - Test Error Cases

  func testInvalidKey() async {
    // Generate test data
    let plaintext = SecureBytes(Array("Test secure message".utf8))

    // Create an invalid key (wrong size)
    let invalidKey = SecureBytes(Array("tooShort".utf8)) // Only 8 bytes

    // Create config
    let config = SecurityConfigDTO(
      algorithm: "AES-GCM",
      keySizeInBits: 256
    )

    // Attempt to encrypt with invalid key
    let encryptResult = await cryptoService.encryptSymmetric(
      data: plaintext,
      key: invalidKey,
      config: config
    )

    // Verify encryption fails with appropriate error
    XCTAssertFalse(encryptResult.success, "Encryption with invalid key should fail")
  }
}
