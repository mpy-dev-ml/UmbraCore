import CoreTypes
@testable import FeaturesLoggingServices
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import UmbraSecurityNoFoundation
import UmbraSecurityServicesNoFoundation
import XCTest

@available(macOS 14.0, *)
final class LoggingServiceNoFoundationTests: XCTestCase {

    private var loggingService: LoggingServiceNoFoundation!
    private var securityProvider: DefaultSecurityProviderNoFoundation!

    override func setUp() async throws {
        super.setUp()
        securityProvider = DefaultSecurityProviderNoFoundation()
        loggingService = LoggingServiceNoFoundation(securityProvider: securityProvider)
    }

    override func tearDown() async throws {
        await securityProvider.clearAccessedResources()
        loggingService = nil
        securityProvider = nil
        super.tearDown()
    }

    func testCreateBookmark() async throws {
        // Given
        let testPath = "/path/to/test/file.log"

        // When
        let bookmarkData = try await loggingService.createBookmark(for: testPath)

        // Then
        XCTAssertFalse(bookmarkData.isEmpty, "Bookmark data should not be empty")

        // Verify we can resolve the bookmark
        let resolvedPath = try loggingService.resolveBookmark(bookmarkData)
        XCTAssertEqual(resolvedPath, testPath, "Resolved path should match original path")
    }

    func testSecurityScopedResourceAccess() async throws {
        // Given
        let testPath = "/path/to/test/resource.log"

        // When
        let accessStarted = try loggingService.startAccessingSecurityScopedResource(testPath)

        // Then
        XCTAssertTrue(accessStarted, "Should successfully start accessing security-scoped resource")

        // Verify resource is tracked
        let resourceIds = await loggingService.getAccessedResourceIdentifiers()
        XCTAssertTrue(resourceIds.contains(testPath), "Resource should be tracked")

        // Stop accessing
        loggingService.stopAccessingSecurityScopedResource(testPath)

        // Wait for async operations to complete
        try await Task.sleep(for: .milliseconds(100))

        // Verify resource is no longer tracked
        let updatedResourceIds = await loggingService.getAccessedResourceIdentifiers()
        XCTAssertFalse(updatedResourceIds.contains(testPath), "Resource should no longer be tracked")
    }

    func testClearAccessedResources() async throws {
        // Given
        let testPaths = ["/path/one.log", "/path/two.log", "/path/three.log"]

        // When
        for path in testPaths {
            _ = try loggingService.startAccessingSecurityScopedResource(path)
        }

        // Verify resources are tracked
        let resourceIds = await loggingService.getAccessedResourceIdentifiers()
        XCTAssertEqual(resourceIds.count, testPaths.count, "All resources should be tracked")

        // Clear resources
        await loggingService.clearAccessedResources()

        // Then
        let updatedResourceIds = await loggingService.getAccessedResourceIdentifiers()
        XCTAssertTrue(updatedResourceIds.isEmpty, "All resources should be cleared")
    }

    func testFactoryCreation() {
        // Given & When
        let factoryService = LoggingServiceFactoryNoFoundation.createDefaultService()

        // Then
        XCTAssertNotNil(factoryService, "Factory should create a valid service")
    }
}
