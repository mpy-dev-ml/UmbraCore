import CryptoTypes
import XCTest

final class DefaultCryptoServiceTests: XCTestCase {
  private var cryptoService: DefaultCryptoService!

  override func setUp() async throws {
    cryptoService=DefaultCryptoService()
  }

  func testGenerateSecureRandomKey() async throws {
    let length=32
    let key=try await cryptoService.generateSecureRandomKey(length: length)
    XCTAssertEqual(key.count, length)
  }

  func testGenerateSecureRandomBytes() async throws {
    let length=16
    let bytes=try await cryptoService.generateSecureRandomBytes(length: length)
    XCTAssertEqual(bytes.count, length)
  }

  func testEncryptDecrypt() async throws {
    let data=Data("Hello, World!".utf8)
    let key=try await cryptoService.generateSecureRandomKey(length: 32)
    let initVector=try await cryptoService.generateSecureRandomBytes(length: 12)

    let encrypted=try await cryptoService.encrypt(data, withKey: key, iv: initVector)
    XCTAssertNotEqual(encrypted, data)

    let decrypted=try await cryptoService.decrypt(encrypted, withKey: key, iv: initVector)
    XCTAssertEqual(decrypted, data)
  }

  func testEncryptDecryptWithInvalidKey() async throws {
    let data=Data("Hello, World!".utf8)
    let key=try await cryptoService.generateSecureRandomKey(length: 32)
    let invalidKey=try await cryptoService.generateSecureRandomKey(length: 32)
    let initVector=try await cryptoService.generateSecureRandomBytes(length: 12)

    let encrypted=try await cryptoService.encrypt(data, withKey: key, iv: initVector)

    do {
      _=try await cryptoService.decrypt(encrypted, withKey: invalidKey, iv: initVector)
      XCTFail("Expected decryption to fail with invalid key")
    } catch let error as CryptoError {
      XCTAssertTrue(error.localizedDescription.contains("decryption failed"))
    }
  }

  func testEncryptDecryptWithInvalidIV() async throws {
    let data=Data("Hello, World!".utf8)
    let key=try await cryptoService.generateSecureRandomKey(length: 32)
    let initVector=try await cryptoService.generateSecureRandomBytes(length: 12)
    let invalidInitVector=try await cryptoService.generateSecureRandomBytes(length: 12)

    let encrypted=try await cryptoService.encrypt(data, withKey: key, iv: initVector)

    do {
      _=try await cryptoService.decrypt(encrypted, withKey: key, iv: invalidInitVector)
      XCTFail("Expected decryption to fail with invalid IV")
    } catch let error as CryptoError {
      XCTAssertTrue(error.localizedDescription.contains("decryption failed"))
    }
  }
}
