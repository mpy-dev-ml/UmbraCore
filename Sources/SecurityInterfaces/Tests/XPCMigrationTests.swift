// DEPRECATED: XPCMigrationTests
// This entire file is deprecated and should not be used in new code.
// File marked as deprecated/legacy by naming convention

import Foundation
@testable import SecurityInterfaces
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Tests for the XPC Protocol Migration functionality
class XPCMigrationTests: XCTestCase {
    // MARK: - Protocol Adapter Tests

    func testLegacyServiceToBasicAdapter() async {
        // Create a mock legacy service
        let legacyService = MockLegacyXPCService()

        // Use the extension method to convert to XPCServiceProtocolBasic
        let basicAdapter = legacyService.asXPCServiceProtocolBasic()

        // Test the ping method
        do {
            let pingResult = try await basicAdapter.ping()
            XCTAssertTrue(pingResult, "Ping should succeed")
        } catch {
            XCTFail("Ping should not throw: \(error)")
        }

        // Test key synchronisation
        let testData = SecureBytes(bytes: [0, 1, 2, 3, 4, 5])

        // Key synchronisation should succeed and not throw
        do {
            try await basicAdapter.synchroniseKeys(testData)
            // If we get here, the test passes
        } catch {
            XCTFail("Synchronising keys should not throw: \(error)")
        }
    }

    func testLegacyServiceToStandardAdapter() async {
        // Create a mock legacy service
        let legacyService = MockLegacyXPCService()

        // Use the extension method to convert to XPCServiceProtocolStandard
        let standardAdapter = legacyService.asXPCServiceProtocolStandard()

        // Test the status method
        let statusResult = await standardAdapter.status()

        switch statusResult {
        case let .success(status):
            XCTAssertNotNil(status["version"])
            XCTAssertEqual(status["version"] as? String, "1.0")
        case let .failure(error):
            XCTFail("Status should succeed, but got error: \(error)")
        }

        // Test getHardwareIdentifier
        let idResult = await standardAdapter.getHardwareIdentifier()

        switch idResult {
        case let .success(identifier):
            XCTAssertEqual(identifier, "TEST-DEVICE-ID")
        case let .failure(error):
            XCTFail("getHardwareIdentifier should succeed, but got error: \(error)")
        }

        // Test an unsupported operation (legacy doesn't support resetSecurityData)
        let resetResult = await standardAdapter.resetSecurityData()

        switch resetResult {
        case .success:
            XCTFail("resetSecurityData should fail for legacy service")
        case let .failure(error):
            // Can't compare directly for equality since SecurityError doesn't conform to Equatable
            // Check the description instead
            XCTAssertTrue(
                "\(error)" == "\(XPCProtocolsCore.SecurityError.serviceUnavailable)",
                "Should get serviceUnavailable for unsupported operations"
            )
        }
    }

    func testFactoryCreation() {
        // Create a mock legacy service
        let legacyService = MockLegacyXPCService()

        // Use the factory directly to create adapters
        let basicAdapter = XPCProtocolMigrationFactory.createBasicAdapter(wrapping: legacyService)
        let standardAdapter = XPCProtocolMigrationFactory.createStandardAdapter(wrapping: legacyService)

        // Verify we got valid adapters
        XCTAssertNotNil(basicAdapter)
        XCTAssertNotNil(standardAdapter)

        // Verify protocol identifiers
        XCTAssertEqual(type(of: basicAdapter).protocolIdentifier, "com.umbra.xpc.service.adapter.basic")
    }

    // MARK: - Error Handling Tests

    func testErrorHandlingInAdapters() async {
        // Create a failing legacy service
        let failingService = FailingLegacyXPCService()

        // Convert to standard protocol
        let standardAdapter = failingService.asXPCServiceProtocolStandard()

        // Test error handling in status
        let statusResult = await standardAdapter.status()

        switch statusResult {
        case .success:
            XCTFail("Status should fail for failing service")
        case let .failure(error):
            // Can't compare directly for equality since SecurityError doesn't conform to Equatable
            // Check the description instead
            XCTAssertTrue(
                "\(error)".contains("Failed to get service status"),
                "Error should include correct failure reason"
            )
        }

        // Test error handling in getHardwareIdentifier
        let idResult = await standardAdapter.getHardwareIdentifier()

        switch idResult {
        case .success:
            XCTFail("getHardwareIdentifier should fail for failing service")
        case let .failure(error):
            // Can't compare directly for equality since SecurityError doesn't conform to Equatable
            // Check the description instead
            XCTAssertTrue(
                "\(error)".contains("Failed to get device identifier"),
                "Error should include correct failure reason"
            )
        }
    }
}

// MARK: - Test Implementations

/// Mock implementation of a legacy XPC service
private final class MockLegacyXPCService: XPCServiceProtocol {
    static var protocolIdentifier: String {
        "com.umbra.test.legacy"
    }

    func ping() async -> Bool {
        true
    }

    func getServiceVersion() async -> String? {
        "1.0"
    }

    func getServiceStatus() async -> [String: Any]? {
        ["version": "1.0", "status": "running", "uptime": 3_600]
    }

    func getDeviceIdentifier() async -> String? {
        "TEST-DEVICE-ID"
    }

    func synchronizeKeys(_ data: SecureBytes) async -> Bool {
        // Just pretend we did something with the data
        !data.isEmpty
    }
}

/// Mock implementation of a failing legacy XPC service
private final class FailingLegacyXPCService: XPCServiceProtocol {
    static var protocolIdentifier: String {
        "com.umbra.test.failing"
    }

    func ping() async -> Bool {
        false
    }

    func getServiceVersion() async -> String? {
        nil
    }

    func getServiceStatus() async -> [String: Any]? {
        nil
    }

    func getDeviceIdentifier() async -> String? {
        nil
    }

    func synchronizeKeys(_: SecureBytes) async -> Bool {
        false
    }
}
