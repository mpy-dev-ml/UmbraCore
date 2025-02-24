@testable import ResticCLIHelper
import UmbraTestKit
import XCTest

/// Base test case for Restic CLI tests
open class ResticTestCase: XCTestCase {
    /// Mock repository for testing
    var mockRepository: MockResticRepository!

    /// CLI helper instance
    var helper: ResticCLIHelper!

    override open func setUp() async throws {
        try await super.setUp()

        // Create mock repository
        mockRepository = try MockResticRepository()

        // Initialize CLI helper
        helper = ResticCLIHelper(resticPath: "/opt/homebrew/bin/restic")
    }

    override open func tearDown() async throws {
        try mockRepository?.cleanup()
        mockRepository = nil
        helper = nil
        try await super.tearDown()
    }
}
