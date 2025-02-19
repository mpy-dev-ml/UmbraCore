/// SecurityTypes Module
///
/// Provides core security primitives and protocols for the UmbraCore framework.
/// This module is designed to be dependency-free and focuses on pure Swift implementations
/// of security-critical components.
///
/// # Key Features
/// - Hardware-backed security operations
/// - Secure credential storage
/// - Security-scoped bookmark management
/// - Comprehensive error handling
///
/// # Module Organisation
/// The module is organised into distinct components:
///
/// ## Models
/// Contains domain models for security operations:
/// ```swift
/// SecurityCredential
/// SecurityContext
/// ```
///
/// ## Protocols
/// Defines core security interfaces:
/// ```swift
/// SecurityProvider
/// CredentialProvider
/// ```
///
/// ## Services
/// Implements security operations:
/// ```swift
/// DefaultSecurityProvider
/// ```
///
/// ## Types
/// Provides error types and handlers:
/// ```swift
/// SecurityError
/// SecurityErrorHandler
/// ```
///
/// # Thread Safety
/// All public types in this module are designed to be thread-safe and
/// conform to Swift's structured concurrency model. Types marked with
/// `@preconcurrency` require explicit `Sendable` conformance.
///
/// # Error Handling
/// This module uses the `SecurityError` type for error reporting. All errors
/// are designed to be:
/// - Actionable: Clear guidance on how to resolve
/// - Contextual: Include relevant error context
/// - Localised: User-friendly error messages
///
/// # Usage Example
/// ```swift
/// let provider = DefaultSecurityProvider()
/// try await provider.withSecurityScopedAccess(to: path) {
///     // Perform secure file operations
/// }
/// ```
public enum SecurityTypes {
    /// Current version of the SecurityTypes module
    public static let version = "1.0.0"
    
    /// Initialise SecurityTypes with default configuration
    public static func initialise() {
        // Configure security services
    }
}
