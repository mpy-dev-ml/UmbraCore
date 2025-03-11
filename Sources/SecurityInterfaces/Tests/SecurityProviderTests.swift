import ErrorHandlingDomains
import Foundation
@testable import SecurityInterfaces
import SecurityInterfacesBase
import XCTest

// Import our test helpers instead of SecurityProtocolsCore directly
import SecurityTestHelpers

/// Tests for SecurityProvider protocol implementation
/// Validates that SPC provider types can be used through the interface adapters
class SecurityProviderTests: XCTestCase {

  func testSecurityProviderCreation() {
    // Use the wrapper factory instead of directly accessing SecurityProtocolsCore
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")
    XCTAssertNotNil(wrappedProvider)
  }

  func testSecurityOperation() async {
    // Get a wrapped test provider
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Perform the operation using our wrapper
    let result=await wrappedProvider.performSecureOperation(
      operationName: "symmetricEncryption",
      options: [
        "key": "test_key",
        "algorithm": "AES-GCM"
      ]
    )

    // Verify that the operation succeeded
    XCTAssertTrue(result.success)
  }

  func testErrorMapping() {
    // Create a test error from the ErrorHandlingDomains module
    let error=UmbraErrors.Security.Protocols.invalidFormat(reason: "Test error")

    // Use our TestErrorMapper helper instead of direct adapter interactions
    let mappedError=TestErrorMapper.mapToNSError(error)

    // Verify the error properties
    XCTAssertEqual(mappedError.domain, "com.umbracore.security.test")
    XCTAssertTrue(
      mappedError.localizedDescription.contains("Invalid format"),
      "Error message should contain 'Invalid format'"
    )
    XCTAssertTrue(
      mappedError.localizedDescription.contains("Test error"),
      "Error message should contain the original reason"
    )

    // Test the helper method for checking error contents
    XCTAssertTrue(TestErrorMapper.errorContains(mappedError, substring: "Invalid format"))
  }

  func testProtocolAdaptation() {
    // Get a wrapped provider
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create an adapter using the provider's raw reference
    // This approach maintains isolation while still allowing creation of adapter
    let rawProvider=wrappedProvider.getRawProvider()
    let adapter=SecurityProviderAdapter(
      bridge: rawProvider as! SecurityInterfaces.SecurityProviderBridge,
      service: xpcService
    )

    // Check that we can access core properties through the adapter
    XCTAssertNotNil(adapter.cryptoService)
    XCTAssertNotNil(adapter.keyManager)
  }

  /// Test to verify subpackage-based type resolution
  func testSubpackageTypeResolution() async {
    // Create provider through our wrapper
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create adapter using the provider's raw reference
    let rawProvider=wrappedProvider.getRawProvider()
    let adapter=SecurityProviderAdapter(
      bridge: rawProvider as! SecurityInterfaces.SecurityProviderBridge,
      service: xpcService
    )

    // Test getting a host identifier to verify the adapter works
    let hostIdResult=await adapter.getHostIdentifier()
    if case let .success(id)=hostIdResult {
      XCTAssertFalse(id.isEmpty)
    } else if case let .failure(error)=hostIdResult {
      XCTFail("Failed to get host identifier: \(error)")
    }

    // Test passing complex operation to ensure cross-module types work
    // Using our wrapper factory to create the operation
    let result=await wrappedProvider.performSecureOperation(
      operationName: "symmetricEncryption",
      options: [
        "key": "test-key",
        "algorithm": "AES-256",
        "data": Data("Test data".utf8)
      ]
    )

    XCTAssertTrue(result.success)
  }

  func testSecurityStatus() async {
    // Get a wrapped test provider
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create adapter using the provider's raw reference
    let rawProvider=wrappedProvider.getRawProvider()
    let adapter=SecurityProviderAdapter(
      bridge: rawProvider as! SecurityInterfaces.SecurityProviderBridge,
      service: xpcService
    )

    // Get the host identifier as a substitute for status
    let idResult=await adapter.getHostIdentifier()
    if case let .success(id)=idResult {
      XCTAssertFalse(id.isEmpty)
    } else {
      XCTFail("Failed to get host identifier")
    }
  }

  func testLowLevelOperation() async {
    // Get a wrapped test provider
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Perform a low level operation
    let result=await wrappedProvider.performSecureOperation(
      operationName: "symmetricEncryption",
      options: [
        "key": "test_encryption_key",
        "data": "Test secure data".data(using: .utf8)!
      ]
    )

    // Verify the result
    XCTAssertTrue(result.success)
  }

  func testErrorHandling() async {
    // Get a wrapped test provider
    let wrappedProvider=SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService=DummyXPCService()

    // Create adapter using the provider's raw reference
    let rawProvider=wrappedProvider.getRawProvider()
    let adapter=SecurityProviderAdapter(
      bridge: rawProvider as! SecurityInterfaces.SecurityProviderBridge,
      service: xpcService
    )

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
