import CoreServicesTypes
import Foundation

/// Represents the current state of a service
/// @deprecated This will be replaced by CoreServicesTypes.ServiceState in a future version.
/// New code should use CoreServicesTypes.ServiceState directly.
@available(
    *,
    deprecated,
    message: "This will be replaced by CoreServicesTypes.ServiceState in a future version. Use CoreServicesTypes.ServiceState directly."
)
// Type alias removed in favor of using CoreServicesTypes.ServiceState directly
// public typealias ServiceState = CoreServicesTypes.ServiceState

// Migration helper extension for CoreServicesTypes.ServiceState
public extension CoreServicesTypes.ServiceState {
    /// Convert from legacy ServiceState (if needed by client code)
    /// This should only be used during the migration period
    @available(*, deprecated, message: "Use CoreServicesTypes.ServiceState directly")
    static func fromLegacy(_ legacy: CoreServicesTypes.ServiceState) -> CoreServicesTypes.ServiceState {
        return legacy
    }
}
