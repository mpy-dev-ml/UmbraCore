import Foundation
@testable import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

final class RandomDataTests: XCTestCase {

  private var mockXPCService: MockFoundationXPCSecurityService!

  override func setUp() async throws {
    try await super.setUp()
    mockXPCService = MockFoundationXPCSecurityService()
  }

  override func tearDown() async throws {
    mockXPCService = nil
    try await super.tearDown()
  }

  func testGenerateRandomDataXPC() async throws {
    // Arrange
    let expectedLength = 32
    let expectedData = Data(repeating: 42, count: expectedLength)
    mockXPCService.randomDataToReturn = expectedData

    var randomData: Data?
    var error: Error?

    // Act - Use completion handler directly
    let expectation = XCTestExpectation(description: "Random data generation complete")
    mockXPCService.generateRandomData(length: expectedLength) { data, err in
      randomData = data
      error = err
      expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 5.0)

    // Assert
    XCTAssertNil(error)
    XCTAssertNotNil(randomData)
    XCTAssertEqual(randomData, expectedData)

    let methodCalls = mockXPCService.methodCalls
    XCTAssertTrue(methodCalls.contains("generateRandomData(\(expectedLength))"))
  }

  func testSimpleRandomDataGeneration() async throws {
    // A very simple test to check if the basic random data generation works
    let randomBytes = try await SecureRandomGenerator.shared.generateRandomBytes(count: 16)
    XCTAssertEqual(randomBytes.count, 16)

    // This is not a strong test of randomness, just that we got data
    let allZeros = [UInt8](repeating: 0, count: 16)
    XCTAssertNotEqual(randomBytes, allZeros)
  }
}

// A minimal random generator for testing
final class SecureRandomGenerator {
  static let shared = SecureRandomGenerator()

  func generateRandomBytes(count: Int) async throws -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    for i in 0..<count {
      bytes[i] = UInt8.random(in: 0...255)
    }
    return bytes
  }
}
