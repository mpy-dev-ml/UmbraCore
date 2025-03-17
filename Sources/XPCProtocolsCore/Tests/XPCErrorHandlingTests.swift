/**
 # XPC Error Handling Tests

 This file contains tests for XPC error handling utilities and types defined in
 the XPCProtocolsCore module. It verifies correct functioning of error conversion,
 equality comparison, and other error-related utilities.

 ## Test Areas

 * XPCSecurityError equality implementation
 * Error conversion from various domains to XPCSecurityError
 * ServiceStatus enum functionality
 * Error localisation and error descriptions
 * NSError integration
 */

import CoreErrors
import ErrorHandling
import Foundation
import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Tests for XPC Error Handling
class XPCErrorHandlingTests: XCTestCase {
    // MARK: - XPCSecurityError Equality Tests

    func testXPCSecurityErrorEquality() {
        // Test equal cases
        XCTAssertEqual(XPCSecurityError.serviceUnavailable, XPCSecurityError.serviceUnavailable)
        XCTAssertEqual(
            XPCSecurityError.serviceNotReady(reason: "test"),
            XPCSecurityError.serviceNotReady(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.timeout(after: 10.0),
            XPCSecurityError.timeout(after: 10.0)
        )
        XCTAssertEqual(
            XPCSecurityError.authenticationFailed(reason: "test"),
            XPCSecurityError.authenticationFailed(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.authorizationDenied(operation: "encrypt"),
            XPCSecurityError.authorizationDenied(operation: "encrypt")
        )
        XCTAssertEqual(
            XPCSecurityError.operationNotSupported(name: "test"),
            XPCSecurityError.operationNotSupported(name: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.invalidInput(details: "test"),
            XPCSecurityError.invalidInput(details: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.invalidState(details: "test"),
            XPCSecurityError.invalidState(details: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.keyNotFound(identifier: "test"),
            XPCSecurityError.keyNotFound(identifier: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.invalidKeyType(expected: "RSA", received: "AES"),
            XPCSecurityError.invalidKeyType(expected: "RSA", received: "AES")
        )
        XCTAssertEqual(
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test"),
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.decryptionFailed(reason: "test"),
            XPCSecurityError.decryptionFailed(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.keyGenerationFailed(reason: "test"),
            XPCSecurityError.keyGenerationFailed(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.notImplemented(reason: "test"),
            XPCSecurityError.notImplemented(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.internalError(reason: "test"),
            XPCSecurityError.internalError(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.connectionInterrupted,
            XPCSecurityError.connectionInterrupted
        )
        XCTAssertEqual(
            XPCSecurityError.connectionInvalidated(reason: "test"),
            XPCSecurityError.connectionInvalidated(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.invalidData(reason: "test"),
            XPCSecurityError.invalidData(reason: "test")
        )
        XCTAssertEqual(
            XPCSecurityError.encryptionFailed(reason: "test"),
            XPCSecurityError.encryptionFailed(reason: "test")
        )

        // Test unequal cases
        XCTAssertNotEqual(
            XPCSecurityError.serviceNotReady(reason: "test1"),
            XPCSecurityError.serviceNotReady(reason: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.serviceUnavailable,
            XPCSecurityError.serviceNotReady(reason: "test")
        )
        XCTAssertNotEqual(
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test"),
            XPCSecurityError.cryptographicError(operation: "decrypt", details: "test")
        )
        XCTAssertNotEqual(
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test1"),
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test1"),
            XPCSecurityError.cryptographicError(operation: "encrypt", details: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.invalidData(reason: "test1"),
            XPCSecurityError.invalidData(reason: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.encryptionFailed(reason: "test1"),
            XPCSecurityError.encryptionFailed(reason: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.decryptionFailed(reason: "test1"),
            XPCSecurityError.decryptionFailed(reason: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.keyGenerationFailed(reason: "test1"),
            XPCSecurityError.keyGenerationFailed(reason: "test2")
        )
        XCTAssertNotEqual(
            XPCSecurityError.notImplemented(reason: "test1"),
            XPCSecurityError.notImplemented(reason: "test2")
        )
    }

    // MARK: - Error Conversion Tests

    func testConvertFoundationErrorsToXPCError() {
        // Test URL error conversion
        let urlTimeoutError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut,
            userInfo: nil
        )
        let convertedURLTimeoutError = XPCErrorUtilities.convertToXPCError(urlTimeoutError)
        if case let .timeout(after) = convertedURLTimeoutError {
            XCTAssertEqual(after, 30.0, "Should convert to timeout with default value")
        } else {
            XCTFail("URL timeout should convert to XPCSecurityError.timeout")
        }

        // Test other URL errors
        let urlOtherError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNetworkConnectionLost,
            userInfo: nil
        )
        let convertedURLOtherError = XPCErrorUtilities.convertToXPCError(urlOtherError)
        XCTAssertEqual(
            convertedURLOtherError,
            .connectionInterrupted,
            "Other URL errors should convert to connectionInterrupted"
        )

        // Test XPC connection error
        let xpcConnectionError = NSError(
            domain: "XPCConnectionErrorDomain",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Connection lost"]
        )
        let convertedXPCError = XPCErrorUtilities.convertToXPCError(xpcConnectionError)
        if case let .connectionInvalidated(reason) = convertedXPCError {
            XCTAssertEqual(reason, "Connection lost", "Should preserve the error description")
        } else {
            XCTFail("XPC connection error should convert to connectionInvalidated")
        }

        // Test cryptographic error
        let cryptoError = CoreErrors.CryptoError.encryptionFailed(reason: "Bad key")
        let convertedCryptoError = XPCErrorUtilities.convertToXPCError(cryptoError)
        if case let .cryptographicError(operation, details) = convertedCryptoError {
            XCTAssertEqual(operation, "encryption", "Should extract operation from error")
            XCTAssertTrue(details.contains("Bad key"), "Should preserve reason in details")
        } else {
            XCTFail("CryptoError should convert to cryptographicError")
        }

        // Test passing through existing XPCSecurityError
        let originalXPCError = XPCSecurityError.invalidInput(details: "Test detail")
        let passedThroughError = XPCErrorUtilities.convertToXPCError(originalXPCError)
        XCTAssertEqual(
            passedThroughError,
            originalXPCError,
            "Converting an XPCSecurityError should return the same error"
        )
    }

    // MARK: - Service Status Tests

    func testServiceStatusValues() {
        // Test all enum cases and their raw values
        XCTAssertEqual(ServiceStatus.operational.rawValue, "operational")
        XCTAssertEqual(ServiceStatus.initializing.rawValue, "initializing")
        XCTAssertEqual(ServiceStatus.maintenance.rawValue, "maintenance")
        XCTAssertEqual(ServiceStatus.shuttingDown.rawValue, "shuttingDown")
        XCTAssertEqual(ServiceStatus.degraded.rawValue, "degraded")
        XCTAssertEqual(ServiceStatus.failed.rawValue, "failed")
    }

    func testServiceStatusCoding() {
        // Test encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test all statuses can be encoded and decoded correctly
        for status in [
            ServiceStatus.operational,
            ServiceStatus.initializing,
            ServiceStatus.maintenance,
            ServiceStatus.shuttingDown,
            ServiceStatus.degraded,
            ServiceStatus.failed,
        ] {
            do {
                let encoded = try encoder.encode(status)
                let decoded = try decoder.decode(ServiceStatus.self, from: encoded)
                XCTAssertEqual(status, decoded, "Encoded and decoded ServiceStatus should be equal")
            } catch {
                XCTFail("Failed to encode/decode ServiceStatus: \(error)")
            }
        }
    }

    // MARK: - Localised Error Tests

    func testErrorLocalisation() {
        // Test that all error cases provide a localised description
        let errors: [XPCSecurityError] = [
            .serviceUnavailable,
            .serviceNotReady(reason: "Not initialised"),
            .timeout(after: 15.0),
            .authenticationFailed(reason: "Invalid credentials"),
            .authorizationDenied(operation: "delete"),
            .operationNotSupported(name: "customOperation"),
            .invalidInput(details: "Malformed data"),
            .invalidData(reason: "Corrupt bytes"),
            .encryptionFailed(reason: "Algorithm failure"),
            .invalidState(details: "Service shutting down"),
            .keyNotFound(identifier: "master-key"),
            .invalidKeyType(expected: "EC", received: "RSA"),
            .cryptographicError(operation: "sign", details: "Invalid padding"),
            .decryptionFailed(reason: "Invalid key material"),
            .keyGenerationFailed(reason: "Insufficient entropy"),
            .notImplemented(reason: "Feature planned for next release"),
            .internalError(reason: "Unexpected state"),
            .connectionInterrupted,
            .connectionInvalidated(reason: "Service crashed"),
        ]

        for error in errors {
            let description = error.errorDescription
            XCTAssertNotNil(description, "All XPCSecurityError cases should provide an error description")
            XCTAssertFalse(description?.isEmpty ?? true, "Error description should not be empty")

            // Verify the description includes the specific details for parameterised cases
            switch error {
            case let .serviceNotReady(reason):
                XCTAssertTrue(description?.contains(reason) ?? false, "Description should include the reason")
            case let .timeout(after):
                XCTAssertTrue(description?.contains("\(after)") ?? false, "Description should include the timeout value")
            case let .authenticationFailed(reason):
                XCTAssertTrue(description?.contains(reason) ?? false, "Description should include the reason")
            case let .operationNotSupported(name):
                XCTAssertTrue(description?.contains(name) ?? false, "Description should include the operation name")
            case let .invalidKeyType(expected, received):
                XCTAssertTrue(description?.contains(expected) ?? false, "Description should include expected key type")
                XCTAssertTrue(description?.contains(received) ?? false, "Description should include received key type")
            default:
                // Just check that description exists for other cases
                XCTAssertTrue(description?.count ?? 0 > 0, "Description should not be empty")
            }
        }
    }
}

// MARK: - Custom Test Helpers

/// Run all tests in this file
extension XPCErrorHandlingTests {
    static func runAllTests() throws {
        let tests = XPCErrorHandlingTests()
        tests.testXPCSecurityErrorEquality()
        tests.testConvertFoundationErrorsToXPCError()
        tests.testServiceStatusValues()
        tests.testServiceStatusCoding()
        tests.testErrorLocalisation()
    }
}

/// Entry point to run tests directly
struct XPCErrorHandlingTestsMain {
    static func main() throws {
        // Run tests
        let testSuite = XCTestSuite.default
        testSuite.run()
        // Test results will be reported by the XCTest framework
    }
}
