import Foundation
@testable import SecurityBridge
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest

// MARK: - Tests for Security Provider Adapter

/// Simple test class that focuses only on the config creation functionality
final class SecurityConfigCreationTests: XCTestCase {
    func testSimpleConfigCreation() {
        // Create a simple adapter directly without any mocks
        let adapter = SecurityProviderAdapter(implementation: MockFoundationSecurityProvider())

        // Create a very simple options dictionary
        let options: [String: Any] = ["algorithm": "AES-GCM", "keySizeInBits": 256]

        // Call the method directly
        let config = adapter.createSecureConfig(options: options)

        // Very simple assertions to verify the method worked
        XCTAssertEqual(config.algorithm, "AES-GCM")
        XCTAssertEqual(config.keySizeInBits, 256)
    }
}

/// Simple test class that focuses only on secure operations
final class SecurityOperationTests: XCTestCase {
    /// Basic test with minimal setup - just verifies the method returns
    func testMinimalOperationCall() async {
        // Create components directly in the test without any complex setup
        let mock = MockFoundationSecurityProvider()

        // Important: Configure the mock to succeed immediately with simple data
        mock.dataToReturn = Data([1, 2, 3])

        // Create adapter with the configured mock
        let adapter = SecurityProviderAdapter(implementation: mock)

        // Create minimal config with default values
        let config = SecurityConfigDTO(algorithm: "AES", keySizeInBits: 128)

        // Just call the method and ensure it returns without hanging
        _ = await adapter.performSecureOperation(
            operation: .symmetricEncryption,
            config: config
        )

        // Simple assertion to verify the test reached this point
        // This will only pass if the method returns and doesn't hang
        XCTAssertTrue(true)
    }

    /// Tests that the operation returns the expected errorCode
    func testErrorCodeReturned() async {
        // Setup
        let mock = MockFoundationSecurityProvider()

        // Force a failure
        mock.shouldFail = true
        mock.errorToReturn = NSError(domain: "MockSecurityError", code: 42, userInfo: nil)

        let adapter = SecurityProviderAdapter(implementation: mock)
        let config = SecurityConfigDTO(algorithm: "AES", keySizeInBits: 128)

        // When: Perform operation
        let result = await adapter.performSecureOperation(
            operation: .symmetricEncryption,
            config: config
        )

        // Then: Should have an error code matching our mock error
        XCTAssertEqual(result.errorCode, 42)
    }
}

/// Tests for the Security Provider Adapter
final class SecurityProviderAdapterTests: XCTestCase {
    // MARK: - Properties

    private var mockFoundationProvider: MockFoundationSecurityProvider!
    private var adapter: SecurityProviderAdapter!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Create fresh instance for each test - prevents state leaking between tests
        mockFoundationProvider = MockFoundationSecurityProvider()
        adapter = SecurityProviderAdapter(implementation: mockFoundationProvider)
    }

    override func tearDown() {
        adapter = nil
        mockFoundationProvider = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// Tests that DataAdapter correctly converts between SecureBytes and Data
    func testDataConversion() {
        // Arrange
        let secureBytes = SecureBytes(bytes: [0, 1, 2, 3, 4, 5])

        // Act
        let data = DataAdapter.data(from: secureBytes)
        let convertedBack = DataAdapter.secureBytes(from: data)

        // Assert
        XCTAssertEqual(secureBytes.count, data.count)
        XCTAssertEqual(secureBytes.count, convertedBack.count)

        // Verify the bytes are the same
        for i in 0 ..< secureBytes.count {
            XCTAssertEqual(secureBytes[i], data[i])
            XCTAssertEqual(secureBytes[i], convertedBack[i])
        }
    }
}
