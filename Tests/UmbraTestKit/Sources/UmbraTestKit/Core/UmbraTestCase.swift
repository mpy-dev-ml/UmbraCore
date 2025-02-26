import Foundation
import XCTest

/// Base test case class for all UmbraCore tests
open class UmbraTestCase: XCTestCase {
    /// Setup method called before each test
    open override func setUp() async throws {
        try await super.setUp()
        // Common setup for all tests
    }
    
    /// Teardown method called after each test
    open override func tearDown() async throws {
        // Common teardown for all tests
        try await super.tearDown()
    }
    
    /// Helper method to create a temporary directory for tests
    public func createTemporaryDirectory() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("UmbraTest-\(UUID().uuidString)")
        
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return tempDir
    }
    
    /// Helper method to create a test file with content
    public func createTestFile(in directory: URL, named: String, content: String) throws -> URL {
        let fileURL = directory.appendingPathComponent(named)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    /// Helper method to clean up a directory
    public func cleanupDirectory(_ url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
