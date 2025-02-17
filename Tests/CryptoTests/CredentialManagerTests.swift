import XCTest
@testable import UmbraCore
import SecurityTypes
import UmbraMocks

final class CredentialManagerTests: XCTestCase {
    var mockKeychain: MockKeychain!
    var credentialManager: CredentialManager!
    
    override func setUp() async throws {
        mockKeychain = MockKeychain()
        credentialManager = CredentialManager(keychain: mockKeychain)
    }
    
    override func tearDown() async throws {
        await mockKeychain.reset()
        credentialManager = nil
    }
    
    func testCredentialStorage() async throws {
        let testCredential = "test_credential"
        let identifier = "test_id"
        
        try await credentialManager.store(credential: testCredential, withIdentifier: identifier)
        let storedCredential = try await credentialManager.retrieve(withIdentifier: identifier)
        XCTAssertEqual(storedCredential, testCredential, "Retrieved credential should match stored credential")
    }
    
    func testCredentialDeletion() async throws {
        let testCredential = "test_credential"
        let identifier = "test_id"
        
        try await credentialManager.store(credential: testCredential, withIdentifier: identifier)
        try await credentialManager.delete(withIdentifier: identifier)
        
        do {
            _ = try await credentialManager.retrieve(withIdentifier: identifier)
            XCTFail("Should throw error for deleted credential")
        } catch {
            XCTAssertTrue(error is SecurityError, "Error should be a SecurityError")
        }
    }
    
    func testCredentialUpdate() async throws {
        let identifier = "test_id"
        let originalCredential = "original_credential"
        let updatedCredential = "updated_credential"
        
        try await credentialManager.store(credential: originalCredential, withIdentifier: identifier)
        try await credentialManager.store(credential: updatedCredential, withIdentifier: identifier)
        
        let retrievedCredential = try await credentialManager.retrieve(withIdentifier: identifier)
        XCTAssertEqual(retrievedCredential, updatedCredential, "Retrieved credential should match updated credential")
    }
    
    func testNonexistentCredential() async throws {
        do {
            _ = try await credentialManager.retrieve(withIdentifier: "nonexistent")
            XCTFail("Should throw error for nonexistent credential")
        } catch {
            XCTAssertTrue(error is SecurityError, "Error should be a SecurityError")
        }
    }
    
    func testCredentialExists() async throws {
        let identifier = "test_id"
        let credential = "test_credential"
        
        let exists = await credentialManager.exists(withIdentifier: identifier)
        XCTAssertFalse(exists, "Credential should not exist initially")
        
        try await credentialManager.store(credential: credential, withIdentifier: identifier)
        let existsAfterStore = await credentialManager.exists(withIdentifier: identifier)
        XCTAssertTrue(existsAfterStore, "Credential should exist after storage")
        
        try await credentialManager.delete(withIdentifier: identifier)
        let existsAfterDelete = await credentialManager.exists(withIdentifier: identifier)
        XCTAssertFalse(existsAfterDelete, "Credential should not exist after deletion")
    }
}
