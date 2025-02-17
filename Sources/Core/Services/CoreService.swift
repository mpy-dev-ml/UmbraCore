import SecurityTypes

/// Core service that manages application-wide functionality
@MainActor public final class CoreService {
    /// Shared instance
    public static let shared = CoreService(securityProvider: MockSecurityProvider())

    /// Security provider for managing security-scoped resources
    private let securityProvider: any SecurityProvider

    /// Initialize with a security provider
    /// - Parameter securityProvider: Provider for security operations
    public init(securityProvider: any SecurityProvider) {
        self.securityProvider = securityProvider
    }

    /// Get the security provider
    /// - Returns: The current security provider
    public func getSecurityProvider() -> any SecurityProvider {
        securityProvider
    }
}
