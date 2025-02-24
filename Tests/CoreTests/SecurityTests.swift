import Core
import XCTest
import Foundation

final class SecurityTests: XCTestCase {
    func testServiceInitialization() async throws {
        let container = ServiceContainer()
        let service = SecurityService(container: container)
        
        try await container.register(service)
        let initialState = await service.state
        XCTAssertEqual(initialState, ServiceState.uninitialized)
        
        try await container.initialiseAll()
        let readyState = await service.state
        XCTAssertEqual(readyState, ServiceState.ready)
    }
    
    func testBookmarkOperations() async throws {
        let container = ServiceContainer()
        let service = SecurityService(container: container)
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test bookmark creation
        let testPath = "/test/path"
        let bookmark = try await service.createBookmark(forPath: testPath)
        XCTAssertFalse(bookmark.isEmpty)
        
        // Test bookmark resolution
        let (resolvedPath, isStale) = try await service.resolveBookmark(bookmark)
        XCTAssertEqual(resolvedPath, testPath)
        XCTAssertFalse(isStale)
        
        // Test invalid bookmark
        do {
            _ = try await service.resolveBookmark([])
            XCTFail("Expected bookmark resolution error")
        } catch let error as SecurityError {
            XCTAssertTrue(error.errorDescription?.contains("Invalid bookmark") == true)
        }
    }
    
    func testSecurityScopedAccess() async throws {
        let container = ServiceContainer()
        let service = SecurityService(container: container)
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test starting access
        let testPath = "/test/path"
        let accessGranted = try await service.startAccessing(path: testPath)
        XCTAssertTrue(accessGranted)
        let isAccessing = await service.isAccessing(path: testPath)
        XCTAssertTrue(isAccessing)
        
        // Test getting accessed paths
        let accessedPaths = await service.getAccessedPaths()
        XCTAssertTrue(accessedPaths.contains(testPath))
        
        // Test stopping access
        await service.stopAccessing(path: testPath)
        let isStillAccessing = await service.isAccessing(path: testPath)
        XCTAssertFalse(isStillAccessing)
        
        // Test stopping all access
        _ = try await service.startAccessing(path: testPath)
        await service.stopAccessingAllResources()
        let finalPaths = await service.getAccessedPaths()
        XCTAssertTrue(finalPaths.isEmpty)
    }
    
    func testBookmarkStorage() async throws {
        let container = ServiceContainer()
        let service = SecurityService(container: container)
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test saving and loading bookmark
        let testPath = "/test/path"
        let identifier = "test-bookmark"
        let bookmark = try await service.createBookmark(forPath: testPath)
        
        try await service.saveBookmark(bookmark, withIdentifier: identifier)
        let loadedBookmark = try await service.loadBookmark(withIdentifier: identifier)
        XCTAssertEqual(bookmark, loadedBookmark)
        
        // Test bookmark validation
        let isValid = try await service.validateBookmark(bookmark)
        XCTAssertTrue(isValid)
        
        // Test deleting bookmark
        try await service.deleteBookmark(withIdentifier: identifier)
        do {
            _ = try await service.loadBookmark(withIdentifier: identifier)
            XCTFail("Expected bookmark not found error")
        } catch let error as SecurityError {
            XCTAssertTrue(error.errorDescription?.contains("not found") == true)
        }
    }
    
    func testErrorHandling() async throws {
        let container = ServiceContainer()
        let service = SecurityService(container: container)
        
        // Test operations before initialization
        do {
            _ = try await service.createBookmark(forPath: "/test/path")
            XCTFail("Expected service not ready error")
        } catch let error as ServiceError {
            XCTAssertTrue(error.errorDescription?.contains("Service not ready") == true)
        }
        
        try await container.register(service)
        try await container.initialiseAll()
        
        // Test invalid path
        do {
            _ = try await service.createBookmark(forPath: "")
            XCTFail("Expected invalid path error")
        } catch let error as SecurityError {
            XCTAssertTrue(error.errorDescription?.contains("Invalid path") == true)
        }
    }
}
