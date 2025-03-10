import CoreErrors
import UmbraCoreTypes
import XCTest
import ErrorHandlingDomains
@testable import XPCProtocolsCore

final class LegacyXPCAdapterTests: XCTestCase {

  // Test ping functionality
  func testPing() async throws {
    let mockService=MockLegacyXPCService()
    let adapter=LegacyXPCServiceAdapter(service: mockService)

    let result=await adapter.pingComplete()

    // Verify that the adapter correctly converts the result
    switch result {
      case let .success(value):
        XCTAssertTrue(value)
        XCTAssertTrue(mockService.pingCalled)
      case .failure:
        XCTFail("Ping should succeed")
    }
  }

  // Test error mapping
  @available(*, deprecated)
  func testErrorMapping() {
    // Legacy to standard error mapping
    let legacyError=SecurityError.encryptionFailed
    let mappedError=LegacyXPCServiceAdapter.mapError(legacyError)
    XCTAssertEqual(mappedError, XPCSecurityError.cryptoError)

    // Standard to legacy error mapping
    let standardError=XPCSecurityError.accessError
    let mappedLegacyError=LegacyXPCServiceAdapter.mapToLegacyError(standardError)
    XCTAssertEqual(mappedLegacyError, SecurityError.serviceFailed)
  }

  // Test data conversion between SecureBytes and legacy BinaryData
  func testEncryption() async throws {
    let mockService=MockLegacyXPCService()
    let adapter=LegacyXPCServiceAdapter(service: mockService)

    let testData=SecureBytes(bytes: [1, 2, 3, 4, 5])
    let result=await adapter.encrypt(data: testData)

    switch result {
      case let .success(encryptedData):
        // The mock service simply doubles each byte
        let expectedBytes: [UInt8]=[2, 4, 6, 8, 10]
        let actualBytes=encryptedData.withUnsafeBytes { Array($0) }
        XCTAssertEqual(actualBytes, expectedBytes)
        XCTAssertTrue(mockService.encryptCalled)
      case .failure:
        XCTFail("Encryption should succeed")
    }
  }

  // Test random data generation
  func testRandomDataGeneration() async throws {
    let mockService=MockLegacyXPCService()
    let adapter=LegacyXPCServiceAdapter(service: mockService)

    let randomData=try await adapter.generateRandomData(length: 10)

    // Our mock service generates zeroes
    XCTAssertEqual(randomData.count, 10)
    XCTAssertTrue(mockService.generateRandomDataCalled)
  }

  // Test hash generation
  func testHashGeneration() async throws {
    let mockService=MockLegacyXPCService()
    let adapter=LegacyXPCServiceAdapter(service: mockService)

    let testData=SecureBytes(bytes: [1, 2, 3, 4, 5])
    let result=await adapter.hash(data: testData)

    switch result {
      case let .success(hashedData):
        // The mock service just returns a fixed hash
        XCTAssertEqual(hashedData.count, 32) // Fixed SHA-256 style hash size
        XCTAssertTrue(mockService.hashCalled)
      case .failure:
        XCTFail("Hashing should succeed")
    }
  }

  // Test factory creation
  func testFactoryCreation() {
    let mockService=MockLegacyXPCService()

    let standardAdapter=XPCProtocolMigrationFactory.createStandardAdapter(from: mockService)
    XCTAssertNotNil(standardAdapter)

    let completeAdapter=XPCProtocolMigrationFactory.createCompleteAdapter(from: mockService)
    XCTAssertNotNil(completeAdapter)
  }
}

// MARK: - Mock Classes for Testing

/// Mock implementation of a legacy XPC service to test the adapter
class MockLegacyXPCService: LegacyXPCBase, LegacyEncryptor, LegacyHasher, LegacyKeyGenerator,
LegacyRandomGenerator {
  // Tracking properties
  var pingCalled=false
  var synchroniseKeysCalled=false
  var encryptCalled=false
  var decryptCalled=false
  var hashCalled=false
  var generateKeyCalled=false
  var generateRandomDataCalled=false

  // Mock BinaryData implementation
  struct MockBinaryData {
    let bytes: [UInt8]

    init(_ bytes: [UInt8]) {
      self.bytes=bytes
    }
  }

  // LegacyXPCBase conformance
  func ping() async throws -> Bool {
    pingCalled=true
    return true
  }

  func synchroniseKeys(_: Any) async throws {
    synchroniseKeysCalled=true
    // No-op implementation
  }

  // LegacyEncryptor conformance
  func encrypt(data: Any) async throws -> Any {
    encryptCalled=true

    // Extract bytes from input data
    var inputBytes: [UInt8]=[]
    if let binaryData=data as? MockBinaryData {
      inputBytes=binaryData.bytes
    } else if let bytesArray=data as? [UInt8] {
      inputBytes=bytesArray
    }

    // Simulate encryption by doubling each byte
    let outputBytes=inputBytes.map { $0 * 2 }
    return MockBinaryData(outputBytes)
  }

  func decrypt(data: Any) async throws -> Any {
    decryptCalled=true

    // Extract bytes from input data
    var inputBytes: [UInt8]=[]
    if let binaryData=data as? MockBinaryData {
      inputBytes=binaryData.bytes
    } else if let bytesArray=data as? [UInt8] {
      inputBytes=bytesArray
    }

    // Simulate decryption by halving each byte
    let outputBytes=inputBytes.map { $0 / 2 }
    return MockBinaryData(outputBytes)
  }

  // Helper methods for conversion
  func createBinaryData(from bytes: [UInt8]) -> Any {
    MockBinaryData(bytes)
  }

  func extractBytesFromBinaryData(_ binaryData: Any) -> SecureBytes {
    if let mockData=binaryData as? MockBinaryData {
      return SecureBytes(bytes: mockData.bytes)
    }
    return SecureBytes()
  }

  // LegacyHasher conformance
  func hash(data _: Any) async throws -> Any {
    hashCalled=true
    // Return fixed size hash (like SHA-256)
    return MockBinaryData([UInt8](repeating: 0x42, count: 32))
  }

  // LegacyKeyGenerator conformance
  func generateKey() async throws -> Any {
    generateKeyCalled=true
    // Return fixed key
    return MockBinaryData([UInt8](repeating: 0xFF, count: 32))
  }

  // LegacyRandomGenerator conformance
  func generateRandomData(length: Int) async throws -> Any {
    generateRandomDataCalled=true
    // Return zeroes as "random" data
    return MockBinaryData([UInt8](repeating: 0, count: length))
  }
}
