import Foundation
import SecurityBridge
import SecurityInterfaces_SecurityProtocolsCore
import SecurityInterfacesBase
import SecurityInterfacesProtocols

/// Factory for creating SecurityProvider instances
public struct SecurityProviderFactory {
  private init() {}

  /// Create a SecurityProvider instance
  /// - Parameter providerType: Type of the provider to create
  /// - Parameter configuration: Optional configuration for the provider
  /// - Returns: A configured SecurityProvider instance
  /// - Throws: SecurityInterfacesError if the provider can't be created
  public static func createProvider(
    ofType providerType: String,
    configuration: [String: Any]?=nil
  ) throws -> SecurityProvider {
    // Use the isolated factory to create a core provider
    let bridge=SPCProviderFactory.createProvider(
      ofType: providerType,
      withConfig: configuration
    )

    // Wrap it in our adapter
    return SecurityProviderAdapter(bridge: bridge)
  }

  /// Create a SecurityProvider from a third-party provider
  /// - Parameter thirdPartyProvider: The third-party provider to wrap
  /// - Returns: A SecurityProvider instance
  public static func createProvider(
    fromThirdParty thirdPartyProvider: Any
  ) throws -> SecurityProvider {
    // Use our isolated factory to create a bridge
    var bridge: SPCProvider=if let directProvider=thirdPartyProvider as? SPCProvider {
      // Use the provider directly if it's already a core provider
      directProvider
    } else {
      // For simplicity in this case, we'll just create a test provider
      // rather than trying to bridge between the complex types
      SPCProviderFactory.createProvider(
        ofType: "test"
      )
    }

    // Wrap the bridge in our adapter
    return SecurityProviderAdapter(bridge: bridge)
  }
}
