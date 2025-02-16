import XCTest
@testable import Security
@testable import Core

@MainActor
final class SecurityServiceTests: XCTestCase {
    var securityService: SecurityService!
    let testFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("security_test.txt")
    
    override func setUp() async throws {
        securityService = SecurityService.shared
        try "Test content".write(to: testFileURL, atomically: true, encoding: .utf8)
    }
    
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: testFileURL)
        await securityService.stopAccessingAllResources()
    }
    
    func testBookmarkCreationAndResolution() async throws {
        // Create bookmark
        let bookmarkData = try await securityService.createBookmark(for: testFileURL)
        XCTAssertFalse(bookmarkData.isEmpty, "Bookmark data should not be empty")
        
        // Resolve bookmark
        let resolvedURL = try await securityService.resolveBookmark(bookmarkData)
        XCTAssertEqual(resolvedURL, testFileURL, "Resolved URL should match original")
    }
    
    func testSecurityScopedAccess() async throws {
        // Start accessing
        let success = try await securityService.startAccessing(testFileURL)
        XCTAssertTrue(success, "Should successfully start accessing resource")
        
        // Read content while accessing
        let content = try String(contentsOf: testFileURL, encoding: .utf8)
        XCTAssertEqual(content, "Test content", "Should be able to read content")
        
        // Stop accessing
        await securityService.stopAccessing(testFileURL)
    }
    
    func testWithSecurityScopedAccess() async throws {
        let content = try await securityService.withSecurityScopedAccess(to: testFileURL) {
            try String(contentsOf: testFileURL, encoding: .utf8)
        }
        XCTAssertEqual(content, "Test content", "Should be able to read content")
    }
    
    func testStopAccessingAllResources() async throws {
        // Start accessing multiple resources
        try await securityService.startAccessing(testFileURL)
        
        let secondFileURL = testFileURL.deletingLastPathComponent().appendingPathComponent("second_test.txt")
        try "Second test".write(to: secondFileURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: secondFileURL) }
        
        try await securityService.startAccessing(secondFileURL)
        
        // Stop accessing all
        await securityService.stopAccessingAllResources()
        
        // Try to access files (this should work since we're in a sandbox)
        XCTAssertNoThrow(try String(contentsOf: testFileURL, encoding: .utf8))
        XCTAssertNoThrow(try String(contentsOf: secondFileURL, encoding: .utf8))
    }
}
