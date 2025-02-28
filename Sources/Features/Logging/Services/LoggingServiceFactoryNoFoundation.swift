import CoreTypes
import FoundationBridgeTypes
import SecurityInterfacesFoundationCore
import SecurityInterfacesFoundationNoFoundation
import UmbraSecurityNoFoundation
import UmbraSecurityServicesNoFoundation

/// Factory for creating logging services without Foundation dependencies
@available(macOS 14.0, *)
public enum LoggingServiceFactoryNoFoundation {
    /// Create a default logging service
    public static func createDefaultService() -> LoggingServiceNoFoundation {
        let securityProvider = SecurityProviderNoFoundationFactory.createDefaultProvider()
        return LoggingServiceNoFoundation(securityProvider: securityProvider)
    }

    /// Create a logging service with a custom security provider
    public static func createService(with provider: any SecurityProviderCore) -> LoggingServiceNoFoundation {
        return LoggingServiceNoFoundation(securityProvider: provider)
    }

    /// Create a logging service with a security service
    public static func createService(with service: SecurityServiceNoFoundation) -> LoggingServiceNoFoundation {
        // Extract the security provider from the service or create a new one
        let securityProvider = SecurityProviderNoFoundationFactory.createDefaultProvider()
        return LoggingServiceNoFoundation(securityProvider: securityProvider)
    }
}
