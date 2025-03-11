/**
 # XPC Service Protocol Aliases

 This file provides type aliases for XPC service protocols to allow for more convenient usage
 of these protocols throughout the codebase. It helps standardise naming across the application.

 Note: This is a transitional file to help with the migration from legacy error types to the
 new standardised error types in XPCProtocolsCore.
 */

import CoreErrors
import ErrorHandlingDomains
import UmbraCoreTypes
import XPCProtocolsCore

// NOTE: This typealias has been deprecated in favour of using XPCProtocolsCore.SecurityError
// directly.
// It is kept temporarily for backward compatibility but will be removed in a future release.
// For new code, please use XPCProtocolsCore.SecurityError instead.
// @deprecated Use XPCProtocolsCore.SecurityError instead.
// public typealias XPCSecurityError=UmbraCoreTypes.CoreErrors.SecurityError

// Import XPCProtocolsCore.SecurityError directly
@_exported import enum XPCProtocolsCore.SecurityError

/// Alias to the modern XPC service protocol from XPCProtocolsCore
public typealias XPCServiceProtocol=XPCProtocolsCore.ServiceProtocolStandard

/// Alias to the basic XPC service protocol
public typealias XPCServiceProtocolBase=XPCProtocolsCore.ServiceProtocolBasic

/// Alias to the complete XPC service protocol
public typealias XPCServiceProtocolComplete=XPCProtocolsCore.ServiceProtocolComplete

/// Legacy XPC service protocol (deprecated)
@available(
  *,
  deprecated,
  message: "Use XPCServiceProtocol instead which points to XPCProtocolsCore.ServiceProtocolStandard"
)
public typealias LegacyXPCServiceProtocol=XPCServiceProtocol
