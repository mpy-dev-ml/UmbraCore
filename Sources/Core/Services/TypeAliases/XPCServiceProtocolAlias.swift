import CoreTypes
import ObjCBridgingTypes
import SecurityInterfaces
import SecurityInterfacesBase
import SecurityInterfacesFoundation
import XPCProtocolsCore

/// Alias to the modern XPC service protocol
public typealias XPCServiceProtocol=XPCProtocolsCore.XPCServiceProtocolStandard

/// Re-export XPCServiceProtocolBase from SecurityInterfacesBase
public typealias XPCServiceProtocolBase=SecurityInterfacesBase.XPCServiceProtocolBase

/// Legacy XPC service protocol (deprecated)
@available(
  *,
  deprecated,
  message: "Use XPCServiceProtocol instead which points to XPCProtocolsCore.XPCServiceProtocolStandard"
)
public typealias LegacyXPCServiceProtocol=SecurityInterfaces.XPCServiceProtocol
