import XCTest
@testable import SecurityTypes

final class SecurityErrorTests: XCTestCase {
    func testSecurityErrorDescriptions() {
        let testURL = URL(fileURLWithPath: "/test/path")
        let underlyingError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let errors: [(SecurityError, String)] = [
            (.bookmarkCreationFailed(url: testURL, underlying: underlyingError),
             "Failed to create bookmark for /test/path: Test error"),
            
            (.bookmarkResolutionFailed(underlying: underlyingError),
             "Failed to resolve bookmark: Test error"),
            
            (.accessDenied(url: testURL),
             "Access denied to /test/path")
        ]
        
        for (error, expectedDescription) in errors {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }
}
