import Testing
@testable import ErrorHandling

@Suite("CoreError Tests")
struct CoreErrorTests {
    @Test("Test core error descriptions")
    func testCoreErrorDescriptions() {
        // Test authentication failed error
        let authError = CoreError.authenticationFailed
        #expect(authError.errorDescription == "Authentication failed")
        
        // Test insufficient permissions error
        let permError = CoreError.insufficientPermissions
        #expect(permError.errorDescription == "Insufficient permissions to perform the operation")
        
        // Test invalid configuration error
        let configError = CoreError.invalidConfiguration("Missing API key")
        #expect(configError.errorDescription == "Invalid configuration: Missing API key")
        
        // Test system error
        let sysError = CoreError.systemError("Process terminated unexpectedly")
        #expect(sysError.errorDescription == "System error: Process terminated unexpectedly")
    }
}

// Example service error for testing
struct TestServiceError: ServiceErrorProtocol {
    let errorType: ServiceErrorType
    let contextInfo: [String: String]
    let message: String
    
    var errorDescription: String? {
        message
    }
}

@Suite("Service Error Tests")
struct ServiceErrorTests {
    @Test("Test service error type")
    func testServiceErrorType() {
        let error = TestServiceError(
            errorType: .configuration,
            contextInfo: ["key": "value"],
            message: "Test error"
        )
        
        #expect(error.severity == .error) // Default severity
        #expect(!error.isRecoverable) // Default not recoverable
        #expect(error.category == "Configuration")
        #expect(error.description == "[ERROR] Configuration Error: Test error")
        
        let dict = error.toDictionary()
        #expect(dict["type"] as? String == "TestServiceError")
        #expect(dict["error_type"] as? String == "Configuration")
        #expect(dict["description"] as? String == "Test error")
        #expect((dict["context"] as? [String: String])?["key"] == "value")
    }
    
    @Test("Test error severity")
    func testErrorSeverity() {
        #expect(ErrorSeverity.critical.rawValue == "critical")
        #expect(ErrorSeverity.error.rawValue == "error")
        #expect(ErrorSeverity.warning.rawValue == "warning")
        #expect(ErrorSeverity.info.rawValue == "info")
    }
    
    @Test("Test service error types")
    func testServiceErrorTypes() {
        #expect(ServiceErrorType.configuration.description == "Configuration Error")
        #expect(ServiceErrorType.operation.description == "Operation Error")
        #expect(ServiceErrorType.network.description == "Network Error")
    }
}
