@testable import Core
import XCTest

/// Tests for the KeyManager class that handles cryptographic key operations
final class KeyManagerTests: XCTestCase {
    // MARK: - Properties

    private var keyManager: KeyManager!

    // MARK: - Test Lifecycle

    override func setUp() async throws {
        keyManager = KeyManager()
    }

    override func tearDown() async throws {
        keyManager = nil
    }

    // MARK: - Implementation Selection Tests

    /// Tests that the correct cryptographic implementation is selected for different application types
    func testImplementationSelection() async throws {
        // Test ResticBar implementation selection
        let resticBarContext = SecurityContext(applicationType: .resticBar)
        let resticBarImpl = await keyManager.selectImplementation(for: resticBarContext)
        XCTAssertEqual(
            resticBarImpl,
            .cryptoKit,
            "ResticBar should use CryptoKit implementation"
        )

        // Test Rbum implementation selection
        let rbumContext = SecurityContext(applicationType: .rbum)
        let rbumImpl = await keyManager.selectImplementation(for: rbumContext)
        XCTAssertEqual(
            rbumImpl,
            .cryptoSwift,
            "Rbum should use CryptoSwift implementation"
        )

        // Test Rbx implementation selection
        let rbxContext = SecurityContext(applicationType: .rbx)
        let rbxImpl = await keyManager.selectImplementation(for: rbxContext)
        XCTAssertEqual(
            rbxImpl,
            .cryptoSwift,
            "Rbx should use CryptoSwift implementation"
        )
    }

    // MARK: - Key Operation Tests

    /// Tests successful key generation for a given security context
    func testKeyGenerationSucceeds() async throws {
        let context = SecurityContext(applicationType: .resticBar)
        let keyId = try await keyManager.generateKey(for: context)
        XCTAssertNotNil(
            keyId,
            "Key generation should succeed and return a valid identifier"
        )
    }

    /// Tests that a newly generated key passes validation
    func testKeyValidationSucceeds() async throws {
        // Generate a key first
        let context = SecurityContext(applicationType: .resticBar)
        let keyId = try await keyManager.generateKey(for: context)

        // Validate the key
        let result = try await keyManager.validateKey(id: keyId)
        XCTAssertTrue(
            result.isValid,
            "Newly generated key should pass validation"
        )
    }

    /// Tests that attempting to validate a non-existent key throws the expected error
    func testKeyValidationFailsForNonExistentKey() async throws {
        let unknownId = KeyIdentifier(id: "unknown")

        do {
            _ = try await keyManager.validateKey(id: unknownId)
            XCTFail("Should throw keyNotFound error for non-existent key")
        } catch KeyManagerError.keyNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
