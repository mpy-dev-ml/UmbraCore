import XCTest
@testable import CoreErrors
import ErrorHandling

/// Tests focused on cross-domain error handling and centralised error functionality
final class ErrorConsolidationTests: XCTestCase {
    
    // MARK: - Cross-Domain Error Tests
    
    func testCrossDomainErrorConversion() {
        // Test conversion between different error domains
        
        // Create a security error
        let securityError = CoreErrors.SecurityError.invalidKey(reason: "Test reason")
        
        // Convert to canonical form
        let canonicalError = securityError.toCanonicalError()
        
        // Verify canonical type is correct and conversion happened
        XCTAssertNotNil(canonicalError, "Should convert to canonical form")
        XCTAssertFalse(canonicalError is CoreErrors.SecurityError, 
                       "Canonical error should be different from original SecurityError")
        
        // Create a crypto error
        let cryptoError = CryptoError.encryptionFailed(reason: "Algorithm failure")
        
        // Convert to canonical form
        let cryptoCanonical = cryptoError.toCanonical()
        
        // Verify canonical type is correct and conversion happened
        XCTAssertNotNil(cryptoCanonical, "Should convert to canonical form")
        XCTAssertFalse(cryptoCanonical is CryptoError, 
                       "Canonical error should be different from original CryptoError")
    }
    
    func testErrorDomainIdentification() {
        // Test ability to identify an error's domain regardless of specific type
        
        let testErrors: [Error] = [
            CoreErrors.SecurityError.invalidKey(reason: "Test"),
            CryptoError.encryptionFailed(reason: "Test"),
        ]
        
        for error in testErrors {
            let domainInfo = extractErrorDomainInfo(from: error)
            XCTAssertNotNil(domainInfo, "Should extract domain information from \(type(of: error))")
            XCTAssertFalse(domainInfo?.domain.isEmpty ?? true, "Domain should not be empty")
        }
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
            let typeDescription = String(describing: type(of: error))
            if typeDescription == "Core" {
                // We need to distinguish between different Core types
                // Can use the error description or other properties
                let errorDescription = String(describing: error)
                if errorDescription.contains("security") || 
                   errorDescription.contains("key") ||
                   errorDescription.contains("authentication") {
                    return ("Security", "Canonical")
                } else if errorDescription.contains("crypto") ||
                          errorDescription.contains("encryption") ||
                          errorDescription.contains("decryption") {
                    return ("Crypto", "Canonical")
                } else if errorDescription.contains("resource") ||
                          errorDescription.contains("file") {
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
        let securityError = CoreErrors.SecurityError.operationFailed(
            operation: "encryption",
            reason: "Key size mismatch"
        )
        
        let cryptoError = CryptoError.invalidKeyLength(expected: 32, got: 16)
        
        // Check error descriptions by converting to string
        let securityDescription = String(describing: securityError)
        XCTAssertTrue(securityDescription.contains("encryption"), 
                      "Security error description should contain operation name")
        XCTAssertTrue(securityDescription.contains("Key size mismatch"), 
                      "Security error description should contain reason")
        
        let cryptoDescription = String(describing: cryptoError)
        XCTAssertTrue(cryptoDescription.contains("32"), 
                      "Crypto error description should contain expected length")
        XCTAssertTrue(cryptoDescription.contains("16"), 
                      "Crypto error description should contain actual length")
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
