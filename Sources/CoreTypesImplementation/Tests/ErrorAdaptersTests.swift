import CoreErrors
@testable import CoreTypesImplementation
import XCTest

final class ErrorAdaptersTests: XCTestCase {
  func testExternalToCoreErrorMapping() {
    // Test mapping from an external error to CoreErrors.SecurityError
    struct ExternalError: Error, CustomStringConvertible {
      let reason: String
      var description: String { "External error: \(reason)" }
    }

    let externalError = ExternalError(reason: "Test failure")
    let coreError = mapExternalToCoreError(externalError)

    if case let .general(message) = coreError {
      XCTAssertTrue(
        message.contains("External error"),
        "Error message should contain original error description"
      )
      XCTAssertTrue(message.contains("Test failure"), "Error message should contain reason")
    } else {
      XCTFail("Error not mapped correctly to general case")
    }
  }

  func testCoreErrorPassthrough() {
    // When passing a CoreErrors.SecurityError, it should be returned unchanged
    let originalError = CoreErrors.SecurityError.encryptionFailed
    let mappedError = mapExternalToCoreError(originalError)

    XCTAssertEqual(
      originalError,
      mappedError,
      "Original CoreErrors.SecurityError should pass through unchanged"
    )
  }

  func testCoreToExternalErrorMapping() {
    // Test mapping from CoreErrors.SecurityError back to a generic Error
    let coreError = CoreErrors.SecurityError.accessError
    let mappedError = mapCoreToExternalError(coreError)

    // Verify it's still a SecurityError
    XCTAssertTrue(
      mappedError is CoreErrors.SecurityError,
      "Mapped error should still be a SecurityError"
    )

    // Verify it's the same error
    if let securityError = mappedError as? CoreErrors.SecurityError {
      XCTAssertEqual(securityError, coreError, "Error should remain unchanged")
    } else {
      XCTFail("Error type was changed unexpectedly")
    }
  }

  func testSecureBytesErrorMapping() {
    // Test mapping each SecureBytesError case to CoreErrors.SecurityError

    // Test invalid hex string
    let hexError = SecureBytesError.invalidHexString
    let mappedHexError = mapSecureBytesToCoreError(hexError)

    if case let .general(message) = mappedHexError {
      XCTAssertTrue(
        message.contains("Invalid hex string"),
        "Error message doesn't match expected content"
      )
    } else {
      XCTFail("Invalid hex string error not mapped correctly")
    }

    // Test out of bounds
    let boundsError = SecureBytesError.outOfBounds
    let mappedBoundsError = mapSecureBytesToCoreError(boundsError)

    if case let .general(message) = mappedBoundsError {
      XCTAssertTrue(
        message.contains("Index out of bounds"),
        "Error message doesn't match expected content"
      )
    } else {
      XCTFail("Out of bounds error not mapped correctly")
    }

    // Test allocation failed
    let allocError = SecureBytesError.allocationFailed
    let mappedAllocError = mapSecureBytesToCoreError(allocError)

    if case let .general(message) = mappedAllocError {
      XCTAssertTrue(
        message.contains("Memory allocation failed"),
        "Error message doesn't match expected content"
      )
    } else {
      XCTFail("Allocation failed error not mapped correctly")
    }
  }

  func testResultErrorMapping() {
    // Test mapping Result with different error types to Result<T, CoreErrors.SecurityError>

    // Test success case (should pass through)
    let successResult = Result<String, Error>.success("test data")
    let mappedSuccess = mapToSecurityResult(successResult)

    switch mappedSuccess {
      case let .success(value):
        XCTAssertEqual(value, "test data", "Success value should be preserved")
      case .failure:
        XCTFail("Success result was incorrectly mapped to failure")
    }

    // Test CoreErrors.SecurityError (should pass through)
    let securityError = CoreErrors.SecurityError.encryptionFailed
    let securityResult = Result<String, Error>.failure(securityError)
    let mappedSecurityResult = mapToSecurityResult(securityResult)

    switch mappedSecurityResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        XCTAssertEqual(error, securityError, "SecurityError should pass through unchanged")
    }

    // Test SecureBytesError
    let bytesError = SecureBytesError.invalidHexString
    let bytesResult = Result<String, Error>.failure(bytesError)
    let mappedBytesResult = mapToSecurityResult(bytesResult)

    switch mappedBytesResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        if case let .general(message) = error {
          XCTAssertTrue(
            message.contains("Invalid hex string"),
            "Error message doesn't match expected content"
          )
        } else {
          XCTFail("SecureBytesError not mapped to general error correctly")
        }
    }

    // Test generic error
    struct GenericError: Error { let message = "Generic error" }
    let genericResult = Result<String, Error>.failure(GenericError())
    let mappedGenericResult = mapToSecurityResult(genericResult)

    switch mappedGenericResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        if case let .general(message) = error {
          XCTAssertTrue(
            message.contains("GenericError"),
            "Error should contain original error type"
          )
        } else {
          XCTFail("Generic error not mapped to general error correctly")
        }
    }
  }
}
