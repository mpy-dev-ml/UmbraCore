import ErrorHandling
import ErrorHandlingDomains
import Foundation
import SecurityProtocolsCore
@testable import SecurityInterfaces
import UmbraCoreTypes
import XCTest
import XPCProtocolsCore

/// Tests for the SecurityInterfacesError implementation and related error mapping functionality
class SecurityErrorTests: XCTestCase {
    // MARK: - Error Description Tests
    
    func testErrorDescriptions() {
        // Test all error cases to ensure they provide meaningful descriptions
        let cases: [(SecurityInterfacesError, String)] = [
            (.bookmarkCreationFailed(path: "/test/path"), "Failed to create security bookmark for path: /test/path"),
            (.bookmarkResolutionFailed, "Failed to resolve security bookmark"),
            (.bookmarkStale(path: "/stale/path"), "Security bookmark is stale for path: /stale/path"),
            (.bookmarkNotFound(path: "/missing/path"), "Security bookmark not found for path: /missing/path"),
            (.resourceAccessFailed(path: "/resource/path"), "Failed to access security-scoped resource: /resource/path"),
            (.randomGenerationFailed, "Failed to generate random data"),
            (.hashingFailed, "Failed to perform hashing operation"),
            (.itemNotFound, "Security item not found"),
            (.operationFailed("Test failure"), "Security operation failed: Test failure"),
            (.bookmarkError("Bookmark issue"), "Security bookmark error: Bookmark issue"),
            (.accessError("Access issue"), "Security access error: Access issue"),
            (.serializationFailed(reason: "Invalid format"), "Serialization or deserialization failed: Invalid format"),
            (.encryptionFailed(reason: "Bad key"), "Encryption failed: Bad key")
        ]
        
        for (error, expectedDescription) in cases {
            XCTAssertEqual(
                error.errorDescription,
                expectedDescription,
                "Error description for \(String(describing: error)) should match expected text"
            )
            
            // Also test localizedDescription
            XCTAssertEqual(
                error.localizedDescription,
                expectedDescription,
                "Localized description for \(String(describing: error)) should match expected text"
            )
        }
    }
    
    func testWrappedErrorDescription() {
        // Create a core error to wrap
        let coreError = UmbraErrors.Security.Core.authenticationFailed(reason: "Invalid credentials")
        
        // Wrap it in SecurityInterfacesError
        let wrappedError = SecurityInterfacesError.wrapped(coreError)
        
        // Verify the description includes the original error's description
        XCTAssertTrue(
            wrappedError.errorDescription?.contains("Wrapped security error") ?? false,
            "Wrapped error description should contain 'Wrapped security error'"
        )
        
        XCTAssertTrue(
            wrappedError.errorDescription?.contains("Invalid credentials") ?? false,
            "Wrapped error description should contain the original error's message"
        )
    }
    
    // MARK: - Error Conversion Tests
    
    func testCoreErrorConversion() {
        // Test conversion from UmbraErrors.Security.Core to SecurityInterfacesError
        let coreError = UmbraErrors.Security.Core.authenticationFailed(reason: "Invalid credentials")
        let interfaceError = SecurityInterfacesError(from: coreError)
        
        // Verify it's properly wrapped
        if case let .wrapped(unwrappedCoreError) = interfaceError {
            XCTAssertEqual(
                unwrappedCoreError.localizedDescription,
                coreError.localizedDescription,
                "Wrapped error should preserve the original error's description"
            )
        } else {
            XCTFail("Expected a wrapped error but got \(interfaceError)")
        }
    }
    
    func testToCoreErrorConversion() {
        // Test conversion from SecurityInterfacesError to UmbraErrors.Security.Core
        
        // For a wrapped error, it should return the original core error
        let originalCoreError = UmbraErrors.Security.Core.authenticationFailed(reason: "Invalid credentials")
        let wrappedError = SecurityInterfacesError.wrapped(originalCoreError)
        let convertedCoreError = wrappedError.toCoreError()
        
        XCTAssertNotNil(convertedCoreError, "Converting a wrapped error should return a non-nil core error")
        XCTAssertEqual(
            convertedCoreError?.localizedDescription,
            originalCoreError.localizedDescription,
            "Converting a wrapped error should return the original core error"
        )
        
        // For a non-wrapped error, it should return nil
        let nonWrappedError = SecurityInterfacesError.operationFailed("Test failure")
        XCTAssertNil(
            nonWrappedError.toCoreError(),
            "Converting a non-wrapped error should return nil"
        )
    }
    
    // MARK: - Error Mapping Tests
    
    func testMapSPCError() {
        // Create protocol errors to map
        let protocolErrors: [(UmbraErrors.Security.Protocols, String)] = [
            (.invalidFormat(reason: "Bad format"), "Invalid format: Bad format"),
            (.missingProtocolImplementation(protocolName: "TestProtocol"), "Missing protocol implementation: TestProtocol"),
            (.unsupportedOperation(name: "TestOperation"), "Unsupported operation: TestOperation"),
            (.incompatibleVersion(version: "1.0"), "Incompatible version: 1.0"),
            (.invalidState(state: "current", expectedState: "ready"), "Invalid state: current=current, expected=ready"),
            (.internalError("Internal issue"), "Internal error: Internal issue"),
            (.invalidInput(reason: "Bad input"), "Invalid input: Bad input"),
            (.encryptionFailed(reason: "Key issue"), "Encryption failed: Key issue"),
            (.decryptionFailed(reason: "Wrong key"), "Decryption failed: Wrong key"),
            (.randomGenerationFailed(reason: "Entropy issue"), "Random generation failed: Entropy issue"),
            (.storageOperationFailed(reason: "Disk full"), "Storage operation failed: Disk full"),
            (.serviceError(reason: "Service unavailable"), "Service error: Service unavailable"),
            (.notImplemented(feature: "TestFeature"), "Not implemented: TestFeature")
        ]
        
        for (protocolError, expectedErrorMessage) in protocolErrors {
            let mappedError = mapSPCError(protocolError)
            
            // The mapped error should be a SecurityInterfacesError
            guard let securityError = mappedError as? SecurityInterfacesError else {
                XCTFail("Expected a SecurityInterfacesError but got \(String(describing: mappedError))")
                continue
            }
            
            // For most protocol errors, the mapped error should be .operationFailed
            // Special case for .encryptionFailed which maps to .encryptionFailed
            if case .encryptionFailed(reason: let reason) = protocolError {
                if case .encryptionFailed(reason: let mappedReason) = securityError {
                    XCTAssertEqual(reason, mappedReason, "The encryption failed reason should be preserved")
                } else {
                    XCTFail("Expected .encryptionFailed but got \(securityError)")
                }
            } else {
                if case .operationFailed(let message) = securityError {
                    XCTAssertEqual(
                        message,
                        expectedErrorMessage,
                        "Error message for \(String(describing: protocolError)) should match expected text"
                    )
                } else {
                    XCTFail("Expected .operationFailed but got \(securityError)")
                }
            }
        }
    }
    
    func testMapNonProtocolError() {
        // Test mapping a non-protocol error
        let randomError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let mappedError = mapSPCError(randomError)
        
        // Should be mapped to a generic .operationFailed
        guard let securityError = mappedError as? SecurityInterfacesError else {
            XCTFail("Expected a SecurityInterfacesError but got \(String(describing: mappedError))")
            return
        }
        
        if case .operationFailed(let message) = securityError {
            XCTAssertTrue(
                message.contains("Unknown error"),
                "Error message for non-protocol error should contain 'Unknown error'"
            )
            XCTAssertTrue(
                message.contains("TestDomain"),
                "Error message for non-protocol error should contain the original error domain"
            )
        } else {
            XCTFail("Expected .operationFailed but got \(securityError)")
        }
    }
    
    // MARK: - Type Alias Tests
    
    func testTypeAlias() {
        // Verify that SecurityError is indeed an alias for SecurityInterfacesError
        let interfaceError = SecurityInterfacesError.operationFailed("Test")
        let aliasedError: SecurityError = .operationFailed("Test")
        
        // Both should be the same type
        XCTAssertTrue(
            type(of: interfaceError) == type(of: aliasedError),
            "SecurityError should be a type alias for SecurityInterfacesError"
        )
    }
}
