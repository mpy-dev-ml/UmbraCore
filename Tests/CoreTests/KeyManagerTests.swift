@testable import Core
import XCTest

final class KeyManagerTests: XCTestCase {
    var keyManager: KeyManager!

    override func setUp() async throws {
        keyManager = KeyManager()
    }

    override func tearDown() async throws {
        keyManager = nil
    }

    func testImplementationSelection() async throws {
        // Test ResticBar implementation selection
        let resticBarContext = SecurityContext(applicationType: .resticBar)
        let resticBarImpl = await keyManager.selectImplementation(for: resticBarContext)
        XCTAssertEqual(resticBarImpl, .cryptoKit, "ResticBar should use CryptoKit")

        // Test Rbum implementation selection
        let rbumContext = SecurityContext(applicationType: .rbum)
        let rbumImpl = await keyManager.selectImplementation(for: rbumContext)
        XCTAssertEqual(rbumImpl, .cryptoSwift, "Rbum should use CryptoSwift")

        // Test Rbx implementation selection
        let rbxContext = SecurityContext(applicationType: .rbx)
        let rbxImpl = await keyManager.selectImplementation(for: rbxContext)
        XCTAssertEqual(rbxImpl, .cryptoSwift, "Rbx should use CryptoSwift")
    }

    func testKeyGeneration() async throws {
        let context = SecurityContext(applicationType: .resticBar)
        let keyId = try await keyManager.generateKey(for: context)
        XCTAssertNotNil(keyId, "Key generation should succeed")
    }

    func testKeyValidation() async throws {
        // Generate a key first
        let context = SecurityContext(applicationType: .resticBar)
        let keyId = try await keyManager.generateKey(for: context)

        // Validate the key
        let result = try await keyManager.validateKey(id: keyId)
        XCTAssertTrue(result.isValid, "Newly generated key should be valid")
    }

    func testKeyNotFound() async throws {
        let unknownId = KeyIdentifier(id: "unknown")

        do {
            _ = try await keyManager.validateKey(id: unknownId)
            XCTFail("Should throw keyNotFound error")
        } catch KeyManagerError.keyNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
