import Core
@testable import SecurityInterfacesForTesting
import XCTest

final class SecurityErrorTests: XCTestCase {
  func testErrorDescription() {
    let error=SecurityError.accessError("Access denied to /test/path")
    XCTAssertEqual(
      error.errorDescription,
      "Access error: Access denied to /test/path"
    )
  }

  func testErrorEquality() {
    let error1=SecurityError.accessError("Access denied to /test/path")
    let error2=SecurityError.accessError("Access denied to /test/path")
    let error3=SecurityError.accessError("Access denied to /different/path")

    XCTAssertEqual(error1.errorDescription, error2.errorDescription)
    XCTAssertNotEqual(error1.errorDescription, error3.errorDescription)
  }

  func testErrorMetadata() {
    let error=SecurityError.accessError("Access denied to /test/path")
    XCTAssertEqual(error.errorDescription, "Access error: Access denied to /test/path")
  }
}
