import Foundation
import SecurityBridge
@testable import SecurityInterfaces
import SecurityInterfacesBase
import SecurityProtocolsCore
import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Tests for the refactored SecurityProviderFactory implementation
/// Verifies that the new adapter-based approach works correctly
class ProviderFactoryAdapterTests: XCTestCase {
    // MARK: - Basic Factory Tests

    func testFactoryCreateModernProvider() {
        // Create a configuration for a modern provider
        let config = ProviderFactoryConfiguration(
            useModernProtocols: true,
            useMockServices: true
        )

        // Create a provider using the adapter
        let provider = SecurityProviderAdapter.shared.createSecurityProvider(config: config)

        // Verify we got a valid provider
        XCTAssertNotNil(provider)
        XCTAssertTrue(provider is ModernSecurityProviderAdapter)
    }

    func testFactoryCreateLegacyProvider() {
        // Create a configuration for a legacy provider
        let config = ProviderFactoryConfiguration(
            useModernProtocols: false,
            useMockServices: true
        )

        // Create a provider using the adapter
        let provider = SecurityProviderAdapter.shared.createSecurityProvider(config: config)

        // Verify we got a valid provider
        XCTAssertNotNil(provider)
        XCTAssertTrue(provider is LegacySecurityProviderAdapter)
    }

    // MARK: - Backwards Compatibility Tests

    func testOldFactoryStillWorks() {
        // Create the factory
        let factory = StandardSecurityProviderFactory()

        // Get a provider using default configuration
        let provider = factory.createDefaultSecurityProvider()

        // Verify we got a valid provider
        XCTAssertNotNil(provider)
        XCTAssertNotNil(provider.cryptoService)
        XCTAssertNotNil(provider.keyManager)
    }

    func testStaticFactoryMethodsStillWork() async {
        do {
            // Use the old static factory method
            let provider = try await StandardSecurityProviderFactory.createProvider(ofType: "default")

            // Verify we got a valid provider
            XCTAssertNotNil(provider)
        } catch {
            XCTFail("Failed to create provider: \(error)")
        }
    }

    func testSynchronousFactoryMethodsStillWork() {
        // Use the synchronous factory method
        let provider = SecurityProviderFactory.createSynchronousProvider(ofType: "test")

        // Verify we got a valid provider
        XCTAssertNotNil(provider)
        XCTAssertNotNil(provider.cryptoService)
        XCTAssertNotNil(provider.keyManager)
    }

    // MARK: - Helper Method Tests

    func testGenerateSecurityOptions() {
        // Create a configuration
        let config = ProviderFactoryConfiguration(
            useModernProtocols: true,
            useMockServices: false,
            securityLevel: .high,
            requiresAuthentication: true,
            debugMode: false,
            options: ["customOption": "value"]
        )

        // Generate options
        let options = StandardSecurityProviderFactory.generateSecurityOptions(config: config)

        // Verify options
        XCTAssertEqual(options["securityLevel"], "3")
        XCTAssertEqual(options["timeout"], "30.0")
        XCTAssertEqual(options["testMode"], "false")
        XCTAssertEqual(options["allowUnsafeOperations"], "true")
        XCTAssertEqual(options["retryCount"], "5")
        XCTAssertEqual(options["customOption"], "value")
    }

    func testCreateSecureConfig() {
        // Create the factory
        let factory = StandardSecurityProviderFactory()

        // Create options
        let options: [String: String] = [
            "algorithm": "RSA",
            "keySizeInBits": "2048",
            "iterations": "1000",
            "keyIdentifier": "test-key",
        ]

        // Create a config
        let config = factory.createSecureConfig(options: options)

        // Verify config
        XCTAssertEqual(config.algorithm, "RSA")
        XCTAssertEqual(config.keySizeInBits, 2048)
        XCTAssertEqual(config.iterations, 1000)
        XCTAssertEqual(config.keyIdentifier, "test-key")
    }

    // MARK: - Integration Tests

    func testCreateProviderByType() async {
        do {
            // Test different provider types
            let standardProvider = try await StandardSecurityProviderFactory.createProvider(type: .standard)
            XCTAssertNotNil(standardProvider)

            let testProvider = try await StandardSecurityProviderFactory.createProvider(type: .test)
            XCTAssertNotNil(testProvider)

            let legacyProvider = try await StandardSecurityProviderFactory.createProvider(type: .legacy)
            XCTAssertNotNil(legacyProvider)

            // Compare providers - they should be different instances
            XCTAssertFalse(standardProvider === testProvider)
            XCTAssertFalse(standardProvider === legacyProvider)
            XCTAssertFalse(testProvider === legacyProvider)
        } catch {
            XCTFail("Failed to create provider: \(error)")
        }
    }
}
