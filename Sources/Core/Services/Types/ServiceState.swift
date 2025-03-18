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
public typealias ServiceState = CoreServicesTypes.ServiceState
