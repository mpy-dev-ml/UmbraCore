// XPCProtocolsTests.swift
// XPCProtocolsCore/Tests
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Simple validation tests for XPCProtocolsCore
class XPCProtocolsCoreTests: XCTestCase {

    /// Test protocol references exist
    func testProtocolsExist() {
        // Verify that we can create protocol type references
        let _: any XPCServiceProtocolBasic.Type = MockXPCService.self
        let _: any XPCServiceProtocolStandard.Type = MockXPCService.self
        let _: any XPCServiceProtocolComplete.Type = MockXPCService.self

        // If we got this far, the test passes
        XCTAssertTrue(true, "Protocol type references should exist")
    }

    /// Test basic protocol methods
    func testBasicProtocolMethods() async throws {
        let service = MockXPCService()
        let isActive = try await service.ping()
        XCTAssertTrue(isActive, "Ping should return true")

        // This should not throw
        try await service.synchroniseKeys(SecureBytes(bytes: [1, 2, 3, 4]))
    }

    /// Test complete protocol methods
    func testCompleteProtocolMethods() async {
        let service = MockXPCService()
        let pingResult = await service.pingComplete()
        XCTAssertTrue(pingResult.isSuccess, "pingComplete should succeed")

        let syncResult = await service.synchronizeKeys(SecureBytes(bytes: [1, 2, 3, 4]))
        XCTAssertTrue(syncResult.isSuccess, "synchronizeKeys should succeed")

        let encryptResult = await service.encrypt(data: SecureBytes(bytes: [5, 6, 7, 8]))
        XCTAssertTrue(encryptResult.isSuccess, "encrypt should succeed")
    }

    /// Run all tests
    static func runAllTests() async throws {
        let tests = XPCProtocolsCoreTests()

        // Run synchronous tests
        tests.testProtocolsExist()

        // Run asynchronous tests
        try await tests.testBasicProtocolMethods()
        await tests.testCompleteProtocolMethods()

        print("All XPCProtocolsCore tests passed!")
    }
}

// MARK: - Test Helpers

/// Mock implementation of all XPC protocols for testing
private final class MockXPCService: XPCServiceProtocolComplete {
    static let protocolIdentifier: String = "com.test.mock.xpc.service"

    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        return .success(true)
    }

    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, XPCSecurityError> {
        return .success(())
    }

    func encrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return .success(data)
    }

    func decrypt(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return .success(data)
    }

    func generateKey() async -> Result<SecureBytes, XPCSecurityError> {
        return .success(SecureBytes(bytes: [0, 1, 2, 3]))
    }

    func hash(data: SecureBytes) async -> Result<SecureBytes, XPCSecurityError> {
        return .success(data)
    }

    // Standard protocol methods
    func generateRandomData(length: Int) async throws -> SecureBytes {
        return SecureBytes(bytes: Array(repeating: 0, count: length))
    }

    func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        return data
    }

    func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        return data
    }

    func synchroniseKeys(_ syncData: SecureBytes) async throws {
        // No-op for test
    }

    func ping() async throws -> Bool {
        return true
    }

    // Add missing methods required by XPCServiceProtocolStandard
    func hashData(_ data: SecureBytes) async throws -> SecureBytes {
        return data
    }

    func signData(_ data: SecureBytes, keyIdentifier: String) async throws -> SecureBytes {
        return data
    }

    func verifySignature(_ signature: SecureBytes, for data: SecureBytes, keyIdentifier: String) async throws -> Bool {
        return true
    }
}

// Helper extension for Result to make tests more readable
extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

// Main entry point for running tests
@main
struct XPCProtocolsCoreTestsMain {
    static func main() async throws {
        try await XPCProtocolsCoreTests.runAllTests()
    }
}
