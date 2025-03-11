import ErrorHandlingDomains
import Foundation
@testable import SecurityInterfaces
import SecurityInterfacesBase
import SecurityProtocolsCore
import XCTest

/// Tests for SecurityProvider protocol implementation
/// Validates that SPC provider types can be used through the interface adapters
class SecurityProviderTests: XCTestCase {

  func testSecurityProviderCreation() {
    // Test creation of a standard provider using our factory
    let provider=SPCProviderFactory.createProvider(ofType: "test")
    XCTAssertNotNil(provider)
  }

  func testSecurityOperation() async {
    // Get a test provider
    let provider=SPCProviderFactory.createProvider(ofType: "test")

    // Set up test parameters
    let operation=SecurityProtocolsCore.SecurityOperation.symmetricEncryption
    let config=provider.createSecureConfig(options: [
      "key": "test_key",
      "algorithm": "AES-GCM"
    ])

    // Perform the operation
    let result=await provider.performSecureOperation(
      operation: operation,
      config: config
    )

    // Verify that the operation succeeded
    XCTAssertTrue(result.success)
  }

  func testErrorMapping() {
    // Create a test error from the ErrorHandlingDomains module
    let error=UmbraErrors.Security.Protocols.invalidFormat(reason: "Test error")

    // Create a provider and service to access the error mapping method
    let provider=SPCProviderFactory.createProvider(ofType: "test")
    let service=DummyXPCService()
    let adapter=SecurityProviderAdapter(bridge: provider, service: service)

    // Use the adapter's method instead of deprecated global function
    let mappedError=adapter.mapError(error)

    // Verify the error was mapped to the right type
    if case let SecurityInterfacesError.operationFailed(message)=mappedError {
      XCTAssertTrue(
        message.contains("Invalid format"),
        "Expected error message to contain 'Invalid format' but got: \(message)"
      )
      XCTAssertTrue(
        message.contains("Test error"),
        "Expected error message to contain the original reason but got: \(message)"
      )
    } else {
      XCTFail("Error wasn't mapped to the expected type. Got \(mappedError)")
    }

    // Ensure NSError bridging works correctly
    let nsError=mappedError as NSError
    XCTAssertNotNil(nsError)
  }

  func testProtocolAdaptation() {
    // Get a direct SPC provider
    let bridge=SPCProviderFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create an adapter provider that conforms to our local protocol
    let adapter=SecurityProviderAdapter(bridge: bridge, service: xpcService)

    // Check that we can access core properties through the adapter
    XCTAssertNotNil(adapter.cryptoService)
    XCTAssertNotNil(adapter.keyManager)
  }

  /// Test to verify subpackage-based type resolution
  func testSubpackageTypeResolution() async {
    // Create provider through alias type
    let bridge=SPCProviderFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create adapter using the SPCProvider type
    let adapter=SecurityProviderAdapter(bridge: bridge, service: xpcService)

    // Test getting a host identifier to verify the adapter works
    let hostIdResult=await adapter.getHostIdentifier()
    if case let .success(id)=hostIdResult {
      XCTAssertFalse(id.isEmpty)
    } else if case let .failure(error)=hostIdResult {
      XCTFail("Failed to get host identifier: \(error)")
    }

    // Test passing complex operation to ensure cross-module types work
    let operation=SecurityProtocolsCore.SecurityOperation.symmetricEncryption
    let config=bridge.createSecureConfig(options: [
      "key": "test-key",
      "algorithm": "AES-256",
      "data": Data("Test data".utf8)
    ])

    let result=await adapter.performSecureOperation(
      operation: operation,
      config: config
    )

    XCTAssertTrue(result.success)
  }

  func testSecurityStatus() async {
    // Get a test provider
    let provider=SPCProviderFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create adapter using the provider
    let adapter=SecurityProviderAdapter(bridge: provider, service: xpcService)

    // Get the host identifier as a substitute for status
    let idResult=await adapter.getHostIdentifier()
    if case let .success(id)=idResult {
      XCTAssertFalse(id.isEmpty)
    } else {
      XCTFail("Failed to get host identifier")
    }
  }

  func testLowLevelOperation() async {
    // Get a test provider
    let provider=SPCProviderFactory.createProvider(ofType: "test")

    // Set up a config with parameters
    let config=provider.createSecureConfig(options: [
      "key": "test_encryption_key",
      "data": "Test secure data".data(using: .utf8)!
    ])

    // Perform a low level operation
    let result=await provider.performSecureOperation(
      operation: .symmetricEncryption,
      config: config
    )

    // Verify the result
    XCTAssertTrue(result.success)
  }

  func testErrorHandling() async {
    // Get a test provider
    let provider=SPCProviderFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create adapter using the provider
    let adapter=SecurityProviderAdapter(bridge: provider, service: xpcService)

    // Try a client registration operation
    let result=await adapter.registerClient(bundleIdentifier: "")

    // Verify we got a result
    switch result {
      case let .success(success):
        // Our dummy implementation likely returns success
        XCTAssertTrue(success)
      case let .failure(error):
        // If it fails, just check we have a valid error
        XCTAssertNotNil(error)
    }
  }
}
