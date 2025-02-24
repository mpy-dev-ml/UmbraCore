import Core
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

        XCTAssertEqual(error1.localizedDescription, error2.localizedDescription)
        XCTAssertNotEqual(error1.localizedDescription, error3.localizedDescription)
    }

    func testErrorMetadata() {
        let error = SecurityError.accessDenied(reason: "Access denied to /test/path")
        XCTAssertEqual(error.localizedDescription, "Access denied: Access denied to /test/path")
    }
}
