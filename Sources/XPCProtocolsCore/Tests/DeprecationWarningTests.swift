import CoreErrors
import Foundation
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest
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
        true
    }

    @objc
    func synchroniseKeys(_: [UInt8], completionHandler: @escaping (NSError?) -> Void) {
        // Legacy synchronisation implementation
        completionHandler(nil)
    }

    func pingComplete() async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    func encryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier _: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func decryptSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier _: String?) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func hashSecureData(_ data: UmbraCoreTypes.SecureBytes) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func signSecureData(_ data: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func verifySignature(_: UmbraCoreTypes.SecureBytes, for _: UmbraCoreTypes.SecureBytes, keyIdentifier _: String) async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    func generateKeyPair(type _: String, keySize _: Int, identifier _: String?) async -> Result<String, XPCSecurityError> {
        .success("test-key-id")
    }

    func getServiceStatus() async -> Result<XPCServiceStatus, XPCSecurityError> {
        .success(XPCServiceStatus(
            timestamp: Date(),
            protocolVersion: "1.0",
            serviceVersion: "1.0",
            deviceIdentifier: "Mock-Device-ID",
            additionalInfo: ["serviceType": "Mock Service"]
        ))
    }

    func importKey(data _: UmbraCoreTypes.SecureBytes, type _: String, keyIdentifier _: String?) async -> Result<String, XPCSecurityError> {
        .success("imported-key-id")
    }

    func exportKey(keyIdentifier _: String) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(UmbraCoreTypes.SecureBytes())
    }

    func deriveKey(from _: String, salt _: UmbraCoreTypes.SecureBytes, iterations _: Int, keyLength _: Int, targetKeyIdentifier _: String?) async -> Result<String, XPCSecurityError> {
        .success("derived-key-id")
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

    func generateKey(keyType _: XPCProtocolTypeDefs.KeyType, keyIdentifier: String?, metadata _: [String: String]?) async -> Result<String, XPCSecurityError> {
        .success(keyIdentifier ?? "generated-key-id")
    }

    func hash(
        data: UmbraCoreTypes
            .SecureBytes
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(data)
    }

    func generateRandomData(length: Int) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: length)))
    }

    func encryptData(
        _ data: NSData,
        keyIdentifier _: String?
    ) async -> NSObject? {
        data
    }

    func decryptData(
        _ data: NSData,
        keyIdentifier _: String?
    ) async -> NSObject? {
        data
    }

    func hashData(_ data: NSData) async -> NSObject? {
        data
    }

    func signData(
        _: NSData,
        keyIdentifier _: String
    ) async -> NSObject? {
        NSData(bytes: Array(repeating: 0, count: 64), length: 64)
    }

    func verifySignature(
        _: NSData,
        for _: NSData,
        keyIdentifier _: String
    ) async -> NSNumber? {
        NSNumber(value: true)
    }

    func verify(
        signature: UmbraCoreTypes.SecureBytes, 
        for data: UmbraCoreTypes.SecureBytes, 
        keyIdentifier: String
    ) async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    func sign(
        _ data: UmbraCoreTypes.SecureBytes,
        keyIdentifier: String
    ) async -> Result<UmbraCoreTypes.SecureBytes, XPCSecurityError> {
        .success(UmbraCoreTypes.SecureBytes(bytes: Array(repeating: 0, count: 64)))
    }

    // Add the missing importKey method as required by XPCServiceProtocolStandard
    func importKey(
        keyData _: UmbraCoreTypes.SecureBytes,
        keyType _: XPCProtocolTypeDefs.KeyType,
        keyIdentifier: String?,
        metadata _: [String: String]?
    ) async -> Result<String, XPCSecurityError> {
        .success(keyIdentifier ?? "imported-key-id")
    }

    func importKey(
        _: UmbraCoreTypes.SecureBytes,
        type _: String,
        identifier _: String
    ) async -> Result<Bool, XPCSecurityError> {
        .success(true)
    }

    // Required for XPCServiceProtocolStandard
    func resetSecurity() async -> Result<Void, XPCSecurityError> {
        .success(())
    }
    
    func getServiceVersion() async -> Result<String, XPCSecurityError> {
        .success("1.0.0")
    }
    
    func getHardwareIdentifier() async -> Result<String, XPCSecurityError> {
        .success("test-hardware-id")
    }
    
    // Required for CryptoXPCServiceProtocol
    func synchroniseKeys(_ syncData: UmbraCoreTypes.SecureBytes) async throws {
        // Implementation for synchronisation
    }

    // Additional required methods for XPCServiceProtocolComplete
    func deleteKey(keyIdentifier _: String) async -> Result<Void, XPCSecurityError> {
        .success(())
    }

    func listKeys() async -> Result<[String], XPCSecurityError> {
        .success(["test-key"])
    }
}
