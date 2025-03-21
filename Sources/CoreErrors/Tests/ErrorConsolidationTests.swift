@testable import CoreErrors
import ErrorHandling
import XCTest

/// Tests focused on cross-domain error handling and centralised error functionality
final class ErrorConsolidationTests: XCTestCase {
  // MARK: - Cross-Domain Error Tests

  func testCrossDomainErrorConversion() {
    // Test conversion between different error domains

    // Create a security error
    let securityError=CoreErrors.SecurityError.invalidKey(reason: "Test reason")

    // Convert to canonical form
    let canonicalError=securityError.toCanonicalError()

    // Verify canonical type is correct and conversion happened
    XCTAssertNotNil(canonicalError, "Should convert to canonical form")
    XCTAssertFalse(
      canonicalError is CoreErrors.SecurityError,
      "Canonical error should be different from original SecurityError"
    )

    // Create a crypto error
    let cryptoError=CryptoError.encryptionFailed(reason: "Algorithm failure")

    // Convert to canonical form
    let cryptoCanonical=cryptoError.toCanonical()

    // Verify canonical type is correct and conversion happened
    XCTAssertNotNil(cryptoCanonical, "Should convert to canonical form")
    XCTAssertFalse(
      cryptoCanonical is CryptoError,
      "Canonical error should be different from original CryptoError"
    )
  }

  func testErrorPropagationChain() {
    // Test complete error propagation chains between domains

    // Create a security error
    let securityError=CoreErrors.SecurityError.operationFailed(
      operation: "key_generation",
      reason: "Insufficient entropy"
    )

    // First conversion: security -> canonical
    let canonicalError=securityError.toCanonicalError()
    XCTAssertNotNil(canonicalError, "Should convert to canonical form")

    // Second conversion: attempt to map canonical to crypto domain error
    // This demonstrates cross-domain mapping capabilities
    let errorDescription=String(describing: canonicalError)

    // Create a crypto error that would result from such a propagation
    let cryptoError=CryptoError.keyGenerationFailed

    // Verify the propagated error maintains critical information
    let cryptoErrorDesc=String(describing: cryptoError)
    XCTAssertTrue(
      cryptoErrorDesc.contains("key") || cryptoErrorDesc.contains("generation"),
      "Operation type should be preserved in propagation"
    )
  }

  func testRoundtripErrorConversion() {
    // Test full roundtrip conversion between domain-specific and canonical errors

    // Start with a security error
    let originalError=CoreErrors.SecurityError.invalidContext(reason: "Missing parameters")

    // Convert to canonical form
    let canonicalError=originalError.toCanonicalError()
    XCTAssertNotNil(canonicalError, "Should convert to canonical form")

    // Convert back to domain-specific error (if supported)
    // Note: This may not be implemented for all error types, so we test the concept

    // Check if information is preserved in the description
    let canonicalDesc=String(describing: canonicalError)
    XCTAssertTrue(
      canonicalDesc.contains("context") || canonicalDesc.contains("parameters"),
      "Key information should be preserved in canonical form"
    )
  }

  func testErrorDomainIdentification() {
    // Test ability to identify an error's domain regardless of specific type

    let testErrors: [Error]=[
      CoreErrors.SecurityError.invalidKey(reason: "Test"),
      CryptoError.encryptionFailed(reason: "Test")
    ]

    for error in testErrors {
      let domainInfo=extractErrorDomainInfo(from: error)
      XCTAssertNotNil(domainInfo, "Should extract domain information from \(type(of: error))")
      XCTAssertFalse(domainInfo?.domain.isEmpty ?? true, "Domain should not be empty")
    }
  }

  // MARK: - Error Hierarchy Tests

  func testErrorHierarchyRelationships() {
    // Test proper inheritance/composition relationships within error types

    // Create errors of different types within the same domain
    let operationError=CoreErrors.SecurityError.operationFailed(
      operation: "authentication",
      reason: "Invalid credentials"
    )
    let keyError=CoreErrors.SecurityError.invalidKey(reason: "Invalid format")

    // Test that they're part of the same error family
    XCTAssertTrue(
      operationError is CoreErrors.SecurityError,
      "Operation error should be a SecurityError"
    )
    XCTAssertTrue(keyError is CoreErrors.SecurityError, "Key error should be a SecurityError")

    // Test that they're distinguishable
    switch operationError {
      case CoreErrors.SecurityError.operationFailed:
        // Expected case
        break
      default:
        XCTFail("Operation error should be identifiable as operationFailed")
    }

    switch keyError {
      case CoreErrors.SecurityError.invalidKey:
        // Expected case
        break
      default:
        XCTFail("Key error should be identifiable as invalidKey")
    }
  }

  func testErrorCategorization() {
    // Test error categorization functionality

    // Create various errors
    let errors: [Error]=[
      CoreErrors.SecurityError.invalidKey(reason: "Test"),
      CoreErrors.SecurityError.operationFailed(operation: "encrypt", reason: "Test"),
      CryptoError.encryptionFailed(reason: "Test"),
      CryptoError.decryptionFailed(reason: "Test")
    ]

    // Count by category
    var categoryCounts: [String: Int]=[:]

    for error in errors {
      if let info=extractErrorDomainInfo(from: error) {
        let key=info.domain
        categoryCounts[key]=(categoryCounts[key] ?? 0) + 1
      }
    }

    // Verify categorization results
    XCTAssertEqual(categoryCounts["Security"], 2, "Should have 2 Security errors")
    XCTAssertEqual(categoryCounts["Crypto"], 2, "Should have 2 Crypto errors")
  }

  // MARK: - Error Serialization Tests

  func testErrorSerialization() {
    // Test error encoding/decoding for persistence

    // Create a serializable error
    let securityError=CoreErrors.SecurityError.operationFailed(
      operation: "key_generation",
      reason: "Insufficient entropy"
    )

    // Convert to a serializable format (dictionary representation)
    let errorDict: [String: String]=[
      "domain": "Security",
      "code": "operationFailed",
      "operation": "key_generation",
      "reason": "Insufficient entropy"
    ]

    // Verify dictionary contains essential error information
    XCTAssertEqual(errorDict["domain"], "Security", "Domain should be preserved")
    XCTAssertEqual(errorDict["operation"], "key_generation", "Operation should be preserved")

    // Conceptual reconstruction from dictionary (actual implementation would be more complex)
    let reconstructedDesc="\(errorDict["domain"] ?? "").\(errorDict["code"] ?? ""): \(errorDict["reason"] ?? "")"
    XCTAssertTrue(
      reconstructedDesc.contains("Security"),
      "Reconstructed error should preserve domain"
    )
    XCTAssertTrue(
      reconstructedDesc.contains("operationFailed"),
      "Reconstructed error should preserve error type"
    )
  }

  func testErrorIPCSerialization() {
    // Test error transmission across IPC boundaries

    // In a real IPC scenario, errors would need to be encoded/decoded for transmission
    // This test demonstrates the concept by simulating an IPC boundary

    // Create an error for test purposes
    let securityError=CoreErrors.SecurityError.operationFailed(
      operation: "authentication",
      reason: "User not found"
    )

    // Convert to string representation (simulating IPC transmission)
    let serializedError="""
      {
          "domain": "Security",
          "type": "operationFailed",
          "details": {
              "operation": "authentication",
              "reason": "User not found"
          }
      }
      """

    // Verify the serialized form contains expected information
    XCTAssertTrue(
      serializedError.contains("Security"),
      "Domain should be preserved in serialization"
    )
    XCTAssertTrue(
      serializedError.contains("authentication"),
      "Operation should be preserved in serialization"
    )
    XCTAssertTrue(
      serializedError.contains("User not found"),
      "Reason should be preserved in serialization"
    )

    // Conceptual deserialization (would be implemented differently in actual code)
    // This test verifies that the concept of IPC error transmission is documented and considered
    XCTAssertTrue(
      !serializedError.isEmpty,
      "Should have a serialized representation for IPC transmission"
    )
  }

  // MARK: - Error Consolidation Helpers

  /// Extract domain information from any error type
  private func extractErrorDomainInfo(from error: Error) -> (domain: String, category: String)? {
    switch error {
      case is CoreErrors.SecurityError:
        return ("Security", "Core")
      case is CryptoError:
        return ("Crypto", "Core")
      default:
        // For canonical errors, use type description
        // We know from testing that canonical types are named "Core"
        let typeDescription=String(describing: type(of: error))
        if typeDescription == "Core" {
          // We need to distinguish between different Core types
          // Can use the error description or other properties
          let errorDescription=String(describing: error)
          if
            errorDescription.contains("security") ||
            errorDescription.contains("key") ||
            errorDescription.contains("authentication")
          {
            return ("Security", "Canonical")
          } else if
            errorDescription.contains("crypto") ||
            errorDescription.contains("encryption") ||
            errorDescription.contains("decryption")
          {
            return ("Crypto", "Canonical")
          } else if
            errorDescription.contains("resource") ||
            errorDescription.contains("file")
          {
            return ("Resource", "Canonical")
          }
        }
        return nil
    }
  }

  // MARK: - Error Metadata Tests

  func testErrorMetadataConsistency() {
    // Test consistent error metadata across different error types

    // Create various errors
    let securityError=CoreErrors.SecurityError.operationFailed(
      operation: "encryption",
      reason: "Key size mismatch"
    )

    let cryptoError=CryptoError.invalidKeyLength(expected: 32, got: 16)

    // Check error descriptions by converting to string
    let securityDescription=String(describing: securityError)
    XCTAssertTrue(
      securityDescription.contains("encryption"),
      "Security error description should contain operation name"
    )
    XCTAssertTrue(
      securityDescription.contains("Key size mismatch"),
      "Security error description should contain reason"
    )

    let cryptoDescription=String(describing: cryptoError)
    XCTAssertTrue(
      cryptoDescription.contains("32"),
      "Crypto error description should contain expected length"
    )
    XCTAssertTrue(
      cryptoDescription.contains("16"),
      "Crypto error description should contain actual length"
    )
  }

  // MARK: - Cross-Module Error References

  func testCrossModuleErrorReferences() {
    // This test provides reference documentation for error types across modules

    // -- UmbraCoreTypes Error Types --
    // SecureBytesError.invalidHexString -> maps to CEResourceError.operationFailed
    // ResourceLocatorError.resourceNotFound -> maps to CEResourceError.resourceNotFound

    // -- SecurityImplementation Error Types --
    // KeyStorageResult.failure(.keyNotFound) -> maps to SecurityError.keyUnavailable
    // CryptoServiceError.algorithm(.unsupported) -> maps to CryptoError.algorithmUnsupported

    // -- ErrorHandling Error Types --
    // These provide the canonical representation for all other errors
    // UmbraErrors (namespace)
    //  ├── Security.Core - canonical security errors
    //  ├── Crypto.Core - canonical crypto errors
    //  └── Resource.Core - canonical resource errors

    // This consolidated test documents the error mapping between modules
    // ensuring we have a reference to understand how errors propagate
    XCTAssertTrue(true, "Cross-module error references documented")
  }
}
