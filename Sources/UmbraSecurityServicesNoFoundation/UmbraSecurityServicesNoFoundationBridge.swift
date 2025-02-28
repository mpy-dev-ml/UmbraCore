import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import SecurityInterfacesProtocols
import UmbraSecurityNoFoundation

/// Bridge between UmbraSecurityServicesNoFoundation and UmbraSecurityServices
/// This provides a way to use the Foundation-free security services from Foundation-dependent code
@available(macOS 14.0, *)
public final class SecurityServiceNoFoundationBridge {
    private let securityService: SecurityServiceNoFoundation

    /// Initialize with a security service
    public init(securityService: SecurityServiceNoFoundation) {
        self.securityService = securityService
    }

    /// Get a security provider to use with this service
    public func getSecurityProvider() -> any SecurityProviderCore {
        // Create a new provider instead of accessing the private one
        return SecurityProviderNoFoundationFactory.createDefaultProvider()
    }

    /// Create a factory for the security service
    public static func createFactory() -> SecurityServiceFactoryNoFoundation.Type {
        return SecurityServiceFactoryNoFoundation.self
    }

    /// Create a default security service
    public static func createDefaultService() -> SecurityServiceNoFoundation {
        return SecurityServiceFactoryNoFoundation.createDefaultService()
    }
}
