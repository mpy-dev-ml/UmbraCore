import SecurityInterfacesProtocols

/// Base protocol for security providers
/// This protocol is designed to be Foundation-free and serve as a base for more specific security provider protocols
public protocol SecurityProviderBase: Sendable {
    /// Protocol identifier - used for protocol negotiation
    static var protocolIdentifier: String { get }

    /// Test if the security provider is available
    /// - Returns: True if the provider is available, false otherwise
    /// - Throws: SecurityError if the check fails
    func isAvailable() async throws -> Bool

    /// Get the provider's version information
    /// - Returns: Version string
    func getVersion() async -> String
}

/// Default implementation for SecurityProviderBase
public extension SecurityProviderBase {
    /// Default protocol identifier
    static var protocolIdentifier: String {
        return "com.umbra.security.provider.base"
    }

    /// Default implementation that assumes the provider is available
    func isAvailable() async throws -> Bool {
        return true
    }

    /// Default version string
    func getVersion() async -> String {
        return "1.0.0"
    }
}

/// Adapter class to convert between SecurityProviderProtocol and SecurityProviderBase
public final class SecurityProviderBaseAdapter: SecurityProviderBase {
    private let provider: any SecurityProviderProtocol

    public init(provider: any SecurityProviderProtocol) {
        self.provider = provider
    }

    public static var protocolIdentifier: String {
        return "com.umbra.security.provider.base.adapter"
    }

    public func isAvailable() async throws -> Bool {
        // This is a simple implementation that assumes the provider is available
        // In a real implementation, you might want to perform some checks
        return true
    }

    public func getVersion() async -> String {
        // This is a simple implementation that returns a fixed version
        // In a real implementation, you might want to get the version from the provider
        return "1.0.0"
    }
}
