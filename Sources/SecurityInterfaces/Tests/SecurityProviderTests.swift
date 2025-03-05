import Foundation
@testable import SecurityInterfaces
import XPCProtocolsCoreimport SecurityInterfacesBase
import UmbraCoreTypesimport XPCProtocolsCoreimport XPCProtocolsCoreimport SecurityProtocolsCore
import UmbraCoreTypesimport XCTest

/// Test suite for the SecurityProvider implementation
class SecurityProviderTests: XCTestCase {

  func testSecurityProviderCreation() throws {
    // Test creation of a standard provider
    let provider=try SecurityProviderFactory.createProvider(ofType: "test")
    XCTAssertNotNil(provider)
  }

  func testSecurityOperation() async throws {
    // Get a test provider
    let provider=try SecurityProviderFactory.createProvider(ofType: "test")

    // Set up test parameters
    let parameters: [String: Any]=[
      "data": Data("Test data".utf8),
      "key": "test-key",
      "algorithm": "AES-256"
    ]

    // Test encrypt operation
    let result=try await provider.performSecurityOperation(
      operation: .encrypt,
      parameters: parameters
    )

    // Verify result
    XCTAssertTrue(result.success)
    XCTAssertNotNil(result.data)
  }

  func testErrorMapping() {
    // Create a SecurityError from the original module
    let error=SecurityError.encryptionFailed(reason: "Test error")

    // Map it using our isolated mapping function
    let mappedError=mapSPCError(error)

    // All errors in Swift bridge to NSError
    let nsError=mappedError as NSError
    let description=nsError.localizedDescription

    // Verify the error message contains our expected text
    XCTAssertTrue(
      description.contains("Encryption failed"),
      "Expected error description to contain 'Encryption failed' but got: \(description)"
    )

    // Verify the domain is correct
    XCTAssertEqual(nsError.domain, "com.umbracore.SecurityProtocolsCore")
  }

  /// Test to specifically verify that namespace resolution is working correctly
  func testNamespaceResolution() throws {
    // Test 1: Verify SecurityError types from different modules
    // Create a SecurityProtocolsCore error using the imported type
    let spcError=SecurityError.encryptionFailed(reason: "SPC error")

    // Test 2: Create a SecurityError using our local type
    let interfaceError=SecurityInterfacesError.operationFailed("Interface error")

    // Test 3: Verify they're distinct types
    XCTAssertEqual(String(describing: type(of: spcError)), "SecurityError")
    XCTAssertEqual(String(describing: type(of: interfaceError)), "SecurityInterfacesError")
  }

  /// Test to verify subpackage-based type resolution
  func testSubpackageTypeResolution() async throws {
    // Create provider through alias type
    let bridge=SPCProviderFactory.createProvider(ofType: "test")

    // Create adapter using the SPCProvider type
    let adapter=SecurityProviderAdapter(bridge: bridge)

    // Verify adapter was created successfully
    let status=await adapter.getSecurityStatus()
    XCTAssertTrue(status.isActive)

    // Test passing complex operation to ensure cross-module types work
    let result=try await adapter.performSecurityOperation(
      operation: .encrypt,
      parameters: [
        "data": Data("Test".utf8),
        "key": "test-key"
      ]
    )

    XCTAssertTrue(result.success)
  }

  func testSecurityStatus() async {
    // Get a test provider
    let provider=try! SecurityProviderFactory.createProvider(ofType: "test")

    // Get the security status
    let status=await provider.getSecurityStatus()

    // Verify it has the expected properties
    XCTAssertTrue(status.isActive)
    XCTAssertEqual(status.statusCode, 200)
    XCTAssertTrue(status.statusMessage.contains("active"))
  }

  func testLowLevelOperation() async throws {
    // Get a test provider
    let provider=try SecurityProviderFactory.createProvider(ofType: "test")

    // Set up parameters
    let parameters: [String: Any]=[
      "data": Data("Test data".utf8),
      "key": "test-key"
    ]

    // Call the security operation with the renamed method
    let result=try await provider.performSecurityOperation(
      operation: .encrypt,
      parameters: parameters
    )

    XCTAssertTrue(result.success)
  }

  func testErrorHandling() async {
    // Get a test provider
    let provider=try! SecurityProviderFactory.createProvider(ofType: "test")

    // Try an invalid operation that should return .failure(.custom(message: "an error
"))    do {
      _=try await provider.resetSecurityData()
      XCTFail("Should have thrown an error")
    } catch {
      // Verify we got the expected error
      XCTAssertTrue(error is SecurityInterfacesError)
      if
        let secError=error as? SecurityInterfacesError,
        case let .operationFailed(message)=secError
      {
        XCTAssertTrue(message.contains("not supported"))
      } else {
        XCTFail("Unexpected error type")
      }
    }
  }
}
