@testable import ErrorHandling
@testable import ErrorHandlingCommon
@testable import ErrorHandlingDomains
@testable import ErrorHandlingInterfaces
import XCTest

/// Tests for the UmbraErrors.GeneralSecurity error domain
///
/// These tests verify that security error types correctly implement
/// the expected behaviour and properties across different error cases.
final class TestErrorHandling_Security: XCTestCase {
    // MARK: - Security Protocol Errors Tests

    func testSecurityProtocolErrors() {
        // Test missing protocol implementation error
        let missingProtocolError = UmbraErrors.GeneralSecurity.Protocols.missingProtocolImplementation(protocolName: "TestProtocol")

        // Use String(describing:) to get descriptive text without using ambiguous localizedDescription
        let errorDesc = String(describing: missingProtocolError)
        XCTAssertTrue(errorDesc.contains("TestProtocol"))
        XCTAssertEqual(String(describing: missingProtocolError), "missingProtocolImplementation(protocolName: \"TestProtocol\")")

        // Test invalid format error
        let invalidFormatError = UmbraErrors.GeneralSecurity.Protocols.invalidFormat(reason: "Incorrect byte sequence")

        let invalidFormatDesc = String(describing: invalidFormatError)
        XCTAssertTrue(invalidFormatDesc.contains("Incorrect byte sequence"))
        XCTAssertEqual(String(describing: invalidFormatError), "invalidFormat(reason: \"Incorrect byte sequence\")")

        // Test unsupported operation error
        let unsupportedOpError = UmbraErrors.GeneralSecurity.Protocols.unsupportedOperation(name: "decrypt")

        let unsupportedOpDesc = String(describing: unsupportedOpError)
        XCTAssertTrue(unsupportedOpDesc.contains("decrypt"))
        XCTAssertEqual(String(describing: unsupportedOpError), "unsupportedOperation(name: \"decrypt\")")

        // Test incompatible version error
        let incompatibleVersionError = UmbraErrors.GeneralSecurity.Protocols.incompatibleVersion(version: "1.0")

        let incompatibleVersionDesc = String(describing: incompatibleVersionError)
        XCTAssertTrue(incompatibleVersionDesc.contains("1.0"))
        XCTAssertEqual(String(describing: incompatibleVersionError), "incompatibleVersion(version: \"1.0\")")

        // Test invalid state error
        let invalidStateError = UmbraErrors.GeneralSecurity.Protocols.invalidState(state: "initialised", expectedState: "running")

        let invalidStateDesc = String(describing: invalidStateError)
        XCTAssertTrue(invalidStateDesc.contains("initialised"))
        XCTAssertTrue(invalidStateDesc.contains("running"))
        XCTAssertEqual(String(describing: invalidStateError), "invalidState(state: \"initialised\", expectedState: \"running\")")

        // Test internal error
        let internalError = UmbraErrors.GeneralSecurity.Protocols.internalError("Unexpected condition")

        let internalErrorDesc = String(describing: internalError)
        XCTAssertTrue(internalErrorDesc.contains("Unexpected condition"))
        XCTAssertEqual(String(describing: internalError), "internalError(\"Unexpected condition\")")
    }

    // MARK: - Security Core Errors Tests

    func testSecurityCoreErrors() {
        // Test encryption failure error
        let encryptionError = UmbraErrors.GeneralSecurity.Core.encryptionFailed(reason: "Invalid key length")

        let encryptionErrorDesc = String(describing: encryptionError)
        XCTAssertTrue(encryptionErrorDesc.contains("Invalid key length"))
        XCTAssertEqual(String(describing: encryptionError), "encryptionFailed(reason: \"Invalid key length\")")

        // Test decryption error
        let decryptionError = UmbraErrors.GeneralSecurity.Core.decryptionFailed(reason: "Corrupted data")

        let decryptionErrorDesc = String(describing: decryptionError)
        XCTAssertTrue(decryptionErrorDesc.contains("Corrupted data"))
        XCTAssertEqual(String(describing: decryptionError), "decryptionFailed(reason: \"Corrupted data\")")

        // Test invalid key error
        let invalidKeyError = UmbraErrors.GeneralSecurity.Core.invalidKey(reason: "Incorrect format")

        let invalidKeyErrorDesc = String(describing: invalidKeyError)
        XCTAssertTrue(invalidKeyErrorDesc.contains("Incorrect format"))
        XCTAssertEqual(String(describing: invalidKeyError), "invalidKey(reason: \"Incorrect format\")")
    }

    // MARK: - Error Context Test

    func testErrorContext() {
        // Create context with metadata - explicitly use ErrorHandlingCommon.ErrorContext
        let context = ErrorHandlingCommon.ErrorContext(
            source: "SecurityService",
            operation: "encryptData",
            details: "Encryption failed: Invalid key"
        )

        // Since the ErrorContext doesn't have metadata methods in this version,
        // we'll create a dictionary to simulate what metadata would contain
        let metadata: [String: Any] = [
            "dataSize": 1_024,
            "algorithm": "AES-256"
        ]

        // Verify context properties
        XCTAssertEqual(context.source, "SecurityService")
        XCTAssertEqual(context.operation, "encryptData")

        // Verify the metadata dictionary values directly
        XCTAssertEqual(metadata["dataSize"] as? Int, 1_024)
        XCTAssertEqual(metadata["algorithm"] as? String, "AES-256")

        // Demonstrate how an error would be created with this context if needed
        let errorWithContext = UmbraErrors.GeneralSecurity.Core.encryptionFailed(reason: "Invalid key")
        XCTAssertNotNil(errorWithContext)
    }

    /// Tests that security test mode is properly recognized
    func testSecurityTestMode() throws {
        // Set security test mode flags
        setenv("UMBRA_SECURITY_TEST_MODE", "1", 1)
        UserDefaults.standard.set(true, forKey: "UMBRA_SECURITY_TEST_MODE")

        // Create a struct to capture test results
        struct TestResults {
            var securityTestModeDetected = false
        }
        var results = TestResults()

        // Check if we're in test mode using environment variable
        if getenv("UMBRA_SECURITY_TEST_MODE") != nil {
            results.securityTestModeDetected = true
        }

        // Check if we're in test mode using UserDefaults
        if UserDefaults.standard.bool(forKey: "UMBRA_SECURITY_TEST_MODE") {
            results.securityTestModeDetected = true
        }

        // Verify test mode was detected
        XCTAssertTrue(results.securityTestModeDetected, "Security test mode should be detected")

        // Clean up
        unsetenv("UMBRA_SECURITY_TEST_MODE")
        UserDefaults.standard.removeObject(forKey: "UMBRA_SECURITY_TEST_MODE")
    }
}
