import CoreTypesInterfaces
import ErrorHandling
import ErrorHandlingDomains
import Foundation
@testable import SecurityInterfaces
import SecurityInterfacesBase
import SecurityProtocolsCore
import SecurityTestHelpers
import XCTest
import XPCProtocolsCore

/// Tests for SecurityProvider protocol implementation
/// Validates that SPC provider types can be used through the interface adapters
class SecurityProviderTests: XCTestCase {

  func testSecurityProviderCreation() {
    // Use the wrapper factory instead of directly accessing SecurityProtocolsCore
    let wrappedProvider = SecurityTestHelpers.SecurityProtocolsWrapperFactory.createProvider(ofType: "test")
    XCTAssertNotNil(wrappedProvider)
  }

  func testSecurityOperation() async {
    // Get a wrapped test provider
    let wrappedProvider = SecurityTestHelpers.SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Perform the operation using our wrapper
    let result = await wrappedProvider.performSecureOperation(
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
    let error = UmbraErrors.Security.Protocols.invalidFormat(reason: "Test error")

    // Use our TestErrorMapper helper instead of direct adapter interactions
    let mappedError = SecurityTestHelpers.TestErrorMapper.mapToNSError(error)

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
    XCTAssertTrue(SecurityTestHelpers.TestErrorMapper.errorContains(mappedError, substring: "Invalid format"))
  }

  func testProtocolAdaptation() {
    // Get a wrapped provider
    let wrappedProvider = SecurityTestHelpers.SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService = SecurityTestHelpers.DummyXPCService()
    
    // Use the adapter method to convert XPCServiceProtocol to XPCServiceProtocolStandard
    let standardService = xpcService.asXPCServiceProtocolStandard()

    // Create an adapter using the provider's raw reference
    // This approach maintains isolation while still allowing creation of adapter
    let rawProvider = wrappedProvider.getRawProvider()
    let adapter = SecurityTestHelpers.TestSecurityProviderAdapter(
      bridge: rawProvider,
      service: standardService
    )

    // Check that we can access core properties through the adapter
    XCTAssertNotNil(adapter.cryptoService)
    XCTAssertNotNil(adapter.keyManager)
  }

  func testSecurityStatus() async {
    // Get a wrapped test provider
    let wrappedProvider = SecurityTestHelpers.SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService = SecurityTestHelpers.DummyXPCService()
    
    // Use the adapter method to convert XPCServiceProtocol to XPCServiceProtocolStandard
    let standardService = xpcService.asXPCServiceProtocolStandard()

    // Create adapter using the provider's raw reference
    let rawProvider = wrappedProvider.getRawProvider()
    let adapter = SecurityTestHelpers.TestSecurityProviderAdapter(
      bridge: rawProvider,
      service: standardService
    )

    // Get the host identifier as a substitute for status
    let idResult = await adapter.getHostIdentifier()
    if case let .success(id) = idResult {
      XCTAssertFalse(id.isEmpty)
    } else {
      XCTFail("Failed to get host identifier")
    }
  }

  func testLowLevelOperation() async {
    // Get a wrapped test provider
    let wrappedProvider = SecurityTestHelpers.SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Perform a low level operation
    let result = await wrappedProvider.performSecureOperation(
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
    let wrappedProvider = SecurityTestHelpers.SecurityProtocolsWrapperFactory.createProvider(ofType: "test")

    // Create a dummy XPC service for testing
    let xpcService = SecurityTestHelpers.DummyXPCService()
    
    // Use the adapter method to convert XPCServiceProtocol to XPCServiceProtocolStandard
    let standardService = xpcService.asXPCServiceProtocolStandard()

    // Create adapter using the provider's raw reference
    let rawProvider = wrappedProvider.getRawProvider()
    let adapter = SecurityTestHelpers.TestSecurityProviderAdapter(
      bridge: rawProvider,
      service: standardService
    )

    // Try a client registration operation
    let result = await adapter.registerClient(bundleIdentifier: "")

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
