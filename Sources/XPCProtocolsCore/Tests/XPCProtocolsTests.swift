// XPCProtocolsTests.swift
// XPCProtocolsCore/Tests
//
// Created as part of the UmbraCore XPC Protocols Refactoring
//

import XPCProtocolsCore
import UmbraCoreTypes
/// Simple validation tests for XPCProtocolsCore
class XPCProtocolsCoreTests {
    
    /// Test protocol references exist
    func testProtocolsExist() {
        // Verify that we can create protocol type references
        let _: any XPCServiceProtocolBasic.Type = MockXPCService.self
        let _: any XPCServiceProtocolStandard.Type = MockXPCService.self
        let _: any XPCServiceProtocolComplete.Type = MockXPCService.self
        
        // If we got this far, the test passes
        assert(true, "Protocol type references should exist")
    }
    
    /// Test basic protocol methods
    func testBasicProtocolMethods() async throws {
        let service = MockXPCService()
        let isActive = try await service.ping()
        assert(isActive, "Ping should return true")
        
        // This should not throw
        try await service.synchroniseKeys(SecureBytes([1, 2, 3, 4]))
    }
    
    /// Test complete protocol methods
    func testCompleteProtocolMethods() async {
        let service = MockXPCService()
        let pingResult = await service.pingComplete()
        assert(pingResult.isSuccess, "pingComplete should succeed")
        
        let syncResult = await service.synchronizeKeys(SecureBytes([1, 2, 3, 4]))
        assert(syncResult.isSuccess, "synchronizeKeys should succeed")
        
        let encryptResult = await service.encrypt(data: SecureBytes([5, 6, 7, 8]))
        assert(encryptResult.isSuccess, "encrypt should succeed")
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
    static var protocolIdentifier: String = "com.test.mock.xpc.service"
    
    func pingComplete() async -> Result<Bool, SecurityError> {
        return .success(true)
    }
    
    func synchronizeKeys(_ syncData: SecureBytes) async -> Result<Void, SecurityError> {
        return .success(())
    }
    
    func encrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        return .success(data)
    }
    
    func decrypt(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        return .success(data)
    }
    
    func generateKey() async -> Result<SecureBytes, SecurityError> {
        return .success(SecureBytes([0, 1, 2, 3]))
    }
    
    func hash(data: SecureBytes) async -> Result<SecureBytes, SecurityError> {
        return .success(data)
    }
    
    // Standard protocol methods
    func generateRandomData(length: Int) async throws -> SecureBytes {
        return SecureBytes(Array(repeating: 0, count: length))
    }
    
    func encryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        return data
    }
    
    func decryptData(_ data: SecureBytes, keyIdentifier: String?) async throws -> SecureBytes {
        return data
    }
    
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
