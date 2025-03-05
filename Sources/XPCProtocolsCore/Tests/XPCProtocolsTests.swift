import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Comprehensive tests for XPCProtocolsCore
class XPCProtocolsCoreTests: XCTestCase {

  /// Test protocol references exist
  func testProtocolsExist() {
    // Verify that we can create protocol type references
    let _: any XPCServiceProtocolBasic.Type=MockXPCService.self
    let _: any XPCServiceProtocolStandard.Type=MockXPCService.self
    let _: any XPCServiceProtocolComplete.Type=MockXPCService.self

    // If we got this far, the test passes
    XCTAssertTrue(true, "Protocol type references should exist")
  }

  /// Test protocol inheritance hierarchy
  func testProtocolHierarchy() {
    // Verify that XPCServiceProtocolStandard extends XPCServiceProtocolBasic
    let standardIsBasic=XPCServiceProtocolStandard.self is XPCServiceProtocolBasic.Type
    XCTAssertTrue(
      standardIsBasic,
      "XPCServiceProtocolStandard should extend XPCServiceProtocolBasic"
    )

    // Verify that XPCServiceProtocolComplete extends XPCServiceProtocolStandard
    let completeIsStandard=XPCServiceProtocolComplete.self is XPCServiceProtocolStandard.Type
    XCTAssertTrue(
      completeIsStandard,
      "XPCServiceProtocolComplete should extend XPCServiceProtocolStandard"
    )
  }

  /// Test basic protocol methods
  func testBasicProtocolMethods() async throws {
    let service=MockXPCService()
    let isActive=try await service.ping()
    XCTAssertTrue(isActive, "Ping should return true")

    // This should not throw
    try await service.synchroniseKeys(SecureBytes(bytes: [1, 2, 3, 4]))

    // Test with empty data
    try await service.synchroniseKeys(SecureBytes(bytes: []))
  }

  /// Test throwing methods in standard protocol
  func testStandardProtocolMethods() async throws {
    let service=MockXPCService()

    // Test generateRandomData
    let randomData=try await service.generateRandomData(length: 16)
    XCTAssertEqual(randomData.count, 16, "Random data should be of requested length")

    // Test encryptData
    let testData=SecureBytes(bytes: [1, 2, 3, 4, 5])
    let encryptedData=try await service.encryptData(testData, keyIdentifier: "test-key")
    XCTAssertEqual(
      encryptedData.count,
      testData.count,
      "Encrypted data should have same length in mock"
    )

    // Test decryptData
    let decryptedData=try await service.decryptData(encryptedData, keyIdentifier: "test-key")
    XCTAssertEqual(
      decryptedData.count,
      testData.count,
      "Decrypted data should have same length as original"
    )

    // Test hashData
    let hashedData=try await service.hashData(testData)
    XCTAssertGreaterThan(hashedData.count, 0, "Hashed data should not be empty")

    // Test signData
    let signature=try await service.signData(testData, keyIdentifier: "test-key")
    XCTAssertGreaterThan(signature.count, 0, "Signature should not be empty")

    // Test verifySignature
    let verified=try await service.verifySignature(
      signature,
      for: testData,
      keyIdentifier: "test-key"
    )
    XCTAssertTrue(verified, "Signature verification should succeed")
  }

  /// Test complete protocol methods
  func testCompleteProtocolMethods() async {
    let service=MockXPCService()

    // Test pingComplete
    let pingResult=await service.pingComplete()
    XCTAssertTrue(pingResult.isSuccess, "pingComplete should succeed")
    if case let .success(value)=pingResult {
      XCTAssertTrue(value, "Ping should return true")
    }

    // Test synchronizeKeys
    let syncResult=await service.synchronizeKeys(SecureBytes(bytes: [1, 2, 3, 4]))
    XCTAssertTrue(syncResult.isSuccess, "synchronizeKeys should succeed")

    // Test encrypt
    let testData=SecureBytes(bytes: [5, 6, 7, 8])
    let encryptResult=await service.encrypt(data: testData)
    XCTAssertTrue(encryptResult.isSuccess, "encrypt should succeed")
    if case let .success(encrypted)=encryptResult {
      XCTAssertEqual(
        encrypted.count,
        testData.count,
        "Encrypted data should have same length in mock"
      )
    }

    // Test decrypt
    let decryptResult=await service.decrypt(data: testData)
    XCTAssertTrue(decryptResult.isSuccess, "decrypt should succeed")
    if case let .success(decrypted)=decryptResult {
      XCTAssertEqual(
        decrypted.count,
        testData.count,
        "Decrypted data should have same length as original"
      )
    }

    // Test generateKey
    let keyResult=await service.generateKey()
    XCTAssertTrue(keyResult.isSuccess, "generateKey should succeed")
    if case let .success(key)=keyResult {
      XCTAssertEqual(key.count, 4, "Key should be 4 bytes in mock")
    }

    // Test hash
    let hashResult=await service.hash(data: testData)
    XCTAssertTrue(hashResult.isSuccess, "hash should succeed")
    if case let .success(hash)=hashResult {
      XCTAssertEqual(hash.count, testData.count, "Hash should have same length as original in mock")
    }
  }

  /// Test error conditions in a failing mock service
  func testErrorConditions() async {
    let service=FailingMockXPCService()

    // Test error handling for Complete protocol
    let pingResult=await service.pingComplete()
    XCTAssertFalse(pingResult.isSuccess, "pingComplete should fail")
    if case let .failure(error)=pingResult {
      XCTAssertEqual(error, .cryptoError, "Error should be cryptoError")
    }

    let syncResult=await service.synchronizeKeys(SecureBytes(bytes: [1, 2, 3, 4]))
    XCTAssertFalse(syncResult.isSuccess, "synchronizeKeys should fail")

    let encryptResult=await service.encrypt(data: SecureBytes(bytes: [5, 6, 7, 8]))
    XCTAssertFalse(encryptResult.isSuccess, "encrypt should fail")

    let decryptResult=await service.decrypt(data: SecureBytes(bytes: [5, 6, 7, 8]))
    XCTAssertFalse(decryptResult.isSuccess, "decrypt should fail")

    let keyResult=await service.generateKey()
    XCTAssertFalse(keyResult.isSuccess, "generateKey should fail")

    let hashResult=await service.hash(data: SecureBytes(bytes: [5, 6, 7, 8]))
    XCTAssertFalse(hashResult.isSuccess, "hash should fail")
  }

  /// Test throwing error conditions in a failing mock service
  func testThrowingErrorConditions() async {
    let service=FailingMockXPCService()

    // Test error handling for Basic and Standard protocols
    do {
      _=try await service.ping()
      XCTFail("ping should throw an error")
    } catch {
      XCTAssertTrue(true, "ping should throw an error")
    }

    do {
      try await service.synchroniseKeys(SecureBytes(bytes: [1, 2, 3, 4]))
      XCTFail("synchroniseKeys should throw an error")
    } catch {
      XCTAssertTrue(true, "synchroniseKeys should throw an error")
    }

    do {
      _=try await service.generateRandomData(length: 16)
      XCTFail("generateRandomData should throw an error")
    } catch {
      XCTAssertTrue(true, "generateRandomData should throw an error")
    }

    do {
      _=try await service.encryptData(
        SecureBytes(bytes: [1, 2, 3, 4, 5]),
        keyIdentifier: "test-key"
      )
      XCTFail("encryptData should throw an error")
    } catch {
      XCTAssertTrue(true, "encryptData should throw an error")
    }
  }

  /// Run all tests
  static func runAllTests() async throws {
    let tests=XPCProtocolsCoreTests()

    // Run synchronous tests
    tests.testProtocolsExist()
    tests.testProtocolHierarchy()

    // Run asynchronous tests
    try await tests.testBasicProtocolMethods()
    try await tests.testStandardProtocolMethods()
    await tests.testCompleteProtocolMethods()
    await tests.testErrorConditions()

    do {
      try await tests.testThrowingErrorConditions()
    } catch {
      // This is expected to catch errors
      print("Successfully caught errors in testThrowingErrorConditions")
    }

    print("All XPCProtocolsCore tests passed!")
  }
}

// MARK: - Test Helpers

/// Mock implementation of all XPC protocols for testing
private final class MockXPCService: XPCServiceProtocolComplete {
  static let protocolIdentifier: String="com.test.mock.xpc.service"

  func pingComplete() async -> Result<Bool, XPCSecurityError> {
    .success(true)
  }

  func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
    .success(())
  }

  func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .success(data)
  }

  func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .success(data)
  }

  func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    .success(SecureBytes(bytes: [0, 1, 2, 3]))
  }

  func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .success(data)
  }

  // Standard protocol methods
  func generateRandomData(length: Int) async throws -> SecureBytes {
    SecureBytes(bytes: Array(repeating: 0, count: length))
  }

  func encryptData(_ data: SecureBytes, keyIdentifier _: String?) async throws -> SecureBytes {
    data
  }

  func decryptData(_ data: SecureBytes, keyIdentifier _: String?) async throws -> SecureBytes {
    data
  }

  func synchroniseKeys(_: SecureBytes) async throws {
    // No-op for test
  }

  func ping() async throws -> Bool {
    true
  }

  // Add missing methods required by XPCServiceProtocolStandard
  func hashData(_ data: SecureBytes) async throws -> SecureBytes {
    data
  }

  func signData(_ data: SecureBytes, keyIdentifier _: String) async throws -> SecureBytes {
    data
  }

  func verifySignature(
    _: SecureBytes,
    for _: SecureBytes,
    keyIdentifier _: String
  ) async throws -> Bool {
    true
  }
}

/// Mock implementation that always fails for error testing
private final class FailingMockXPCService: XPCServiceProtocolComplete {
  static let protocolIdentifier: String="com.test.failing.mock.xpc.service"

  func pingComplete() async -> Result<Bool, XPCSecurityError> {
    .failure(.cryptoError)
  }

  func synchronizeKeys(_: SecureBytes) async -> Result<Void, XPCSecurityError> {
    .failure(.cryptoError)
  }

  func encrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.cryptoError)
  }

  func decrypt(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.cryptoError)
  }

  func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.cryptoError)
  }

  func hash(data _: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
    .failure(.cryptoError)
  }

  // Standard protocol methods that throw
  func generateRandomData(length _: Int) async throws -> SecureBytes {
    throw CoreErrors.CryptoError.randomGenerationFailed(reason: "Test error")
  }

  func encryptData(_: SecureBytes, keyIdentifier _: String?) async throws -> SecureBytes {
    throw CoreErrors.CryptoError.encryptionFailed(reason: "Test error")
  }

  func decryptData(_: SecureBytes, keyIdentifier _: String?) async throws -> SecureBytes {
    throw CoreErrors.CryptoError.decryptionFailed(reason: "Test error")
  }

  func synchroniseKeys(_: SecureBytes) async throws {
    throw CoreErrors.CryptoError.serviceFailed(reason: "Test error")
  }

  func ping() async throws -> Bool {
    throw CoreErrors.CryptoError.serviceFailed(reason: "Test error")
  }

  func hashData(_: SecureBytes) async throws -> SecureBytes {
    throw CoreErrors.CryptoError.hashingFailed(reason: "Test error")
  }

  func signData(_: SecureBytes, keyIdentifier _: String) async throws -> SecureBytes {
    throw CoreErrors.CryptoError.cryptoOperationFailed(reason: "Test error")
  }

  func verifySignature(
    _: SecureBytes,
    for _: SecureBytes,
    keyIdentifier _: String
  ) async throws -> Bool {
    throw CoreErrors.CryptoError.cryptoOperationFailed(reason: "Test error")
  }
}

// Helper extension for Result to make tests more readable
extension Result {
  var isSuccess: Bool {
    switch self {
      case .success: true
      case .failure: false
    }
  }
}

// Main entry point for running tests
@main
struct XPCProtocolsCoreTestsMain {
  static func main() async throws {
    try await XPCProtocolsCoreTests.runAllTests()
  }
}
