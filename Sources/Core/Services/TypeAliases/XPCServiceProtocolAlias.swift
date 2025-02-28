import CoreTypes
import ObjCBridgingTypes
import SecurityInterfaces
import SecurityInterfacesBase
// Remove direct import of SecurityInterfacesFoundation to break circular dependency
// import SecurityInterfacesFoundation

/// Re-export XPCServiceProtocol from SecurityInterfaces
public typealias XPCServiceProtocol = SecurityInterfaces.XPCServiceProtocol

/// Re-export XPCServiceProtocolBase from SecurityInterfacesBase
public typealias XPCServiceProtocolBase = SecurityInterfacesBase.XPCServiceProtocolBase
