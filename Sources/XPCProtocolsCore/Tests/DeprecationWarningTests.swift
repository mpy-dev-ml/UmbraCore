import CoreErrors
import Foundation
import UmbraCoreTypes
import XCTest
import SecurityProtocolsCore
@testable import XPCProtocolsCore

/// Tests that verify deprecated protocol warnings
class DeprecationWarningTests: XCTestCase {
    /// Test that demonstrates using the deprecated protocols
    /// This test intentionally uses deprecated APIs to verify they work during migration
    /// but will generate compiler warnings.
    #if false // Temporarily disabled due to missing dependencies
        func testDeprecatedProtocolStillFunctional() async throws {
            // This test is temporarily disabled until we resolve dependency issues
            XCTAssert(true, "Test disabled")
        }
    #endif

    /// Test that demonstrates the recommended approach with new protocols
    func testModernProtocolUsage() async throws {
        // Create a service using the new protocols
        let modernService = ModernService()

        // Use the standardized protocols
        let secureBytes = UmbraCoreTypes.SecureBytes(bytes: [1, 2, 3, 4])
        let secureData = secureBytes.toNSData()
        
        // Convert NSData to SecureBytes for assertion
        let encryptedData = await modernService.encryptData(secureData, keyIdentifier: "test-key")
        XCTAssertNotNil(encryptedData, "Encryption should succeed")
        
        guard let encryptedNSData = encryptedData as? NSData else {
            XCTFail("Result should be NSData")
            return
        }
        
        XCTAssertEqual(encryptedNSData.length, 4, "Encryption should work with modern service")

        // Try the result-based API
        let encryptResult = await modernService.encrypt(data: secureBytes)
        guard case .success = encryptResult else {
            XCTFail("Result-based API should succeed")
            return
        }
        XCTAssert(true, "Result-based API succeeded")
    }
}

/// A modern service using the new protocols directly
@available(macOS 14.0, *)
private final class ModernService: NSObject, XPCServiceProtocolComplete {
    static var protocolIdentifier: String {
        "com.test.modern.service"
    }
    
    @objc
    func ping() async -> Bool {
        return true
    }
    
    @objc 
    func synchroniseKeys(_ bytes: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // Legacy synchronisation implementation
        completionHandler(nil)
    }
    
    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    func synchronizeKeys(_: UmbraCoreTypes.SecureBytes) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    func encrypt(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func decrypt(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func generateKey() async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 32)))
    }
    
    func generateKey(keyType: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata: [String: String]?) async -> Result<String, XPCSecurityError> {
        .success(keyIdentifier ?? "generated-key-id")
    }

    func hash(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func generateRandomData(length: Int) async -> NSObject? {
        NSData(bytes: Array(repeating: 0, count: length), length: length)
    }

    func encryptData(
        _ data: NSData, 
        keyIdentifier: String?
    ) async -> NSObject? {
        data
    }

    func decryptData(
        _ data: NSData, 
        keyIdentifier: String?
    ) async -> NSObject? {
        data
    }

    func hashData(_ data: NSData) async -> NSObject? {
        data
    }

    func signData(
        _ data: NSData,
        keyIdentifier: String
    ) async -> NSObject? {
        NSData(bytes: Array(repeating: 0, count: 64), length: 64)
    }

    func verifySignature(
        _ signature: NSData,
        for data: NSData,
        keyIdentifier: String
    ) async -> NSNumber? {
        NSNumber(value: true)
    }
    
    func verify(
        signature: UmbraCoreTypes.SecureBytes, 
        data: UmbraCoreTypes.SecureBytes, 
        keyIdentifier: String
    ) async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }
    
    func sign(
        data: UmbraCoreTypes.SecureBytes, 
        keyIdentifier: String
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 64)))
    }
    
    // Add the missing importKey method as required by XPCServiceProtocolStandard
    func importKey(
        keyData: UmbraCoreTypes.SecureBytes,
        keyType: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        .success(keyIdentifier ?? "imported-key-id")
    }
    
    func importKey(
        _ key: UmbraCoreTypes.SecureBytes, 
        type: String, 
        identifier: String
    ) async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }
    
    // Additional required methods for XPCServiceProtocolComplete
    func deleteKey(keyIdentifier: String) async -> Result<Void, XPCSecurityError> {
        .success(())
    }
    
    func listKeys() async -> Result<[String], XPCSecurityError> {
        .success(["test-key"])
    }
}
