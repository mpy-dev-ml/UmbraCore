import CoreTypes
import ObjCBridgingTypes
import XPCProtocolsCore

/// Re-export XPCServiceProtocolStandard from XPCProtocolsCore
/// This replaces the deprecated SecurityInterfaces.XPCServiceProtocol
public typealias XPCServiceProtocol = XPCProtocolsCore.XPCServiceProtocolStandard

/// Re-export XPCServiceProtocolBasic from XPCProtocolsCore
/// This replaces the deprecated SecurityInterfacesBase.XPCServiceProtocolBase
public typealias XPCServiceProtocolBase = XPCProtocolsCore.XPCServiceProtocolBasic
