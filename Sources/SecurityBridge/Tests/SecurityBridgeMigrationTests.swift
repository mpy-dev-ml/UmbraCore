import CoreTypesInterfaces
import Foundation
import FoundationBridgeTypes
import SecurityBridge
import SecurityBridgeProtocolAdapters
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest
import ErrorHandlingDomains

final class SecurityBridgeMigrationTests: XCTestCase {
  // MARK: - XPCServiceBridge Tests

  func testXPCServiceBridgeProtocolIdentifier() {
    XCTAssertEqual(
      CoreTypesToFoundationBridgeAdapter.protocolIdentifier,
      "com.umbra.xpc.service.adapter.coretypes.bridge"
    )
  }

  func testCoreToBridgeAdapter() throws {
    let mockXPCService=MockXPCServiceProtocolBasic()
    let adapter=CoreTypesToFoundationBridgeAdapter(wrapping: mockXPCService)

    let expectation=XCTestExpectation(description: "Ping response received")
    adapter.pingFoundation { success, error in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  func testBridgeToCoreAdapter() async {
    let mockFoundationService=MockFoundationXPCService()
    let adapter=FoundationToCoreTypesAdapter(wrapping: mockFoundationService)

    let result=await adapter.ping()
    switch result {
      case let .success(value):
        XCTAssertTrue(value)
      case .failure:
        XCTFail("Should have succeeded")
    }
  }

  // MARK: - SecurityProvider Tests

  func testSecurityProviderAdapterEncryptionDecryption() async throws {
    let mockBridge=MockSecurityProviderBridge()
    let adapter=SecurityBridgeProtocolAdapters.SecurityProviderProtocolAdapter(bridge: mockBridge)

    // Create test data using SecureBytes instead of legacy BinaryData
    let testData=SecureBytes([1, 2, 3, 4, 5])
    let testKey=SecureBytes([10, 20, 30, 40, 50])

    // Test with Result types
    let encryptResult=await adapter.encrypt(testData, key: testKey)
    switch encryptResult {
      case let .success(encrypted):
        var encryptedBytes=[UInt8]()
        encrypted.withUnsafeBytes { buffer in
          encryptedBytes=Array(buffer)
        }

        var testDataBytes=[UInt8]()
        testData.withUnsafeBytes { buffer in
          testDataBytes=Array(buffer)
        }

        XCTAssertNotEqual(encryptedBytes, testDataBytes)

        let decryptResult=await adapter.decrypt(encrypted, key: testKey)
        switch decryptResult {
          case let .success(decrypted):
            var decryptedBytes=[UInt8]()
            decrypted.withUnsafeBytes { buffer in
              decryptedBytes=Array(buffer)
            }
            XCTAssertEqual(decryptedBytes, testDataBytes)
          case let .failure(error):
            XCTFail("Decryption failed: \(error)")
        }
      case let .failure(error):
        XCTFail("Encryption failed: \(error)")
    }
  }

  func testSecurityProviderAdapterGenerateRandomData() async {
    let mockBridge=MockSecurityProviderBridge()
    let adapter=SecurityBridgeProtocolAdapters.SecurityProviderProtocolAdapter(bridge: mockBridge)

    // Test the newly added generateRandomData
    let dataResult=await adapter.generateRandomData(length: 10)
    switch dataResult {
      case let .success(data):
        XCTAssertEqual(data.count, 10)
      case let .failure(error):
        XCTFail("Generate random data failed: \(error)")
    }
  }
}

// MARK: - Test Mocks

private class MockXPCServiceProtocolBasic: ServiceProtocolBasic,
@unchecked Sendable {
  static var protocolIdentifier: String="mock.protocol"

  func ping() async -> Result<Bool, SecurityError> {
    .success(true)
  }

  func synchronizeKeys(_: SecureBytes) async -> Result<Void, SecurityError> {
    .success(())
  }

  func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    var bytes=[UInt8]()
    for i in 0..<length {
      bytes.append(UInt8(i % 256))
    }
    return .success(SecureBytes(bytes))
  }
}

private class MockFoundationXPCService: NSObject, Sendable {
  func pingFoundation(completion: @escaping (Bool, Error?) -> Void) {
    completion(true, nil)
  }

  func synchronizeKeys(_: Data, completion: @escaping (Error?) -> Void) {
    completion(nil) // No error means success
  }
}

private class CoreTypesToFoundationBridgeAdapter: NSObject {
  private let service: ServiceProtocolBasic

  init(wrapping service: ServiceProtocolBasic) {
    self.service=service
    super.init()
  }

  static var protocolIdentifier: String {
    "com.umbra.xpc.service.adapter.coretypes.bridge"
  }

  func pingFoundation(completion: @escaping (Bool, Error?) -> Void) {
    Task {
      let result=await service.ping()
      switch result {
        case let .success(value):
          completion(value, nil)
        case let .failure(error):
          completion(false, error)
      }
    }
  }
}

private class FoundationToCoreTypesAdapter: ServiceProtocolBasic {
  private let service: MockFoundationXPCService

  init(wrapping service: MockFoundationXPCService) {
    self.service=service
  }

  static var protocolIdentifier: String="com.umbra.xpc.service.adapter.foundation.bridge"

  func ping() async -> Result<Bool, SecurityError> {
    await withCheckedContinuation { continuation in
      service.pingFoundation { success, _ in
        if let error {
          continuation.resume(returning: .failure(.general))
        } else {
          continuation.resume(returning: .success(success))
        }
      }
    }
  }

  func synchronizeKeys(_: SecureBytes) async -> Result<Void, SecurityError> {
    .success(())
  }

  func generateRandomData(length: Int) async -> Result<SecureBytes, SecurityError> {
    var bytes=[UInt8]()
    for i in 0..<length {
      bytes.append(UInt8(i % 256))
    }
    return .success(SecureBytes(bytes))
  }
}

private class MockSecurityProviderBridge: @unchecked Sendable {
  static var protocolIdentifier: String="mock.provider.bridge"

  func encrypt(
    _ data: DataBridge,
    key _: DataBridge
  ) async -> Result<DataBridge, SecurityError> {
    // Simple "encryption" for test
    let bytes=data.bytes.map { $0 ^ 0xFF } // Just XOR with 0xFF
    return .success(DataBridge(bytes))
  }

  func decrypt(
    _ data: DataBridge,
    key _: DataBridge
  ) async -> Result<DataBridge, SecurityError> {
    // Simple "decryption" for test
    let bytes=data.bytes.map { $0 ^ 0xFF } // Just XOR with 0xFF
    return .success(DataBridge(bytes))
  }

  func generateRandomData(length: Int) async -> Result<DataBridge, SecurityError> {
    var bytes=[UInt8]()
    for i in 0..<length {
      bytes.append(UInt8(i % 256))
    }
    return .success(DataBridge(bytes))
  }
}
