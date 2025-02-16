import XCTest
@testable import UmbraCore

final class UmbraCoreTests: XCTestCase {
    func testModuleImports() {
        // Test that we can access types from all modules
        let _ = SecurityService.shared
        let _ = LoggingService.shared
    }
}
