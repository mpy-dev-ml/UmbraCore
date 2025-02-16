import XCTest
import SecurityTypes
@testable import Core

final class CoreServiceTests: XCTestCase {
    var mockSecurityProvider: MockSecurityProvider!
    var coreService: CoreService!
    
    override func setUp() {
        mockSecurityProvider = MockSecurityProvider()
        coreService = CoreService(securityProvider: mockSecurityProvider)
    }
    
    func testSecurityProviderInjection() {
        let provider = coreService.getSecurityProvider()
        XCTAssertTrue(provider is MockSecurityProvider)
    }
}

// MARK: - Mock Security Provider

private class MockSecurityProvider: SecurityProvider {
    func createBookmark(for url: URL) async throws -> Data {
        Data()
    }
    
    func resolveBookmark(_ bookmarkData: Data) async throws -> URL {
        URL(fileURLWithPath: "/test")
    }
    
    func startAccessing(_ url: URL) async throws -> Bool {
        true
    }
    
    func stopAccessing(_ url: URL) async {
    }
    
    func withSecurityScopedAccess<T>(to url: URL, perform operation: () async throws -> T) async throws -> T {
        try await operation()
    }
    
    func stopAccessingAllResources() async {
    }
}
