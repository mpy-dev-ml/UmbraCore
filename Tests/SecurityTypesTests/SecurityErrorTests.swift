import XCTest
@testable import SecurityTypes

final class SecurityErrorTests: XCTestCase {
    func testErrorDescription() {
        let error = SecurityError.accessDenied(path: "/test/path")
        XCTAssertEqual(
            error.localizedDescription,
            "Access denied to path: /test/path"
        )
    }
    
    func testErrorEquality() {
        let error1 = SecurityError.accessDenied(path: "/test/path")
        let error2 = SecurityError.accessDenied(path: "/test/path")
        let error3 = SecurityError.accessDenied(path: "/different/path")
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    func testErrorCoding() throws {
        let error = SecurityError.accessDenied(path: "/test/path")
        let data = try JSONEncoder().encode(error)
        let decoded = try JSONDecoder().decode(SecurityError.self, from: data)
        
        XCTAssertEqual(error, decoded)
    }
    
    func testErrorMetadata() {
        let error = SecurityError.accessDenied(path: "/test/path")
        XCTAssertEqual(error.path, "/test/path")
        XCTAssertEqual(error.errorDescription, "Access denied to path: /test/path")
    }
}
