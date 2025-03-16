@testable import CryptoTypes
@testable import CryptoTypesServices
import Foundation
import XCTest

/**
 * Tests for the CredentialManager class
 *
 * These tests verify that the CredentialManager correctly handles credential
 * operations including saving, retrieving, and deleting credentials.
 */
final class CredentialManagerTests: XCTestCase {
    // Mock keychain for testing
    class MockKeychainAccess: KeychainAccessProtocol {
        var savedCredentials: [String: Credentials] = [:]
        var expectedResults: [String: Result<Credentials?, Error>] = [:]
        var deleteResults: [String: Bool] = [:]
        var verificationLog: [String] = []

        func saveCredentials(_ credentials: Credentials) -> Bool {
            verificationLog.append("saveCredentials: \(credentials.server)")
            savedCredentials[credentials.server] = credentials
            return true
        }

        func retrieveCredentials(server: String) -> Result<Credentials?, Error> {
            verificationLog.append("retrieveCredentials: \(server)")
            return expectedResults[server] ?? .success(nil)
        }

        func deleteCredentials(server: String) -> Bool {
            verificationLog.append("deleteCredentials: \(server)")
            return deleteResults[server] ?? false
        }

        // Helper methods for setting up expectations
        func expectRetrieveCredentials(server: String, result: Result<Credentials?, Error>) {
            expectedResults[server] = result
        }

        func expectDeleteCredentials(server: String, result: Bool) {
            deleteResults[server] = result
        }

        // Verify expected calls were made
        func verify() {
            // This method would normally compare actual calls to expected calls
            // For simplicity in this test, we'll just ensure calls were logged
            XCTAssertFalse(verificationLog.isEmpty, "No keychain operations were performed")
        }
    }

    private var credentialManager: CredentialManager!
    private var mockKeychain: MockKeychainAccess!

    override func setUp() {
        super.setUp()
        mockKeychain = MockKeychainAccess()
        credentialManager = CredentialManager(keychainAccess: mockKeychain)
    }

    /**
     * Test saving credentials successfully
     */
    func testSaveCredentials() async throws {
        // Given
        let testCredentials = Credentials(
            username: "testuser",
            password: "testpassword",
            server: "testserver"
        )

        // When
        let result = try await credentialManager.saveCredentials(testCredentials)

        // Then
        XCTAssertTrue(result, "Credential save operation should return true")
        XCTAssertEqual(mockKeychain.savedCredentials["testserver"]?.username, "testuser",
                       "Username should be saved correctly")
        XCTAssertEqual(mockKeychain.savedCredentials["testserver"]?.password, "testpassword",
                       "Password should be saved correctly")
        mockKeychain.verify()
    }

    /**
     * Test retrieving credentials successfully
     */
    func testRetrieveCredentials() async throws {
        // Given
        let expectedCredentials = Credentials(
            username: "testuser",
            password: "testpassword",
            server: "testserver"
        )

        mockKeychain.expectRetrieveCredentials(
            server: "testserver",
            result: .success(expectedCredentials)
        )

        // When
        let credentials = try await credentialManager.retrieveCredentials(server: "testserver")

        // Then
        XCTAssertEqual(credentials.username, expectedCredentials.username,
                       "Retrieved username should match expected")
        XCTAssertEqual(credentials.password, expectedCredentials.password,
                       "Retrieved password should match expected")
        XCTAssertEqual(credentials.server, expectedCredentials.server,
                       "Retrieved server should match expected")
        mockKeychain.verify()
    }

    /**
     * Test retrieving credentials when none exist
     */
    func testRetrieveNonExistentCredentials() async {
        // Given
        mockKeychain.expectRetrieveCredentials(server: "nonexistent", result: .success(nil))

        // When/Then
        do {
            _ = try await credentialManager.retrieveCredentials(server: "nonexistent")
            XCTFail("Should throw an error when credentials don't exist")
        } catch {
            // Verify error is properly thrown
            XCTAssertTrue(error is CredentialError, "Should throw CredentialError")
        }
        mockKeychain.verify()
    }

    /**
     * Test retrieving credentials when an error occurs
     */
    func testRetrieveCredentialsFailure() async {
        // Given
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        mockKeychain.expectRetrieveCredentials(
            server: "testserver",
            result: .failure(expectedError)
        )

        // When/Then
        do {
            _ = try await credentialManager.retrieveCredentials(server: "testserver")
            XCTFail("Should have thrown an error")
        } catch {
            // Verify error is properly forwarded
            XCTAssertEqual((error as NSError).domain, expectedError.domain,
                           "Error domain should be preserved")
            XCTAssertEqual((error as NSError).code, expectedError.code,
                           "Error code should be preserved")
        }
        mockKeychain.verify()
    }

    /**
     * Test deleting credentials successfully
     */
    func testDeleteCredentials() async throws {
        // Given
        mockKeychain.expectDeleteCredentials(server: "testserver", result: true)

        // When
        let result = try await credentialManager.deleteCredentials(server: "testserver")

        // Then
        XCTAssertTrue(result, "Delete operation should return true")
        mockKeychain.verify()
    }

    /**
     * Test deleting credentials that fail
     */
    func testDeleteCredentialsFailing() async {
        // Given
        mockKeychain.expectDeleteCredentials(server: "testserver", result: false)

        // When/Then
        do {
            let result = try await credentialManager.deleteCredentials(server: "testserver")
            XCTAssertFalse(result, "Delete operation should return false")
        } catch {
            XCTFail("Should not throw error on deletion failure, just return false")
        }
        mockKeychain.verify()
    }
}
