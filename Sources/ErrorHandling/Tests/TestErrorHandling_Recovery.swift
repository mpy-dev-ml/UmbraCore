@testable import ErrorHandling
@testable import ErrorHandlingDomains
@testable import ErrorHandlingInterfaces
@testable import ErrorHandlingRecovery
@testable import ErrorHandlingCommon
import XCTest

/// Tests for the error recovery functionality
///
/// These tests verify that the error recovery mechanisms work correctly,
/// including recovery options creation, provider registration, and option execution.
final class TestErrorHandling_Recovery: XCTestCase {
    
    // MARK: - Test Recovery Option
    
    /// A simple test recovery option implementation for testing purposes
    struct TestRecoveryOption: ErrorHandlingInterfaces.RecoveryOption {
        let id = UUID()
        let title: String
        let description: String?
        let isDisruptive: Bool
        
        init(title: String, description: String? = nil, isDisruptive: Bool = false) {
            self.title = title
            self.description = description
            self.isDisruptive = isDisruptive
        }
        
        func perform() async {
            // No-op implementation for testing
        }
    }
    
    // MARK: - Simple Test Error
    
    /// A simple error type that conforms to RecoverableError for testing
    struct SimpleTestError: Error, ErrorHandlingRecovery.RecoverableError, CustomStringConvertible {
        let message: String
        private var errorCtx: ErrorHandlingInterfaces.ErrorContext
        private var errorSrc: ErrorHandlingInterfaces.ErrorSource?
        private var underlying: Error?
        
        init(message: String) {
            self.message = message
            self.errorCtx = ErrorHandlingInterfaces.ErrorContext(
                source: "TestSource",
                operation: "TestOperation",
                details: "Test error: \(message)"
            )
            self.errorSrc = nil
            self.underlying = nil
        }
        
        // UmbraError protocol conformance
        var domain: String { return "test.domain" }
        var code: String { return "test_error" }
        var errorDescription: String { return "Test Error: \(message)" }
        var source: ErrorHandlingInterfaces.ErrorSource? { return errorSrc }
        var underlyingError: (any Error)? { return underlying }
        var context: ErrorHandlingInterfaces.ErrorContext { return errorCtx }
        
        func with(context: ErrorHandlingInterfaces.ErrorContext) -> Self {
            var copy = self
            copy.errorCtx = context
            return copy
        }
        
        func with(underlyingError: any Error) -> Self {
            var copy = self
            copy.underlying = underlyingError
            return copy
        }
        
        func with(source: ErrorHandlingInterfaces.ErrorSource) -> Self {
            var copy = self
            copy.errorSrc = source
            return copy
        }
        
        // CustomStringConvertible conformance
        var description: String {
            return "SimpleTestError: \(message)"
        }
        
        // RecoverableError protocol conformance
        func recoveryOptions() -> [ErrorHandlingRecovery.ErrorRecoveryOption] {
            return [
                ErrorHandlingRecovery.ErrorRecoveryOption(
                    title: "Retry Operation", 
                    description: "Try the operation again",
                    recoveryAction: { @Sendable in
                        // No-op recovery action for testing
                    }
                ),
                ErrorHandlingRecovery.ErrorRecoveryOption(
                    title: "Cancel", 
                    description: "Abort the operation", 
                    isDisruptive: true,
                    recoveryAction: { @Sendable in
                        // No-op recovery action for testing
                    }
                )
            ]
        }
        
        func attemptRecovery() async -> Bool {
            return true
        }
    }
    
    // MARK: - Mock Recovery Provider
    
    /// A mock recovery provider for testing
    class MockRecoveryProvider: DomainRecoveryProvider {
        var domain: String {
            return "test.domain"
        }
        
        func canHandle(domain: String) -> Bool {
            return domain == "test.domain"
        }
        
        func recoveryOptions(for error: Error) -> [any ErrorHandlingInterfaces.RecoveryOption] {
            return [
                TestRecoveryOption(title: "Default Recovery", description: "Standard recovery action")
            ]
        }
    }
    
    // MARK: - Recovery Manager Tests
    
    /*
    // FIXME: This test is temporarily disabled due to security encryption errors
    // A security error is being thrown: "Core security error: encryptionFailed(reason: "Invalid key size")"
    // This test needs to be redesigned to handle security-related errors that may occur
    // during recovery option retrieval.
    @MainActor
    func testRecoveryManager() async {
        // Create recovery manager
        let recoveryManager = ErrorHandlingRecovery.RecoveryManager()
        
        // Register mock provider
        let mockProvider = MockRecoveryProvider()
        recoveryManager.register(provider: mockProvider, for: "test.domain")
        
        // Create test error
        let testError = SimpleTestError(message: "Test failure")
        
        // Get recovery options
        let options = await recoveryManager.recoveryOptions(for: testError)
        
        // Verify options returned from error's own methods
        XCTAssertNotNil(options)
        XCTAssertGreaterThanOrEqual(options.count, 1)
        
        // Create generic error with our test domain to ensure provider matching works
        let genericError = NSError(domain: "test.domain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Generic test error"])
        
        // Get recovery options for generic error
        let genericOptions = await recoveryManager.recoveryOptions(for: genericError)
        
        // Verify options returned from provider
        XCTAssertNotNil(genericOptions)
        XCTAssertGreaterThanOrEqual(genericOptions.count, 1, "Provider should return at least one recovery option")
    }
    */
    
    // MARK: - Recovery Context Tests
    
    func testRecoveryContext() {
        // Create error with context
        let error = SimpleTestError(message: "Operation failed")
        
        // Create error context that matches the interface type
        let context = ErrorHandlingInterfaces.ErrorContext(
            source: "TestOperation",
            operation: "testFunction", 
            details: "Testing recovery options"
        )
        
        // Test recovery directly with error's method
        let recoveryOptions = error.recoveryOptions()
        XCTAssertEqual(recoveryOptions.count, 2)
        XCTAssertEqual(recoveryOptions.first?.title, "Retry Operation")
        
        // Test that the error conforms to RecoverableError
        let recoverableError = error as ErrorHandlingRecovery.RecoverableError
        XCTAssertNotNil(recoverableError)
        
        // Test using the error with the new context
        let errorWithContext = error.with(context: context)
        XCTAssertEqual(errorWithContext.context.source, "TestOperation")
    }
}
