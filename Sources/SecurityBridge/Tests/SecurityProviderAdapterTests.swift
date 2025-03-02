// SecurityProviderAdapterTests.swift
// SecurityBridge
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import Foundation
import SecureBytes
@testable import SecurityBridge
import SecurityProtocolsCore
import XCTest

final class SecurityProviderAdapterTests: XCTestCase {

    // MARK: - Properties

    private var mockFoundationProvider: MockFoundationSecurityProvider!
    private var adapter: SecurityProviderAdapter!
    
    // Add a timeout for all test executions
    private let testTimeout: TimeInterval = 5.0

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFoundationProvider = MockFoundationSecurityProvider()
        adapter = SecurityProviderAdapter(implementation: mockFoundationProvider)
    }

    override func tearDown() {
        mockFoundationProvider = nil
        adapter = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createTestSecureBytes() -> SecureBytes {
        return SecureBytes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
    }

    private func createTestData() -> Data {
        return Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
    }

    // MARK: - Tests

    /// Tests that DataAdapter correctly converts between SecureBytes and Data
    func testDataConversion() async throws {
        // Arrange
        let secureBytes = createTestSecureBytes()

        // Act
        let data = DataAdapter.data(from: secureBytes)
        let convertedBack = DataAdapter.secureBytes(from: data)

        // Assert
        XCTAssertEqual(data.count, secureBytes.count)
        XCTAssertEqual(convertedBack.count, secureBytes.count)

        // Compare contents
        XCTAssertEqual(Array(data), secureBytes.unsafeBytes)
        XCTAssertEqual(convertedBack.unsafeBytes, secureBytes.unsafeBytes)
    }

    /// Tests creating a security config
    func testCreateSecureConfig() async throws {
        // Arrange
        let options: [String: Any] = [
            "algorithm": "AES-GCM",
            "keySizeInBits": 256,
            "initializationVector": Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
            "additionalAuthenticatedData": Data([11, 22, 33, 44]),
            "iterations": 10_000,
            "algorithmOptions": ["mode": "CBC", "padding": "PKCS7"]
        ]

        // Act
        let config = adapter.createSecureConfig(options: options)

        // Assert
        XCTAssertEqual(config.algorithm, "AES-GCM")
        XCTAssertEqual(config.keySizeInBits, 256)
        XCTAssertEqual(config.iterations, 10_000)

        // Verify data conversion worked
        XCTAssertNotNil(config.initializationVector)
        XCTAssertNotNil(config.additionalAuthenticatedData)

        // Verify options
        XCTAssertEqual(config.options["mode"], "CBC")
        XCTAssertEqual(config.options["padding"], "PKCS7")
    }

    /// Tests edge cases in SecureBytes/Data conversion
    func testEdgeCasesInDataConversion() async throws {
        // Test empty SecureBytes
        let emptySecureBytes = SecureBytes()
        let emptyData = DataAdapter.data(from: emptySecureBytes)
        XCTAssertEqual(emptyData.count, 0)

        // Test empty Data
        let emptyConvertedBack = DataAdapter.secureBytes(from: Data())
        XCTAssertEqual(emptyConvertedBack.count, 0)

        // Test large data
        let largeSecureBytes = SecureBytes(count: 1_024) // 1KB of zeros (smaller for performance)
        let largeData = DataAdapter.data(from: largeSecureBytes)
        XCTAssertEqual(largeData.count, 1_024)

        // Test with random data (smaller sample for performance)
        var randomBytes = [UInt8](repeating: 0, count: 64)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let randomSecureBytes = SecureBytes(randomBytes)
        let randomData = DataAdapter.data(from: randomSecureBytes)
        let randomConvertedBack = DataAdapter.secureBytes(from: randomData)

        XCTAssertEqual(randomData.count, randomBytes.count)
        XCTAssertEqual(randomConvertedBack.unsafeBytes, randomBytes)
    }
    
    /// Tests a basic encryption-decryption flow using the adapter
    func testPerformSecureOperation() async throws {
        // Arrange
        let testData = SecureBytes([1, 2, 3, 4, 5])
        let testKey = SecureBytes([10, 20, 30, 40, 50])
        let config = SecurityConfigDTO(
            algorithm: "AES-GCM",
            keySizeInBits: 256,
            options: [:]
        )
        
        // Configure mock to return success
        mockFoundationProvider.dataToReturn = Data([100, 101, 102]) // Mocked encrypted data
        
        // Act - now uses built-in timeout protection
        let result = await adapter.performSecureOperation(
            operation: .symmetricEncryption,
            config: config
        )
        
        // Assert
        XCTAssertEqual(result.errorCode, 0)  // No error
        XCTAssertNotNil(result.data)
        XCTAssertEqual(result.data?.count, 3)
        
        // Verify the mock was called correctly
        XCTAssertTrue(mockFoundationProvider.methodCalls.contains("performOperation:symmetricEncryption"))
    }
}
