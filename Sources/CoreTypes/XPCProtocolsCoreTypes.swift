// XPCProtocolsCoreTypes.swift
//
// This file provides isolated imports and type aliases for XPCProtocolsCore
// to avoid namespace conflicts when used alongside other security-related modules.

// Only import XPCProtocolsCore in this file to isolate namespace conflicts
import UmbraCoreTypes
import XPCProtocolsCore

/// Direct access to the XPCSecurityError type in the XPCProtocolsCore module
/// This approach avoids the namespace conflict with the enum named XPCProtocolsCore
public typealias XPCSecurityErrorType = XPCProtocolsCore.XPCSecurityError

/// Protocol to convert between XPCProtocolsCore error types and other error types
public protocol XPCProtocolsCoreErrorConvertible {
    /// Convert to XPCProtocolsCore.XPCSecurityError
    func toXPCSecurityError() -> XPCSecurityErrorType

    /// Create from XPCProtocolsCore.XPCSecurityError
    static func fromXPCSecurityError(_ error: XPCSecurityErrorType) -> Self
}

/// Helper functions for error conversion
public extension XPCSecurityErrorType {
    /// Convert to a string representation
    func detailedDescription() -> String {
        return String(describing: self)
    }
}
