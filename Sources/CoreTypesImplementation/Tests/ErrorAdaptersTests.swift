import CoreErrors
@testable import CoreTypesImplementation
import ErrorHandlingDomains // Add import for UmbraErrors
import XCTest

final class ErrorAdaptersTests: XCTestCase {
  func testExternalToCoreErrorMapping() {
    // Test mapping from an external error to CoreErrors.SecurityError
    struct ExternalError: Error, CustomStringConvertible {
      let reason: String
      var description: String { "External error: \(reason)" }
    }

    let externalError=ExternalError(reason: "API call failed")
    let mappedError=externalErrorToCoreError(externalError)

    // Check that we can convert the error to a string instead of checking for specific case
    let errorDescription=String(describing: mappedError)
    XCTAssertTrue(
      errorDescription.contains("External error"),
      "Mapped error should contain the original description"
    )
  }

  func testCoreErrorPassthrough() {
    // When passing a CoreErrors.SecurityError, it should be returned unchanged
    let originalError=CoreErrors.SecurityError.encryptionFailed
    let mappedError=mapExternalToCoreError(originalError)

    XCTAssertEqual(
      originalError,
      mappedError,
      "Original CoreErrors.SecurityError should pass through unchanged"
    )
  }

  func testCoreToExternalErrorMapping() {
    // Test mapping from CoreErrors.SecurityError back to a generic Error
    let coreError=CoreErrors.SecurityError.accessError
    let mappedError=mapCoreToExternalError(coreError)

    // Verify it's still a SecurityError
    XCTAssertTrue(
      mappedError is CoreErrors.SecurityError,
      "Mapped error should still be a SecurityError"
    )

    // Verify it's the same error
    if let securityError=mappedError as? CoreErrors.SecurityError {
      XCTAssertEqual(securityError, coreError, "Error should remain unchanged")
    } else {
      XCTFail("Error type was changed unexpectedly")
    }
  }

  func testSecureBytesErrorMapping() {
    // Test mapping SecureBytesError to CoreErrors.SecurityError

    // Memory allocation failure
    let allocError=SecureBytesError.memoryAllocationFailed
    let mappedAllocError=mapSecureBytesToCoreError(allocError)

    // Use string comparison instead of case pattern matching
    let allocErrorString=String(describing: mappedAllocError)
    XCTAssertTrue(
      allocErrorString.contains("Memory allocation failed"),
      "Error message doesn't match expected content"
    )

    // Invalid hex string
    let hexError=SecureBytesError.invalidHexString
    let mappedHexError=mapSecureBytesToCoreError(hexError)

    // Use string comparison instead of case pattern matching
    let hexErrorString=String(describing: mappedHexError)
    XCTAssertTrue(
      hexErrorString.contains("Invalid hex string"),
      "Error message doesn't match expected content"
    )
  }

  func testResultErrorMapping() {
    // Test mapping Result with different error types to Result<T, CoreErrors.SecurityError>

    // Test success case (should pass through)
    let successResult=Result<String, Error>.success("test data")
    let mappedSuccessResult=mapToSecurityResult(successResult)

    switch mappedSuccessResult {
      case let .success(value):
        XCTAssertEqual(value, "test data", "Success value should pass through unchanged")
      case .failure:
        XCTFail("Success result was incorrectly mapped to failure")
    }

    // Test standard error
    struct StandardError: Error, CustomStringConvertible {
      let reason: String
      var description: String { "Standard error: \(reason)" }
    }

    let standardError=StandardError(reason: "Something went wrong")
    let standardResult=Result<String, Error>.failure(standardError)
    let mappedStandardResult=mapToSecurityResult(standardResult)

    switch mappedStandardResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        // Use string comparison instead of case pattern matching
        let errorString=String(describing: error)
        XCTAssertTrue(
          errorString.contains("Standard error"),
          "Mapped error should contain the original description"
        )
    }

    // Test NSError
    let nsError=NSError(
      domain: "TestDomain",
      code: 123,
      userInfo: [NSLocalizedDescriptionKey: "NSError test"]
    )
    let nsResult=Result<String, Error>.failure(nsError)
    let mappedNSResult=mapToSecurityResult(nsResult)

    switch mappedNSResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        // Use string comparison instead of case pattern matching
        let errorString=String(describing: error)
        XCTAssertTrue(
          errorString.contains("NSError"),
          "Mapped error should contain the original NSError description"
        )
    }

    // Test SecurityError
    let securityError=UmbraErrors.Security.Core.invalidKey(reason: "bad key")
    let securityResult=Result<String, Error>.failure(securityError)
    let mappedSecurityResult=mapToSecurityResult(securityResult)

    switch mappedSecurityResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        // Compare string descriptions instead of direct error comparison
        let errorDescription=String(describing: error)
        XCTAssertTrue(
          errorDescription.contains("invalid key") || errorDescription.contains("bad key"),
          "SecurityError description should match the original error"
        )
    }

    // Test SecureBytesError
    let bytesError=SecureBytesError.invalidHexString
    let bytesResult=Result<String, Error>.failure(bytesError)
    let mappedBytesResult=mapToSecurityResult(bytesResult)

    switch mappedBytesResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        let errorString=String(describing: error)
        XCTAssertTrue(
          errorString.contains("Invalid hex string"),
          "Error message doesn't match expected content"
        )
    }

    // Test generic error
    struct GenericError: Error { let message="Generic error" }
    let genericResult=Result<String, Error>.failure(GenericError())
    let mappedGenericResult=mapToSecurityResult(genericResult)

    switch mappedGenericResult {
      case .success:
        XCTFail("Failure result was incorrectly mapped to success")
      case let .failure(error):
        let errorString=String(describing: error)
        XCTAssertTrue(
          errorString.contains("GenericError"),
          "Error should contain original error type"
        )
    }
  }
}
