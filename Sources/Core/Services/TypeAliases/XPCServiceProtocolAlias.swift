import UmbraCoreTypes
import XPCProtocolsCore

/// Alias to the modern XPC service protocol from XPCProtocolsCore
public typealias XPCServiceProtocol = XPCProtocolsCore.XPCServiceProtocolStandard

/// Alias to the basic XPC service protocol
public typealias XPCServiceProtocolBase = XPCProtocolsCore.XPCServiceProtocolBasic

/// Alias to the complete XPC service protocol
public typealias XPCServiceProtocolComplete = XPCProtocolsCore.XPCServiceProtocolComplete

/// Standard security error type for XPC services
public typealias XPCSecurityError = UmbraCoreTypes.CoreErrors.SecurityError

/// Legacy XPC service protocol (deprecated)
@available(
  *,
  deprecated, 
  message: "Use XPCServiceProtocol instead which points to XPCProtocolsCore.XPCServiceProtocolStandard"
)
public typealias LegacyXPCServiceProtocol = XPCServiceProtocol
