import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Simple validation tests for XPCProtocolsCore
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

  /// Test basic protocol methods
  func testBasicProtocolMethods() async throws {
    let service=MockXPCService()
    let isActive=try await service.ping()
    XCTAssertTrue(isActive, "Ping should return true")

    // This should not throw
    try await service.synchroniseKeys(SecureBytes(bytes: [1, 2, 3, 4]))
  }

  /// Test complete protocol methods
  func testCompleteProtocolMethods() async {
    let service=MockXPCService()
    let pingResult=await service.pingComplete()
    XCTAssertTrue(pingResult.isSuccess, "pingComplete should succeed")

    let syncResult=await service.synchronizeKeys(SecureBytes(bytes: [1, 2, 3, 4]))
    XCTAssertTrue(syncResult.isSuccess, "synchronizeKeys should succeed")

    let encryptResult=await service.encrypt(data: SecureBytes(bytes: [5, 6, 7, 8]))
    XCTAssertTrue(encryptResult.isSuccess, "encrypt should succeed")
  }

  /// Run all tests
  static func runAllTests() async throws {
    let tests=XPCProtocolsCoreTests()

    // Run synchronous tests
    tests.testProtocolsExist()

    // Run asynchronous tests
    try await tests.testBasicProtocolMethods()
    await tests.testCompleteProtocolMethods()

    print("All XPCProtocolsCore tests passed!")
  }
}

// MARK: - Test Helpers

/// Mock implementation of all XPC protocols for testing
private final class MockXPCService: XPCServiceProtocolComplete {
  static let protocolIdentifier: String="com.test.mock.xpc.service"

  func pingComplete() async -> Result<Bool, SecurityError> {
    .success(true)
  }

  func synchronizeKeys(_: SecureBytes) async -> Result<Void, SecurityError> {
    .success(())
  }

  func encrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    .success(data)
  }

  func decrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
    .success(data)
  }

  func generateKey() async -> Result<SecureBytes, SecurityError> {
    .success(SecureBytes(bytes: [0, 1, 2, 3]))
  }

  func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
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
