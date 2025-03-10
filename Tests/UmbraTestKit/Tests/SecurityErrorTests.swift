import Core
import ErrorHandlingDomains
import SecurityInterfaces
import XCTest

final class SecurityErrorTests: XCTestCase {
  func testErrorDescription() {
    let error=SecurityInterfaces.SecurityError.accessError("Access denied to /test/path")
    XCTAssertEqual(
      error.errorDescription,
      "Access error: Access denied to /test/path"
    )
  }

  func testErrorEquality() {
    let error1=SecurityInterfaces.SecurityError.accessError("Access denied to /test/path")
    let error2=SecurityInterfaces.SecurityError.accessError("Access denied to /test/path")
    let error3=SecurityInterfaces.SecurityError.accessError("Access denied to /different/path")

    XCTAssertEqual(error1.errorDescription, error2.errorDescription)
    XCTAssertNotEqual(error1.errorDescription, error3.errorDescription)
  }

  func testErrorMetadata() {
    let error=SecurityInterfaces.SecurityError.accessError("Access denied to /test/path")
    XCTAssertEqual(error.errorDescription, "Access error: Access denied to /test/path")
  }
}
