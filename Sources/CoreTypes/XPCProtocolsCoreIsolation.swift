// XPCProtocolsCoreIsolation.swift
//
// This file implements the "Isolation Pattern" described in NAMESPACE_RESOLUTION.md
// Its sole purpose is to isolate imports of XPCProtocolsCore to avoid namespace conflicts.
// ONLY THIS FILE should import XPCProtocolsCore directly.

import CoreErrors
import Foundation
import UmbraCoreTypes

// Only import XPCProtocolsCore in this file to isolate namespace conflicts
import XPCProtocolsCore

/// Direct access to the XPCSecurityError type in the XPCProtocolsCore module
/// This approach avoids the namespace conflict with the enum named XPCProtocolsCore
public typealias XPCSecurityError = XPCProtocolsCore.XPCSecurityError

/// Map from XPCProtocolsCore.XPCSecurityError to CoreErrors.SecurityError
/// This provides a clean conversion between error domains
public func mapXPCToCoreError(_ error: XPCSecurityError) -> CoreErrors.SecurityError {
    switch error {
    case let .encryptionError(reason):
        return .encryptionError(reason: reason)
    case let .decryptionError(reason):
        return .decryptionError(reason: reason)
    case let .keyError(reason):
        return .keyManagementError(reason: reason)
    case .invalidKey:
        return .invalidKey
    case let .authenticationError(reason):
        return .authenticationError(reason: reason)
    case let .invalidInput(reason):
        return .invalidInput(reason: reason)
    case .serviceNotAvailable:
        return .serviceUnavailable(reason: "XPC service not available")
    case .operationNotSupported:
        return .operationNotSupported
    case let .internalError(reason):
        return .internalError(reason: reason)
    default:
        return .internalError(reason: "Unknown XPC error: \(error)")
    }
}

/// Map from CoreErrors.SecurityError to XPCProtocolsCore.XPCSecurityError
/// This provides the reverse conversion for round-trip support
public func mapCoreToXPCError(_ error: CoreErrors.SecurityError) -> XPCSecurityError {
    switch error {
    case let .encryptionError(reason):
        return .encryptionError(reason: reason)
    case let .decryptionError(reason):
        return .decryptionError(reason: reason)
    case let .keyManagementError(reason):
        return .keyError(reason: reason)
    case .invalidKey:
        return .invalidKey
    case let .authenticationError(reason):
        return .authenticationError(reason: reason)
    case let .invalidInput(reason):
        return .invalidInput(reason: reason)
    case .serviceUnavailable:
        return .serviceNotAvailable
    case .operationNotSupported:
        return .operationNotSupported
    case let .internalError(reason):
        return .internalError(reason: reason)
    default:
        return .internalError(reason: "Unmapped core error: \(error)")
    }
}

/// Provide consistent factory methods for common XPC security operations
public enum XPCSecurityOperations {
    /// Create a standard encryption error
    public static func createEncryptionError(reason: String) -> XPCSecurityError {
        return .encryptionError(reason: reason)
    }

    /// Create a standard decryption error
    public static func createDecryptionError(reason: String) -> XPCSecurityError {
        return .decryptionError(reason: reason)
    }

    /// Create a standard key error
    public static func createKeyError(reason: String) -> XPCSecurityError {
        return .keyError(reason: reason)
    }
}
