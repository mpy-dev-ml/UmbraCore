@testable import SecurityTypes
import XCTest

final class SecurityErrorTests: XCTestCase {
    func testErrorDescription() {
        let error = SecurityError.accessDenied(reason: "Access denied to /test/path")
        XCTAssertEqual(
            error.localizedDescription,
            "Access denied: Access denied to /test/path"
        )
    }

    func testErrorEquality() {
        let error1 = SecurityError.accessDenied(reason: "Access denied to /test/path")
        let error2 = SecurityError.accessDenied(reason: "Access denied to /test/path")
        let error3 = SecurityError.accessDenied(reason: "Access denied to /different/path")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testErrorMetadata() {
        let error = SecurityError.accessDenied(reason: "Access denied to /test/path")
        XCTAssertEqual(error.localizedDescription, "Access denied: Access denied to /test/path")
    }
}
