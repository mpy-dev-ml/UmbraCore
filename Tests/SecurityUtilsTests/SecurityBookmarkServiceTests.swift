import XCTest
@testable import SecurityUtils
import SecurityTypes

final class SecurityBookmarkServiceTests: XCTestCase {
    var service: SecurityBookmarkService!
    var mockURLProvider: MockURLProvider!
    
    override func setUp() async throws {
        mockURLProvider = MockURLProvider()
        service = SecurityBookmarkService(urlProvider: mockURLProvider)
    }
    
    override func tearDown() async throws {
        service = nil
        mockURLProvider = nil
    }
    
    func testCreateBookmark() async throws {
        // Given
        let testPath = "/path/to/test"
        guard let url = URL(string: testPath) else {
            XCTFail("Failed to create test URL")
            return
        }
        
        // When
        let bookmarkData = try await service.createBookmark(for: url)
        
        // Then
        XCTAssertFalse(bookmarkData.isEmpty, "Bookmark data should not be empty")
        let mockString = String(decoding: bookmarkData, as: UTF8.self)
        XCTAssertEqual(mockString, "MockBookmark:\(testPath)", "Bookmark data should match expected format")
    }
    
    func testResolveBookmark() async throws {
        // Given
        let testPath = "/path/to/test"
        guard let url = URL(string: testPath) else {
            XCTFail("Failed to create test URL")
            return
        }
        let bookmarkData = try await service.createBookmark(for: url)
        
        // When
        let (resolvedURL, isStale) = try await service.resolveBookmark(bookmarkData)
        
        // Then
        XCTAssertEqual(resolvedURL.path, testPath, "Resolved URL path should match original")
        XCTAssertFalse(isStale, "Newly created bookmark should not be stale")
    }
    
    func testResolveStaleBookmark() async throws {
        // Given
        let testPath = "/path/to/stale/test"
        guard let url = URL(string: testPath) else {
            XCTFail("Failed to create test URL")
            return
        }
        let bookmarkData = try await service.createBookmark(for: url)
        
        // When
        let (resolvedURL, isStale) = try await service.resolveBookmark(bookmarkData)
        
        // Then
        XCTAssertEqual(resolvedURL.path, testPath, "Resolved URL path should match original")
        XCTAssertTrue(isStale, "Bookmark should be detected as stale")
    }
    
    func testStartAndStopAccessing() async throws {
        // Given
        let testPath = "/path/to/test"
        guard let url = URL(string: testPath) else {
            XCTFail("Failed to create test URL")
            return
        }
        
        // When
        let success = try await service.startAccessing(url)
        
        // Then
        XCTAssertTrue(success, "Should successfully start accessing resource")
        
        // When
        await service.stopAccessing(url)
        
        // Then
        // No assertion needed for stopAccessing as it doesn't return anything
    }
    
    func testValidateBookmark() async throws {
        // Given
        let testPath = "/path/to/test"
        guard let url = URL(string: testPath) else {
            XCTFail("Failed to create test URL")
            return
        }
        let bookmarkData = try await service.createBookmark(for: url)
        
        // When
        let isValid = try await service.validateBookmark(bookmarkData)
        
        // Then
        XCTAssertTrue(isValid, "Newly created bookmark should be valid")
    }
    
    func testValidateStaleBookmark() async throws {
        // Given
        let testPath = "/path/to/stale/test"
        guard let url = URL(string: testPath) else {
            XCTFail("Failed to create test URL")
            return
        }
        let bookmarkData = try await service.createBookmark(for: url)
        
        // When
        let isValid = try await service.validateBookmark(bookmarkData)
        
        // Then
        XCTAssertFalse(isValid, "Stale bookmark should be invalid")
    }
}
