@testable import Models
import XCTest

final class ErrorContextTests: XCTestCase {
    func testErrorContextCreation() {
        let underlyingError = NSError(domain: "test", code: 1, userInfo: nil)
        let context = ErrorContext(
            source: "TestService",
            operation: "testOperation",
            details: "Test details",
            underlyingError: underlyingError,
            file: "test.swift",
            line: 42,
            function: "testFunction()"
        )

        XCTAssertEqual(context.source, "TestService")
        XCTAssertEqual(context.operation, "testOperation")
        XCTAssertEqual(context.details, "Test details")
        XCTAssertEqual(context.file, "test.swift")
        XCTAssertEqual(context.line, 42)
        XCTAssertEqual(context.function, "testFunction()")
    }

    func testErrorContextDescription() {
        let underlyingError = NSError(domain: "test", code: 1, userInfo: nil)
        let context = ErrorContext(
            source: "TestService",
            operation: "testOperation",
            details: "Test details",
            underlyingError: underlyingError,
            file: "test.swift",
            line: 42,
            function: "testFunction()"
        )

        let description = context.errorDescription ?? ""

        XCTAssertTrue(description.contains("Error in TestService while testOperation"))
        XCTAssertTrue(description.contains("File: test.swift"))
        XCTAssertTrue(description.contains("Line: 42"))
        XCTAssertTrue(description.contains("Function: testFunction()"))
        XCTAssertTrue(description.contains("Details: Test details"))
        XCTAssertTrue(description.contains("Underlying error: The operation couldn't be completed. (test error 1.)"))
    }

    func testErrorContextWithoutDetails() {
        let underlyingError = NSError(domain: "test", code: 1, userInfo: nil)
        let context = ErrorContext(
            source: "TestService",
            operation: "testOperation",
            underlyingError: underlyingError,
            file: "test.swift",
            line: 42,
            function: "testFunction()"
        )

        let description = context.errorDescription ?? ""

        XCTAssertFalse(description.contains("Details:"))
    }
}
